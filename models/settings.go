package models

// GeneralSettings represents the general settings of the application.
type GeneralSettings struct {
	SiteName string `json:"site_name" form:"site_name"`
	Language string `json:"language" form:"language"`
	Theme    string `json:"theme" form:"theme"`
	RunMode  string `json:"run_mode" form:"run_mode"`
}

// ProfileSettings represents the profile settings of a user.
type ProfileSettings struct {
	FullName       string `json:"full_name" form:"full_name"`
	Username       string `json:"username" form:"username"`
	Email          string `json:"email" form:"email"`
	ProfilePicture string `json:"profile_picture" form:"profile_picture"`
	Bio            string `json:"bio" form:"bio"`
}

// Settings is a wrapper struct to hold all settings.
type Settings struct {
	General GeneralSettings `json:"general"`
	Profile ProfileSettings `json:"profile"`
}
