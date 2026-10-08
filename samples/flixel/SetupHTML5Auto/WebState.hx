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

        if (!GameJolt.onGameJolt)
            throw "you must run this inside a gamejolt.net window/client!";

        GameJolt.init(gameID, privateKey);
        GameJolt.loginAutomatically({
            onSucceed: function():Void
                trace('yay welcome aboard mr ${GameJolt.getCredentials().username}!'),
            onFail: function(message:String):Void
                trace('Wuh oh! authentication failed! error: "$message"')
        });
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}