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
     * 构造函数.
     * @param priority 等级值,数值越小等级越高,越早被下载
     * @param urlRequest 需下载项的url地址
     * @param backupUrlRequest 备份的url地址
     */
    public function BackupURLLoaderAdapter(priority:uint,
                                           urlRequest:URLRequest, 
                                           backupUrlRequest:URLRequest)
    {
        super(priority, urlRequest, null);
        
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
    
    //----------------------------------
    //  date
    //----------------------------------
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
     * 消毁此对象内在引用
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
    override protected function container_errorHandler(event:IOErrorEvent):void
    {
        //如果不是采用备用地址，则开始加载备用地址数据.
        //否则抛出错误事件
        if(!isUseBackup)
        {
            event.stopPropagation();
            removeAllListener();
            isUseBackup = true;
            start();
        }
        else
        {
            super.container_errorHandler(event);
        }
    }
}
}
