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
	public var name:String;
	public var description:String;
	public var variable:String;
	public var type:String;

	public function new(name:String, description:String = '', variable:String, type:String = 'bool')
	{
		this.name = name;
		this.description = description;
		this.variable = variable;
		this.type = type;
	}
}
