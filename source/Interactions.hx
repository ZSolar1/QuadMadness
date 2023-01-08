package;

import flixel.FlxG;
import flixel.FlxSprite;

class Interactions
{
	public static function IsHovered(object:FlxSprite):Bool
	{
		if (FlxG.mouse.x > object.x
			&& FlxG.mouse.x < object.x + object.width
			&& FlxG.mouse.y > object.y
			&& FlxG.mouse.y < object.y + object.height
			&& object.alive)
			return true;
		else
			return false;
	}

	public static function Clicked(object:FlxSprite):Bool
	{
		if (IsHovered(object) && FlxG.mouse.justPressed)
			return true;
		else
			return false;
	}
}
