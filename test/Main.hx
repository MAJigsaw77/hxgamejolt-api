package;

import hxgamejolt.GameJolt;

class Main
{
	public static function main():Void
	{
		GameJolt.init('game id', 'private key');

		GameJolt.authUser('user name', 'user token', {
			onSucceed: function(data:Dynamic):Void
			{
				// your code
			},
			onFail: function(message:String):Void
			{
				trace(message);
			}
		});

		GameJolt.fetchUser('user name', [], {
			onSucceed: function(data:Dynamic):Void
			{
				// your code
			},
			onFail: function(message:String):Void
			{
				trace(message);
			}
		});

		Sys.sleep(10);
	}
}
