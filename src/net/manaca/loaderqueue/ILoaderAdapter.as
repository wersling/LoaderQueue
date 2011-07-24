/*
 * Copyright (c) 2011, wersling.com All rights reserved.
 */
package net.manaca.loaderqueue
{
import flash.events.IEventDispatcher;

/**
 * 适配器接口类,所有任务适配器需引用此接口
 * @see LoaderAdapter
 * @see CommandAdapter
 * @author Austin
 * @update sean
 */
public interface ILoaderAdapter extends IEventDispatcher
{
    
    /**
     * A boolean indicating if the instace has started and has not finished loading.
     * @return
     *
     */
    function get isStarted():Boolean;
    
    /**
     * The priority level of the loader queue.
     * @return
     *
     */
    function get priority():uint;
    
    /**
     * loading state.
     * @return 
     * 
     */   
    function get state():String;
    
    function set state(value:String):void;
    
    /**
     * Indicates the number of bytes that have been loaded 
     * thus far during the load operation.
     * @return 
     * 
     */    
    function get bytesLoaded():Number;
    
    /**
     * Indicates the total number of bytes in the downloaded data.
     * @return 
     * 
     */    
    function get bytesTotal():Number;
    
    /**
     * Custom data.
     * @return 
     * 
     */    
    function get customData():*;
    function set customData(obj:*):void;
    
    /**
     * The URL to be requested.
     * @return 
     * 
     */    
    function get url():String;
    
    /**
     * start loading.
     *
     */
    function start():void;

    /**
     * stop loading.
     *
     */
    function stop():void;

    /**
     * Frees memory that is used to store the ILoaderAdapter object.
     *
     */
    function dispose():void;
}
}
