package net.manaca.loaderqueue
{
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.clearInterval;
import flash.utils.setInterval;

/**
 * 任务队列总进度更新时派发
 * @eventType flash.events.Event.CHANGE
 */
[Event(name="change", type="flash.events.Event")]
/**
 * 任务队列完成时派发
 * @eventType flash.events.Event.COMPLETE
 */
[Event(name="complete", type="flash.events.Event")]

/**
 * 用于计算一个加载集合和总进度.
 * @author Sean Zou
 * 
 */
public class LoaderProgress extends EventDispatcher
{
    //==========================================================================
    //  Constructor
    //==========================================================================
    /**
     * 构造函数.
     * 
     */
    public function LoaderProgress()
    {
    }
    //==========================================================================
    //  Variables
    //==========================================================================
    private var items:Array = [];
    private var isStart:Boolean = false;
    private var updateInterval:int;
    //==========================================================================
    //  Properties
    //==========================================================================
    private var _totalProgress:Number;
    /**
     * 总进度
     * @return 
     * 
     */    
    public function get totalProgress():Number
    {
        return _totalProgress;
    }
    //==========================================================================
    //  Methods
    //==========================================================================
    /**
     * 添加一个需要计算的下载对象
     * @param loaderAdapter
     * 
     */    
    public function addItem(loaderAdapter:ILoaderAdapter):void
    {
        if(items.indexOf(loaderAdapter) == -1)
        {
            items.push(loaderAdapter);
            
            if(isStart)
            {
                update();
            }
        }
    }
    
    /**
     * 删除一个需要计算的下载对象
     * @param loaderAdapter
     * 
     */   
    public function removeItem(loaderAdapter:ILoaderAdapter):void
    {
        var index:int = items.indexOf(loaderAdapter);
        if(index != -1)
        {
            items.splice(index, 1);
            if(isStart)
            {
                update();
            }
        }
    }
    
    /**
     * 开始计算
     * 
     */    
    public function start():void
    {
        updateInterval = setInterval(update, 100);
        isStart = true;
    }
    
    /**
     * 结束计算
     * 
     */    
    public function stop():void
    {
        clearInterval(updateInterval);
        isStart = false;
    }
    
    /**
     * 销毁该对象
     * 
     */    
    public function dispose():void
    {
        stop();
        items = null;
    }
    
    /**
     * 更新进度
     * @private
     */    
    private function update():void
    {
        var itemsLen:int = items.length;
        var loader:ILoaderAdapter;
        var tp:Number = 0;
        for (var i:int = 0; i < itemsLen; i++) 
        {
            loader = items[i];
            if(!isNaN(loader.bytesLoaded / loader.bytesTotal))
            {
                tp += loader.bytesLoaded / loader.bytesTotal;
            }
        }
        _totalProgress = tp / itemsLen;
        dispatchEvent(new Event(Event.CHANGE));
        if(_totalProgress == 1 || itemsLen == 0)
        {
            dispatchEvent(new Event(Event.COMPLETE));
            stop();
        }
    }
}
}