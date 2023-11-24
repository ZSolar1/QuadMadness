package states.options;

import flixel.util.FlxTimer;
import Fonts.NotoSans;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;

class VisualState extends FlxState
{
	var background:ParallaxSprite;

	// var buttonBack:QButton;
	// var buttonApply:QButton;
	// var buttonAudio:QButton;
	// var buttonInput:QButton;
	var optionLabels:FlxTypedGroup<FlxText>;
	var optionVarLabels:FlxTypedGroup<FlxText>;
	var optionDesc:FlxText;
	var optionSelector:FlxText;
	var selected:Int = 0;
	var optionSize = 48;

	var optionNames = ['Visual Offset', 'Scroll Speed', 'Downscroll', 'Windowed'];
	var optionDescs = [
		'Are notes appearing early? (-) or late? (+)',
		'How fast are the notes?',
		'Are notes going up, or down?',
		'Window / Fullscreen?'
	];
	var optionVars = ['visualOffset', 'scrollSpeed', 'downscroll', 'windowed'];
	var optionSuffix = [' ms', '', '', ''];

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
		// buttonAudio = new QButton(240, FlxG.height - 272, 1, 'audio');
		// buttonInput = new QButton(464, FlxG.height - 272, 1, 'input');
		// buttonApply = new QButton(FlxG.width - 272, FlxG.height - 272, 1, 'yes');

		// add(buttonBack);
		// add(buttonAudio);
		// add(buttonInput);
		// add(buttonApply);

		// add(buttonBack.icon);
		// add(buttonAudio.icon);
		// add(buttonInput.icon);
		// add(buttonApply.icon);

		// buttonAudio.appear();
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
			if (!Std.isOfType(Reflect.field(Preferences, optionVars[i]), Bool))
				optionVarLabels.members[i].text = Reflect.field(Preferences, optionVars[i]) + optionSuffix[i];
			else
				switch (i)
				{
					case 2:
						optionVarLabels.members[i].text = Preferences.downscroll ? "Yes" : "No";
					case 3:
						optionVarLabels.members[i].text = Preferences.windowed ? "Yes" : "No";
				}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		updateVars();
		if (FlxG.keys.justPressed.BACKSPACE || FlxG.keys.justPressed.ESCAPE)
		{
			Preferences.savePrefs('visual');
			FlxG.switchState(new MenuState());
		}
		// if (Interactions.Clicked(buttonBack.icon))
		// {
		// 	buttonBack.dissapear();
		// 	new FlxTimer().start(0.5, function(tmr)
		// 	{
		// 		FlxG.switchState(new MenuState());
		// 	});
		// }
		// if (Interactions.Clicked(buttonAudio.icon))
		// {
		// 	buttonAudio.dissapear();
		// 	new FlxTimer().start(0.5, function(tmr)
		// 	{
		// 		FlxG.switchState(new AudioState());
		// 	});
		// }
		// if (Interactions.Clicked(buttonApply.icon))
		// {
		// 	buttonApply.click();
		// 	Preferences.savePrefs('visual');
		// 	Preferences.applyPrefs('visual');
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
				case 'visualOffset':
					Preferences.visualOffset += if (FlxG.keys.justPressed.LEFT) -1 else 1;
				case 'scrollSpeed':
					Preferences.scrollSpeed += if (FlxG.keys.justPressed.LEFT) -0.1 else 0.1;
				case 'downscroll':
					Preferences.downscroll = !Preferences.downscroll;
				case 'windowed':
					Preferences.windowed = !Preferences.windowed;
			}
		}
	}
}
