package;

import flixel.FlxG;

class Controls
{
	public static function pressed(direction:String):Bool
	{
		switch (direction)
		{
			case 'left':
				return FlxG.keys.anyPressed(Preferences.keyBinds.get('left'));
			case 'down':
				return FlxG.keys.anyPressed(Preferences.keyBinds.get('down'));
			case 'up':
				return FlxG.keys.anyPressed(Preferences.keyBinds.get('up'));
			case 'right':
				return FlxG.keys.anyPressed(Preferences.keyBinds.get('right'));
			case 'pause':
				return FlxG.keys.anyPressed(Preferences.keyBinds.get('pause'));
			default:
				return false;
		}
	}

	public static function justPressed(direction:String):Bool
	{
		switch (direction)
		{
			case 'left':
				return FlxG.keys.anyJustPressed(Preferences.keyBinds.get('left'));
			case 'down':
				return FlxG.keys.anyJustPressed(Preferences.keyBinds.get('down'));
			case 'up':
				return FlxG.keys.anyJustPressed(Preferences.keyBinds.get('up'));
			case 'right':
				return FlxG.keys.anyJustPressed(Preferences.keyBinds.get('right'));
			case 'pause':
				return FlxG.keys.anyJustPressed(Preferences.keyBinds.get('pause'));
			default:
				return false;
		}
	}

	public static function justReleased(direction:String):Bool
	{
		switch (direction)
		{
			case 'left':
				return FlxG.keys.anyJustReleased(Preferences.keyBinds.get('left'));
			case 'down':
				return FlxG.keys.anyJustReleased(Preferences.keyBinds.get('down'));
			case 'up':
				return FlxG.keys.anyJustReleased(Preferences.keyBinds.get('up'));
			case 'right':
				return FlxG.keys.anyJustReleased(Preferences.keyBinds.get('right'));
			case 'pause':
				return FlxG.keys.anyJustReleased(Preferences.keyBinds.get('pause'));
			default:
				return false;
		}
	}
}
