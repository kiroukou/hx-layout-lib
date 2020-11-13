package ee.ui.comp;

class Button extends h2d.Sprite
{
	public var inter : h2d.Interactive;
	public var lbl : h2d.Text;
	var bg  : h2d.Graphics;
	var colorMain : Int;
	var colorDark : Int;
	
	//@:getter(width)
	override function get_width():Float 
	{
		return width;
	}
	
	//@:setter(width)
	override function set_width(value:Float):Float 
	{
		return width = value;
	}
	
	//@:getter(height)
	override function get_height():Float 
	{
		return height;
	}
	
	//@:setter(height)
	override function set_height(value:Float):Float 
	{
		return height = value;
	}
	
	public function new(color : Int, text : String, ?p) {
		super(p);
		colorMain = color;
		
		var cd = new h3d.Vector();
		cd.setColor(colorMain);
		colorDark = Style.darken(cd).toColor();
		
		bg  = new h2d.Graphics(this);
		lbl = new h2d.Text(Assets.FONT_MEDIUM, this);
		lbl.text = text;
		
		width = 100;
		height = 24;
		
		inter = new h2d.Interactive(0, 0, this);
		inter.onRelease = function(_) {
			if(inter.visible) SoundsManager.play(UI_BUTTON_CLICK);
		}
	}
	
	public function resize(w : Float, h : Float) {
		width  = w;
		height = h;
		
		inter.width = w;
		inter.height = h;

		bg.clear();
		bg.beginFill(colorMain);
		bg.drawRect(0, 0, w, h);
		bg.endFill();
		
		bg.beginFill(colorDark);
		bg.drawRect(0, h - Style.gutterSize, w, Style.gutterSize);
		bg.endFill();
		
		lbl.x = (w - lbl.textWidth) / 2;
		lbl.y = (h - lbl.textHeight - Style.gutterSize) / 2;
	}
	
	public function setColor(color : Int) {
		var cd = new h3d.Vector();
		colorMain = color;
		cd.setColor(colorMain);
		colorDark = Style.darken(cd).toColor();
		resize(width, height);
	}
}