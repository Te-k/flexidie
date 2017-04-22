package com.vvt.remotecommandmanager;

import java.io.File;
import java.util.ArrayList;

import com.vvt.datadeliverymanager.Customization;
import com.vvt.ioutil.Path;
import com.vvt.ioutil.Persister;
import com.vvt.logger.FxLog;

class RemoteCommandDataStore {
	
	private static final String TAG = "RemoteCommandStore";
	private static final boolean LOGE = Customization.ERROR;
	
	private static final String FILE_NAME = "remotecommanddatastore.ser";
	private static String mWrittableFile = "";
	
	
	public RemoteCommandDataStore(String writtablePath) {
		mWrittableFile = Path.combine(writtablePath, FILE_NAME);
	}
	
	@SuppressWarnings("unchecked")
	public synchronized boolean insertCommand(RemoteCommandData commandData) {
		
		boolean isSuccess = true; 
		ArrayList<RemoteCommandData> commandDatas = null;

		try {
			
			if(new File(mWrittableFile).exists()) {
				Object deserializedObj = Persister.deserializeToObject(mWrittableFile);
				if (deserializedObj instanceof ArrayList<?>) {
					commandDatas = (ArrayList<RemoteCommandData>)deserializedObj;
				}
			}
			
			//write a new file.
			if(commandDatas != null) {
				commandDatas.add(commandData);
				isSuccess = Persister.persistObject(commandDatas, mWrittableFile);
			} else {
				commandDatas = new ArrayList<RemoteCommandData>();
				commandDatas.add(commandData);
				isSuccess = Persister.persistObject(commandDatas, mWrittableFile);
			}
		} catch (Exception e) {
			isSuccess = false;
		}

		return isSuccess;
	}
	
	@SuppressWarnings("unchecked")
	public synchronized boolean deleteCommand(RemoteCommandData commandData) {
		boolean isSuccess = true; 
		ArrayList<RemoteCommandData> commandDatas = null;
		
		try {
			Object deserializedObj = Persister.deserializeToObject(mWrittableFile);
			if (deserializedObj instanceof ArrayList<?>) {
				commandDatas = (ArrayList<RemoteCommandData>)deserializedObj;
			}
		
			if(commandDatas != null) { // deserialized Object success.
				
				//delete the fist commandData that has the same commnd Code.
				for(RemoteCommandData cmdData : commandDatas) {
					if(cmdData.getCommandCode().equals(commandData.getCommandCode())) {
						isSuccess = isSuccess && commandDatas.remove(cmdData);
						break;
					}
				}
				
				if(isSuccess) {
					isSuccess = isSuccess && Persister.persistObject(commandDatas, mWrittableFile);
					if(!isSuccess) {
						if(LOGE) FxLog.e(TAG, "removeCommand # Persisting FAILED!!");
					}
				} else {
					if(LOGE) FxLog.e(TAG, "removeCommand # remove FAILED!!");
				}
			
			} else { // deserialized Object fail.
				isSuccess = false;
			}
		} catch (Exception e) {
			isSuccess = false;
		}
		
		return isSuccess;
	}
	
	@SuppressWarnings("unchecked")
	public synchronized ArrayList<RemoteCommandData> getCommandDataList() {
		
		ArrayList<RemoteCommandData> commandDatas = null;
		
		Object deserializedObj = Persister.deserializeToObject(mWrittableFile);
		if (deserializedObj instanceof ArrayList<?>) {
			commandDatas = (ArrayList<RemoteCommandData>)deserializedObj;
		}
		
		if(commandDatas == null) {
			commandDatas = new ArrayList<RemoteCommandData>();
		}
		
		return commandDatas;
	}
	
}
