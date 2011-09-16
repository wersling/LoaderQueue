/*
 * Copyright (c) 2011, wersling.com All rights reserved.
 */
package net.manaca.loaderqueue.adapter
{
import flash.events.ProgressEvent;
import flash.net.URLRequest;
import flash.net.URLStream;

import net.manaca.loaderqueue.ILoaderAdapter;
import net.manaca.loaderqueue.LoaderQueueEvent;

/**
 * 将URLStream类包装成可用于LoaderQueue的适配器
 * @see net.manaca.loaderqueue#LoaderQueue
 * @author Austin
 * @update sean
 */
public class URLStreamAdapter extends AbstractLoaderAdapter implements ILoaderAdapter
{
    /**
     * 构造函数.
     * @param priority 等级值,数值越小等级越高,越早被下载
     * @param urlRequest 需下载项的url地址
     * 
     */    
    public function URLStreamAdapter(priority:uint,
                                     urlRequest:URLRequest)
    {
        super(priority, urlRequest);
    }


    //==========================================================================
    //  Properties
    //==========================================================================
    //----------------------------------
    //  bytesLoaded
    //----------------------------------
    private var _bytesLoaded:Number = 0;
    /**
     * @inheritDoc
     */  
    public function get bytesLoaded():Number
    {
        return _bytesLoaded;
    }

    //----------------------------------
    //  bytesTotal
    //----------------------------------
    private var _bytesTotal:Number = 0;
    /**
     * @inheritDoc
     */
    public function get bytesTotal():Number
    {
        return _bytesTotal;
    }
    
    //----------------------------------
    //  adaptee
    //----------------------------------
    private var _adaptee:URLStream;
    /**
     * 返回加载对象具体实例。
     * @return 
     * 
     */    
    public function get adaptee():URLStream
    {
        return _adaptee;
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
        _adaptee = new URLStream();
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
    //==========================================================================
    //  Event Handlers
    //==========================================================================
    /**
     * @inheritDoc
     */ 
    override protected function container_progressHandler(
        event:ProgressEvent):void
    {
        super.container_progressHandler(event);
        _bytesLoaded = event.bytesLoaded;
        _bytesTotal = event.bytesTotal;
    }
}
}
