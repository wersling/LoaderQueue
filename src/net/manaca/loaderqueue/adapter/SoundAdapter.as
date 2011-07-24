/*
 * Copyright (c) 2011, wersling.com All rights reserved.
 */
package net.manaca.loaderqueue.adapter
{
import net.manaca.loaderqueue.ILoaderAdapter;
import net.manaca.loaderqueue.LoaderQueueEvent;

import flash.events.Event;
import flash.media.ID3Info;
import flash.media.Sound;
import flash.media.SoundLoaderContext;
import flash.net.URLRequest;

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
     * Constructs a new <code>SoundAdapter</code> instance.
     *
     */
    public function SoundAdapter(priority:uint,
                                 urlRequest:URLRequest,
                                 loaderContext:SoundLoaderContext = null)
    {
        super(priority, urlRequest, loaderContext);
        _adaptee = new Sound();
        _adaptee.addEventListener(Event.ID3, onID3Event);
        adapteeAgent = _adaptee;
    }

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
    
    //----------------------------------
    //  adaptee
    //----------------------------------
    private var _adaptee:Sound;
    
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

    public function start():void
    {
        preStartHandle();
        try
        {
            adaptee.load(urlRequest, loaderContext);
        }
        catch (error:Error)
        {
            dispatchEvent(
                new LoaderQueueEvent(LoaderQueueEvent.TASK_ERROR,customData));
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
        }

    }

    //==========================================================================
    //  Event Handlers
    //==========================================================================
    private function onID3Event(event:Event):void
    {
        var obj:ID3Info = event.currentTarget["id3"] as ID3Info;
    }
}
}
