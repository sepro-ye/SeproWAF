package controllers

import (
	beego "github.com/beego/beego/v2/server/web"
)

type MainController struct {
	beego.Controller
}

func (c *MainController) Get() {
	c.Data["Title"] = "Home"
	c.Layout = "site-layout.tpl"
	c.TplName = "index.tpl"
}
