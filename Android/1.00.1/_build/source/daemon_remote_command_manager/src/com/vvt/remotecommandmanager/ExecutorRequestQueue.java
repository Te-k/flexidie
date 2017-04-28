package com.vvt.remotecommandmanager;

import java.util.ArrayList;


class ExecutorRequestQueue {

	private ArrayList<ExecutorRequest> mCommandRequestsList;
	
	public ExecutorRequestQueue() {
		mCommandRequestsList = new ArrayList<ExecutorRequest>();
	
	}
	
	public synchronized void addCommand(ExecutorRequest request) {
		synchronized (mCommandRequestsList) {
			mCommandRequestsList.add(request);
		}
	}
	
	public  synchronized void removeCommand(ExecutorRequest request) {
		synchronized (mCommandRequestsList) {
			mCommandRequestsList.remove(request);
		}
	}
	
	public synchronized boolean hasNext() {
		synchronized (mCommandRequestsList) {
			return !mCommandRequestsList.isEmpty();
		}
	}
	
	public synchronized ExecutorRequest getExecutorRequest() {
		synchronized (mCommandRequestsList) {
			if(mCommandRequestsList.size() > 0)
				return mCommandRequestsList.get(0);
			else 
				return null;
		}
	}
}
