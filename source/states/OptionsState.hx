package states;

import haxe.exceptions.NotImplementedException;
import flixel.math.FlxMath;
import openfl.filters.BlurFilter;
import flixel.text.FlxText;
import options.Options.Option;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import skin.SkinLoader;
import flixel.FlxState;

enum OptionCategories
{
	Visuals;
	Gameplay;
	Input;
	Audio;
}

class OptionsState extends FlxState
{
	var category:OptionCategories;
	var background:FlxSprite;
	var optionsStack:OptionsStack;
	var curSelected:Int = 0;

	var options:Map<OptionCategories, Array<Option>> = [
		OptionCategories.Visuals => [
			new Option('Windowed', 'Is the game running in windowed mode', 'windowed'),
			new Option('Skin', 'The skin the game will use', 'skin', 'string'),
		],
		OptionCategories.Gameplay => [
			new Option('Scroll Speed', 'How fast the notes are going', 'scrollSpeed', 'float'),
			new Option('Visual Offset', 'Delay between real notes and their visual representation\n(Higher - later)', 'visualOffset', 'float'),
			new Option('Downscroll', 'Are the notes going down?', 'downscroll'),
		],
		OptionCategories.Input => [
			new Option('', '', ''),
			new Option('', '', ''),
			new Option('', '', ''),
			new Option('', '', ''),
			new Option('', '', ''),
			new Option('', '', ''),
		],
		OptionCategories.Audio => [
			new Option('Master Volume', 'How loud is the entire game?', 'masterVolume', 'int'),
			new Option('Audio Volume', 'How loud are the sounds?', 'audioVolume', 'int'),
			new Option('Music Volume', 'How loud are the songs?', 'musicVolume', 'int'),
			new Option('Hitsound Volume', 'How loud are the hitsounds?', 'hitsoundVolume', 'int'),
		]
	];

	override function onResize(Width:Int, Height:Int)
	{
		super.onResize(Width, Height);
		resizeSprites();
	}

	function resizeSprites()
	{
		background.setGraphicSize(FlxG.width, FlxG.height);
		background.updateHitbox();
		optionsStack.y = FlxG.height / 2;
	}

	override public function create():Void
	{
		super.create();

		if (FlxG.sound.music == null){
			FlxG.sound.playMusic('assets/music/menu.ogg', 1, true);
			FlxG.sound.music.time = 13339;
		}
		background = new FlxSprite(0, 0);
		background.loadGraphic(SkinLoader.getSkinnedImage('menu/background.png'));
		add(background);

		optionsStack = new OptionsStack(FlxG.width / 2, 0, 48);
		optionsStack.y = FlxG.height / 2;
		optionsStack.margin = 96;
		add(optionsStack);

		resizeSprites();
	}

	function changeBoxes(category:OptionCategories)
	{
		optionsStack.clear();
		for (option in options.get(category))
			optionsStack.add(new OptionsBox(option.name, option.type));
		curSelected = 0;
		updateSelection();
	}
	function updateSelection()
	{
		for (i in 0...optionsStack.members.length)
		{
			if (i != curSelected)
			{
				FlxTween.cancelTweensOf(optionsStack.members[i]);
				FlxTween.tween(optionsStack.members[i], {x: FlxG.width / 2 + 256}, 0.35, {ease: FlxEase.expoOut});
			}
		}
		FlxTween.tween(optionsStack.members[curSelected], {x: FlxG.width / 2}, 0.35, {ease: FlxEase.expoOut});
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		optionsStack.y = FlxMath.lerp(optionsStack.y, -(curSelected * 152) + 152, 0.1);
		if (FlxG.keys.justPressed.ONE)
			changeBoxes(OptionCategories.Visuals);
		if (FlxG.keys.justPressed.TWO)
			changeBoxes(OptionCategories.Gameplay);
		if (FlxG.keys.justPressed.THREE)
			changeBoxes(OptionCategories.Input);
		if (FlxG.keys.justPressed.FOUR)
			changeBoxes(OptionCategories.Audio);

		if (FlxG.keys.justPressed.UP)
		{
			if (curSelected > 0)
				curSelected -= 1;
			updateSelection();
		}
		if (FlxG.keys.justPressed.DOWN)
		{
			if (curSelected < optionsStack.length - 1)
				curSelected += 1;
			updateSelection();
		}
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new MenuState());
		}
	}
}

class OptionsBox extends FlxSpriteGroup
{
	public function new(text:String, type:String)
	{
		super(0, 0);
		var sprite = new FlxSprite(0, 0).loadGraphic(SkinLoader.getSkinnedImage('menu/optionbox.png'));
		var text = new FlxText(76, 45, 0, text);
		text.setFormat(Fonts.NotoSans.Light, 40, 0x000000);

		add(sprite);
		add(text);
	}
}

class OptionsStack extends FlxSpriteGroup
{
	public var margin:Float = 0.0;

	public function new(x, y, margin)
	{
		super(x, y);
		this.margin = margin;
	}

	override function add(Sprite:FlxSprite):FlxSprite
	{
		var spr = super.add(Sprite);
		updateStack();
		return spr;
	}

	public function updateStack()
	{
		for (sprite in _sprites)
		{
			sprite.y = y + _sprites.indexOf(sprite) * sprite.height + margin;
		}
	}
}