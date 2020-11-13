package ee.ui.layout;

import ee.ui.layout.Element;

interface IElementContainer
{
	var onUpdate : Void->Void;
	var onDisabled : Void->Void;

//	function eval():Void;
	
	function addElement (child:Element) : Element; 
	
	function addElementAt (child:Element, p_index:Int) : Element; 
	
	function getElementByName( pName:String ):Null<Element>;
	
	function getElements():Iterable<Element>;
	
	function getElementIndex(p_element:Element):Int;
	
	function invalidate():Void;
	
	function getElementAt(p_index:Int):Null<Element>;
	
	function removeAll():Void;
	
	function removeElement(child:Element):Bool;
	
	function refresh():Void;
	
	function resize( pWidth:Float, pHeight:Float, ?pForceWidth:Null<Float>, ?pForceHeight:Null<Float> ):Void;
	
	function clean():Void;
	
	function notify():Void;

	var numElements(get, null):Int;
	
	var name:String;
	var root(default, null):Null<IElementContainer>;
	var hLayout:HLayoutKind;
	var vLayout:VLayoutKind;
	
	var hChildrenLayout(default, set):HLayoutKind;
	var vChildrenLayout(default, set):VLayoutKind;
	
	var globalX(get, null):Float;
	var globalY(get, null):Float;
	
	var x(default, null):Float;
	var y(default, null):Float;
	
	var width(default, null):Float;
	var height(default, null):Float;
	var bounds(default, null): Bounds;
}