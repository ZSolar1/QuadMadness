package maps;

enum QMPackageVersion
{
	VERSION_FIRST;
}

enum QMPackageType
{
	TYPE_SONG;
}

typedef QMPackageInfo =
{
	var Version:QMPackageVersion;
	var Type:QMPackageType;
}

typedef QMPackageEntry =
{
	var Name:String;
	var Data:String;
}

typedef QMPackage =
{
	var Info:QMPackageInfo;
	var Entries:Array<QMPackageEntry>;
}