package ee.ui.comp;

import hxd.res.FontBuilder;
import h2d.Text.Align;

class Text extends UIComponent
{
	public static var DEFAULT_FONT_SIZE = 24;
	var lbl : h2d.Text;
	var fontSize : Int;
	
	override public function init()
	{
		if( !_isInit ) 
		{
			super.init();
			fontSize = DEFAULT_FONT_SIZE;
			lbl = new h2d.Text(hxd.res.DefaultFont.get(), this);
			setText('');
		}
	}

	public function setText(t:String)
	{
		lbl.text = t;
	}
	
	override public function resize(w : Float, h : Float, bounds)
	{
		super.resize(w, h, bounds);
		lbl.constraintSize(w, h);
		lbl.maxWidth = w;
		//lbl.x = (w - lbl.textWidth) / 2;
		//lbl.y = (h - lbl.textHeight) / 2;
	}

	override public function applyStyle(style:ee.ui.comp.Style) 
	{
		super.applyStyle(style);

		if( style.textColor != null )
			lbl.textColor = style.textColor;
		
		if( style.fontName != null )
			lbl.font = FontBuilder.getFont(style.fontName, fontSize);
			//lbl.font = new hxd.res.Font(hxd.Res.load(style.fontName));

		if(style.fontSize != null )
			fontSize = style.fontSize;

		lbl.font.resizeTo( fontSize );
		
		if( style.textAlign != null )
		{
			switch(style.textAlign)
			{
				case Left: lbl.textAlign = Align.Left;
				case Center:  lbl.textAlign = Align.Center;
				case Right:  lbl.textAlign = Align.Right;
			}
		}
	}

}