package net.manaca.loaderqueue.adapter
{
import flash.net.URLRequest;

import flexunit.framework.Assert;

import net.manaca.loaderqueue.LoaderQueue;
import net.manaca.loaderqueue.LoaderQueueEvent;
import net.manaca.loaderqueue.TestURL;

import org.flexunit.asserts.assertEquals;
import org.flexunit.async.Async;

public class LoaderAdapterPreventCacheTest
{		
    private var loaderQueue:LoaderQueue;
    private var loaderAdapter1:LoaderAdapter;
    
    [Before]
    public function setUp():void
    {
        loaderQueue = new LoaderQueue();
        loaderAdapter1 = new LoaderAdapter(1, new URLRequest(TestURL.PIC1));
    }
    
    [After]
    public function tearDown():void
    {
        loaderQueue.dispose();
        loaderQueue = null;
    }
    
    [Test]
    public function testGetSetpreventCache():void
    {
        loaderAdapter1.preventCache = true;
        assertEquals(loaderAdapter1.preventCache, true);
        
        loaderAdapter1.preventCache = false;
        assertEquals(loaderAdapter1.preventCache, false);
    }
    
    [Test(async)]
    public function testPreventCache():void
    {
        loaderAdapter1.preventCache = true;
        Async.handleEvent(this, loaderAdapter1, LoaderQueueEvent.TASK_COMPLETED, 
            verifyPreventCacheURL, TestURL.WAIT_TIME, {});
        loaderQueue.addItem(loaderAdapter1);
    }
    
    private function verifyPreventCacheURL(...arg):void
    {
        Assert.assertTrue(
            loaderAdapter1.adaptee.contentLoaderInfo.url.indexOf("LoaderQueueNoCache=") != -1);
    }
    
    [Test(async)]
    public function testNoPreventCache():void
    {
        loaderAdapter1.preventCache = false;
        Async.handleEvent(this, loaderAdapter1, LoaderQueueEvent.TASK_COMPLETED, 
            verifyNoPreventCacheURL, TestURL.WAIT_TIME, {});
        loaderQueue.addItem(loaderAdapter1);
    }
    
    private function verifyNoPreventCacheURL(...arg):void
    {
        Assert.assertTrue(
            loaderAdapter1.adaptee.contentLoaderInfo.url.indexOf("LoaderQueueNoCache=") == -1);
    }
}
}