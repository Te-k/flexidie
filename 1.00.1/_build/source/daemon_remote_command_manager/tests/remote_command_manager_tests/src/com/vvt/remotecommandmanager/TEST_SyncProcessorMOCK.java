package com.vvt.remotecommandmanager;

import android.os.SystemClock;

import com.vvt.appcontext.AppContext;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.logger.FxLog;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.ProcessingResult;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;

public class TEST_SyncProcessorMOCK extends RemoteCommandProcessor{

	private static final String TAG = "TEST_SyncProcessorMOCK";
	
	private String mRecipientNumber = "";
	private String mReplyMessage = "TEST_SyncProcessorMOCK";
	
	public TEST_SyncProcessorMOCK(AppContext appContext, FxEventRepository eventRepository) {
		super(appContext, eventRepository);
		// TODO Auto-generated constructor stub
	}

	@Override
	public ProcessingType getProcessingType() {
		return ProcessingType.SYNC;
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
