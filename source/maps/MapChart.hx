package maps;

import gameplay.Note;

class MapChart
{
	public var notes:Array<Note>;
	public var bpm:Array<Dynamic>;
	public var additionalData:Array<Dynamic>;

	public function new(notes, bpm, additionalData)
	{
		this.notes = notes;
		this.bpm = bpm;
		this.additionalData = additionalData;
	}
}
