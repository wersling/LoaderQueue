/*
 * Copyright (c) 2011, wersling.com All rights reserved.
 */
package net.manaca.loaderqueue
{
/**
 * 用于标明LoaderQueue所使用的Adapter的状态
 *
 * p.s:请注意，LoaderQueue并不具有状态，
 * 所以此状态并非为LoaderQueue使用，即不是LoaderQueue的状态
 */
public class LoaderQueueConst
{
    static public const STATE_COMPLETED:String = "completed";
    static public const STATE_ERROR:String = "error";
    static public const STATE_REMOVED:String = "removed";
    static public const STATE_STARTED:String = "started";
    static public const STATE_WAITING:String = "waiting";
}
}
