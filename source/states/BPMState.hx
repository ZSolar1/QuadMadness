package states;

import flixel.FlxG;
import flixel.FlxState;

class BPMState extends FlxState
{
	// FNF is a good example
	var bpm:Float = 0.0;
	var crochet:Float = 0.0;
	var stepCrochet:Float = 0.0;
	var beats:Float;
	var steps:Float;

	public var curBeat:Int = 0;
	public var curStep:Int = 0;
	public var stepAmount:Int = 4;
    public var songPos:Float = 0;

    override function create(){
        super.create();
        updateCrochet();
    }

	//Just in case the bpm changes
	private function updateCrochet(){
		crochet = (60 / bpm) * 1000;
		stepCrochet = crochet / 4;
	}

	// Finally added beats and steps
	private function beatHit() {}

	// I thought it would be harder
	private function stepHit()
	{
		if (curStep % stepAmount == 0)
			beatHit();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
        if (FlxG.sound.music != null)
            songPos = FlxG.sound.music.time;
		var prevStep = curStep;
		steps = songPos / stepCrochet;
		beats = songPos / crochet;

		curStep = Math.floor(steps);
		curBeat = Math.floor(beats);

        // So simple, yet so effective
        if (prevStep != curStep)
            if (curStep > 0)
                stepHit();
	}
}
