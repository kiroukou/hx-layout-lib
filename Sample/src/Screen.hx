package;

import ee.ui.comp.UIComponent;
import h2d.Tile;
import h3d.scene.Interactive;
import hxd.Window;

class Screen extends h2d.Object
{
	var label:h2d.Text;
	var layout:ee.ui.layout.Element;

	public function resize()
	{
		layout.resize( ee.Metrics.w(), ee.Metrics.h() );
	}
	
	public function init()
	{
        // We get the layout XML, parse it, and generate the layout !
        var entry = hxd.Res.layout.entry;
        entry.watch( refreshUI.bind(entry) );
        refreshUI(entry);		
    }
    
    public function refreshUI(entry) {
        if (layout != null ) layout.clean();
        //
        var template = new haxe.Template(entry.getText());
		var xmlData = template.execute( getContext() );
		var xml = try Xml.parse( xmlData ) catch(e:Any) { return trace("Malformed XML"); }
        layout = try ee.ui.layout.UIBuilder.build( xml ) catch(e:Any) { return trace("Invalid format \n"+e); }
        //
        this.removeChildren();
        skinUI(layout, this, 0);
        //must do done AFTER skinning, for onUpdate call isn't make right away, resize call does that happen
        resize();
        //
        label = new h2d.Text(hxd.res.DefaultFont.get(), this);
        label.maxWidth = 100;
        label.x = label.y = 5;

    }
	
	public function update(dt:Float)
	{
	}
    
    //Basic and useless way to skin. But that is for the sample
	function skinUI( ui:ee.ui.layout.Element, parentNode:h2d.Object, depth:Int )
	{
		var comp = new UIComponent(parentNode);
		ui.onUpdate.add( function(e) {
			comp.name = e.name;
			comp.x = e.x;
			comp.y = e.y;
		
			comp.parseScript(e.script);
			comp.parseStyle(e.style);
			//do that after !
			comp.resize(e.width, e.height);

			comp.init();
		} );
        
        //Do it recurssively
		if( Std.is(ui, ee.ui.layout.IElementContainer ) )
		{
			var group = cast( ui, ee.ui.layout.IElementContainer );
			for( e in group.getElements() )
			{
				skinUI(e, comp, depth+1);
			}
		}
	}
	
	static function getContext()
	{
		var stage = hxd.Window.getInstance();
		var layoutContext:Dynamic = { screenWidth:stage.width, screenHeight:stage.height };
		#if debug
		layoutContext.debug = true;
		#end
		layoutContext.app = true;
		return layoutContext;
	}
}
