package hxgamejolt;

class Types {} // blank

typedef User = {
	var id:Int; // The ID of the user.
	var type:String; // The type of user. Can be User, Developer, Moderator, or Administrator.
	var username:String; // The user's username.
	var avatar_url:String; // The URL of the user's avatar.
	var signed_up:String; // How long ago the user signed up.
	var signed_up_timestamp:Int; // The timestamp (in seconds) of when the user signed up.
	var last_logged_in:String; // How long ago the user was last logged in. Will be Online Now if the user is currently online.
	var last_logged_in_timestamp:Int; // The timestamp (in seconds) of when the user was last logged in.
	var status:String; // Active if the user is still a member of the site. Banned if they've been banned.
	var developer_name:String; // The user's display name.
	var developer_website:String; // The user's website (or empty string if not specified).
	var developer_description:String; // The user's profile markdown description.
}
