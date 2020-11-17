package ee.ui.comp;

import h3d.shader.Base2d;
import h3d.mat.Texture;
import h2d.Tile;
import h3d.impl.NullDriver;
using Std;

class Background extends h2d.Layers implements ee.ui.layout.Resizable
{
	var outline:h2d.Bitmap;
	var background:h2d.Bitmap;
	var w:Float;
	var h:Float;
	var thickness:Null<Int>;
	var style:Style;
	
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
		//outer outline implementation
		outline.x = outline.y = -pThickness;
		if( outline.tile != null )
		{
			outline.tile.setSize(w + 2 * pThickness, h + 2*pThickness);
		}
	}
	
	public function applyStyle( pStyle:Style )
	{
		this.style = pStyle;
		//
		if ( pStyle.outlineColor != null ) 
		{
			outline.visible = true;
			outline.tile = h2d.Tile.fromColor(pStyle.outlineColor, w.int(), h.int());
		}
		else
		{
			outline.visible = false;
		}

		if ( pStyle.backgroundTexture != null )
		{
			var t = hxd.Res.load(pStyle.backgroundTexture).toTile();
			switch(pStyle.backgroundTextureMode)
			{
				case Repeat: 
					background.tileWrap = true;
				default:
			}
			
			background.tile = t;
			background.visible = true;
		}
		else if ( pStyle.backgroundColor != null )
		{
			background.tile = h2d.Tile.fromColor(pStyle.backgroundColor, w.int(), h.int());
			background.visible = true;
		}
		else
		{
			background.visible = false;
		}

		thickness = null;
		if( pStyle.outlineThickness != null ) 
			thickness = pStyle.outlineThickness;
	}
	
	public function resize(pWidth:Float, pHeight:Float, bounds):Void
	{
		w = pWidth;
		h = pHeight;
		if( background.tile != null )
		{
			switch(style.backgroundTextureMode)
			{
				case Scale:
					background.tile.scaleToSize(w, h);
				default:
					background.tile.setSize(w, h);
			}
		}
		
		if( thickness != null ) 
			adjustThickness(thickness);
	}
}