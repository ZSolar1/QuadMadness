import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class Preferences
{
	public static var downscroll:Bool = false;
	public static var windowed:Bool = true;
	public static var scrollSpeed:Float = 2.5;
	public static var visualOffset:Float = -30;
	public static var skin:String;

	public static var audioOffset:Float = 0.0;
	public static var masterVolume:Int = 100;
	public static var musicVolume:Int = 100;
	public static var hitsoundVolume:Int = 100;

	public static var keyBinds:Map<String, Array<FlxKey>> = [
		'left' => [D, LEFT],
		'down' => [F, DOWN],
		'up' => [J, UP],
		'right' => [K, RIGHT],
		'pause' => [ESCAPE, ENTER],
	];

	public static function savePrefs(type:String)
	{
		FlxG.save.bind('qm-options');

		switch (type)
		{
			case 'visual':
				FlxG.save.data.downscroll = downscroll;
				FlxG.save.data.windowed = windowed;
				FlxG.save.data.scrollSpeed = scrollSpeed;
				FlxG.save.data.visualOffset = visualOffset;
				FlxG.save.data.skin = skin;
			case 'audio':
				FlxG.save.data.audioOffset = audioOffset;
				FlxG.save.data.masterVolume = masterVolume;
				FlxG.save.data.musicVolume = musicVolume;
				FlxG.save.data.hitsoundVolume = hitsoundVolume;
			case 'input':
				FlxG.save.data.keybinds = keyBinds;
		}

		FlxG.save.flush();
	}

	public static function applyPrefs(type:String)
	{
		switch (type)
		{
			case 'visual':
				FlxG.fullscreen = !windowed;
			case 'audio':
				FlxG.sound.volume = masterVolume / 100;
		}
	}

	public static function loadPrefs()
	{
		FlxG.save.bind('qm-options');
		if (FlxG.save.data.downscroll != null)
			downscroll = FlxG.save.data.downscroll;

		if (FlxG.save.data.windowed != null)
			windowed = FlxG.save.data.windowed;

		if (FlxG.save.data.scrollSpeed != null)
			scrollSpeed = FlxG.save.data.scrollSpeed;

		if (FlxG.save.data.visualOffset != null)
			visualOffset = FlxG.save.data.visualOffset;

		if (FlxG.save.data.skin != null)
			skin = FlxG.save.data.skin;

		if (FlxG.save.data.audioOffset != null)
			audioOffset = FlxG.save.data.audioOffset;

		if (FlxG.save.data.masterVolume != null)
			masterVolume = FlxG.save.data.masterVolume;

		if (FlxG.save.data.musicVolume != null)
			musicVolume = FlxG.save.data.musicVolume;

		if (FlxG.save.data.hitsoundVolume != null)
			hitsoundVolume = FlxG.save.data.hitsoundVolume;

		if (FlxG.save.data.keybinds != null)
			keyBinds = FlxG.save.data.keybinds;

		FlxG.save.flush();
	}
}
