import flixel.FlxG;

typedef SongSave =
{
	var accuracy:Float;
	var misses:Int;
	var score:Int;
	var hits:Int;
	var maxCombo:Int;
}

typedef SongSaveData =
{
	var diffs:Map<String, SongSave>;
}

class Scores
{
	public static var scores:Map<String, SongSaveData>;

	public static function saveScores()
	{
		FlxG.save.bind('qm-scores');
		FlxG.save.data.scores = scores;
		FlxG.save.flush();
	}

	public static function loadSavedScores()
	{
		FlxG.save.bind('qm-scores');
		scores = FlxG.save.data.scores;
		if (scores == null)
		{
			scores = new Map<String, SongSaveData>();
		}
	}

	public static function saveSong(song:String, diff:String, saveData:SongSave)
	{
		trace('Trying to save song `$song` on difficulty `$diff`');
		if (scores.get(song) == null)
		{
			trace('Song Save Data did not exist, just mapping it.');
			scores.set(song, {
				diffs: [diff => saveData]
			});
		}
		else
		{
			var lastScore = scores.get(song);
			if (lastScore.diffs.get(diff) == null)
			{
				trace('Song Difficulty Save Data did not exist, just mapping it.');
				scores.get(song).diffs.set(diff, saveData);
			}
			else
			{
				// And it will come, like a flood of pain
				// Pouring down on me
				trace('Song exists, difficulty exists, doing personal best calculations');
				var newResult = scores.get(song).diffs.get(diff);
				newResult.accuracy = saveData.accuracy > newResult.accuracy ? saveData.accuracy : newResult.accuracy;
				newResult.hits = saveData.hits > newResult.hits ? saveData.hits : newResult.hits;
				newResult.maxCombo = saveData.maxCombo > newResult.maxCombo ? saveData.maxCombo : newResult.maxCombo;
				newResult.score = saveData.score > newResult.score ? saveData.score : newResult.score;
				newResult.misses = saveData.misses < newResult.misses ? saveData.misses : newResult.misses;
				scores.get(song).diffs.set(diff, newResult);
			}
		}
	}

	public static function loadSong(song:String):SongSaveData
	{
		if (!scores.exists(song))
		{
			return null;
		}
		return scores.get(song);
	}
}
