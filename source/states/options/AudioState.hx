package states.options;

import flixel.util.FlxTimer;
import Fonts.NotoSans;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;

class AudioState extends FlxState
{
	var background:ParallaxSprite;

	// var buttonBack:QButton;
	// var buttonApply:QButton;
	// var buttonVideo:QButton;
	// var buttonInput:QButton;
	var optionLabels:FlxTypedGroup<FlxText>;
	var optionVarLabels:FlxTypedGroup<FlxText>;
	var optionDesc:FlxText;
	var optionSelector:FlxText;
	var selected:Int = 0;
	var optionSize = 48;

	var optionNames = ['Audio Offset', 'Master Volume', 'Music Volume', 'Hitsound Volume'];
	var optionDescs = [
		'Is music playing early? (-) or late? (+)',
		'How loud is the entire game?',
		'How loud are the songs?',
		'How loud are hitsounds?'
	];
	var optionVars = ['audioOffset', 'masterVolume', 'musicVolume', 'hitsoundVolume'];
	var optionSuffix = [' ms', '%', '%', '%'];

	override public function create()
	{
		super.create();
		if (FlxG.sound.music == null){
			FlxG.sound.playMusic('assets/music/menu.ogg', 1, true);
			FlxG.sound.music.time = 13339;
		}
		optionLabels = new FlxTypedGroup<FlxText>();
		optionVarLabels = new FlxTypedGroup<FlxText>();

		background = new ParallaxSprite(0, 0, 64);
		background.loadGraphic('assets/images/menu/background.png');
		background.scale.x = 1.25;
		background.scale.y = 1.25;
		background.antialiasing = true;
		add(background);

		// buttonBack = new QButton(16, FlxG.height - 272, 1, 'back');
		// buttonVideo = new QButton(240, FlxG.height - 272, 1, 'display');
		// buttonInput = new QButton(464, FlxG.height - 272, 1, 'input');
		// buttonApply = new QButton(FlxG.width - 272, FlxG.height - 272, 1, 'yes');

		// add(buttonBack);
		// add(buttonVideo);
		// add(buttonInput);
		// add(buttonApply);

		// add(buttonBack.icon);
		// add(buttonVideo.icon);
		// add(buttonInput.icon);
		// add(buttonApply.icon);

		// buttonVideo.appear();
		// buttonBack.appear();
		// buttonInput.appear();
		// buttonApply.appear();

		optionDesc = new FlxText(0, FlxG.height - 348, FlxG.width, optionDescs[selected]);
		optionDesc.alignment = CENTER;
		optionDesc.setFormat(NotoSans.Light, optionSize);

		optionSelector = new FlxText(48, 32 + (selected * optionSize * 1.75), FlxG.width, '>');
		optionSelector.alignment = LEFT;
		optionSelector.setFormat(NotoSans.Light, optionSize);

		for (i in 0...4)
		{
			var label = new FlxText(96, 32 + (i * optionSize * 1.75), FlxG.width, optionNames[i]);
			label.alignment = LEFT;
			label.setFormat(NotoSans.Light, optionSize);
			optionLabels.add(label);
		}
		for (i in 0...4)
		{
			var label = new FlxText(0, 32 + (i * optionSize * 1.75), FlxG.width - 96, optionVars[i]);
			label.alignment = RIGHT;
			label.setFormat(NotoSans.Light, optionSize);
			optionVarLabels.add(label);
		}
		add(optionLabels);
		add(optionVarLabels);
		add(optionDesc);
		add(optionSelector);
	}

	function changeSelection()
	{
		optionSelector.y = 32 + (selected * optionSize * 1.75);
		optionDesc.text = optionDescs[selected];
	}

	function updateVars()
	{
		for (i in 0...4)
		{
			optionVarLabels.members[i].text = Reflect.field(Preferences, optionVars[i]) + optionSuffix[i];
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		updateVars();
		if (FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE)
		{
			Preferences.savePrefs('audio');
			FlxG.switchState(new MenuState());
		}
		// if (Interactions.Clicked(buttonVideo.icon))
		// {
		// 	buttonVideo.dissapear();
		// 	new FlxTimer().start(0.5, function(tmr)
		// 	{
		// 		FlxG.switchState(new VisualState());
		// 	});
		// }
		// if (Interactions.Clicked(buttonApply.icon))
		// {
		// 	buttonApply.click();
		// 	Preferences.savePrefs('audio');
		// 	Preferences.applyPrefs('audio');
		// }
		if (FlxG.keys.justPressed.DOWN)
		{
			if (selected < 3)
				selected++;
			else
				selected = 0;
			changeSelection();
		}
		if (FlxG.keys.justPressed.UP)
		{
			if (selected > 0)
				selected--;
			else
				selected = 3;
			changeSelection();
		}

		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
		{
			switch (optionVars[selected])
			{
				case 'audioOffset':
					Preferences.audioOffset += if (FlxG.keys.justPressed.LEFT) -1 else 1;
				case 'masterVolume':
					Preferences.masterVolume += if (FlxG.keys.justPressed.LEFT) -1 else 1;
				case 'musicVolume':
					Preferences.musicVolume += if (FlxG.keys.justPressed.LEFT) -1 else 1;
				case 'hitsoundVolume':
					Preferences.hitsoundVolume += if (FlxG.keys.justPressed.LEFT) -1 else 1;
			}
		}
	}
}
