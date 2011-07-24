/*
 * Copyright (c) 2011, wersling.com All rights reserved.
 */
package net.manaca.loaderqueue
{
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Dictionary;
import flash.utils.Timer;

/**
 * 任务队列全部完成后派发
 * @eventType net.manaca.loaderqueue.LoaderQueueEvent.TASK_QUEUE_COMPLETED
 */
[Event(name="taskQueueCompleted", 
    type="net.manaca.loaderqueue.LoaderQueueEvent")]

/**
 * 任务队列及下载队列的管理器
 * @example
 * var urlLoader:URLLoaderAdapter =
 *                           new URLLoaderAdapter(4,"http://ggg.ggg.com/a.swf");
 * urlLoader.addEventListener(LoaderQueueEvent.TASK_COMPLETED,
 *                                                           onLoadedCompleted);
 * var loaderQueue:LoaderQueue = new LoaderQueue();
 * loaderQueue.addItem(urlLoader);
 *
 * @see net.manaca.loaderqueue.adapter#URLLoaderAdapter
 *
 * @author Austin
 * @update sean
 */
public class LoaderQueue extends EventDispatcher implements ILoaderQueue
{
    //==========================================================================
    //  Constructor
    //==========================================================================
    /**
     * Constructs a new <code>LoaderQueue</code> instance.
     * @param threadLimit 下载线程数的上限。默认2
     * @param delay 下载队列排序延迟时间，单位毫秒。默认500毫秒
     * @param jumpQueueIfCached 如果该url文件已经加载过，是否跳过队列直接加载。
     * 该参数通过加载文件的url来判断。默认为true
     */
    public function LoaderQueue(threadLimit:uint = 2, delay:int = 500, 
                                jumpQueueIfCached:Boolean = true)
    {
        this.threadLimit = threadLimit;
        this.delay = delay;
        this.jumpQueueIfCached = jumpQueueIfCached;
        
        timeOutToSort = new Timer(delay, 1);
        timeOutToSort.addEventListener(TimerEvent.TIMER_COMPLETE,
            timeOutToSort_timerCompleteHandler);
    }

    //==========================================================================
    //  Variables
    //==========================================================================
    /**
     * 下载队列排序延迟时间，单位毫秒
     */
    private var delay:int;
    
    /**
     * 缓存已经加载过的url地址
     */    
    private var cacheMap:Object = {};
    
    /**
     * 用于保存所有的下载项目
     * p.s:已下载的会被清除
     * @private
     */
    private var loaderDict:Dictionary/* of ILoaderAdapter */= new Dictionary();
    
    /**
     * 用于决定下载的等级的顺序
     * @private
     */
    private var loaderPriorityLib:Array /* of uint */ = [];
    
    /**
     * 用于保存目前正在下载的对象
     * @private
     */
    private var threadLib:Array /* of ILoaderAdapter */ = [];
    
    /**
     * 用于在添加新的Item后延迟触发排序.
     */
    private var timeOutToSort:Timer;
    //==========================================================================
    //  Properties
    //==========================================================================
    /**
     * 如果该url文件已经加载过，是否跳过队列直接加载。
     * 该参数通过加载文件的url来判断。默认为true
     * @default true
     */    
    public var jumpQueueIfCached:Boolean = true;
    
    /**
     * 最大线程数上限值
     */
    public var threadLimit:uint;

    /**
     * 等级排序时是否使用倒序(如4,3,2,1)
     */
    public var reversePriority:Boolean = false;
    //==========================================================================
    //  Methods
    //==========================================================================
    /**
     * @inheritDoc 
     */
    public function addItem(loaderAdapter:ILoaderAdapter):void
    {
        dispatchEvent(
            new LoaderQueueEvent(LoaderQueueEvent.TASK_ADDED, loaderAdapter));
        
        loaderAdapter.state = LoaderQueueConst.STATE_WAITING;
        //如果jumpQueueIfCached为true,则检查是否已经加载过，如果加载过，则不添加到队列，
        //而是直接开始加载
        if(jumpQueueIfCached)
        {
            if(cacheMap[loaderAdapter.url])
            {
                loaderAdapter.start();
                return;
            }
        }
        
        if (loaderDict[loaderAdapter.priority] == null)
        {
            loaderDict[loaderAdapter.priority] = [];
            loaderPriorityLib.push(loaderAdapter.priority);
        }
        loaderDict[loaderAdapter.priority].push(loaderAdapter);

        loaderAdapter.addEventListener(LoaderQueueEvent.TASK_DISPOSE,
                                       loaderAdapter_disposeHandler);
        
        // 使用Timer调用是为防止同一时间多个添加造成的性能浪费
        if (!timeOutToSort.running)
        {
            timeOutToSort.start();
        }
    }

    /**
    * 将LoaderQueue实例中的所有内容消毁，并将下载队列清空
    */
    public function dispose():void
    {
        removeAllItem();
        loaderDict = null;
        loaderPriorityLib = null;
        threadLib = null;

        timeOutToSort.stop();
        timeOutToSort.removeEventListener(TimerEvent.TIMER_COMPLETE, 
            timeOutToSort_timerCompleteHandler);
        timeOutToSort = null;
    }

    /**
     * 停止并移除队列中所有等级的下载项
     */
    public function removeAllItem():void
    {
        for each (var i:uint in loaderPriorityLib)
        {
            removeItemByPriority(i);
        }
    }

    /**
     * 停止并移除队列中指定的下载项
     * 如想消毁Item实例需手动调用其自身的dispose方法
     */
    public function removeItem(loaderAdapter:ILoaderAdapter):void
    {
        disposeItem(loaderAdapter);
        loaderAdapter.state = LoaderQueueConst.STATE_REMOVED;
        dispatchEvent(
            new LoaderQueueEvent(LoaderQueueEvent.TASK_REMOVED, loaderAdapter));
    }

    /**
     * 停止并移除队列中所有相应等级的下载项
     * @param priority 需停止并移除的等级
     */
    public function removeItemByPriority(priority:uint):void
    {
        for each (var i:ILoaderAdapter in loaderDict[priority])
        {
            removeItem(i);
        }
    }

    /**
     * 停止并移除队列中除指定等级以外的所有等级的下载项
     * @param priority 需保留的等级
     */
    public function saveItemByPriority(priority:uint):void
    {
        for each (var i:ILoaderAdapter in loaderDict[priority])
        {
            if (i.priority != priority)
            {
                removeItem(i);
            }
        }
    }

    /**
     * 取得当前正在运行的线程数
     * @return uint
     */
    public function get currentStartedNum():uint
    {
        return threadLib.length;
    }

    /**
     * 检查队列中是否还有项目需下载
     * @private
     */
    private function checkQueueHandle():Boolean
    {
        for each (var priority:uint in loaderPriorityLib)
        {
            if (loaderDict[priority].length > 0)
            {
                return true;
            }
        }
        dispatchEvent(
                new LoaderQueueEvent(LoaderQueueEvent.TASK_QUEUE_COMPLETED));
        return false;
    }

    /**
     * 检查下载线程是否已到最大上限
     * @private
     */
    private function checkThreadHandle(loaderAdapter:ILoaderAdapter):void
    {
        if (loaderAdapter == null)
        {
            //执行到此处说明队列中的所有项目均正在执行
            return;
        }
        if (threadLib.length < threadLimit)
        {
            threadLib.push(loaderAdapter);
            startItem(loaderAdapter);
        }
        else
        {
            threadFullHandle(loaderAdapter);
        }
    }

    /**
     * 将项目从线程池与队列中移出,但并不消毁其自身
     * (如想消毁项目实例需手动调用其自身的dispose方法)
     * p.s:一般在item发生completed与error后调用
     *
     * @private
     */
    private function disposeItem(loaderAdapter:ILoaderAdapter):void
    {
        if (loaderAdapter.isStarted)
        {
            loaderAdapter.removeEventListener(LoaderQueueEvent.TASK_COMPLETED,
                                              loaderAdapter_completedHandler);
            loaderAdapter.removeEventListener(LoaderQueueEvent.TASK_ERROR,
                                              loaderAdapter_errorHandler);
            try
            {
                loaderAdapter.stop();
            }
            catch (e:Error)
            {
                //屏蔽可能的错误
            }
        }
        loaderAdapter.removeEventListener(LoaderQueueEvent.TASK_DISPOSE,
                                          loaderAdapter_disposeHandler);
        var num:uint = threadLib.indexOf(loaderAdapter);
        if (num != -1)
        {
            threadLib.splice(num, 1);
        }
        num = loaderDict[loaderAdapter.priority].indexOf(loaderAdapter);

        loaderDict[loaderAdapter.priority].splice(num, 1);
    }

    /**
     * 取得下一个需要下载的项目
     * @private
     */
    private function getNextIdleItem():ILoaderAdapter
    {
        for each (var priority:uint in loaderPriorityLib)
        {
            for each (var loaderAdapter:ILoaderAdapter in loaderDict[priority])
            {
                if (!loaderAdapter.isStarted)
                {
                    return loaderAdapter;
                }
            }
        }
        return null;
    }

    /**
     * 启动LoaderAdapter实例
     * @private
     */
    private function startItem(loaderAdapter:ILoaderAdapter):void
    {
        loaderAdapter.state = LoaderQueueConst.STATE_STARTED;
        loaderAdapter.addEventListener(LoaderQueueEvent.TASK_COMPLETED,
                                       loaderAdapter_completedHandler);
        loaderAdapter.addEventListener(LoaderQueueEvent.TASK_ERROR,
                                       loaderAdapter_errorHandler);
        loaderAdapter.start();
    }

    /**
     * 停止LoaderAdapter实例并屏蔽可能引发的错误
     * @private
     */
    private function stopItem(loaderAdapter:ILoaderAdapter):void
    {
        loaderAdapter.state = LoaderQueueConst.STATE_WAITING;
        loaderAdapter.removeEventListener(LoaderQueueEvent.TASK_COMPLETED,
                                          loaderAdapter_completedHandler);
        loaderAdapter.removeEventListener(LoaderQueueEvent.TASK_ERROR,
                                          loaderAdapter_errorHandler);

        try
        {
            loaderAdapter.stop();
        }
        catch (error:Error)
        {
            //屏蔽可能的错误
        }
    }

    /**
     * 当下载线程全部被占用时,对新添加的实例进行的操作
     * @private
     */
    private function threadFullHandle(loaderAdapter:ILoaderAdapter):void
    {
        for (var i:uint = 0; i < threadLib.length; i++)
        {
            var reversePriorityResult:Boolean =
                    checkReversePriority(ILoaderAdapter(threadLib[i]).priority, 
                        loaderAdapter.priority);
            if (reversePriorityResult)
            {
                stopItem(threadLib[i]);
                threadLib[i] = loaderAdapter;
                startItem(loaderAdapter);
            }
        }
    }

    /**
     * 将已启动的adapter重新排序
     */
    private function sortStartedItem():void
    {
        var itemLoader:ILoaderAdapter = getNextIdleItem();
        if (itemLoader == null)
        {
            //已无项目，或是所有项目都已开始下载
            //所以已无重新排序必要
            return;
        }
        var oldPriority:int = itemLoader.priority;
        var idleLoaderAdapter:ILoaderAdapter;
        var runningLoaderAdapter:ILoaderAdapter;
        for (var i:uint = 0; i < threadLib.length; i++)
        {
            runningLoaderAdapter = threadLib[i];
            var reversePriorityResult:Boolean =
                checkReversePriority(
                    runningLoaderAdapter.priority, oldPriority);
            if (reversePriorityResult)
            {
                idleLoaderAdapter = getNextIdleItem();
                reversePriorityResult = 
                    checkReversePriority(runningLoaderAdapter.priority,
                                                    idleLoaderAdapter.priority);
                if (reversePriorityResult)
                {
                    stopItem(runningLoaderAdapter);
                    threadLib[i] = idleLoaderAdapter;
                    startItem(idleLoaderAdapter);
                    oldPriority = idleLoaderAdapter.priority;
                }
                else
                {
                    oldPriority = runningLoaderAdapter.priority;
                }
            }
            else
            {
                oldPriority = runningLoaderAdapter.priority;
            }
        }
    }

    /**
     * 如线程池未全部使用，则将等待下载的项目装进线程池
     */
    private function fillThreadPool():void
    {
        var nextIdleAdapter:ILoaderAdapter;
        while (currentStartedNum < threadLimit)
        {
            nextIdleAdapter = getNextIdleItem();
            if (nextIdleAdapter != null)
            {
                threadLib.push(nextIdleAdapter);
                startItem(nextIdleAdapter);
                nextIdleAdapter = null;
            }
            else
            {
                //线程未满，但已没有等待下载的项目时调用此处
                break;
            }
        }
    }

    //==========================================================================
    //  Event Handlers
    //==========================================================================
    private function loaderAdapter_completedHandler(event:LoaderQueueEvent):void
    {
        var loaderAdapter:ILoaderAdapter =
                                          event.currentTarget as ILoaderAdapter;
        if(jumpQueueIfCached)
        {
            cacheMap[loaderAdapter.url] = true;
        }
        disposeItem(loaderAdapter);
        
        if (checkQueueHandle())
        {
            checkThreadHandle(getNextIdleItem());
        }
    }

    private function loaderAdapter_errorHandler(event:LoaderQueueEvent):void
    {
        var loaderAdapter:ILoaderAdapter =
                                        event.currentTarget as ILoaderAdapter;
        disposeItem(loaderAdapter);
        if (checkQueueHandle())
        {
            checkThreadHandle(getNextIdleItem());
        }
    }

    /**
    * adataper实例自动调用其自身的dispose方法后触发此处
    * @private
    */
    private function loaderAdapter_disposeHandler(event:LoaderQueueEvent):void
    {
        removeItem(event.target as ILoaderAdapter);
    }

    private function timeOutToSort_timerCompleteHandler(event:TimerEvent):void
    {
        timeOutToSort.reset();

        if (!reversePriority)
        {
            loaderPriorityLib.sort(Array.NUMERIC);
        }
        else
        {
            loaderPriorityLib.sort(Array.NUMERIC);
            loaderPriorityLib.reverse();
        }

        if (threadLib.length > 0)
        {
            sortStartedItem();
        }
        fillThreadPool();
    }

    /**
     * 根据是否倒序,来得出两个等级之间优先级的结果
     * @param priority1
     * @param priority2
     * @return
     * @private
     */
    private function checkReversePriority(priority1:uint, priority2:uint):Boolean
    {
        if (!this.reversePriority)
        {
            return priority1 > priority2;
        }
        return priority2 > priority1;
    }
}
}
