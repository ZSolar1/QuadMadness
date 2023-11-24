package maps;

import maps.SMPackage;

class MapPackager
{
	private static function Encode(data:String):String
	{
		return "";
	}

	private static function Decode(data:String):String
	{
		return "";
	}

	public static function packageSong(game:String, song:String)
	{
		var files:Array<String>;
		var songPackage:SMPackage = {
			Info: {
				Version: VERSION_FIRST,
				Type: TYPE_SONG
			},
			Entries: []
		};
		if (game == 'fnf')
			files = SMAssets.readModDirectory('fnf/$song');
		else
			files = [];
		songPackage.Info.Version = SMPackageVersion.VERSION_FIRST;
		songPackage.Info.Type = SMPackageType.TYPE_SONG;

		for (filename in files)
		{
			var file = SMAssets.readBinaryModChart(game, '$song/$filename');
			var entry:SMPackageEntry = {
				Name: "",
				Data: "",
			};
			entry.Name = filename;
			entry.Data = file.toHex();
			songPackage.Entries.push(entry);
		}

		SMAssets.writeChartPackage(song, songPackage);
	}

	private static function castJsonToPackage(data:String):SMPackage
		return cast haxe.Json.parse(data);

	public static function extractSong(song:String)
	{
		var data = SMAssets.readModChart('charts', '$song.qmp');
		var songPackage:SMPackage = castJsonToPackage(data);

		SMAssets.makeDirectory('mods/charts/$song');
		for (file in songPackage.Entries)
		{
			SMAssets.writeHexChart(song, file.Name, file.Data);
		}
	}
}
