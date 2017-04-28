package com.vvt.data_delivery_manager.stresstests;

import android.content.Context;

import com.vvt.data_delivery_manager.testsfunctional.GenerateTestValue;
import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.DeliveryResponse;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.enums.DeliveryRequestType;
import com.vvt.datadeliverymanager.interfaces.DeliveryListener;
import com.vvt.datadeliverymanager.store.RequestStore;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.CommandData;

public class RSInsertThread extends Thread{
	
	private static final String TAG = "RSInsertThread";
	private static final int mNumber = 10000;
	
	private StressTestListener mStressTestListener;
	private Context mContext;
	
	private int mCountInsert = 0;

	public RSInsertThread(Context context, StressTestListener listener) {
		mContext = context;
		mStressTestListener = listener;
	}
	
	@Override
	public void run() {
		RequestStore requestStore = RequestStore.getInstance(mContext);
		
		mCountInsert= 0;
		
		for(int i = 1; i<= mNumber ; i++) {
			DeliveryRequest deliveryRequest = new DeliveryRequest();
			deliveryRequest.setCallerID(i);
			FxLog.v(TAG, "CallerID = "+ deliveryRequest.getCallerID());
			
			MockCommandData commandData = new MockCommandData();
			commandData.setCmd(i);
			
			deliveryRequest.setCommandData(commandData);
			deliveryRequest.setCSID(GenerateTestValue.getRandomInteger(1, 100000));
			deliveryRequest.setDataProviderType(DataProviderType.DATA_PROVIDER_TYPE_ALL_REGULAR);
			deliveryRequest.setDelayTime(10);
			deliveryRequest.setDeliveryListener(deliveryListener);
			
			deliveryRequest.setDeliveryRequestType(DeliveryRequestType.REQUEST_TYPE_NEW);
			deliveryRequest.setIsReadyToResume(true);
			deliveryRequest.setMaxRetryCount(0);
			deliveryRequest.setRequestPriority(GenerateTestValue.getRandomPriorityRequestType());
			deliveryRequest.setRetryCount(0);
			deliveryRequest.setIsRequireCompression(true);
			deliveryRequest.setIsRequireEncryption(true);
		
			requestStore.insertRequest(deliveryRequest);
			mCountInsert++;
		}
		
		mStressTestListener.onInsertFinish(mCountInsert);
	}
	
	DeliveryListener deliveryListener = new DeliveryListener() {
		@Override
		public void onProgress(DeliveryResponse response) {
		}

		@Override
		public void onFinish(DeliveryResponse response) {
		}
	};
	
	private class MockCommandData implements CommandData {

		private int m_CmdId;

		public void setCmd(int cmd_id) {
			m_CmdId = cmd_id;
		}

		@Override
		public int getCmd() {
			return m_CmdId;
		}
	}
	
}
