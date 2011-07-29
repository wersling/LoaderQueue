package net.manaca.loaderqueue.adapter
{
import flash.net.URLRequest;

import flexunit.framework.Assert;

import net.manaca.loaderqueue.LoaderAdapterState;
import net.manaca.loaderqueue.LoaderQueue;
import net.manaca.loaderqueue.LoaderQueueEvent;
import net.manaca.loaderqueue.TestURL;

import org.flexunit.async.Async;

public class LoaderAdapterStateTest
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
    
    [Test(async)]
    public function testNormalState():void
    {
        Async.handleEvent(this, loaderAdapter1, LoaderQueueEvent.TASK_START, 
            verifyStartState, 1000, {});
        Async.handleEvent(this, loaderAdapter1, LoaderQueueEvent.TASK_COMPLETED, 
            verifyCompleteState, TestURL.WAIT_TIME, {});
        
        Assert.assertEquals(loaderAdapter1.state, LoaderAdapterState.WAITING);
        loaderQueue.addItem(loaderAdapter1);
    }
    
    private function verifyStartState(...arg):void
    {
        Assert.assertEquals(loaderAdapter1.state, LoaderAdapterState.STARTED);
    }
    
    private function verifyCompleteState(...arg):void
    {
        Assert.assertEquals(loaderAdapter1.state, LoaderAdapterState.COMPLETED);
    }
    
    [Test(async)]
    public function testErrorState():void
    {
        loaderAdapter1 = new LoaderAdapter(1, new URLRequest(TestURL.ERROR));
        Async.handleEvent(this, loaderAdapter1, LoaderQueueEvent.TASK_ERROR, 
            verifyErrorState, TestURL.WAIT_TIME, {});
        
        loaderQueue.addItem(loaderAdapter1);
    }
    
    private function verifyErrorState(...arg):void
    {
        Assert.assertEquals(loaderAdapter1.state, LoaderAdapterState.ERROR);
    }
}
}