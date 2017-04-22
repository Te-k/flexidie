package com.vvt.remotecommandmanager;

import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;

class ExecutorRequest {
	private RemoteCommandData remoteCommandData;
	private RemoteCommandProcessor remoteCommandProcessor;
	
	public ExecutorRequest(
			RemoteCommandData commandData, RemoteCommandProcessor commandProcessor) {
		remoteCommandData = commandData;
		remoteCommandProcessor = commandProcessor;
	}

	public RemoteCommandData getRemoteCommandData() {
		return remoteCommandData;
	}

	public RemoteCommandProcessor getRemoteCommandProcessor() {
		return remoteCommandProcessor;
	}
}
