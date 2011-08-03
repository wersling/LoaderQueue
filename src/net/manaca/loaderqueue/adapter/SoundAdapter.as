/*
 * Copyright (c) 2011, wersling.com All rights reserved.
 */
package net.manaca.loaderqueue.adapter
{
import flash.media.Sound;
import flash.media.SoundLoaderContext;
import flash.net.URLRequest;

import net.manaca.loaderqueue.ILoaderAdapter;
import net.manaca.loaderqueue.LoaderQueueEvent;

/**
 * 将Sound类包装成可用于LoaderQueue的适配器
 * @see net.manaca.loaderqueue#LoaderQueue
 * @author Austin
 * @update sean
 */
public class SoundAdapter extends AbstractLoaderAdapter
                            implements ILoaderAdapter
{
    //==========================================================================
    //  Constructor
    //==========================================================================
    /**
     * 构造函数.
     *
     */
    public function SoundAdapter(priority:uint,
                                 urlRequest:URLRequest,
                                 loaderContext:SoundLoaderContext = null)
    {
        super(priority, urlRequest, loaderContext);
    }

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
    private var _adaptee:Sound;
    /**
     * 返回加载对象具体实例。
     * @return 
     * 
     */  
    public function get adaptee():Sound
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
        _adaptee = new Sound();
        adapteeAgent = _adaptee;
        preStartHandle();
        try
        {
            adaptee.load(urlRequest, loaderContext);
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
        }

    }
}
}
