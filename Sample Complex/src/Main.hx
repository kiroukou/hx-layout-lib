package;

import hxd.Window;
import  comp.ImageComp;
import ee.ui.comp.Button;

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
	}

	// if the window is resized
	override function onResize() 
	{
		trace("onResize APp");
		scene.layout.resize(Window.getInstance().width, Window.getInstance().height);
		scene.layout.refresh();
	}

	override function update(dt:Float) 
	{
		super.update(dt);
		//scene.update(dt);
	}
}