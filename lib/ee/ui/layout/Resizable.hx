package ee.ui.layout;

interface Resizable
{
	public function resize(pWidth:Float, pHeight:Float, bounds:{x:Float, y:Float, width:Float, height:Float}):Void;
}