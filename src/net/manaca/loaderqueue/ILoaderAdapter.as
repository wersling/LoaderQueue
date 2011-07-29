/*
 * Copyright (c) 2011, wersling.com All rights reserved.
 */
package net.manaca.loaderqueue
{
import flash.events.IEventDispatcher;

/**
 * 适配器接口类,所有任务适配器需引用此接口。
 * @see LoaderAdapter
 * @see CommandAdapter
 * @author Austin
 * @update sean
 */
public interface ILoaderAdapter extends IEventDispatcher
{
    /**
     * 指示该加载对象是(true)否(false)开始加载。
     * @return
     *
     */
    function get isStarted():Boolean;
    
    /**
     * 指示该加载对象是(true)否(false)完成加载。
     * @return 
     * 
     */    
    function get isCompleted():Boolean;
            
    /**
     * 加载优先级。
     * @return
     *
     */
    function get priority():uint;
    
    /**
     * 指示该加载对象的状态。
     * @return 
     * 
     */   
    function get state():String;
    
    function set state(value:String):void;
    
    /**
     * 已经加载的文件字节数。
     * @return 
     * 
     */    
    function get bytesLoaded():Number;
    
    /**
     * 需要加载的字节总数。
     * @return 
     * 
     */    
    function get bytesTotal():Number;
    
    /**
     * 用户自定义数据。
     * @return 
     * 
     */    
    function get customData():*;
    function set customData(obj:*):void;
    
    /**
     * 加载URL地址。
     * @return 
     * 
     */    
    function get url():String;
    
    /**
     * 为url地址添加一个随机数，用于清除缓存。
     * 也可以通过设置ILoaderQueue.preventAllCache = true来清除所有加载项的缓存。
     * @see net.manaca.loaderqueue.ILoaderQueue.preventAllCache
     * @return 
     * 
     */    
    function get preventCache():Boolean;
    function set preventCache(value:Boolean):void;
    
    /**
     * 开始加载。
     *
     */
    function start():void;

    /**
     * 停止加载。
     *
     */
    function stop():void;

    /**
     * GC该对象。
     *
     */
    function dispose():void;
}
}
