package maps;

// https://osu.ppy.sh/wiki/en/Client/File_formats/Osu_%28file_format%29
using StringTools;

typedef OsuBeatMap =
{
	var General:Map<String, Dynamic>;
	var Editor:Map<String, Dynamic>;
	var Metadata:Map<String, Dynamic>;
	var Difficulty:Map<String, Dynamic>;
	var Events:Array<Array<Dynamic>>;
	var TimingPoints:Array<Array<Dynamic>>;
	var Colours:Map<String, Dynamic>;
	var HitObjects:Array<Array<Dynamic>>;
};

class OsuParser
{
	public static function parseMap(song:String, diff:String):OsuBeatMap
	{
		var code = SMAssets.readModChart('mania', (song.toLowerCase() + '/' + diff.toLowerCase())).trim();
		var keyValueSectors = ['General', 'Editor', 'Metadata', 'Difficulty', 'Colours'];
		var lines = code.split('\n');
		var finalBeatMap:OsuBeatMap = {
			General: new Map<String, Dynamic>(),
			Editor: new Map<String, Dynamic>(),
			Metadata: new Map<String, Dynamic>(),
			Difficulty: new Map<String, Dynamic>(),
			Events: [],
			TimingPoints: [],
			Colours: new Map<String, Dynamic>(),
			HitObjects: []
		};
		var curSector = '';
		for (line in lines)
		{
			var trimmed = line.trim();
			if (trimmed.startsWith('//'))
				continue;
			else if (trimmed == '')
				continue;
			else if (trimmed.startsWith('['))
			{
				curSector = trimmed.substring(1, trimmed.length - 1);
				// trace('Found sector "$curSector"');
			}
			else if (curSector == 'TimingPoints')
			{
				finalBeatMap.TimingPoints.push(trimmed.split(','));
			}
			else if (curSector == 'HitObjects')
			{
				finalBeatMap.HitObjects.push(trimmed.split(','));
			}
			else if (keyValueSectors.contains(curSector))
			{
				var keyValuePair = trimmed.split(':');
				switch (curSector)
				{
					case 'General':
						finalBeatMap.General.set(keyValuePair[0].trim(), keyValuePair[1].trim());
					case 'Editor':
						finalBeatMap.Editor.set(keyValuePair[0].trim(), keyValuePair[1].trim());
					case 'Metadata':
						finalBeatMap.Metadata.set(keyValuePair[0].trim(), keyValuePair[1].trim());
					case 'Difficulty':
						finalBeatMap.Difficulty.set(keyValuePair[0].trim(), keyValuePair[1].trim());
					case 'Colours':
						finalBeatMap.Colours.set(keyValuePair[0].trim(), keyValuePair[1].trim());
				}
				// trace(keyValuePair);
			}
			else
				// trace(line);
				continue;
		}
		trace(finalBeatMap);
		return finalBeatMap;
	}
}
