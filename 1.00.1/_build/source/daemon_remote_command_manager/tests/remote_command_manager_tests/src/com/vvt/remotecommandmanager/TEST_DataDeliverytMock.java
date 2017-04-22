package com.vvt.remotecommandmanager;

import com.vvt.base.FxEventType;
import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.DeliveryResponse;
import com.vvt.datadeliverymanager.enums.DataProviderType;
import com.vvt.datadeliverymanager.interfaces.DataDelivery;
import com.vvt.logger.FxLog;
import com.vvt.phoenix.prot.command.DataProvider;
import com.vvt.phoenix.prot.command.SendEvents;
import com.vvt.phoenix.prot.event.Event;

public class TEST_DataDeliverytMock implements DataDelivery
{
	private static final String TAG = "DataDeliveryMock";
	DataProviderType dataProviderType;
	
	
	public TEST_DataDeliverytMock(DataProviderType dataProviderType) {
		this.dataProviderType = dataProviderType;
	}
	
	@Override
	public void deliver(final DeliveryRequest deliveryRequest) {
		
		Thread thd = new Thread(new Runnable() {
			
			@Override
			public void run() {
				try {Thread.sleep(100);} catch (InterruptedException e) {}
				
				DeliveryResponse response = new DeliveryResponse();
				
				SendEvents eventProvider  = (SendEvents)deliveryRequest.getCommandData();
				DataProvider p = eventProvider.getEventProvider();
				
				Event event = null;
				while(p.hasNext()) {
					event = (Event)p.getObject();
					event.toString();
				}
				
				response.setCanRetry(false);
				response.setCSMresponse(null);
				response.setDataProviderType(dataProviderType);
				response.setStatusCode(0);
				if(event != null) {
					String type = String.format("%s", FxEventType.forValue(event.getEventType()));
					response.setStatusMessage(type);
					FxLog.i(TAG,String.format("%s",type));
				}else {
					FxLog.i(TAG,"event is NULL");
					response.setStatusMessage("NULL");
				}

				response.setSuccess(true);
				
				deliveryRequest.getDeliveryListener().onFinish(response);
				
			}
		});
		thd.start();
	}
}

