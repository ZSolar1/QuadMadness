package options;

class OptionsCategory
{
	public var name:String;
	public var options:Array<Option>;

	public function new(name:String, options:Array<Option>)
	{
		this.name = name;
		this.options = options;
	}
}

class Option
{
	public function new(name:String, description:String = '', variable:String, type:String = 'bool') {}
}
