package ee.ui.layout;

import ee.ui.layout.Element;

/**
* Children of this box are aligned relative to box bounds
*/
class CanvasLayout extends Element implements IElementContainer
{	
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
	
	public var numElements(get, null):Int;
	inline function get_numElements():Int
	{
		return mElements.length;
	}
	
	var mElements:Array<Element>;
	public function new(pWidth:String, pHeight:String, ?pHorizontalLayout:HLayoutKind=null, ?pVerticalLayout:VLayoutKind=null, ?pAspect:AspectKind=null)
	{
		super(pWidth, pHeight, pHorizontalLayout, pVerticalLayout, pAspect);
		mElements = new Array();
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
		super.clean();
	}

	override public function getElementByName( pName:String ):Null<Element>
	{
		var el = super.getElementByName(pName);
		if ( el == null ) 
		{
			for ( e in mElements )
			{
				var t = e.getElementByName(pName);
				if ( t != null )
				{
					el = t; break;
				}
			}
		}
		return el;
	}
	
	override public function clone():Element
	{
		var e = new CanvasLayout("1", "1");
		e.name = this.name;
		e.parent = this.parent;
		e.style = Reflect.copy(style);
		e.vLayout = this.vLayout;
		e.hLayout = this.hLayout;
		e.aspect = this.aspect;
		e.disabled = this.disabled;
		e.hChildrenLayout = this.hChildrenLayout;
		e.vChildrenLayout = this.vChildrenLayout;
		e.mElements = Lambda.array(Lambda.map(mElements, function(elt) {
			var c = elt.clone();
			c.parent = e;
			return c;
		} ));
		return e;
	}
	
	public function getElements()
	{
		return mElements.copy();
	}
	
	override public function refresh()
	{
		if ( invalidated )
		{
			for( e in mElements )
			{
				if( e.disabled ) continue;
				e.resize( contentWidth, contentHeight );
			}
		}
		
		for ( e in mElements )
			e.refresh();
		
		super.refresh();
	}
	
	public function addElement (child:Element) : Element 
	{
		return addElementAt(child, mElements.length);
	}
	
	public function addElementAt (child:Element, p_index:Int) : Element
	{
		mElements[p_index] = child;
		child.parent = this;
		if( !child.disabled )
			invalidate();
		return child;
	}
	
	public function removeElement(child:Element):Bool
	{
		if( mElements.remove(child) )
		{
			if( !child.disabled )
				invalidate();
			return true;
		} else {
			return false;
		}
	}
}
