/*
 * Copyright (c) 2011, wersling.com All rights reserved.
 */
package net.manaca.loaderqueue
{
import flash.events.IEventDispatcher;

/**
 * LoaderQueue的接口，主要用于提供给第三方模块调用
 */
public interface ILoaderQueue extends IEventDispatcher
{
    /**
     * Adds a new ILoaderAdapter to be loaded. 
     * @param loaderAdapter
     * 
     */    
    function addItem(loaderAdapter:ILoaderAdapter):void;
    
    /**
     * Deletes all loading and loaded objects. 
     * 
     */    
    function removeAllItem():void;
    
    /**
     * This will delete this item from memory.
     * @param loaderAdapter
     * 
     */    
    function removeItem(loaderAdapter:ILoaderAdapter):void;
    
    /**
     * This will delete this items by priority.
     * @param priority
     * 
     */    
    function removeItemByPriority(priority:uint):void;
    
    /**
     * This will delete this items by unless priority.
     * @param priority
     * 
     */    
    function saveItemByPriority(priority:uint):void;
    
    /**
     * Frees memory that is used to store the LoaderQueue object.
     * 
     */    
    function dispose():void;
}
}
