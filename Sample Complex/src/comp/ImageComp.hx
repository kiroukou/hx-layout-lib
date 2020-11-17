package comp;

class ImageComp extends ee.ui.comp.UIComponent
{
    var img:h2d.Bitmap;

    override public function resize(pWidth:Float, pHeight:Float, bounds):Void
    {
        super.resize(pWidth, pHeight, bounds);
        if( img.tile != null ) 
        {
            switch( style.textureMode )
            {
                case Scale:
                    img.tile.scaleToSize(pWidth, pHeight);
                default: 
                    img.tile.setSize(pWidth, pHeight);
            }
        }
    }

    override public function init()
    {
        if( !_isInit ) 
        {
            super.init();
            this.img = new h2d.Bitmap(this);
        }
    }

    override public function applyStyle(style:ee.ui.comp.Style) 
    {
        super.applyStyle(style);
        if(style.texture != null) 
        {
            this.img.tile = hxd.Res.load(style.texture).toTile();

            switch(style.textureMode)
			{
				case Repeat: 
					this.img.tileWrap = true;
				default:	
            }
            
            if( style.color != null ) 
                this.img.color.setColor(style.color);
        }
    }
}