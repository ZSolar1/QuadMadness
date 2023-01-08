package states.debug;

import Assets.QMAssets;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

class DebugSkinSelect extends FlxState
{
	var skins:FlxText;
	var pickerSym:FlxText;
	var skinList:Array<String>;
	var curSelected:Int = 0;

	override public function create()
	{
		super.create();
		pickerSym = new FlxText(48, 64, FlxG.width - 128, ">");
		skins = new FlxText(64, 64, FlxG.width - 128);
		skinList = QMAssets.readAllSkins();
		for (sn in skinList)
		{
			skins.text += '$sn\n';
		}
		add(pickerSym);
		add(skins);
	}

	private function updatePickerPos()
	{
		pickerSym.y = 64 + (curSelected * 10);
	}

	private function changeSelection(amount:Int, diffs:Bool = false)
	{
		curSelected += amount;

		if (curSelected >= skinList.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = skinList.length - 1;
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
			Preferences.skin = skinList[curSelected];
			Preferences.savePrefs('visual');
			trace('Saved skin preferences with: ${Preferences.skin}');
		}
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new MenuState());
		}
	}
}
