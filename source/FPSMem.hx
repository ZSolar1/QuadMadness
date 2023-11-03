import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.events.EventType;
import flixel.util.FlxColor;
import haxe.Timer;
import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.FlxG;

class FpsMem extends TextField
{
	private var times:Array<Float>;
	private var memPeak:Float = 0;
	private var hidden:Bool = false;
	private var originalY:Float = 0;

	public function new(x:Float, y:Float, color:FlxColor)
	{
		super();
		this.x = x;
		this.y = y;
		originalY = y;
		selectable = false;
		defaultTextFormat = new TextFormat(Fonts.NotoSans.Regular, 12, color);
		text = "FPS: ";
		times = [];
		addEventListener(Event.ENTER_FRAME, onEnter);
		width = 300;
		height = 280;
	}

	private function onEnter(_)
	{
		var now = Timer.stamp();

		times.push(now);

		while (times[0] < now - 1)
			times.shift();

		var mem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100) / 100;

		if (mem > memPeak)
			memPeak = mem;

		if (visible)
		{
			if (!hidden)
			{
				if (!Globals.debugMode)
					text = 'FPS: ${times.length}\nMEM: $mem MB / $memPeak MB';
				else
					text = 'FPS: ${times.length}\nMEM: $mem MB / $memPeak MB\nVersion: ${Globals.version}\nYou\'re running in debug mode!\nPress F7 to open state selection menu';
			}
			else if (Globals.debugMode)
				text = "Press F10 to reveal the debug text";
			else
				text = 'FPS: ${times.length}';
		}

		if (FlxG.keys.justPressed.F7 && Globals.debugMode)
			FlxG.switchState(new states.debug.DebugStateSelect());

		if (FlxG.keys.justPressed.F10)
			hidden = !hidden;
	}
}
