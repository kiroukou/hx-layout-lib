package ee.ui.layout;

import ee.Metrics.Px;

/**
 * Configuration of the element
 */
typedef ElementConfig = {

	var width:String;
	var height:String;
	
	var marginLeft:String;
	var marginRight:String;
	var marginTop:String;
	var marginBottom:String;
	
	@:optional var minWidth:Null<String>;
	@:optional var minHeight:Null<String>;
	@:optional var maxWidth:Null<String>;
	@:optional var maxHeight:Null<String>;
}

/**
 * Position behaviour of the element node inside the layout
 */
enum VLayoutKind {
	MIDDLE;
	TOP;
	BOTTOM;	
	INHERITED;
}

enum HLayoutKind {
	CENTER;
	LEFT;
	RIGHT;
	INHERITED;
}

/**
 * Aspect of the element when it is resized.
 */
enum AspectKind {
	FIXED;
	MATCH_PARENT;
	KEEP_IN( ratio:Float );
	KEEP_OUT( ratio:Float );	
}

typedef Bounds = { 
	x:Float, 
	y:Float, 
	width:Float, 
	height:Float,
}

typedef ScriptInfo = {
	?interp:hscript.Interp,
	?content:String,
	eval:Void->Any
}

class Element
{
	/* EVENTS */
	public var onUpdate:Void->Void;
	public var onDisabled:Void->Void;
	
	public var onUpdateScript:Void->Void;
	public var onDisabledScript:Void->Void;

	/* PROPERTIES */
	
	public var name:String;
	public var config(default, set):ElementConfig;
	public var root(default, null):Null<IElementContainer>;

	public var hLayout:HLayoutKind;
	public var vLayout:VLayoutKind;
	public var aspect:AspectKind;
	
	public var invalidated(default, null):Bool;
	public var script:ScriptInfo;
	public var viewStyle:ee.ui.comp.Style;

	/* GETTERS / SETTERS */
	public var marginLeft(default, null):Float;
	public var marginRight(default, null):Float;
	public var marginTop(default, null):Float;
	public var marginBottom(default, null):Float;
	public var x(default, null):Float;
	public var y(default, null):Float;
	public var globalX(get, null):Float;
	public var globalY(get, null):Float;
	public var width(default, null):Float;
	public var height(default, null):Float;
	public var bounds(default, null): Bounds;
	public var disabled(default, set):Bool;

	inline function set_disabled(value:Bool):Bool {
		if( value != disabled ) {
			disabled = value;
			if ( parent != null ) 
				parent.invalidate();
			
			if ( onDisabled != null ) onDisabled();
			if ( onDisabledScript != null ) onDisabledScript();
		}
		return disabled;
	}
	
	inline public function disable()
	{
		disabled = true;
	}
	
	inline public function enable()
	{
		disabled = false;
	}
	
	var contentX(get, set):Float;
	function get_contentX():Float { return x; }
	function set_contentX(v:Float) {
		x = v;
		bounds.x = v - marginLeft; 
		return v; 
	};
	
	var contentY(get, set):Float;
	function get_contentY():Float { return y; }
	function set_contentY(v:Float) { 
		y = v;
		bounds.y = v - marginTop; 
		return v; 
	};
	
	var contentWidth(get, set):Float;
	function get_contentWidth():Float { return width; }
	function set_contentWidth(v:Float) {
		width = v;
		bounds.width = v + marginLeft + marginRight; 
		return v; 
	};
	
	var contentHeight(get, set):Float;
	function get_contentHeight():Float { return height; }
	function set_contentHeight(v:Float) {
		height = v;
		bounds.height = v + marginTop + marginBottom;
		return v;
	};
	
	public function relativeX( p_ref:Element ):Float
	{
		var lparent:Element = cast parent;
		var lx = x;
		while ( lparent != null && lparent != p_ref )
		{
			lx += lparent.x;
			lparent = cast lparent.parent;
		}
		if ( lparent != p_ref ) throw "invalid reference";
		return lx;
	}
	
	public function relativeY( p_ref:Element ):Float
	{
		var lparent:Element = cast parent;
		var ly = y;
		while ( lparent != null && lparent != p_ref )
		{
			ly += lparent.y;
			lparent = cast lparent.parent;
		}
		if ( lparent != p_ref ) throw "invalid reference";
		return ly;
	}
	
	public var parent(default, set):Null<IElementContainer>;
	inline function set_parent(pParent:Null<IElementContainer>):Null<IElementContainer>
	{
		if ( pParent != null ) root = pParent.root;
		else root = pParent;		
		return parent = pParent;
	}
	
	inline function get_globalX() {
		var v = x;
		if( parent != null )
			v += parent.globalX;
		return v;
	}
	
	inline function get_globalY() {
		var v = y;
		if ( parent != null )
			v += parent.globalY;
		return v;
	}
	
	inline static public function toPixels(v:String, p:Float=0.0):Float 
	{
		var c = v.charAt(v.length - 1);
		return 		if ( c >= '0' && c <= '9') Std.parseFloat(v)
					else if ( c == "%" ) Std.parseFloat(v) * 0.01 * p
					else { var tmp : Px = v; tmp; }
	}
	
	inline public function px(v:String, p:Float=0.0):Float 
	{
		var c = v.charAt(v.length - 1);
		return 		if ( c >= '0' && c <= '9') Std.parseFloat(v)
					else if ( c == "%" ) Std.parseFloat(v) * 0.01 * p
					else { var tmp : Px = v; tmp; }
	}
	
	public function invalidate()
	{
		invalidated = true;
	}
	
	public function new( pWidth:String, pHeight:String, ?pHorizontalLayout:HLayoutKind=null, ?pVerticalLayout:VLayoutKind=null, ?pAspect:AspectKind=null ) 
	{
		this.hLayout = pHorizontalLayout == null ? HLayoutKind.INHERITED : pHorizontalLayout;
		this.vLayout = pVerticalLayout == null ? VLayoutKind.INHERITED : pVerticalLayout;
		this.aspect = pAspect == null ? AspectKind.MATCH_PARENT : pAspect;
		this.bounds = { x:0, y:0, width:0, height:0 };
		this.marginTop = this.marginRight = this.marginLeft = this.marginBottom = 0;
		this.contentHeight = this.contentWidth = 0;
		this.contentX = this.contentY = 0;
		this.disabled = false;
		this.invalidated = true;
		this.script = { eval:() -> null };
		parent = null;
		config = { marginLeft:"0", marginRight:"0", marginTop:"0", marginBottom:"0", width:StringTools.trim(pWidth), height:StringTools.trim(pHeight) };
	}
	
	function set_config(pConfig:ElementConfig)
	{
		for ( f in Reflect.fields(pConfig) )
		{
			if ( Reflect.field(config, f) != Reflect.field(pConfig, f) )
			{
				invalidate();
				break;
			}
		}
		return this.config = pConfig;
	}
	
	public function refresh() : Void 
	{
		var wasInvalidated = invalidated;
		invalidated = false;
		if ( wasInvalidated )
		{
			notify();
		}
	}
	
	public function clone():Element
	{
		var e = new Element("1", "1");
		e.name = this.name;
		e.config = Reflect.copy(config);
		e.vLayout = this.vLayout;
		e.hLayout = this.hLayout;
		e.aspect = this.aspect;
		e.disabled = this.disabled;
		return e;
	}
	
	public function getElementByName( pName:String ):Null<Element>
	{
		return name == pName ? this : null;
	}
	
	public function clean()
	{
		onUpdate = null;
		onDisabled = null;
	}
	
	public function notify()
	{
		if ( onUpdate != null ) onUpdate();
		if ( onUpdateScript != null ) onUpdateScript();
		//if( onDisabled != null ) onDisabled();
	}


	function callScript(fnName:String) {
		if( script.interp == null ) return;
		try {
			var cb = script.interp.variables.get(fnName);
			if( cb != null ) 
				cb();
		} catch(e : Dynamic ) {
			trace("Error on script node function "+fnName);
			trace(Std.string(e));

		}
    }
	
	public function resize( pWidth:Float, pHeight:Float, ?pForceWidth:Null<Float>, ?pForceHeight:Null<Float>)
	{
		if ( disabled ) return;
		invalidate();
		updateSize(pWidth, pHeight, pForceWidth, pForceHeight);
		updatePosition(pWidth, pHeight);
	}
	
	function updatePosition( pContainerWidth:Float, pContainerHeight:Float )
	{
		var left 	= marginLeft;
		var right 	= marginRight;
		var top 	= marginTop;
		var bottom 	= marginBottom;
		
		var layout = if ( hLayout == INHERITED ) parent.hLayout else hLayout;
		switch( layout )
		{
			case LEFT:		contentX = left;
			case RIGHT: 	contentX = pContainerWidth - contentWidth - right;
			case CENTER: 	contentX = ((pContainerWidth - contentWidth) / 2) + ((left - right) / 2);
			case INHERITED:	
		}
		
		var layout = if ( vLayout == INHERITED ) parent.vLayout else vLayout;
		switch( layout )
		{
			case TOP: 		contentY = top;
			case BOTTOM:	contentY = pContainerHeight - contentHeight - bottom;
			case MIDDLE: 	contentY = ((pContainerHeight - contentHeight) / 2) + ((top - bottom) / 2);
			case INHERITED:	
		}
	}
	
	function updateSize( pContainerWidth:Float, pContainerHeight:Float, ?pForceWidth:Null<Float>, ?pForceHeight:Null<Float> ):Void 
	{
		marginLeft 	= px(config.marginLeft, 	(pForceWidth==null	? pContainerWidth 	: pForceWidth));
		marginRight 	= px(config.marginRight, 	(pForceWidth==null	? pContainerWidth	: pForceWidth));
		marginTop 		= px(config.marginTop, 		(pForceHeight==null	? pContainerHeight	: pForceHeight));
		marginBottom 	= px(config.marginBottom, 	(pForceHeight==null	? pContainerHeight	: pForceHeight));
		
		var elementWidth 	= px(config.width, pContainerWidth);
		var elementHeight 	= px(config.height, pContainerHeight);
		
		var screenWidth 	= 	(pForceWidth==null ? elementWidth:pForceWidth) - marginLeft - marginRight;
		var screenHeight 	= 	(pForceHeight==null? elementHeight:pForceHeight) - marginTop - marginBottom;
		
		if( config.minWidth != null && screenWidth < px(config.minWidth, pContainerWidth) ) 		screenWidth 	= px(config.minWidth, pContainerWidth);
		if( config.maxWidth != null && screenWidth > px(config.maxWidth, pContainerWidth) ) 		screenWidth 	= px(config.maxWidth, pContainerWidth);
		if( config.minHeight != null && screenHeight < px(config.minHeight, pContainerHeight) ) screenHeight 	= px(config.minHeight, pContainerHeight);
		if( config.maxHeight != null && screenHeight > px(config.maxHeight, pContainerHeight) ) screenHeight 	= px(config.maxHeight, pContainerHeight);
		
		switch( aspect )
		{
			case KEEP_IN(ratioValue):
				if(screenWidth / ratioValue > screenHeight) 
				{
					contentWidth = screenHeight * ratioValue;
					contentHeight = screenHeight;
				}
				else 
				{
					contentWidth = screenWidth;
					contentHeight = screenWidth / ratioValue;
				}
				
			case KEEP_OUT(ratioValue):
				if(screenWidth / ratioValue < screenHeight) 
				{
					contentWidth = screenHeight * ratioValue;
					contentHeight = screenHeight;
				}
				else
				{
					contentWidth = screenWidth;
					contentHeight = screenWidth / ratioValue;
				}
				
			case MATCH_PARENT:
				contentWidth = screenWidth;
				contentHeight = screenHeight;
				
			case FIXED:
				contentWidth = screenWidth;
				contentHeight = screenHeight;
		}
		
		if( Math.isNaN(contentWidth) )
		{
			trace("oups");
		}
		if( Math.isNaN(contentHeight) )
		{
			trace("oups");
		}
		if(contentWidth < 0) contentWidth = 0;
		if(contentHeight < 0) contentHeight = 0;
	}
	
}
