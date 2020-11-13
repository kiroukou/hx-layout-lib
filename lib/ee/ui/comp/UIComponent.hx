package ee.ui.comp;


class UIComponent extends h2d.Object implements Resizable
{
    var _isInit:Bool;

    public var background:Background;
    public var view:h2d.Object;

    var interp:hscript.Interp;
    var parser:hscript.Parser;

    var rawScript:String;
    var rawStyle:String;

    public function new(parent:h2d.Object, ?p_view) 
    {
        super(parent);
        interp = new hscript.Interp();
        parser = new hscript.Parser();
        _isInit = false;

        background = new Background(this);
        if( p_view != null ) this.view = p_view;
    }

    public function resize(pWidth:Float, pHeight:Float):Void
    {
        background.resize(pWidth, pHeight);
        //TODO, do that for view !
        callScriptFn("onResize");
    }

    public function init()
    {
        if( _isInit ) return;
        _isInit = true;
        callScriptFn("onInit");
    }

    function callScriptFn(fnName:String) {
        if( interp == null ) return;
        var cb = interp.variables.get(fnName);
        if( cb != null ) cb();
    }

    public function update(dt) 
    {
        callScriptFn("onUpdate");
    }

    public function applyStyle(style:ee.ui.comp.Style) {
        background.applyStyle( style);
    }

    public function parseStyle(styleContent:String) {
        styleContent = StringTools.trim(styleContent);
        if( this.rawStyle == styleContent ) return;
        this.rawStyle = styleContent;
        //TODO not what should be done I guess..
        if( this.rawStyle == null || this.rawStyle.length == 0 ) return;
        applyStyle(ee.ui.comp.Style.StyleParser.parse(styleContent));
    }

    public function parseScript(scriptContent:String) {
        scriptContent = StringTools.trim(scriptContent);
        if( this.rawScript == scriptContent ) return;
        this.rawScript = scriptContent;
        //TODO not what should be done I guess..
        if( this.rawScript == null || this.rawScript.length == 0 ) return; 
        //
        var program = parser.parseString(scriptContent);
		interp.variables.set("trace", function(msg:String) {
			trace("LOG(#"+this.name+") "+ msg);
        });
        interp.variables.set("this", this);
		
		try {
			interp.execute(program);
		} catch( e: hscript.Expr.Error ) {
			trace("Runtime Error "+this.name+":"+parser.line);
			trace(e);
		} catch( e: Dynamic ) {
			trace("Unknown Runtime Error "+this.name+":"+parser.line);
			trace(e);
		}
    }

    /**
	 * The shape will be scaled to fit the destination sizes keeping its original ratio
	 * The shape will fit AT MAXIMUM the targeted rectangle
	 */
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

    /**
	 * The shape will be scaled to fit the destination sizes keeping its original ratio
	 * The shape will fit AT MINIMUM the targeted rectangle, meaning the the resulting shape may exeed targeted width or height depending on original ratio
	 */
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

}