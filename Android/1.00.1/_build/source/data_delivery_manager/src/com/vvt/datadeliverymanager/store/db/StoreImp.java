package com.vvt.datadeliverymanager.store.db;

import java.util.ArrayList;
import java.util.List;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteException;

import com.vvt.datadeliverymanager.Customization;
import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.enums.DeliveryRequestType;
import com.vvt.datadeliverymanager.enums.PriorityRequest;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.CommandData;

public class StoreImp implements IStore {
	
	private static final String TAG = "StoreImp";
	private static final boolean LOGE = Customization.ERROR;
	
	private SqliteDbAdapter mDbHelper;
	
	public StoreImp(Context context, String path) {
		mDbHelper = new SqliteDbAdapter(context, path);
	}
	
	@Override
	public void openStore() {
		boolean isOpenFail = true;
		int tryCount = 0;
		
		do {
			try {
				mDbHelper.open();
				isOpenFail = false;
			} catch (SQLiteException ex) {
				if(LOGE) FxLog.e(TAG, ex.getMessage());
				isOpenFail = true;
				tryCount++;
				try {Thread.sleep(1000);} catch (InterruptedException e) {}
			}
		} while(isOpenFail && tryCount<10);
	}

	@Override
	public void closeStore() {
		mDbHelper.close();
	}

	@Override
	public long insert(DeliveryRequest request) {
		return mDbHelper.insert(request);
	}

	@Override
	public boolean delete(long csid) {
		return mDbHelper.delete(csid);
	}

	@Override
	public boolean update(DeliveryRequest request) {
		return mDbHelper.update(request);
	}

	@Override
	public List<DeliveryRequest> getAllDeliveryRequests() {

		Cursor cursor = mDbHelper.fetchAllDeliveryRequest();
		List<DeliveryRequest> list = new ArrayList<DeliveryRequest>(); 
		DeliveryRequest r = null;
		
		if(cursor != null) {
			while (cursor.moveToNext()) {
				r = new DeliveryRequest();
				r.setCallerID(cursor.getInt(cursor.getColumnIndexOrThrow((SqliteDbAdapter.KEY_CALLER_ID))));
				
				MockCommandData cmd = new MockCommandData();
				cmd.setCmd(cursor.getInt(cursor.getColumnIndexOrThrow(SqliteDbAdapter.KEY_CMD_ID)));
				r.setCommandData(cmd);
				r.setCSID(cursor.getLong(cursor.getColumnIndexOrThrow((SqliteDbAdapter.KEY_CSID))));
				r.setDataProviderType(DataProviderType.forValue(cursor.getInt(cursor.getColumnIndexOrThrow(SqliteDbAdapter.KEY_DATA_PROVIDER_TYPE))));
				r.setDeliveryRequestType(DeliveryRequestType.forValue(cursor.getInt(cursor.getColumnIndexOrThrow(SqliteDbAdapter.KEY_DELIVERY_REQUEST_TYPE))));
				r.setIsReadyToResume(cursor.getInt(cursor.getColumnIndexOrThrow((SqliteDbAdapter.KEY_IS_READY_TO_RESUME))) > 0);
				r.setMaxRetryCount(cursor.getInt(cursor.getColumnIndexOrThrow(SqliteDbAdapter.KEY_MAX_RETRY_COUNT)));
				r.setRequestPriority(PriorityRequest.forValue(cursor.getInt(cursor.getColumnIndexOrThrow(SqliteDbAdapter.KEY_PRIORITY_REQUEST))));
				r.setRetryCount(cursor.getInt(cursor.getColumnIndexOrThrow((SqliteDbAdapter.KEY_RETRY_COUNT))));
				r.setDelayTime(cursor.getLong(cursor.getColumnIndexOrThrow((SqliteDbAdapter.KEY_DELAY_TIME))));
				r.setIsRequireEncryption(cursor.getInt(cursor.getColumnIndexOrThrow((SqliteDbAdapter.KEY_IS_REQUIRE_ENCRYPTION))) == 1 ? true : false);
				r.setIsRequireCompression(cursor.getInt(cursor.getColumnIndexOrThrow((SqliteDbAdapter.KEY_IS_REQUIRE_COMPRESSION))) == 1 ? true : false);
				list.add(r);
			}
			
			cursor.close();
		}
		
		return list;
	}
}
	
class MockCommandData implements CommandData {

	private int m_CmdId;

	public void setCmd(int cmd_id) {
		m_CmdId = cmd_id;
	}

	@Override
	public int getCmd() {
		return m_CmdId;
	}
}
