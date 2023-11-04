package;

import flixel.FlxG;
import flixel.FlxState;

class Globals
{
	public static var version:String;
	public static var debugMode:Bool = false;
	public static function LoadState(state:FlxState)
	{
		FlxG.switchState(state);
	}

	public static function CrashGame(message:String)
	{
		FlxG.switchState(new states.CrashHandlerState(message, null));
	}
}
