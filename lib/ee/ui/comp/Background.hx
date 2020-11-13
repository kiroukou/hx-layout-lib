package ee.ui.comp;

class Background extends h2d.Layers implements ee.ui.comp.Resizable
{
	var outline:h2d.Bitmap;
	var background:h2d.Bitmap;
	var style:Style;
	var w:Float;
	var h:Float;
	
	public function new(?pParent:h2d.Object) 
	{
		super(pParent);
		this.name = pParent.name+"#background";
		create();
	}
	
	function create()
	{
		outline = new h2d.Bitmap(this);
		background = new h2d.Bitmap(this);
		outline.visible = false;
		background.visible = false;
	}
	
	function adjustThickness(pThickness:Int)
	{
		background.x = background.y = pThickness;
		background.tile.setSize(w - 2 * pThickness, h - 2 * pThickness);
	}
	
	public function applyStyle( pStyle:Style )
	{
		if ( style == null || pStyle.outlineColor != style.outlineColor )
		{
			if ( pStyle.outlineColor != null ) 
			{
				outline.visible = true;
				outline.tile = h2d.Tile.fromColor(pStyle.outlineColor);
			}
			else
			{
				outline.visible = false;
			}
		}
		if ( style == null || pStyle.backgroundColor != style.backgroundColor )
		{
			if ( pStyle.backgroundColor != null )
			{
				background.tile = h2d.Tile.fromColor(pStyle.backgroundColor);
				background.visible = true;
			}
			else
			{
				background.visible = false;
			}
		}
		
		if ( style == null || pStyle.outlineThickness != style.outlineThickness )
			adjustThickness(pStyle.outlineThickness);
		
		style = Reflect.copy(pStyle);
	}
	
	public function resize(pWidth:Float, pHeight:Float):Void
	{
		w = pWidth;
		h = pHeight;
		if( outline.tile != null )
		{
			outline.tile.setSize(w, h);
		}
		
		if( style != null ) 
			adjustThickness(style.outlineThickness);
	}
}