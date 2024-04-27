package;

import hxgamejolt.GameJolt;

class Main
{
	public static function main():Void
	{
		GameJolt.init('game id', 'private key');

		GameJolt.authUser('user name', 'user token', {
			onSucceed: function(json:Dynamic):Void
			{
				// your code
			},
			onFail: function(message:String):Void
			{
				Sys.println(message);
			}
		});

		GameJolt.fetchUser('user name', [], {
			/*onSucceed: function(json:Dynamic):Void
			{
				// your code
			},
			onFail: function(message:String):Void
			{
				Sys.println(message);
			}*/
		});

		Sys.sleep(10);
	}
}
