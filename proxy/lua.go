package proxy

import (
	"bytes"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/url"
	"os"
	"path/filepath"

	lua "github.com/yuin/gopher-lua"
)

type LuaManager struct {
	L        *lua.LState
	ruleList []string
}

func NewLuaManagerFromDir(dir string) (*LuaManager, error) {
	L := lua.NewState()
	ruleList := []string{}

	// Load every .lua file from the directory
	err := filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && filepath.Ext(path) == ".lua" {
			if err := L.DoFile(path); err != nil {
				return fmt.Errorf("error loading %s: %v", path, err)
			}
			ruleList = append(ruleList, filepath.Base(path))
		}
		return nil
	})

	if err != nil {
		return nil, err
	}

	return &LuaManager{L: L, ruleList: ruleList}, nil
}
func (lm *LuaManager) EvaluateRequest(r *http.Request) (bool, string, error) {
	L := lm.L

	// Extract clean client IP
	clientIP := r.RemoteAddr
	if ip, _, err := net.SplitHostPort(clientIP); err == nil {
		clientIP = ip
	}

	// Decode URI before passing to Lua
	decodedURI, _ := url.QueryUnescape(r.RequestURI)

	// Set Lua globals
	L.SetGlobal("method", lua.LString(r.Method))
	L.SetGlobal("uri", lua.LString(decodedURI))
	L.SetGlobal("ip", lua.LString(clientIP))

	// Set headers table
	headersTable := L.NewTable()
	for k, v := range r.Header {
		if len(v) > 0 {
			headersTable.RawSetString(k, lua.LString(v[0]))
		}
	}
	L.SetGlobal("headers", headersTable)

	// Read and restore body
	bodyBytes, err := io.ReadAll(r.Body)
	if err != nil {
		return false, "", fmt.Errorf("failed to read body: %v", err)
	}
	r.Body = io.NopCloser(bytes.NewReader(bodyBytes)) // Restore for downstream
	L.SetGlobal("body", lua.LString(string(bodyBytes)))

	// List of Lua rule functions
	rules := []string{
		"java_security_rule",
	}

	for _, ruleFunc := range rules {
		call := fmt.Sprintf(`if type(%s) == "function" then return %s(method, uri, headers, ip, body) else error("%s is not a function") end`, ruleFunc, ruleFunc, ruleFunc)
		if err := L.DoString(call); err != nil {
			return false, "", fmt.Errorf("error in rule %s: %v", ruleFunc, err)
		}

		ret := L.Get(-1)
		L.Pop(1)

		if ret.Type() == lua.LTBool && bool(ret.(lua.LBool)) {
			return true, ruleFunc, nil
		}
	}

	return false, "", nil
}
