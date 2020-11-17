package ee.ui.layout;

import ee.ui.layout.Element;


class ElementStack extends Element implements IElementContainer
{	
	public var onChange:Element->Element->Void;
	
	public var hChildrenLayout(default, set):HLayoutKind;
	inline function set_hChildrenLayout(pVal) {
		if ( pVal != hChildrenLayout ) {
			invalidate();
			hChildrenLayout = pVal;
		}
		return hChildrenLayout;
	}
	
	public var vChildrenLayout(default, set):VLayoutKind;
	inline function set_vChildrenLayout(pVal) {
		if ( pVal != vChildrenLayout ) {
			invalidate();
			vChildrenLayout = pVal;
		}
		return vChildrenLayout;
	}
	
	public var currentElement(default, null):Element;
	public var selectedIndex(get, set):Int;
	public var numElements(get, null):Int;
	inline function get_numElements():Int
	{
		return mElements.length;
	}
	
	var mElements:Array<Element>;
	var mLastWidth:Float;
	var mLastHeight:Float;
	var mLastForcedWidth:Null<Float>;
	var mLastForcedHeight:Null<Float>;
	var mReady:Bool;
	@:allow(layout) var index:Int;
	
	public function new()
	{
		super("0", "0");
		mElements = new Array();
		mReady = false;
		index = 0;
		mLastWidth = mLastHeight = 0.0;
		mLastForcedHeight = mLastForcedWidth = null;
		root = this;
	}
	
	override public function refresh()
	{
		if( currentElement != null )
			currentElement.refresh();
		super.refresh();
	}
	
	/*
	override public function eval()
	{
		super.eval();
		for ( e in mElements )
			e.eval();
	}
	*/
	
	inline function get_selectedIndex()
	{
		return index;
	}
	
	//TODO invalidate parent layout !!  Find a way to do that
	function set_selectedIndex(p_index:Int):Int
	{
		p_index = Std.int(Math.max(0, Math.min(p_index, mElements.length-1)));// mt.MLib.wrap(p_index, 0, mElements.length - 1);
		//
		if( mReady && selectedIndex == p_index ) return p_index;
		//
		var oldElement = currentElement;
		index = p_index;
		currentElement = mElements[p_index];
		
		this.hLayout = currentElement.hLayout;
		this.vLayout = currentElement.vLayout;
		this.aspect = currentElement.aspect;
		this.config = currentElement.config;
		
		this.contentHeight = currentElement.contentHeight;
		this.contentWidth = currentElement.contentWidth;
		this.contentX = currentElement.contentX;
		this.contentY = currentElement.contentY;
		this.bounds = currentElement.bounds;	
		mReady = true;
		//
		if( onChange != null ) onChange( oldElement, currentElement );
		return selectedIndex;
	}
	
	override public function getElementByName( pName:String ):Null<Element>
	{
		var el = super.getElementByName(pName);
		if( el == null ) 
		{
			el = currentElement.getElementByName(pName);
		}
		return el;
	}
	
	public function getElementAt(p_index):Null<Element>
	{
		return mElements[p_index];
	}
	
	public function getElementIndex(p_element:Element):Int
	{
		return mElements.indexOf(p_element);
	}
	
	public function removeAll()
	{
		while( mElements.length > 0 )
		{
			var e = mElements.pop();
			e.clean();
			if( Std.is(e, IElementContainer) ) cast( e, IElementContainer ).removeAll();
		}
	}
	
	override public function clean()
	{
		for( e in mElements )
			e.clean();
		onChange = null;
		super.clean();
	}
	
	override public function notify()
	{
		if( currentElement != null ) currentElement.notify();
		super.notify();
	}
	
	public function getElements()
	{
		return mElements.copy();
	}
	
	override public function resize( pWidth:Float, pHeight:Float, ?pForceWidth:Null<Float>, ?pForceHeight:Null<Float> )
	{
		if ( disabled ) return;
		mLastWidth 	= pWidth; 
		mLastHeight = pHeight;
		mLastForcedHeight 	= pForceHeight;
		mLastForcedWidth 	= pForceWidth;
		//
		if( currentElement != null )
		{
			currentElement.resize( pWidth, pHeight, pForceWidth, pForceHeight );
		}
	}
	
	public function setActive( p_element:Element ):Void
	{
		selectedIndex = mElements.indexOf(p_element);
	}
	
	public function removeElement(child:Element):Bool
	{
		if( mElements.remove(child) )
		{
			invalidate();
			return true;
		} else {
			return false;
		}
	}
	
	public function addElement (child:Element) : Element 
	{
		return addElementAt(child, mElements.length);
	}
	
	public function addElementAt (child:Element, p_index:Int) : Element
	{
		mElements[p_index] = child;
		child.parent = this;
		if( !mReady && selectedIndex == (mElements.length - 1) )
			selectedIndex = selectedIndex;
		if( !child.disabled )
			invalidate();
		return child;
	}
	
	override public function clone():Element
	{
		var e = new ElementStack();
		e.name = this.name;
		e.parent = this.parent;
		e.config = Reflect.copy(config);
		e.vLayout = this.vLayout;
		e.hLayout = this.hLayout;
		e.aspect = this.aspect;
		e.disabled = this.disabled;
		e.numElements = this.numElements;
		e.mElements = Lambda.array(Lambda.map(mElements, function(elt) {
			var c = elt.clone();
			c.parent = e;
			return c;
		} ));
		
		e.selectedIndex = this.selectedIndex;
		return e;
	}
}
