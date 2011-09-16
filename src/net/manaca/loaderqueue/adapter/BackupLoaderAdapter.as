/*
 * Copyright (c) 2011, wersling.com All rights reserved.
 */
package net.manaca.loaderqueue.adapter
{
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.LoaderContext;

import net.manaca.loaderqueue.ILoaderAdapter;
import net.manaca.loaderqueue.LoaderQueueEvent;

/**
 * BackupLoaderAdapter可以设置两个URL地址，如果一个地址加载错误，
 * 程序将加载第二个地址。本对象一般用于确定服务的稳定性，如果数据服务器出现问题，
 * 我们可以设置一个静态文件路径，以确保最终显示正常。
 * @see net.manaca.loaderqueue#LoaderQueue
 * @author Austin
 * @update sean
 */
public class BackupLoaderAdapter extends AbstractLoaderAdapter
    implements ILoaderAdapter
{
    //==========================================================================
    //  Constructor
    //==========================================================================
    /**
     * 构造函数.
     * @param priority 优先级,数值越小等级越高,越早被下载
     * @param urlRequest 需下载项的url地址
     * @param backupUrlRequest 备份的url地址
     */
    public function BackupLoaderAdapter(priority:uint,
                                        urlRequest:URLRequest, 
                                        backupUrlRequest:URLRequest,
                                        loaderContext:LoaderContext = null)
    {
        super(priority, urlRequest, loaderContext);
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
    
    //----------------------------------
    //  context
    //----------------------------------
    /**
     * Contains the root display object of the SWF file or image 
     * (JPG, PNG, or GIF) file that was loaded.
     * @return 
     * 
     */    
    public function get content():DisplayObject
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
            if(!isUseBackup)
            {
                adaptee.load(urlRequest, loaderContext);
            }
            else
            {
                if(preventCache)
                {
                    backupUrlRequest.url = 
                        getPreventCacheURL(backupUrlRequest.url);
                }
                adaptee.load(backupUrlRequest, loaderContext);
            }
        }
        catch (error:Error)
        {
            dispatchEvent(new LoaderQueueEvent(LoaderQueueEvent.TASK_ERROR,
                customData));
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
