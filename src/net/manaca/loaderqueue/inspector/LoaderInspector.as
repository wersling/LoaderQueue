package net.manaca.loaderqueue.inspector
{
import com.bit101.components.CheckBox;
import com.bit101.components.ScrollPane;
import com.bit101.components.Style;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.system.Capabilities;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.ui.Keyboard;
import flash.utils.Dictionary;

import net.manaca.loaderqueue.ILoaderAdapter;
import net.manaca.loaderqueue.ILoaderQueue;
import net.manaca.loaderqueue.LoaderQueueConst;
import net.manaca.loaderqueue.LoaderQueueEvent;

/**
 * 提供一个可视化界面用户查看加载队列进行情况.
 * @author wersling
 * 
 */
public class LoaderInspector extends Sprite
{
    //==========================================================================
    //  Constructor
    //==========================================================================
    /**
     * Constructs a new <code>LoaderInspector</code> instance.
     * @param loaderQueue 需要监视的加载队列.
     * 
     */    
    public function LoaderInspector(loaderQueue:ILoaderQueue = null)
    {
        super();
        
        this.loaderQueue = loaderQueue;
        
        initDisplay();
    }
    
    //==========================================================================
    //  Variables
    //==========================================================================
    private var scrollPane:ScrollPane;
    private var container:DisplayObjectContainer;
    private var onlyButton:CheckBox;
    private var itemsMap:Dictionary = new Dictionary(true);
    
    private var parentContainer:DisplayObjectContainer;
    //==========================================================================
    //  Properties
    //==========================================================================
    private var _loaderQueue:ILoaderQueue;
    /**
     * 需要监视的加载队列.
     * @return 
     * 
     */    
    public function get loaderQueue():ILoaderQueue
    {
        return _loaderQueue;
    }

    public function set loaderQueue(value:ILoaderQueue):void
    {
        if(_loaderQueue && _loaderQueue != value)
        {
            removeEvents();
            clearAllTask();
        }
        
        _loaderQueue = value;
        if(_loaderQueue)
        {
            addEvents();
        }
    }
    
    private var _height:Number = 0;
    /**
     * @private 
     */    
    override public function get height():Number
    {
        return _height;
    }
    override public function set height(value:Number):void
    {
        _height = value;
        layout();
    }
    
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
        _width = value;
        layout();
    }
    
    //----------------------------------
    //  freeze
    //----------------------------------
    private var _freeze:Boolean = true;
    /**
     * 是否冻结，如果冻结，则不更新界面.
     * @return 
     * 
     */
    protected function get freeze():Boolean
    {
        return _freeze;
    }

    protected function set freeze(value:Boolean):void
    {
        if(_freeze != value)
        {
            _freeze = value;
            for each (var item:InspectorItem in itemsMap) 
            {
                item.freeze = freeze;
            }
            
            if(!freeze)
            {
                layout();
            }
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
        addEventListener(Event.ADDED_TO_STAGE,
            addedToStageHandler);
        
        var titleLabel:TextField = new TextField();
        titleLabel.autoSize = "left";
        titleLabel.selectable = false;
        titleLabel.text = "LoaderInspector v0.1";
        titleLabel.x = 5;
        titleLabel.y = 3;
        var tf:TextFormat = new TextFormat(Style.fontName, 12, 0x000000, true);
        titleLabel.setTextFormat(tf);
        addChild(titleLabel);
        
        container = new Sprite();
        addChild(container);
        onlyButton = new CheckBox(this, 20, 8, 
            "Only Progressing", onlyProgressingItems);
        scrollPane = new ScrollPane(this, 5, 25);
        scrollPane.content.addChild(container);
        scrollPane.autoHideScrollBar = true;
    }
    
    /**
     * 添加队列事件
     * 
     */    
    private function addEvents():void
    {
        loaderQueue.addEventListener(LoaderQueueEvent.TASK_ADDED,
            loaderQueue_taskAddedHandler);
        loaderQueue.addEventListener(LoaderQueueEvent.TASK_REMOVED,
            loaderQueue_taskRemovedHandler);
    }
    
    /**
     * 删除队列事件
     * 
     */    
    private function removeEvents():void
    {
        loaderQueue.removeEventListener(LoaderQueueEvent.TASK_ADDED,
            loaderQueue_taskAddedHandler);
        loaderQueue.removeEventListener(LoaderQueueEvent.TASK_REMOVED,
            loaderQueue_taskRemovedHandler);
    }
    
    /**
     * 重新布局，调整UI
     * 
     */    
    private function layout():void
    {
        if(freeze)
        {
            return;
        }
        graphics.clear();
        graphics.beginFill(0x141E26);
        graphics.drawRect(0, 0, width, height);
        graphics.drawRect(1, 1, width - 2, height - 2);
        graphics.beginFill(0xC3E8FC, 1);
        graphics.drawRect(1, 1, width - 2, height - 2);
        
        for each (var item:InspectorItem in itemsMap) 
        {
            item.width = width - 20;
        }
        sortItemY();
        
        onlyButton.x = width - 140;
        scrollPane.width = width - 10;
        scrollPane.height = height - 30;
        scrollPane.update();
    }
    
    /**
     * 对队列中的加载对象进行排序
     * 
     */    
    private function sortItemY():void
    {
        if(freeze)
        {
            return;
        }
        var cy:int = 5;
        var items:Array = [];
        for each (var item:InspectorItem in itemsMap) 
        {
            //判断是否只显示正在加载的对象
            if(onlyButton.selected)
            {
                if(item.loaderAdapter.state == LoaderQueueConst.STATE_STARTED)
                {
                    items.push(item);
                }
                else if(container.contains(item))
                {
                    container.removeChild(item);
                }
            }
            else
            {
                items.push(item);
            }
        }
        
        //排序
        items.sortOn(["priority", "index"]);
        
        //调整位置
        for each (item in items) 
        {
            container.addChild(item);
            item.y = cy;
            cy += 35;
        }
    }
    
    /**
     * 销毁该对象
     * 
     */    
    public function dispose():void
    {
        if(loaderQueue)
        {
            removeEvents();
            clearAllTask();
        }
    }
    
    /**
     * 清除所有加载对象
     * 
     */    
    private function clearAllTask():void
    {
        for each (var item:InspectorItem in itemsMap) 
        {
            removeTask(item.loaderAdapter);
        }
    }
    
    /**
     * 添加一个加载对象
     * @param loaderAdapter
     * 
     */    
    private function addTask(loaderAdapter:ILoaderAdapter):void
    {
        if(loaderAdapter)
        {
            var item:InspectorItem = new InspectorItem(loaderAdapter);
            item.addEventListener(Event.CHANGE,
                item_completeHandler);
            item.width = width - 20;
            item.freeze = freeze;
            itemsMap[loaderAdapter] = item;
            
            sortItemY();
            scrollPane.update();
        }
    }
    
    /**
     * 删除一个加载对象
     * @param loaderAdapter
     * 
     */    
    private function removeTask(loaderAdapter:ILoaderAdapter):void
    {
        if(loaderAdapter && itemsMap[loaderAdapter])
        {
            var item:InspectorItem = itemsMap[loaderAdapter];
            item.removeEventListener(Event.CHANGE,
                item_completeHandler);
            item.dispose();
            itemsMap[loaderAdapter] = null;
            
            sortItemY();
            scrollPane.update();
        }
    }
    //==========================================================================
    //  Event Handlers
    //==========================================================================
    protected function addedToStageHandler(event:Event):void
    {
        freeze = false;
        parentContainer = parent;
        stage.addEventListener(Event.RESIZE, resizeHandler);
        stage.addEventListener(Event.REMOVED_FROM_STAGE,
            removeFromStageHandler);
        stage.addEventListener(KeyboardEvent.KEY_UP, shortcutKey);
        resizeHandler(null);
    }
    
    private function removeFromStageHandler():void
    {
        freeze = true;
        stage.removeEventListener(Event.RESIZE, resizeHandler);
        stage.removeEventListener(Event.REMOVED_FROM_STAGE,
            removeFromStageHandler);
    }
    
    protected function resizeHandler(event:Event):void
    {
        width = Math.min(stage.stageWidth, 600);
        height = stage.stageHeight;
        x = int((stage.stageWidth - width)/2);
    }
    
    private function loaderQueue_taskAddedHandler(event:LoaderQueueEvent):void
    {
        addTask(ILoaderAdapter(event.customData));
    }
    
    private function loaderQueue_taskRemovedHandler(event:LoaderQueueEvent):void
    {
        removeTask(ILoaderAdapter(event.customData));
    }
    
    private function item_completeHandler(event:Event):void
    {
        if(onlyButton.selected)
        {
            sortItemY();
        }
    }
    
    /**
     * 更新是否仅仅显示真正加载的对象.
     * @param event
     * 
     */    
    private function onlyProgressingItems(event:Event):void
    {
        sortItemY();
        scrollPane.update();
    }
    
    /**
     * shortcutKey handler.
     * @param e
     */
    private function shortcutKey(event:KeyboardEvent):void
    {
        var effective:Boolean = false;
        if (event.shiftKey && event.altKey && event.ctrlKey && 
            event.keyCode == Keyboard.L)
        {
            effective = true;
        }
        
        if (Capabilities.os.toLowerCase().indexOf("mac") != -1)
        {
            if (event.shiftKey && event.ctrlKey && event.keyCode == Keyboard.L)
            {
                effective = true;
            }
        }
        
        if (effective)
        {
            if (parent && parent.contains(this))
            {
                parent.removeChild(this);
            }
            else if(parentContainer)
            {
                parentContainer.addChild(this);
            }
        }
    }
}
}
