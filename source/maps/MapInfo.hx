package maps;

typedef Beatmap =
{
	var songName:String;
	var charter:String;
	var author:String;
	var difficulties:Array<Difficulty>;
}

typedef Difficulty =
{
	var name:String;
	var id:String;
}
