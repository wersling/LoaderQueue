/*
 * Copyright (c) 2011, wersling.com All rights reserved.
 */
package net.manaca.loaderqueue.adapter
{
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.system.LoaderContext;

import net.manaca.loaderqueue.ILoaderAdapter;
import net.manaca.loaderqueue.LoaderQueueEvent;

/**
 * 将Loader类包装成可用于LoaderQueue的适配器
 * @see net.manaca.loaderqueue#LoaderQueue
 *
 * @author Austin
 * @update sean
 */
public class LoaderAdapter extends AbstractLoaderAdapter
                            implements ILoaderAdapter
{
    //==========================================================================
    //  Constructor
    //==========================================================================
    /**
     * Constructs a new <code>LoaderAdapter</code> instance.
     *
     */
    public function LoaderAdapter(priority:uint,
                                  urlRequest:URLRequest,
                                  loaderContext:LoaderContext = null)
    {
        super(priority, urlRequest, loaderContext);
    }
    
    

    //==========================================================================
    //  Properties
    //==========================================================================
    //----------------------------------
    //  bytesLoaded
    //----------------------------------
    /**
     * @inheritDoc
     */  
    public function get bytesLoaded():Number
    {
        return adaptee ? adaptee.contentLoaderInfo.bytesLoaded : 0;
    }

    //----------------------------------
    //  bytesTotal
    //----------------------------------
    /**
     * @inheritDoc
     */  
    public function get bytesTotal():Number
    {
        return adaptee ? adaptee.contentLoaderInfo.bytesTotal : 0;
    }

    //----------------------------------
    //  adaptee
    //----------------------------------
    private var _adaptee:Loader;
    /**
     * 返回加载对象具体实例。
     * @return 
     * 
     */  
    public function get adaptee():Loader
    {
        return _adaptee;
    }
    
    /**
     * Contains the root display object of the SWF file or image 
     * (JPG, PNG, or GIF) file that was loaded.
     * @return 
     * 
     */    
    public function get context():DisplayObject
    {
        return adaptee.content;
    }
    //==========================================================================
    //  Methods
    //==========================================================================

    /**
     * 消毁此项目内在引用
     * 调用此方法后，此adapter实例会自动从LoaderQueue中移出
     * p.s: 停止下载的操作LoaderQueue会自动处理
     */
    override public function dispose():void
    {
        stop();
        _adaptee && _adaptee.unloadAndStop();
        super.dispose();
        _adaptee = null;
    }

    /**
     * @inheritDoc
     */ 
    override public function start():void
    {
        _adaptee = new Loader();
        adapteeAgent = _adaptee.contentLoaderInfo;
        preStartHandle();
        try
        {
            adaptee.load(urlRequest, loaderContext);
        }
        catch (error:Error)
        {
            dispatchEvent(
                new LoaderQueueEvent(LoaderQueueEvent.TASK_ERROR, customData));
        }
    }

    /**
     * @inheritDoc
     */ 
    public function stop():void
    {
        preStopHandle();
        try
        {
            adaptee.close();
        }
        catch (error:Error)
        {
            //do nothing
        }
    }
}
}
