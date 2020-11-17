package;

import ee.ui.comp.UIComponent;
import h2d.Tile;
import h3d.scene.Interactive;
import hxd.Window;

class Screen
{
	public var layout:ee.ui.layout.Element;
	var view:UIComponent;
	var scene:h2d.Scene;
	public function new(scene:h2d.Scene) 
	{
		this.scene = scene;
		setup();
	}

	function setup() 
	{
		cleanView();
		if( parseLayout() )
			initView();
	}

	//Gestion basique et un peu violente du hot reload.
	// il faut d'abord faire un diff de ce qui a changé dans l'entry
	// si c'est la structure ou simplement du scripting, et le gérer en conséquence
	function parseLayout():Bool
	{
		var entry = hxd.Res.layout.entry;
	   	entry.watch( setup );
		var xml = try Xml.parse( entry.getText() ) catch(e:Any) { trace("Malformed XML"); return false;}
		layout = try ee.ui.layout.UIBuilder.build( xml ) catch(e:Any) { trace("Invalid layout format \n"+e); return false;}
		layout.resize(Window.getInstance().width, Window.getInstance().height);
		return true;
	}

	function cleanView() 
	{
		if( this.view != null )
		{
			this.view.removeChildren();
			this.view.remove();
		}
	}

	function initView()
	{
		this.view = ee.ui.comp.UISkinner.skinUI(layout);
		layout.refresh();
		this.scene.addChild(this.view);
	}

}
