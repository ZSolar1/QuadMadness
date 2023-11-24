package options;

import skin.SkinLoader;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import options.Options.Option;
import options.Options.OptionsCategory;
import states.MenuState;

class OptionsState extends FlxState
{
	var background:ParallaxSprite;
	var optionsFrame:FlxSprite;
	var optionsCatSprites:FlxTypedGroup<FlxSprite>;
	var optionsCatNames:FlxTypedGroup<FlxText>;
	var options:Array<OptionsCategory> = [
		new OptionsCategory('Game', [
			new Option('Downscroll', 'Are notes going up, or down?', 'downscroll', 'bool'),
			new Option('Scroll Speed', 'How fast are the notes?', 'scrollSpeed', 'float'),
		]),
		new OptionsCategory('Visual', [
			new Option('Visual Offset', 'Are notes appearing early? (-) or late? (+)', 'visualOffset', 'int'),
			new Option('Windowed', 'Window / Fullscreen?', 'windowed', 'bool')
		]),
		new OptionsCategory('Audio', [
			new Option('Audio Offset', 'Is music playing early? (-) or late? (+)', 'audioOffset', 'int'),
			new Option('Master Volume', 'How loud is the entire game?', 'masterVolume', 'int'),
			new Option('Music Volume', 'How loud are the songs?', 'musicVolume', 'int'),
			new Option('Hitsound Volume', 'How loud are hitsounds?', 'hitsoundVolume', 'int')
		]),
		new OptionsCategory('Input', [new Option('Change keybinds', 'Change your keybinds in a menu', '', 'key')]),
	];

	var categorySelected:Int = 0;

	override function create()
	{
		super.create();
		if (FlxG.sound.music == null){
			FlxG.sound.playMusic('assets/music/menu.ogg', 1, true);
			FlxG.sound.music.time = 13339;
		}
		optionsCatSprites = new FlxTypedGroup<FlxSprite>();
		optionsCatNames = new FlxTypedGroup<FlxText>();

		background = new ParallaxSprite(0, 0, 64);
		background.loadGraphic(SkinLoader.getSkinnedImage('menu/background.png'));
		background.scale.x = 1.25;
		background.scale.y = 1.25;
		background.antialiasing = true;
		add(background);

		optionsFrame = new FlxSprite(128, 128).makeGraphic(FlxG.width - 256, FlxG.height - 192, FlxColor.BLACK);
		optionsFrame.alpha = 0.5;
		add(optionsFrame);

		for (i in 0...4)
		{
			var optionCategory = new FlxSprite(128 + (i * 192), 64).makeGraphic(192, 64, FlxColor.BLACK);
			optionCategory.alpha = 0.5;
			optionsCatSprites.add(optionCategory);

			var optionCategoryName = new FlxText(128 + (i * 192), 64 + (32 - 12), 192, options[i].name);
			optionCategoryName.setFormat(Fonts.NotoSans.Light, 24, FlxColor.WHITE, CENTER);
			optionsCatNames.add(optionCategoryName);
		}

		add(optionsCatSprites);
		add(optionsCatNames);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new MenuState());
	}
}
