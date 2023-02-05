package states;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

class CrashHandlerState extends FlxState
{
	var messageText:String;

	public function new(message:String)
	{
		super();
		messageText = message;
	}

	override function create()
	{
		super.create();
		var message:FlxText = new FlxText(0, FlxG.height / 2, 0, messageText);
		message.setFormat(Fonts.NotoSans.Light, 24);
		add(message);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
