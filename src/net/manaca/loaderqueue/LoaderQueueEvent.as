/*
 * Copyright (c) 2011, wersling.com All rights reserved.
 */
package net.manaca.loaderqueue
{
import flash.events.Event;
/**
 * <code>LoaderQueueEvent</code>提供对外的一致事件接口.
 * @author Austin
 * @update sean
 */
public class LoaderQueueEvent extends Event
{
    //==========================================================================
    //  Class variables
    //==========================================================================
    /**
     * 任务添加到队列时触发
     */    
    static public const TASK_ADDED:String = "taskAdded";
    
    /**
     * 任务从队列删除时触发
     */    
    static public const TASK_REMOVED:String = "taskRemoved";
    
    /**
     * 单个项目(adapter实例)下载时触发
     */
    static public const TASK_COMPLETED:String = "taskCompleted";
    
    /**
     * 单个加载出错时触发
     */    
    static public const TASK_ERROR:String = "taskError";
    
    /**
     * 单个加载进度更新时触发
     */    
    static public const TASK_PROGRESS:String = "taskProgress";
    
    /**
     * 单个加载开始时触发
     */    
    static public const TASK_START:String = "taskStart";
    
    /**
     * 单个加载停止时触发
     */    
    static public const TASK_STOP:String = "taskStop";
    
    /**
     * 单个加载销毁时触发
     */    
    static public const TASK_DISPOSE:String = "taskDispose";

    /**
     * 队列中所有项目下载完成时触发
     */
    static public const TASK_QUEUE_COMPLETED:String = "taskQueueCompleted";

    //==========================================================================
    //  Constructor
    //==========================================================================
    /**
     * 构造函数.
     *
     */
    public function LoaderQueueEvent(type:String, customData:* = null)
    {
        this.customData = customData;
        super(type);
    }

    //==========================================================================
    //  Variables
    //==========================================================================
    /**
     * 提供给开发者使用，其内容可以为任何对象或值
     */
    public var customData:*;

    /**
     * 已经加载的数据.仅在TASK_PROGRESS事件时此值才有效
     */    
    public var bytesLoaded:Number;

    /**
     * 总需要加载的数据量.仅在TASK_PROGRESS事件时此值才有效
     */    
    public var bytesTotal:Number;

    /**
     * 仅在TASK_ERROR事件时此值才有效
     */
    public var errorMsg:String;

    //==========================================================================
    //  Methods
    //==========================================================================
    override public function clone():Event
    {
        var event:LoaderQueueEvent = new LoaderQueueEvent(type);
        event.customData = customData;
        event.bytesLoaded = bytesLoaded;
        event.bytesTotal = bytesTotal;
        event.errorMsg = errorMsg;
        return event;
    }
}
}
