import flixel.FlxG;
import openfl.Lib;
import flixel.tweens.FlxEase;

using StringTools;

class SMath
{
	public static function isBetween(value:Float, zone1:Float, zone2:Float, inclusive:Bool):Bool
	{
		if (inclusive)
			return value >= zone1 && value <= zone2;
		else
			return value > zone1 && value < zone2;
	}

	public static function isNegative(value:Float):Bool
	{
		return value < 0;
	}

	public static function easeFromString(ease:String)
	{
		var reflected = Reflect.field(FlxEase, ease.trim());
		return reflected != null ? reflected : FlxEase.linear;
	}

	@:keep public static inline function windowSizeDifference():Float
		return FlxG.width / Lib.application.window.width;
}
