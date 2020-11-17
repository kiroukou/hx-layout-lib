package ee.ui.comp;

import ee.ui.comp.UIComponent;
import ee.ui.layout.Element;

class UISkinner
{
	public static var DEFAULT_COMP_CLASS = UIComponent;
	
	public static function skinUI(pLayout:Element): UIComponent
	{
		var cmpClass = (pLayout.viewStyle != null && pLayout.viewStyle.component != null) 
						? Type.resolveClass(pLayout.viewStyle.component) 
						: DEFAULT_COMP_CLASS;

		var comp:UIComponent = Type.createInstance(cmpClass, []);
		comp.visible = !pLayout.disabled;
		comp.name = pLayout.name;
		@:privateAccess comp.layout = pLayout;
		comp.init();

		if( pLayout.viewStyle != null ) 
			comp.applyStyle(pLayout.viewStyle);

		if( pLayout.script.interp != null )
		{
			pLayout.script.interp.variables.set("component", comp);
			pLayout.script.interp.variables.set("find", function(name) {
				var o = comp.getScene().getObjectByName(name);
				return cast(o, UIComponent);
			});
		}
		
		pLayout.onDisabled = function() {
			comp.visible = !pLayout.disabled;
		}
		
		pLayout.onUpdate = function() {
			@:privateAccess pLayout.callScript("onBeforeResize");
			comp.x = pLayout.x;
			comp.y = pLayout.y;
			comp.resize(pLayout.width, pLayout.height, pLayout.bounds);
			@:privateAccess pLayout.callScript("onAfterResize");
		}

		if( Std.is(pLayout, ee.ui.layout.IElementContainer) )
		{
			var l:ee.ui.layout.IElementContainer = cast pLayout;
			for( e in l.getElements() )
			{
				var childComp = skinUI(e);
				comp.addChild(childComp);
			}
		}

		pLayout.script.eval();
		@:privateAccess pLayout.callScript("onInit");

		return comp;
	}
}
