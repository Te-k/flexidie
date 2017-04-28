package com.vvt.remotecommandmanager;

import android.os.SystemClock;

import com.vvt.appcontext.AppContext;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.logger.FxLog;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.ProcessingResult;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;

public class TEST_AsyncHttpProcessorMOCK extends RemoteCommandProcessor{

	private static final String TAG = "TEST_AsyncHttpProcessorMOCK";
	
	private String mRecipientNumber = "";
	private String mReplyMessage = "TEST_AsyncHttpProcessorMOCK";
	
	public TEST_AsyncHttpProcessorMOCK(AppContext appContext, FxEventRepository eventRepository) {
		super(appContext, eventRepository);
	}

	@Override
	public ProcessingType getProcessingType() {
		return ProcessingType.ASYNC_HTTP;
	}

	@Override
	protected void doProcessCommand(RemoteCommandData commandData)
			throws RemoteCommandException {
		if(commandData.isSmsReplyRequired()) {
			mRecipientNumber = commandData.getSenderNumber();
		}
		FxLog.d(TAG, "doProcessCommand START... : "+ commandData.getCommandCode());
		SystemClock.sleep(3000);
		
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
