package net.manaca.loaderqueue.inspector
{
import com.bit101.components.Style;

import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import net.manaca.loaderqueue.ILoaderAdapter;
import net.manaca.loaderqueue.LoaderAdapterState;
import net.manaca.loaderqueue.LoaderQueueEvent;
/**
 * @private
 * 一个加载对象的可视化界面.
 * @author wersling
 * 
 */
internal class InspectorItem extends Sprite
{
    //==========================================================================
    //  Class variables
    //==========================================================================
    static private var GLOBEL_INDEX:int = 0;
    //==========================================================================
    //  Constructor
    //==========================================================================
    /**
     * Constructs a new <code>InspectorItem</code> instance.
     * 
     */
    public function InspectorItem(loaderAdapter:ILoaderAdapter)
    {
        _loaderAdapter = loaderAdapter;
        _index = GLOBEL_INDEX++;
        initDisplay();
    }
    
    //==========================================================================
    //  Variables
    //==========================================================================
    private var progressLabel:TextField;
    private var urlTextLabel:TextField;
    private var priorityLabel:TextField;
    //==========================================================================
    //  Properties
    //==========================================================================
    //----------------------------------
    //  index
    //----------------------------------
    private var _index:int;
    /**
     * 被加入的顺序
     * @return 
     * 
     */    
    public function get index():int
    {
        return _index;
    }
    
    //----------------------------------
    //  loaderAdapter
    //----------------------------------
    private var _loaderAdapter:ILoaderAdapter;
    /**
     * 加载对象
     * @return 
     * 
     */    
    public function get loaderAdapter():ILoaderAdapter
    {
        return _loaderAdapter;
    }
    
    //----------------------------------
    //  priority
    //----------------------------------
    /**
     * 优先级
     * @return 
     * 
     */    
    public function get priority():int
    {
        return loaderAdapter.priority;
    }
    
    //----------------------------------
    //  width
    //----------------------------------
    private var _width:Number = 0;
    /**
     * @private 
     */    
    override public function get width():Number
    {
        return _width;
    }
    
    override public function set width(value:Number):void
    {
        if(_width != value)
        {
            _width = value;
            layout();
        }
    }
    
    //----------------------------------
    //  freeze
    //----------------------------------
    private var _freeze:Boolean = true;
    
    internal function get freeze():Boolean
    {
        return _freeze;
    }
    
    internal function set freeze(value:Boolean):void
    {
        _freeze = value;
        if(!freeze)
        {
            layout();
        }
    }
    //==========================================================================
    //  Methods
    //==========================================================================
    /**
     * 初始化界面
     * 
     */    
    private function initDisplay():void
    {
        priorityLabel = createLabel();
        priorityLabel.y = 0;
        priorityLabel.width = 40;
        priorityLabel.text = loaderAdapter.priority.toString();
        var tf:TextFormat = priorityLabel.getTextFormat();
        tf.align = TextFormatAlign.CENTER;
        priorityLabel.setTextFormat(tf);
        addChild(priorityLabel);
        
        progressLabel = createLabel();
        progressLabel.y = 0;
        progressLabel.width = 40;
        addChild(progressLabel);
        
        urlTextLabel = createLabel();
        urlTextLabel.x = priorityLabel.width;
        urlTextLabel.y = 12;
        urlTextLabel.text = loaderAdapter.url;
        addChild(urlTextLabel);
        
        updateProgress();
        
        addEvens();
    }
    
    /**
     * 重新布局
     * 
     */    
    private function layout():void
    {
        if(freeze)
        {
            return;
        }
        progressLabel.x = width - progressLabel.width;
        urlTextLabel.width = width - priorityLabel.width - progressLabel.width;
        updateProgress();
    }
    
    /**
     * 更新加载进度
     * 
     */    
    private function updateProgress():void
    {
        if(freeze)
        {
            return;
        }
        var progress:Number = 0;
        var barColor:uint = 0x98B72E;
        if(loaderAdapter && 
            loaderAdapter.bytesLoaded && loaderAdapter.bytesTotal)
        {
            progress = loaderAdapter.bytesLoaded / loaderAdapter.bytesTotal;
        }
        
        if(loaderAdapter.state == LoaderAdapterState.COMPLETED)
        {
            progress = 1;
        }
        else if(loaderAdapter.state == LoaderAdapterState.ERROR)
        {
            progress = 1;
            barColor = 0xFF0000;
            
        }
        progressLabel.text = int(progress * 100) + "%";
        
        var w:int = 80;
        graphics.clear();
        graphics.beginFill(0x58799C);
        graphics.drawRect(w / 2, 6, width - w, 6);
        graphics.drawRect(w / 2 + 1, 6 + 1, width - w - 2, 6 - 2);
        
        graphics.beginFill(barColor);
        graphics.drawRect(w / 2 + 1, 6 + 1, (width - w - 2) * progress, 6 - 2);
    }
    
    private function createLabel():TextField
    {
        var label:TextField = new TextField();
        label.height = 19;
        label.multiline = false;
        var tf:TextFormat = new TextFormat(Style.fontName, 12, 0x141E26);
        label.defaultTextFormat = tf;
        return label;
    }
    
    private function addEvens():void
    {
        loaderAdapter.addEventListener(LoaderQueueEvent.TASK_START,
            loaderAdapter_taskStartHandler);
        loaderAdapter.addEventListener(LoaderQueueEvent.TASK_PROGRESS,
            loaderAdapter_taskProgressHandler);
        loaderAdapter.addEventListener(LoaderQueueEvent.TASK_COMPLETED,
            loaderAdapter_taskCompletedHandler);
        loaderAdapter.addEventListener(LoaderQueueEvent.TASK_ERROR,
            loaderAdapter_taskErrorHandler);
    }
    
    private function removeEvens():void
    {
        loaderAdapter.removeEventListener(LoaderQueueEvent.TASK_START,
            loaderAdapter_taskStartHandler);
        loaderAdapter.removeEventListener(LoaderQueueEvent.TASK_PROGRESS,
            loaderAdapter_taskProgressHandler);
        loaderAdapter.removeEventListener(LoaderQueueEvent.TASK_COMPLETED,
            loaderAdapter_taskCompletedHandler);
        loaderAdapter.removeEventListener(LoaderQueueEvent.TASK_ERROR,
            loaderAdapter_taskErrorHandler);
    }
    
    /**
     * 销毁该对象
     * 
     */    
    public function dispose():void
    {
        removeEvens();
    }
    
    //==========================================================================
    //  Event Handlers
    //==========================================================================
    private function loaderAdapter_taskStartHandler(event:LoaderQueueEvent):void
    {
        dispatchEvent(new Event(Event.CHANGE));
    }
    
    private function loaderAdapter_taskProgressHandler(event:LoaderQueueEvent):void
    {
        updateProgress();
    }
    
    private function loaderAdapter_taskCompletedHandler(event:LoaderQueueEvent):void
    {
        updateProgress();
        dispatchEvent(new Event(Event.CHANGE));
    }
    
    private function loaderAdapter_taskErrorHandler(event:LoaderQueueEvent):void
    {
        updateProgress();
    }
}
}