package states.debug;

import states.songselect.SongSelectState;
import options.OptionsState;
import gameplay.SongState;
import states.options.AudioState;
import states.options.VisualState;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

class DebugStateSelect extends FlxState
{
	var states:FlxText;
	var pickerSym:FlxText;
	var stateList:Array<Class<FlxState>>;
	var curSelected:Int = 0;

	override public function create()
	{
		super.create();
		pickerSym = new FlxText(48, 64, FlxG.width - 128, ">");
		states = new FlxText(64, 64, FlxG.width - 128);
		stateList = [
			DebugSkinSelect, DebugSongSelectState, DebugStrumsState, IntroState, MenuState, SongSelectState, VisualState, AudioState, SongState, OptionsState
		];
		for (sn in stateList)
		{
			states.text += '$sn\n';
		}
		add(pickerSym);
		add(states);
	}

	private function updatePickerPos()
	{
		pickerSym.y = 64 + (curSelected * 10);
	}

	private function changeSelection(amount:Int, diffs:Bool = false)
	{
		curSelected += amount;

		if (curSelected >= stateList.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = stateList.length - 1;
		updatePickerPos();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.DOWN)
			changeSelection(1, false);
		else if (FlxG.keys.justPressed.UP)
			changeSelection(-1, false);
		if (FlxG.keys.justPressed.S)
			changeSelection(1, true);
		else if (FlxG.keys.justPressed.W)
			changeSelection(1, true);

		if (FlxG.keys.justPressed.ENTER)
		{
			var debugState = cast Type.createInstance(stateList[curSelected], []);
			FlxG.switchState(debugState);
		}
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new MenuState());
		}
	}
}
