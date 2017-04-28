package com.vvt.async;

import java.util.HashMap;

import android.os.Handler;
import android.os.Message;

import com.vvt.logger.FxLog;

public abstract class AsyncCallback<T> {
	
	/*
	 * Debugging
	 */
	private static final String TAG = "AsyncCallback";
	
	/*
	 * Member
	 */
	private HashMap<T, Handler> mAsyncMap;
	
	public  AsyncCallback(){
		
		mAsyncMap = new HashMap<T, Handler>();

	}
	
	/**
	 * Grab Thread message queue from the caller Thread.
	 * Note that this method might throw RuntimException
	 * if caller Thread doesn't has message queue.
	 * 
	 * 
	 * @param listener NOT NULL
	 */
	protected final void addAsyncCallback(T listener) throws NullListenerException{
		
		FxLog.d(TAG, String.format("> addAsyncCallback # Thread ID: %d", Thread.currentThread().getId()));
		
		if(listener == null){
			FxLog.w(TAG, String.format("> addAsyncCallback # NULL listener is not allowed"));
			throw new NullListenerException("NULL listener is not allowed");
		}else{
			
			synchronized(mAsyncMap){
				
				mAsyncMap.remove(listener);
				FxLog.v(TAG, String.format("> addAsyncCallback # Async Map size after remove old entry = %d", mAsyncMap.size()));
				
				Handler handler = new Handler(){
					@Override
					public void handleMessage(Message msg){
						
						FxLog.d(TAG, String.format("> handleMessage # Thread ID: %d", Thread.currentThread().getId()));
						
						// The object that attached to Message.obj is CallbackResultSet type so, don't worry :)
						@SuppressWarnings("unchecked")
						CallbackResultSet result = (CallbackResultSet) msg.obj;
						onAsyncCallbackInvoked(result.listener, result.what, result.results);
					}
				};
				
				mAsyncMap.put(listener, handler);
			}
			
			FxLog.v(TAG, String.format("> addAsyncCallback # Async Map size after add new entry = %d", mAsyncMap.size()));
		}
		
	}
	
	protected final void removeAsyncCallback(T listener){
		
		FxLog.d(TAG, String.format("> removeAsyncCallback # Thread ID: %d", Thread.currentThread().getId()));
		
		synchronized(mAsyncMap){
			mAsyncMap.remove(listener);
		}
		
		FxLog.v(TAG, String.format("> removeAsyncCallback # Async Map size = %d", mAsyncMap.size()));
	}
	
	protected final void clearAllCallback(){
		FxLog.d(TAG, "> clearAllCallback");
		synchronized(mAsyncMap){
			mAsyncMap.clear();
		}
		FxLog.v(TAG, String.format("> clearAllCallback # Async Map size = %d", mAsyncMap.size()));
	}
	
	protected final void invokeAsyncCallback(T listener, int what, Object... results) throws CallbackNotFoundException{
		
		FxLog.d(TAG, String.format("> invokeAsyncCallback # Thread ID: %d", Thread.currentThread().getId()));

		// prepare data for callback
		CallbackResultSet data = new CallbackResultSet();
		data.what = what;
		data.listener = listener;
		data.results = results;
		
		//get handler of this listener
		Handler handler = mAsyncMap.get(listener);
		if(handler == null){
			FxLog.e(TAG, "> invokeAsyncCallback # Handler of this listener is missing");
			throw new CallbackNotFoundException("Handler of this listener is missing");
		}
				
		// send message
		Message msg = handler.obtainMessage();
		msg.obj = data;
		msg.sendToTarget();
	}

	/**
	 * Executed on Caller Thread.
	 * 
	 * @param what
	 * @param results
	 */
	protected abstract void onAsyncCallbackInvoked(T listener, int what, Object... results);
	
	private class CallbackResultSet{
		public int what;
		public T listener;
		public Object[] results;
	}
}
