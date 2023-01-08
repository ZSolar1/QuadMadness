import flixel.FlxG;

class Scores
{
	public static var scores:Map<String, Array<Dynamic>>;

	public static function loadSavedScores()
	{
		FlxG.save.bind('scores');
		scores = FlxG.save.data.scores;
	}

	public static function saveSong(song:String, saveData:Array<Dynamic>)
	{
		// Temporary
		if (!scores.exists(song))
			scores.set(song, saveData);
		FlxG.save.bind('scores');
		scores = FlxG.save.data.scores;
	}

	public static function loadSong(song:String):Array<Dynamic>
	{
		// Temporary
		if (!scores.exists(song))
			return new Array<Dynamic>();
		return scores.get(song);
	}
}
