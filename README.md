# Haxe-GameJolt-Integration

A full integration of GameJolt to Haxe.

# Features
* Latest API version.
* JSON Data Format.
* And many more!

Feel free to use it for whatever you want but credit me if you do that, thnak you.

# Exemple

```haxe
GameJolt.connect('game id', 'private key');
GameJolt.authUser('user name', 'user token', function(json:Dynamic)
{
	GameJolt.fetchUser('user name', null, function(json:Dynamic)
	{
		if (json.response != null)
		{
			if (json.response.success == 'true')
			{
				var http = new haxe.Http(json.response.users[0].avatar_url);
				http.onBytes = function(bytes:Bytes)
				{
					addChild(new Bitmap(BitmapData.fromBytes(bytes)));
				}
				http.request();
			}
		}
	});
});
```

This will display the user avatar as a bitmap :)

# Credit
* [M.A. Jigsaw](https://github.com/MAJigsaw77) - Creator of this library.
* The Contributors!
