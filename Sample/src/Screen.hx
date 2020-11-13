package;

import ee.ui.comp.UIComponent;
import h2d.Tile;
import h3d.scene.Interactive;
import hxd.Window;

class Screen extends ee.ui.comp.UIComponent
{
	var label:h2d.Text;
	public var layout:ee.ui.layout.Element;

	public function new(?p) 
	{
		super(p);
		this.name = "layout";
		//
		setup();
	}

	function setup() 
	{
		this.removeChildren();
		//
		constructView();
		//
		parseLayout();
		//
		initView();
	}

	function parseLayout()
	{
		var entry = hxd.Res.layout.entry;
	   	entry.watch( setup );
		var xml = try Xml.parse( entry.getText() ) catch(e:Any) { return trace("Malformed XML"); }
		layout = ee.ui.layout.UIBuilder.build( xml );// catch(e:Any) { return trace("Invalid format \n"+e); }
		layout.resize(Window.getInstance().width, Window.getInstance().height);
	}

	public function constructView()
	{
		var box = new ee.ui.comp.UIComponent(this);
		box.name = "boxMenu";
		box.applyStyle({backgroundColor: 0xFFFF0000});

		var img = new ee.ui.comp.UIComponent(box);
		img.name = "image";
		img.applyStyle({backgroundColor: 0xFF00FF00});
	}

	function initView()
	{
		ee.ui.layout.UIBuilder.mapUI(layout, this);
		layout.refresh();
	}

}
