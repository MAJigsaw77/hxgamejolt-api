package;

import flixel.FlxState;
import flixel.text.FlxText;
import hxgamejolt.GameJolt;
import js.Browser;

class WebState extends FlxState
{
    var display:FlxText;
    
    override function create() {
		super.create();

        trace("webstate on");

        final gameID = Browser.window.prompt("Game ID? (Manage Game > Game API > API Settings)");
        final privateKey = Browser.window.prompt("Private Key? (Manage Game > Game API > API Settings)");

        final name = Browser.window.prompt("User Name?");
        final token = Browser.window.prompt("User Token? (Profile > Game Token)");

        GameJolt.init(gameID, privateKey);
        GameJolt.authUser(name, token, {
            onSucceed: function():Void  trace('logged in as ${GameJolt.getCredentials().username}!'),
            onFail: function(message:String):Void  trace('authentication failed! error: "$message"')
        });
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}