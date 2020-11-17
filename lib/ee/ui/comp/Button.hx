package ee.ui.comp;

class Button extends UIComponent
{
	public static var DEFAULT_FONT_SIZE = 24;
	var label : h2d.Text;
	var fontSize : Int;

	override public function init()
	{
		if( !_isInit ) 
		{
			super.init();
			fontSize = DEFAULT_FONT_SIZE;
			this.label = new h2d.Text(hxd.res.DefaultFont.get(), this);
			setInteractive(true);
		}
	}

	override function onOut(e) {
		super.onOut(e);
		this.background.applyStyle(cast style);
	}

	override function onOver(e) {
		super.onOver(e);
		this.background.applyStyle(cast style.states.hover);
	}

	override function onClick(e) {
		super.onClick(e);
	}

	override function onPush(e) {
		super.onPush(e);
		this.background.applyStyle(cast style.states.click);
	}

	public function setLabel(t:String)
	{
		this.label.text = t;
	}
	
	override public function resize(w : Float, h : Float, bounds) {
		super.resize(w, h, bounds);
		label.constraintSize(w, h);
		label.maxWidth = w;
	}

	override public function applyStyle(style:ee.ui.comp.Style) 
	{
		super.applyStyle(style);
		if( style.textColor != null )
			label.textColor = style.textColor;
		
	//	if( style.fontName != null )
	//		label.font = hxd.res.FontBuilder.getFont(style.fontName, fontSize);
	//

	//	if(style.fontSize != null )
	//		fontSize = style.fontSize;

		
		if( style.textAlign != null )
		{
			switch(style.textAlign)
			{
				case Left: label.textAlign = h2d.Text.Align.Left;
				case Center:  label.textAlign = h2d.Text.Align.Center;
				case Right:  label.textAlign = h2d.Text.Align.Right;
			}
		}

	}

}