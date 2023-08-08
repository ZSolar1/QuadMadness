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

class OptionsState extends FlxState
{
	var background:FlxSprite;
	var tipPanel:FlxSprite;
	var optionsStack:OptionsStack;
	var curSelected:Int = 0;

	var options:Map<String, Array<Option>> = [
		"visuals" => [
			new Option('Windowed', 'Is the game running in windowed mode', 'windowed'),
			new Option('Skin', 'The skin the game will use', 'skin', 'string'),
		],
		"gameplay" => [
			new Option('Scroll Speed', 'How fast the notes are going', 'scrollSpeed', 'float'),
			new Option('Visual Offset', 'Delay between real notes and their visual representation\n(Higher - later)', 'visualOffset', 'float'),
			new Option('Downscroll', 'Are the notes going down?', 'downscroll'),
		],
		"input" => [
			new Option('', '', ''),
			new Option('', '', ''),
			new Option('', '', ''),
			new Option('', '', ''),
			new Option('', '', ''),
			new Option('', '', ''),
		],
		"sound" => [
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

		tipPanel.setGraphicSize(FlxG.width, Math.floor(tipPanel.height));
		tipPanel.y = FlxG.height - tipPanel.height;
		tipPanel.updateHitbox();
	}

	override public function create():Void
	{
		super.create();

		background = new FlxSprite(0, 0);
		background.loadGraphic(SkinLoader.getSkinnedImage('menu/background.png'));
		add(background);

		tipPanel = new FlxSprite(0, FlxG.height);
		tipPanel.loadGraphic(SkinLoader.getSkinnedImage('menu/tip-menu.png'));
		tipPanel.antialiasing = true;

		optionsStack = new OptionsStack(FlxG.width / 2, 0, 48);
		add(optionsStack);

		add(tipPanel);
		resizeSprites();

		FlxTween.tween(tipPanel, {y: FlxG.height - tipPanel.height}, 1.0, {ease: FlxEase.cubeOut});
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		optionsStack.y = FlxMath.lerp(optionsStack.y, -(curSelected * 152) + 152, 0.02);
		if (FlxG.keys.justPressed.ONE)
		{
			optionsStack.clear();
			for (option in options.get('visuals'))
			{
				optionsStack.add(new OptionsBox(option.name, option.type));
			}
			curSelected = 0;
		}
		if (FlxG.keys.justPressed.TWO)
		{
			optionsStack.clear();
			for (option in options.get('gameplay'))
			{
				optionsStack.add(new OptionsBox(option.name, option.type));
			}
			curSelected = 0;
		}
		if (FlxG.keys.justPressed.THREE)
		{
			optionsStack.clear();
			for (option in options.get('input'))
			{
				optionsStack.add(new OptionsBox(option.name, option.type));
			}
			curSelected = 0;
		}
		if (FlxG.keys.justPressed.FOUR)
		{
			optionsStack.clear();
			for (option in options.get('sound'))
			{
				optionsStack.add(new OptionsBox(option.name, option.type));
			}
			curSelected = 0;
		}

		if (FlxG.keys.justPressed.UP)
		{
			if (curSelected > 0)
				curSelected -= 1;
		}
		if (FlxG.keys.justPressed.DOWN)
		{
			if (curSelected < optionsStack.length - 1)
				curSelected += 1;
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
		var text = new FlxText(76, 76, 0, text);

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
			sprite.y = _sprites.indexOf(sprite) * sprite.height + margin;
		}
	}
}