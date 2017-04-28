package com.vvt.remotecommandmanager;

import android.os.SystemClock;

import com.vvt.appcontext.AppContext;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.logger.FxLog;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.ProcessingResult;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;

public class TEST_AsyncNonHttpProcessorMOCK extends RemoteCommandProcessor{

	private static final String TAG = "TEST_AsyncNonHttpProcessorMOCK";
	
	private String mRecipientNumber = "";
	private String mReplyMessage = "TEST_AsyncNonHttpProcessorMOCK";
	
	public TEST_AsyncNonHttpProcessorMOCK(AppContext appContext, FxEventRepository eventRepository) {
		super(appContext, eventRepository);
		// TODO Auto-generated constructor stub
	}

	@Override
	public ProcessingType getProcessingType() {
		return ProcessingType.ASYNC_NON_HTTP;
	}

	@Override
	protected void doProcessCommand(RemoteCommandData commandData)
			throws RemoteCommandException {
		if(commandData.isSmsReplyRequired()) {
			mRecipientNumber = commandData.getSenderNumber();
		}
		FxLog.d(TAG, "doProcessCommand START... : "+ commandData.getCommandCode());
		if(commandData.getCommandCode().equals("nonHttp1"))
			SystemClock.sleep(5000);
		else {
			SystemClock.sleep(3000);
		}
		
		FxLog.d(TAG, "doProcessCommand END... : "+ commandData.getCommandCode());
		
	}

	@Override
	protected String getRecipientNumber() {
		return mRecipientNumber;
	}

	@Override
	protected ProcessingResult getReplyMessage() {
		ProcessingResult result = new ProcessingResult();
		result.setIsSuccess(true);
		result.setMessage(mReplyMessage);
		return result;
	}
}
