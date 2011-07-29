/*
 * Copyright (c) 2011, wersling.com All rights reserved.
 */
package net.manaca.loaderqueue.adapter
{
import net.manaca.loaderqueue.ILoaderAdapter;
import net.manaca.loaderqueue.LoaderQueueEvent;

import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;

/**
 * BackupURLLoaderAdapter可以设置两个URL地址，如果一个地址加载错误，
 * 程序将加载第二个地址。本对象一般用于确定服务的稳定性，如果数据服务器出现问题，
 * 我们可以设置一个静态文件路径，以确保最终显示正常。
 * @see net.manaca.loaderqueue#LoaderQueue
 * @author Austin
 * @update sean
 */
public class BackupURLLoaderAdapter extends AbstractLoaderAdapter
    implements ILoaderAdapter
{
    //==========================================================================
    //  Constructor
    //==========================================================================
    /**
     * BackupURLLoaderAdapter
     * @param priority 等级值,数值越小等级越高,越早被下载
     * @param urlRequest 需下载项的url地址
     * @param backupUrlRequest 备份的url地址
     */
    public function BackupURLLoaderAdapter(priority:uint,
                                           urlRequest:URLRequest, 
                                           backupUrlRequest:URLRequest)
    {
        super(priority, urlRequest, null);
        _adaptee = new URLLoader();
        adapteeAgent = _adaptee;
        
        this.backupUrlRequest = backupUrlRequest;
    }
    //==========================================================================
    //  Variables
    //==========================================================================
    private var backupUrlRequest:URLRequest;
    private var isUseBackup:Boolean = false;
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
    
    /**
     * @inheritDoc 
     */
    public function start():void
    {
        preStartHandle();
        try
        {
            if(!isUseBackup)
            {
                adaptee.load(urlRequest);
            }
            else
            {
                if(preventCache)
                {
                    backupUrlRequest.url = 
                        getPreventCacheURL(backupUrlRequest.url);
                }
                adaptee.load(backupUrlRequest);
            }
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
    
    //==========================================================================
    //  Event Handlers
    //==========================================================================
    override protected function container_errorHandler(event:IOErrorEvent):void
    {
        if(!isUseBackup)
        {
            stop();
            isUseBackup = true;
            _adaptee = new URLLoader();
            adapteeAgent = _adaptee;
            start();
        }
        else
        {
            super.container_errorHandler(event);
        }
    }
}
}
