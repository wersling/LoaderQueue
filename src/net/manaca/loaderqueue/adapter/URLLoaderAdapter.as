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
        _adaptee = new URLLoader();
        adapteeAgent = _adaptee;
    }

    //==========================================================================
    //  Properties
    //==========================================================================
    public function get bytesLoaded():Number
    {
        return adaptee.bytesLoaded;
    }

    public function get bytesTotal():Number
    {
        return adaptee.bytesTotal;
    }
    
    //----------------------------------
    //  adaptee
    //----------------------------------
    private var _adaptee:URLLoader;
    /**
     * @private
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
    public function get date():*
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

    public function start():void
    {
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
