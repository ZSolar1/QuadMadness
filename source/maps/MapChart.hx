package maps;

import gameplay.Note;

class MapChart
{
	public var notes:Array<Note>;
	public var bpm:Array<Dynamic>;

	public function new(notes, bpm)
	{
		this.notes = notes;
		this.bpm = bpm;
	}
}
