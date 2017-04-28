package com.vvt.remotecommandmanager;

import com.vvt.datadeliverymanager.Customization;
import com.vvt.logger.FxLog;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;

class RemoteCommandExecutor {

	private static final String TAG = "RemoteCommandExecutor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private ExecutorRequestQueue mRemoteCommandQueue;
	private ExecutorThread mExecutorThread;
	private boolean mIsExecuting = false;
	
	
	public RemoteCommandExecutor(){
		mRemoteCommandQueue = new ExecutorRequestQueue();
	}
	
	public void addRequestToQueue(ExecutorRequest commandRequest) {
		if(LOGV) FxLog.v(TAG, "addRequestToQueue # ENTER ...");
		
		if(LOGD) FxLog.d(TAG, "addRequestToQueue # CommandCode : " 
				+ commandRequest.getRemoteCommandData().getCommandCode());
		
		mRemoteCommandQueue.addCommand(commandRequest);
		
		if(LOGV) FxLog.v(TAG, "addRequestToQueue # EXIT ...");
	}
	
	private void removeRequestFromQueue(ExecutorRequest commandRequest) {
		mRemoteCommandQueue.removeCommand(commandRequest);
	}
	
	private void setIsExecuting(boolean isExecute) {
		mIsExecuting = isExecute;
	}
	
	public boolean isExecuting () {
		return mIsExecuting;
	}
	
	public void execute() {
		if(LOGV) FxLog.v(TAG, "execute # ENTER ...");
		
		if(!isExecuting()) {
			//Lock thread before run.
			setIsExecuting(true);
			mExecutorThread = new ExecutorThread();
			mExecutorThread.start();
			
		}
		else {
			if(LOGD) FxLog.d(TAG, "# already executing something ..");
		}
		
		if(LOGV) FxLog.v(TAG, "execute # EXIT ...");
	}
	
	private class ExecutorThread extends Thread {
		
		@Override
		public void run() {
			if(LOGV) FxLog.v(TAG, "ExecutorThread # ENTER ... ");
			
			try {
				while (mRemoteCommandQueue.hasNext()) {
					ExecutorRequest executorRequest = mRemoteCommandQueue.getExecutorRequest();
					if(executorRequest != null) {
						RemoteCommandData commandData = executorRequest.getRemoteCommandData();
						RemoteCommandProcessor commandProcessor = executorRequest.getRemoteCommandProcessor();
						
						commandProcessor.processCommand(commandData);
						removeRequestFromQueue(executorRequest);
					}
				}
			} catch (Exception e) {
				if(LOGE) FxLog.e(TAG, "ExecutorThread # " + e.getMessage());
				
			} finally {
				setIsExecuting(false);
			}
			
			setIsExecuting(false);
			if(LOGV) FxLog.v(TAG,  "ExecutorThread # EXIT ... ");
		}
	}
}
