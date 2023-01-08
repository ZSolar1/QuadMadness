package states.debug;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import gameplay.NoteParticle;
import gameplay.StrumNote;

class DebugStrumsState extends FlxState
{
	var strums:FlxTypedGroup<StrumNote>;
	var particles:FlxTypedGroup<NoteParticle>;

	override public function create()
	{
		super.create();
		strums = new FlxTypedGroup<StrumNote>();
		particles = new FlxTypedGroup<NoteParticle>();
		for (i in 0...4)
		{
			var strum:StrumNote = new StrumNote(FlxG.width / 2, 0);
			strum.x -= 256;
			strum.x += i * 128;
			strum.y += 16;
			strums.add(strum);
		}
		add(strums);
	}

	private function createParticle(x:Float, y:Float)
	{
		var particle:NoteParticle = new NoteParticle(x, y);
		add(particle);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (Controls.justPressed('left'))
			createParticle(strums.members[0].x, strums.members[0].y);
		if (Controls.justPressed('down'))
			createParticle(strums.members[1].x, strums.members[1].y);
		if (Controls.justPressed('up'))
			createParticle(strums.members[2].x, strums.members[2].y);
		if (Controls.justPressed('right'))
			createParticle(strums.members[3].x, strums.members[3].y);

		if (Controls.pressed('left'))
			strums.members[0].playAnim('pressed');
		if (Controls.pressed('down'))
			strums.members[1].playAnim('pressed');
		if (Controls.pressed('up'))
			strums.members[2].playAnim('pressed');
		if (Controls.pressed('right'))
			strums.members[3].playAnim('pressed');

		if (Controls.justReleased('left'))
			strums.members[0].playAnim('idle');
		if (Controls.justReleased('down'))
			strums.members[1].playAnim('idle');
		if (Controls.justReleased('up'))
			strums.members[2].playAnim('idle');
		if (Controls.justReleased('right'))
			strums.members[3].playAnim('idle');
	}
}
