package maps;

import flixel.math.FlxMath;
import maps.OsuParser.OsuBeatMap;
import gameplay.Note;
import maps.FNF.SwagSong;

class Convert
{
	public static function FNF(song:SwagSong):MapChart
	{
		var notes:Array<Note> = new Array<Note>();
		var bpms:Array<Float> = new Array<Float>();
		bpms.push(song.bpm);
		for (section in song.notes)
		{
			var notesAllowed:Array<Dynamic> = [null, '', 'null', false, true];
			var notesDisallowed:Array<Dynamic> = [1, '1'];
			for (note in section.sectionNotes)
			{
				if (note[1] > -1 && notesAllowed.contains(note[3]) && !notesDisallowed.contains(note[3]))
				{
					if (note[1] < 4 && section.mustHitSection)
						notes.push(new Note(note[0], Std.int(note[1]), note[2]));
					if (note[1] > 3 && !section.mustHitSection)
						if (note[1] < 8)
							notes.push(new Note(note[0], Std.int(note[1] - 4), note[2]));
				}
				#if debug
				trace("Note convert results: " + note[0] + " | " + note[1] + " | " + note[2]);
				#end
			}
		}
		trace("Total Notes: " + notes.length);
		return new MapChart(notes, bpms, []);
	}

	public static function OsuMania(song:OsuBeatMap):MapChart
	{
		var notes:Array<Note> = new Array<Note>();
		var bpms:Array<Float> = new Array<Float>();
		for (hitobject in song.HitObjects)
		{
			var note = new Note(hitobject[2], Math.floor(FlxMath.bound(hitobject[0] * 4 / 512, 0, 3)),
				Std.parseFloat(hitobject[5]) - Std.parseFloat(hitobject[2]));
			notes.push(note);
		}
		for (timingpoint in song.TimingPoints)
		{
			bpms.push(1 / Std.parseFloat(timingpoint[1]) * 1000 * 60);
		}
		return new MapChart(notes, bpms, [song.General.get('AudioFilename')]);
	}
}
