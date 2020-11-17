package ee.ui.comp;

@:keep
@:keepSub
class UIComponent extends h2d.Object implements ee.ui.layout.Resizable
{
    var _isInit:Bool = false;
    var background:Background;
    var inter : h2d.Interactive;
    var style:Style;
    var layout:ee.ui.layout.Element;

    public function resize(pWidth:Float, pHeight:Float, bounds):Void
    {
        background.resize(pWidth, pHeight, bounds);
        if( inter != null )
        {
            inter.width = pWidth;
            inter.height = pHeight;
        }
    }

    public function init()
    {
        if( _isInit ) return;
        background = new Background(this);
        if( layout.script.content != null ) 
            setInteractive(true);

        _isInit = true;
    }

    public function applyStyle(style:ee.ui.comp.Style) {
        this.style = style;
        background.applyStyle(style);
        //if( style.)
    }

    function setInteractive(b:Bool)
    {
        if( inter != null && inter.visible == b ) return;
        if( !b ) inter.remove();
        else
        {
            inter = new h2d.Interactive(layout.width, layout.height, this);
            inter.onClick = onClick;
            inter.onOut = onOut;
            inter.onOver = onOver;
            inter.onPush = onPush;
            inter.onRelease = onRelease.bind(_, false);
            inter.onReleaseOutside = onRelease.bind(_, true);
        }
    }

    function onClick(e:hxd.Event)
    {
        @:privateAccess layout.callScript("onClick");
    }
    function onRelease(e:hxd.Event, outside:Bool) 
    {
        @:privateAccess layout.callScript("onRelease");
    }
    function onOver(e:hxd.Event)
    {
        @:privateAccess layout.callScript("onOver");
    }
    function onOut(e:hxd.Event) 
    {
        @:privateAccess layout.callScript("onOut");
    }
    function onPush(e:hxd.Event) 
    {
        @:privateAccess layout.callScript("onPush");
    }

/* ==========================  HELPERS  ==================================*/
/*
    //
	// The shape will be scaled to fit the destination sizes keeping its original ratio
	// The shape will fit AT MAXIMUM the targeted rectangle
	//
	public function fitIn( p_width:Float, p_height:Float ):UIComponent
    {
        var bounds = this.getBounds(this.parent);

        var ratio = bounds.width / bounds.height;
        if ( Math.isNaN(ratio) ) ratio = 1.0;

        if(p_width / ratio > p_height)
        {
            resize(p_height * ratio, p_height);
        }
        else
        {
            resize(p_width, p_width / ratio);
        }
        return this;
    }

    //
	// The shape will be scaled to fit the destination sizes keeping its original ratio
	// The shape will fit AT MINIMUM the targeted rectangle, meaning the the resulting shape may exeed targeted width or height depending on original ratio
	//
	public function fitOut( p_width:Float, p_height:Float):UIComponent
    {
        var bounds = this.getBounds(this.parent);
        var ratio = bounds.width / bounds.height;
        if ( Math.isNaN(ratio) ) ratio = 1.0;

        if(p_width / ratio < p_height)
        {
            resize(p_height * ratio, p_height);
        }
        else
        {
            resize(p_width, p_width / ratio);
        }
        return this;
    }
*/
}