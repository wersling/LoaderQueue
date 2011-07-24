/*
 * Copyright (c) 2011, wersling.com All rights reserved.
 */
package net.manaca.loaderqueue.adapter
{
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.URLRequest;

import net.manaca.loaderqueue.LoaderQueueConst;
import net.manaca.loaderqueue.LoaderQueueEvent;

/**
 * 任务完成后派发
 * @eventType net.manaca.loaderqueue.LoaderQueueEvent.TASK_COMPLETED
 */
[Event(name="taskCompleted", type="net.manaca.loaderqueue.LoaderQueueEvent")]

/**
 * 任务出错后派发
 * @eventType net.manaca.loaderqueue.LoaderQueueEvent.TASK_ERROR
 */
[Event(name="taskError", type="net.manaca.loaderqueue.LoaderQueueEvent")]

/**
 * 任务进程中派发
 * @eventType net.manaca.loaderqueue.LoaderQueueEvent.TASK_PROGRESS
 */
[Event(name="taskProgress", type="net.manaca.loaderqueue.LoaderQueueEvent")]

/**
 * 任务启动后派发
 * @eventType net.manaca.loaderqueue.LoaderQueueEvent.TASK_START
 */
[Event(name="taskStart", type="net.manaca.loaderqueue.LoaderQueueEvent")]

/**
 * 任务停止或移出后派发
 * @eventType net.manaca.loaderqueue.LoaderQueueEvent.TASK_STOP
 */
[Event(name="taskStop", type="net.manaca.loaderqueue.LoaderQueueEvent")]

/**
 * 任务消毁时派发
 * @eventType net.manaca.loaderqueue.LoaderQueueEvent.TASK_DISPOSE
 */
[Event(name="taskDispose", type="net.manaca.loaderqueue.LoaderQueueEvent")]

/**
 * 虚构类，用于提供给adapter子类继承使用，同时adapter子类需引用ILoaderAdapter接口
 * @see ILoaderAdapter
 * @author Austin
 * @update sean
 */
public class AbstractLoaderAdapter extends EventDispatcher
{
    //==========================================================================
    //  Constructor
    //==========================================================================
    /**
     * Constructs a new <code>AbstractLoaderAdapter</code> instance.
     *
     */
    public function AbstractLoaderAdapter(priority:uint, urlRequest:URLRequest,
                                          loaderContext:* = null)
    {
        _priority = priority;
        this.urlRequest = urlRequest;
        this.loaderContext = loaderContext;
        this._url = urlRequest.url;
    }

    //==========================================================================
    //  Variables
    //==========================================================================
    protected var loaderContext:*;
    protected var urlRequest:URLRequest;


    //==========================================================================
    //  Properties
    //==========================================================================
    private var _customData:*;

    /**
     * 提供给开发者用于数据或参数传递
     * LoaderQueue或是任何Adapter自身并不对此变量附值
     */
    public function get customData():*
    {
        return _customData;
    }

    public function set customData(value:*):void
    {
        _customData = value;
    }

    /**
     * A boolean indicating if the instace has started and has not finished loading.
     * @return
     *
     */
    public function get isStarted():Boolean
    {
        return state == LoaderQueueConst.STATE_STARTED;
    }

    /**
     * A boolean indicating if the instace has finished.
     * @return
     *
     */
    public function get isCompleted():Boolean
    {
        return state == LoaderQueueConst.STATE_COMPLETED;
    }

    protected var _priority:uint;

    /**
     * The priority level of the loader queue.
     * @return
     *
     */
    public function get priority():uint
    {
        return _priority;
    }

    protected var _state:String;

    /**
     * 适配器的状态
     * @return 可能的值为LoaderQueueConst中的常量
     * @see net.manaca.loaderqueue#LoaderQueueConst
     */
    public function get state():String
    {
        return _state;
    }

    public function set state(value:String):void
    {
        _state = value;
    }
    
    private var _adapteeAgent:IEventDispatcher;

    /**
     * 将子类的adaptee传给本类的adapteeAgent,用于在此处理一些事件侦听.
     */
    protected function set adapteeAgent(loader:IEventDispatcher):void
    {
        _adapteeAgent = loader;
    }

    protected function get adapteeAgent():IEventDispatcher
    {
        return _adapteeAgent;
    }

    private var _url:String;
    /**
     * The URL to be requested.
     * @return 
     * 
     */
    public function get url():String
    {
        return _url;
    }

    //==========================================================================
    //  Methods
    //==========================================================================
    /**
     * 消毁此项目内在引用
     * 调用此方法后，此adapter实例会自动从LoaderQueue中移出
     * p.s: 停止下载的操作LoaderQueue会自动处理
     */
    public function dispose():void
    {
        dispatchEvent(new LoaderQueueEvent(LoaderQueueEvent.TASK_DISPOSE,
                                           customData));
        removeAllListener();
        loaderContext = null;
        urlRequest = null;
    }

    /**
     * 此方法应包含在子类start()函数中调用
     */
    protected function preStartHandle():void
    {
        with (adapteeAgent)
        {
            //containerAgent的事件
            addEventListener(Event.COMPLETE, container_completeHandler);
            addEventListener(ProgressEvent.PROGRESS, container_progressHandler);
            addEventListener(IOErrorEvent.DISK_ERROR, container_errorHandler);
            addEventListener(IOErrorEvent.IO_ERROR, container_errorHandler);
            addEventListener(IOErrorEvent.NETWORK_ERROR, container_errorHandler);
        }
        //adapter自身的事件
        addEventListener(IOErrorEvent.DISK_ERROR, container_errorHandler);
        addEventListener(IOErrorEvent.IO_ERROR, container_errorHandler);
        addEventListener(IOErrorEvent.NETWORK_ERROR, container_errorHandler);
        dispatchEvent(new LoaderQueueEvent(LoaderQueueEvent.TASK_START,
                                           customData));
    }

    /**
     * 此方法应包含在子类stop()函数中调用
     */
    protected function preStopHandle():void
    {
        removeAllListener();
        dispatchEvent(new LoaderQueueEvent(LoaderQueueEvent.TASK_STOP,
                                           customData));
    }

    private function removeAllListener():void
    {
        with (adapteeAgent)
        {
            removeEventListener(Event.COMPLETE, container_completeHandler);
            removeEventListener(ProgressEvent.PROGRESS,
                                container_progressHandler);
            removeEventListener(IOErrorEvent.DISK_ERROR, container_errorHandler);
            removeEventListener(IOErrorEvent.IO_ERROR, container_errorHandler);
            removeEventListener(IOErrorEvent.NETWORK_ERROR,
                                container_errorHandler);
        }
        removeEventListener(IOErrorEvent.DISK_ERROR, container_errorHandler);
        removeEventListener(IOErrorEvent.IO_ERROR, container_errorHandler);
        removeEventListener(IOErrorEvent.NETWORK_ERROR, container_errorHandler);
    }

    //==========================================================================
    //  Event Handlers
    //==========================================================================
    /**
     * 目下载完成后调用,由preStartHandle()触发
     * @param event
     */
    protected function container_completeHandler(event:Event):void
    {
        state = LoaderQueueConst.STATE_COMPLETED;
        dispatchEvent(new LoaderQueueEvent(LoaderQueueEvent.TASK_COMPLETED,
                                           customData));
    }

    protected function container_errorHandler(event:IOErrorEvent):void
    {
        state = LoaderQueueConst.STATE_ERROR;
        var errorEvent:LoaderQueueEvent =
            new LoaderQueueEvent(LoaderQueueEvent.TASK_ERROR, customData);
        errorEvent.errorMsg = event.text;
        dispatchEvent(errorEvent);
    }

    /**
     * 项目下载过程中调用,由preStartHandle()触发
     * @param event
     */
    protected function container_progressHandler(event:ProgressEvent):void
    {
        var progressEvent:LoaderQueueEvent =
            new LoaderQueueEvent(LoaderQueueEvent.TASK_PROGRESS, customData);
        progressEvent.bytesLoaded = event.bytesLoaded;
        progressEvent.bytesTotal = event.bytesTotal;
        dispatchEvent(progressEvent);
    }
}
}
