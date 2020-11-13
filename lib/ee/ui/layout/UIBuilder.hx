package ee.ui.layout;

import ee.ui.comp.UIComponent;
import ee.ui.layout.Element;

class UIBuilder
{
	static var uiMap:Map<ee.ui.comp.UIComponent, Element> = new Map();
	public static function build( pXml:Xml, ?pProtected:Array<String> ):Element
	{		
		return cast parse( pXml.firstElement(), pProtected );
	}
	
	public static function getLayout(pComponent:ee.ui.comp.UIComponent)
	{
		return uiMap.get(pComponent);
	}
	
	public static function syncWithLayout(pComponent:ee.ui.comp.UIComponent)
	{
		var l = getLayout(pComponent);
		pComponent.x = l.x;
		pComponent.y = l.y;
		pComponent.resize(l.width, l.height);
	}
	
	public static function mapUI(pLayout:Element, pComponent:ee.ui.comp.UIComponent)
	{
		pComponent.visible = !pLayout.disabled;
		
		uiMap.set(pComponent, pLayout);

		if( pLayout.viewStyle != null ) 
			pComponent.applyStyle(pLayout.viewStyle);

		if( pLayout.script.interp != null )
			pLayout.script.interp.variables.set("component", pComponent);
		
		pLayout.onDisabled = function() {
			pComponent.visible = !pLayout.disabled;
		}
		
		pLayout.onUpdate = function() {
			@:privateAccess pLayout.callScript("onBeforeResize");
			pComponent.x = pLayout.x;
			pComponent.y = pLayout.y;
			pComponent.resize(pLayout.width, pLayout.height);
			@:privateAccess pLayout.callScript("onAfterResize");
		}

		if( Std.is(pLayout, ee.ui.layout.IElementContainer) )
		{
			var l:ee.ui.layout.IElementContainer = cast pLayout;
			for( e in l.getElements() )
			{
				var name = e.name;
				var o = pComponent.getObjectByName(name);
				if( o != null )
				{
					mapUI(cast e, cast o);
				}
			}
		}

		pLayout.script.eval();
		@:privateAccess pLayout.callScript("onInit");
	}
	
	inline static function getVAlign(att:String) {
		return switch( att ) {
			case "middle": VLayoutKind.MIDDLE;
			case "top": VLayoutKind.TOP;
			case "bottom": VLayoutKind.BOTTOM;
			default :  null;
		}
	}
	
	inline static function getHAlign(att:String) {
		return switch( att ) {
			case "left": HLayoutKind.LEFT;
			case "right": HLayoutKind.RIGHT;
			case "center": HLayoutKind.CENTER;
			default : null;
		}
	}
	
	inline static function parseAlign(attr:String) {
		var aligns = attr.split(",").map( function(s) return StringTools.trim(s).toLowerCase() );
		if ( aligns.length > 2 ) throw "Layout element should have align property set with following format : (horizontal),(vertical)";
		var r = { h:HLayoutKind.INHERITED, v:VLayoutKind.INHERITED };
		
		for ( align in aligns )
		{
			var h = getHAlign(align);
			if ( h == null )
			{
				var v = getVAlign(align);
				if ( v == null ) throw "Invalid align attribute :" + align + "  valid values are (top, bottom, middle) (right, left, center)";
				r.v = v;
			}
			else
			{
				r.h = h;
			}
		}
		return r;
	}
	
	static function parse( pNode:Xml, ?pProtected:Array<String>  )
	{
		var elements = pNode.elements();
		var parent = parseNode(pNode);

		for ( e in pNode.elements() )
		{
			if ( e.nodeType != Xml.Element ) continue;
			
			var nodeName = e.nodeName.toLowerCase();
			if ( pProtected != null && Lambda.has(pProtected, nodeName) )   
				throw nodeName+" is a protected keyword !";
			
			switch( nodeName )
			{
				case "script":
					var a = new haxe.xml.Access(e);
					parseScript(a.innerData, cast parent);
				case "style":
					var a = new haxe.xml.Access(e);
					parseStyle(a.innerData, cast parent);
				default:
					var element:ee.ui.layout.Element = parse( e );
					cast( parent, IElementContainer).addElement(element);
			}
		}

		return parent;
	}
	
	static function parseScript(pScript:String, pElement:Element)
	{
		if( pElement.script.content == pScript ) return;

		if( pElement.script.interp == null ) {
			var interp = new hscript.Interp();
			interp.variables.set("trace", function(log) {
				haxe.Log.trace("(script "+pElement.name+") "+log);
			});
			
			interp.variables.set("find", pElement.getElementByName);
			interp.variables.set("px", ee.Metrics.px);
			interp.variables.set("this", pElement);
			interp.variables.set("document", pElement.root);
			
			pElement.script.interp = interp;
		}
		
		var parser = new hscript.Parser();
		var program = parser.parseString(pScript);
		pElement.script.eval = function() {
			return pElement.script.interp.execute(program);
		}
		
		pElement.script.content = pScript;
	}

	static function parseStyle(pStyle:String, pElement:Element)
	{
		var interp = new hscript.Interp();
		var parser = new hscript.Parser();
		interp.variables.set("hex", ee.ui.Color.fromString);
		interp.variables.set("color", ee.ui.Color.fromARGBf);
		parser.allowJSON = true;
		var program = parser.parseString(pStyle);
		var style = interp.execute(program);
		pElement.viewStyle = style;
	}
	
	static function parseNode( pXmlNode:Xml ):Element
	{
		var readAttr = [];
		inline function hasAtt(att:String):Bool 
		{
			return pXmlNode.exists(att);
		}
		
		function getAtt(att:String):Null<String>
		{
			if ( !pXmlNode.exists(att) ) throw "Current node doesn't have the attribute " + att + " defined";
			readAttr.push(att);
			return pXmlNode.get(att);
		}
		
		var id = getAtt('id');		
		var hAlign = HLayoutKind.INHERITED;
		var vAlign = VLayoutKind.INHERITED;
		if ( hasAtt("align") )
		{
			var r = parseAlign(getAtt("align"));
			hAlign = r.h;
			vAlign = r.v;
		}
		
		var aspect = AspectKind.MATCH_PARENT; 
		if ( hasAtt('aspect') )
		{
			var ratio = if ( hasAtt('aspectRatio') ) Std.parseFloat(getAtt('aspectRatio')) else 1.0;
			aspect = switch( getAtt('aspect') )
			{
				case "keep_in": AspectKind.KEEP_IN(ratio);
				case "keep_out": AspectKind.KEEP_OUT(ratio);
				case "stretch": AspectKind.MATCH_PARENT;
				case "fixed": AspectKind.FIXED;
				default: throw "unknown aspect for node " + getAtt('id');
			}
		}
		
		var noAttributes = false;
		var nodeName = pXmlNode.nodeName.toLowerCase();
		var e = switch(nodeName)
		{
			case "hbox", "vbox", "box": 
				var w = hasAtt('width') ? getAtt('width') : '100%';
				var h = hasAtt('height') ? getAtt('height') : '100%';
				var b = new ee.ui.layout.BoxLayout(w, h, hAlign, vAlign, aspect ); 
				b.name = id;
				
				if ( nodeName == "box" ) 	b.vertical = hasAtt("vertical") && getAtt("vertical").toLowerCase() == "true";
				else 						b.vertical = nodeName == "vbox";
				
				b.autoSize = hasAtt("autoSize") && getAtt("autoSize").toLowerCase() == "true";
				
				if ( hasAtt("childAlign") )
				{
					var r = parseAlign(getAtt("childAlign"));
					b.hChildrenLayout = r.h;
					b.vChildrenLayout = r.v;
				}
				
				if( hasAtt('childPadding') )
					b.childPadding = getAtt('childPadding');
				b;
				
			case "canvas":
				var w = hasAtt('width') ? getAtt('width') : '100%';
				var h = hasAtt('height') ? getAtt('height') : '100%';
				var c = new ee.ui.layout.CanvasLayout(w, h, hAlign, vAlign, aspect ); 
				c.name = id;
				c;
			
			case "element":
				var w = hasAtt('width') ? getAtt('width') : '100%';
				var h = hasAtt('height') ? getAtt('height') : '100%';
				var e = new Element(w, h, hAlign, vAlign, aspect);
				e.name = id;
				e;
			
			case "stack":
				noAttributes = true;
				var e = new ElementStack();
				e.name = id;
				if( hasAtt("selectedIndex") )
					@:privateAccess e.index = Std.parseInt(getAtt("selectedIndex"));
				e;
				
			default : throw nodeName + " is not a valid layout element";
		}
		
		//CONFIG attributes
		if( noAttributes == false )
		{
			if( hasAtt('minHeight') ) e.style.minHeight = getAtt('minHeight');
			if( hasAtt('minWidth') ) e.style.minWidth = getAtt('minWidth');
			if( hasAtt('maxHeight') ) e.style.maxHeight = getAtt('maxHeight');
			if( hasAtt('maxWidth') ) e.style.maxWidth = getAtt('maxWidth');

			if( hasAtt('margin') )  e.style.marginTop = e.style.marginBottom = e.style.marginRight = e.style.marginLeft = getAtt('margin');
			if( hasAtt('marginLeft') ) e.style.marginLeft = getAtt('marginLeft');
			if( hasAtt('marginRight') ) e.style.marginRight = getAtt('marginRight');
			if( hasAtt('marginTop') ) e.style.marginTop = getAtt('marginTop');
			if( hasAtt('marginBottom') ) e.style.marginBottom = getAtt('marginBottom');
			if( hasAtt('disabled') ) e.disabled = getAtt('disabled').toLowerCase() == "true";
		}
		
		//check if node does not define unvalid attributes, since it may represent a typo mistake
		for ( att in pXmlNode.attributes() )
		{
			//attribute starting with un underscore are considered as commented attributes, so no check is applied
			if ( StringTools.startsWith(att, '_') ) continue;
			if ( Lambda.indexOf(readAttr,att) == -1 )
			{
				throw "Attribute " + att + " is not used or invalid on the node " + id;
			}
		}
		
		return e;
	}
}
