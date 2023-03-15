package;

import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxSprite;
#if mobile
import flixel.input.touch.FlxTouch;
import flixel.input.touch.FlxTouchManager;
#end

class Interactions
{
	public static function IsHovered(object:FlxSprite):Bool
	{
		#if desktop
		if (FlxG.mouse.x > object.x
			&& FlxG.mouse.x < object.x + object.width
			&& FlxG.mouse.y > object.y
			&& FlxG.mouse.y < object.y + object.height
			&& object.alive)
			return true;
		else
			return false;
		#else
		return false;
		#end
	}

	public static function Clicked(object:FlxSprite):Bool
	{
		#if desktop
		if (IsHovered(object) && FlxG.mouse.justPressed)
			return true;
		else
			return false;
		#else
		var firstTouch = FlxG.touches.getFirst();
		if (firstTouch == null)
			return false;
		var touchPos = firstTouch.getPosition();
		if (firstTouch.justPressed
			&& touchPos.x > object.x
			&& touchPos.x < object.x + object.width
			&& touchPos.y > object.y
			&& touchPos.y < object.y + object.height
			&& object.alive)
			return true;
		else
			return false;
		#end
	}
}
