package states;

import states.songselect.SongSelectState;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import gameplay.SongState;
import openfl.system.System;
import options.OptionsState;
import states.options.AudioState;
import states.options.VisualState;

class MenuState extends FlxState
{
	var background:ParallaxSprite;
	var logo:ParallaxSprite;

	var buttons:FlxTypedGroup<ParallaxSprite>;
	var buttontypes:Array<String> = [];
	var menuMode:String = 'main';

	override public function create()
	{
		super.create();

		QMDiscordRPC.changePresence('In the menus', null);

		background = new ParallaxSprite(0, 0, 64);
		background.loadGraphic('assets/images/menu/background.png');
		background.scale.x = 1.25;
		background.scale.y = 1.25;
		background.antialiasing = true;
		add(background);

		logo = new ParallaxSprite(FlxG.width / 2, FlxG.height / 2, 24);
		logo.loadGraphic('assets/images/logo.png');
		logo.centerPos();
		logo.antialiasing = true;
		add(logo);

		buttons = new FlxTypedGroup<ParallaxSprite>();
		add(buttons);
		logo.alpha = 0;
		FlxTween.color(background, 1, FlxColor.BLACK, FlxColor.WHITE, {ease: FlxEase.expoInOut});
		FlxTween.color(logo, 1.25, FlxColor.BLACK, FlxColor.WHITE, {ease: FlxEase.expoInOut});
		FlxTween.tween(logo, {alpha: 1}, 0.65, {ease: FlxEase.quadOut});
		createButtons('main');
	}

	function exit()
	{
		fade();
		new FlxTimer().start(0.75, function(tmr)
		{
			System.exit(0);
		});
	}

	function createButtons(mode:String)
	{
		buttons.forEach(function(btn)
		{
			FlxTween.cancelTweensOf(btn);
			FlxTween.tween(btn, {"scale.x": 1, 'scale.y': 1, alpha: 0}, 0.35, {
				ease: FlxEase.quadOut,
				onComplete: function(twn)
				{
					buttons.remove(btn, true);
				}
			});
		});

		menuMode = mode;
		var mainbuttons:Array<String> = ['play', 'options', 'download', 'exit'];
		var exitbuttons:Array<String> = ['none', 'no', 'yes', 'none'];
		var playbuttons:Array<String> = ['singleplayer', 'editor', 'multiplayer', 'back'];
		var dwldbuttons:Array<String> = ['none', 'internet', 'import', 'back'];
		var prefbuttons:Array<String> = ['display', 'audio', 'input', 'back'];
		var nonebuttons:Array<String> = ['none', 'none', 'none', 'none'];

		var posX:Array<Int> = [-128, -260, 4, -128];
		var posY:Array<Int> = [-256, -128, -128, 4];

		for (i in 0...4)
		{
			var button:ParallaxSprite = new ParallaxSprite(FlxG.width / 2 + posX[i] + 64, FlxG.height / 2 + posY[i] + 64, 24);
			button.antialiasing = true;
			button.alpha = 0;
			button.scale.x = 0;
			button.scale.y = 0;
			FlxTween.tween(button, {"scale.x": 0.75, "scale.y": 0.75, alpha: 1}, 0.5, {ease: FlxEase.quadOut});
			switch (mode)
			{
				case 'main':
					buttontypes = mainbuttons;
				case 'exit':
					buttontypes = exitbuttons;
				case 'play':
					buttontypes = playbuttons;
				case 'download':
					buttontypes = dwldbuttons;
				case 'preferences':
					buttontypes = prefbuttons;
				case 'none':
					buttontypes = nonebuttons;
			}
			button.loadGraphic('assets/images/menu/buttons/' + buttontypes[i] + '.png');
			buttons.add(button);
		}
	}

	function fade()
	{
		createButtons('none');
		FlxTween.tween(logo, {"scale.x": 1.25, 'scale.y': 1.25, alpha: 0}, 0.5, {
			ease: FlxEase.quadOut
		});
	}

	function gotoPreferences(state:FlxState)
	{
		fade();
		new FlxTimer().start(0.75, function(tmr)
		{
			FlxG.switchState(state);
		});
	}

	// Menu-Mode based buttons
	/* override public function update(elapsed:Float)
		{
			super.update(elapsed);
			if (Interactions.Clicked(buttons.members[0])) // Top
				switch (menuMode)
				{
					case 'main':
						createButtons('play');
					case 'preferences':
						gotoPreferences(new VisualState());
				}
			if (Interactions.Clicked(buttons.members[1])) // Left
				switch (menuMode)
				{
					case 'exit':
						createButtons('main');
					case 'main':
						createButtons('preferences');
					case 'download':
						createButtons('main');
				}
			if (Interactions.Clicked(buttons.members[2])) // Right
				switch (menuMode)
				{
					case 'exit':
						exit();
					case 'main':
						createButtons('download');
				}
			if (Interactions.Clicked(buttons.members[3])) // Ti dayn?
				switch (menuMode)
				{
					case 'main':
						createButtons('exit');
					case 'play':
						createButtons('main');
					case 'preferences':
						createButtons('main');
				}
	}*/
	// Button-type based buttons
	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
		{
			switch (menuMode)
			{
				case 'main':
					createButtons('exit');
				case 'exit':
					exit();
				default:
					createButtons('main');
			}
		}

		if (Interactions.Clicked(buttons.members[0])) // Top
			switch (buttontypes[0])
			{
				case 'play':
					createButtons('play');
				case 'singleplayer':
					FlxG.switchState(new SongSelectState());
				case 'display':
					gotoPreferences(new VisualState());
			}
		if (Interactions.Clicked(buttons.members[1])) // Left
			switch (buttontypes[1])
			{
				case 'options':
					createButtons('preferences');
				case 'no':
					createButtons('main');
				case 'editor':
				case 'internet':
				case 'audio':
					gotoPreferences(new AudioState());
			}
		if (Interactions.Clicked(buttons.members[2])) // Right
			switch (buttontypes[2])
			{
				case 'download':
					createButtons('download');
				case 'multiplayer':
				case 'import':
				case 'input':
				case 'yes':
					exit();
			}
		if (Interactions.Clicked(buttons.members[3])) // Ti dayn?
			switch (buttontypes[3])
			{
				case 'exit':
					createButtons('exit');
				case 'back':
					createButtons('main');
			}
	}
}
