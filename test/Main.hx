package;

import hxgamejolt.GameJolt;

class Main
{
	public static function main():Void
	{
		GameJolt.init('game id', 'private key');

		GameJolt.authUser('user name', 'user token', function(json:Dynamic):Void
		{
			// your code
		}, function(message:String):Void
		{
			// your code
		});

		GameJolt.fetchUser('user name', [], function(json:Dynamic):Void
		{
			// your code
		}, function(message:String):Void
		{
			// your code
		});
	}
}
