package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	override function create() {
		super.create();

		final target = new FlxText();
		target.size = 32;

		#if js
        js.Browser.alert("open inspector!");
        trace("html5 target detected...");
        FlxTimer.wait(1, () -> FlxG.switchState(WebState.new));
		#else target.text = "Non-HTML5 target!";
        #end target.screenCenter();

		add(target);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}