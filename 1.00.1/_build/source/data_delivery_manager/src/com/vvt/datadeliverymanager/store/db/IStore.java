package com.vvt.datadeliverymanager.store.db;

import java.util.List;

import com.vvt.datadeliverymanager.DeliveryRequest;

public interface IStore {
	public void openStore();
	public void closeStore();
	
	public long insert(DeliveryRequest request);
	public boolean delete(long csid);
	public boolean update(DeliveryRequest request);
		
 	public List<DeliveryRequest> getAllDeliveryRequests();
}
