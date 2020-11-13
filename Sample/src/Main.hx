package;

class Main extends hxd.App 
{
	public static function main() 
	{
		hxd.Res.initLocal();
		new Main();
	}
	
	var scene:Screen;	
	public function new() {
		super();
		engine.backgroundColor = 0xFF202020;
	}

	override function init() 
	{
		scene = new Screen(s2d);
		scene.init();
	}

	// if the window is resized
	override function onResize() 
	{
		scene.resize();
	}

	override function update(dt:Float) 
	{
		super.update(dt);
		scene.update(dt);
	}
}