/*
 * Copyright (c) 2011, wersling.com All rights reserved.
 */
package net.manaca.loaderqueue.adapter
{
import net.manaca.loaderqueue.ILoaderAdapter;
import net.manaca.loaderqueue.LoaderQueueEvent;

import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.LoaderContext;

/**
 * 将URLLoader类包装成可用于LoaderQueue的适配器
 * @see net.manaca.loaderqueue#LoaderQueue
 * @author Austin
 * @update sean
 */
public class URLLoaderAdapter extends AbstractLoaderAdapter
                                implements ILoaderAdapter
{
    //==========================================================================
    //  Constructor
    //==========================================================================
    /**
     * URLLoader适配器
     * @param priority 等级值,数值越小等级越高,越早被下载
     * @param urlRequest 需下载项的url地址
     */
    public function URLLoaderAdapter(priority:uint,
                                     urlRequest:URLRequest)
    {
        super(priority, urlRequest, null);
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
        return adaptee ? adaptee.bytesLoaded : 0;
    }
    
    //----------------------------------
    //  bytesTotal
    //----------------------------------
    /**
     * @inheritDoc
     */  
    public function get bytesTotal():Number
    {
        return adaptee ? adaptee.bytesTotal : 0;
    }
    
    //----------------------------------
    //  adaptee
    //----------------------------------
    private var _adaptee:URLLoader;
    /**
     * 返回加载对象具体实例。
     * @return 
     * 
     */  
    public function get adaptee():URLLoader
    {
        return _adaptee;
    }
    
    /**
     * The data received from the load operation.
     * @return 
     * 
     */    
    public function get data():*
    {
        return adaptee.data;
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
        super.dispose();
        _adaptee = null;
    }

    /**
     * @inheritDoc
     */ 
    override public function start():void
    {
        _adaptee = new URLLoader();
        adapteeAgent = _adaptee;
        preStartHandle();
        try
        {
            adaptee.load(urlRequest);
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
