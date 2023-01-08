package maps;

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
		return new MapChart(notes, bpms);
	}
}
