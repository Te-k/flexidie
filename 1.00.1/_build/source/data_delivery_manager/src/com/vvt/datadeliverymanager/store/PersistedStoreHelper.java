package com.vvt.datadeliverymanager.store;

import java.util.List;

import android.content.Context;

import com.vvt.datadeliverymanager.Customization;
import com.vvt.datadeliverymanager.DeliveryRequest;
import com.vvt.datadeliverymanager.enums.PriorityRequest;
import com.vvt.datadeliverymanager.store.db.IStore;
import com.vvt.datadeliverymanager.store.db.StoreImp;
import com.vvt.logger.FxLog;

/**
 * This class provides basic operations for managing persisted requests.
 */
public class PersistedStoreHelper {
	private static final String TAG = "PersistedStoreHelper";
	private static final boolean LOGE = Customization.ERROR;
	
	private IStore store;
	private String mWribablePath;

	public PersistedStoreHelper(Context context, String path) {
		mWribablePath = path;
		store = new StoreImp(context, path);
		store.openStore();
	}

	public String getWriteablePath() {
		return this.mWribablePath;
	}
	
	public void setWritablePath(String path) {
		this.mWribablePath = path;
	}
	
	/**
	 * this method will call when object is destroied.
	 */
	@Override
	protected void finalize() throws Throwable {
		store.closeStore();
	}

	public void initailStore() {
		
		if(getWriteablePath() == null) {
			if(LOGE) FxLog.e(TAG, "WriteablePath is null!");
			return;
		}
		
		List<DeliveryRequest> listForDelete = store.getAllDeliveryRequests();

		// delete request that doesn't want to resume.
		for (DeliveryRequest request : listForDelete) {
			// Delete all requests that contain MaxRetryCount = 0
			if (request.getMaxRetryCount() <= 0)
				store.delete(request.getCsId());
			else {
				// Set all requests's resume state to TRUE
				request.setIsReadyToResume(true);
				store.update(request);
			}
		}
	}

	public boolean updateRequest(DeliveryRequest deliveryRequest) {
		boolean result = false;

		result = store.update(deliveryRequest);

		return result;
	}

	public boolean deleteRequest(long csid) {
		return store.delete(csid);
	}

	public DeliveryRequest getResumeableDeliveryRequest() {

		DeliveryRequest deliveryRequest = null;

		// IMPORTANT: List is ordered by priority, then oldest first
		List<DeliveryRequest> list = store.getAllDeliveryRequests();
		for (DeliveryRequest dr : list) {
			if (dr.isReadyToResume() == true) {
				deliveryRequest = dr;
				break;
			}
		}

		return deliveryRequest;
	}

	public void save(DeliveryRequest request) {
		store.insert(request);

	}

	public boolean hasDeliveryRequest(int cmd) {

		boolean found = false;

		List<DeliveryRequest> list = store.getAllDeliveryRequests();
		for (DeliveryRequest dr : list) {
			if (dr.getCommandData().getCmd() == cmd) {
				found = true;
				break;
			}
		}

		return found;
	}

	public boolean updateRequestAsResumeable(int cmd,PriorityRequest priority) {
		boolean updateResult = false;

		List<DeliveryRequest> list = store.getAllDeliveryRequests();

		for (DeliveryRequest dr : list) {
			if (dr.getCommandData().getCmd() == cmd && dr.getRequestPriority() == priority) {
				dr.setIsReadyToResume(true);
				updateResult = store.update(dr);
				break;
			}
		}

		return updateResult;
	}
	
	public boolean updateRequestAsResumeableWithCsid(long csid) {
		boolean updateResult = false;

		List<DeliveryRequest> list = store.getAllDeliveryRequests();

		for (DeliveryRequest dr : list) {
			if (dr.getCsId() == csid) {
				dr.setIsReadyToResume(true);
				updateResult = store.update(dr);
				break;
			}
		}

		return updateResult;
	}

	public boolean isRequestPending(int callerId) {
		boolean isPending = false;

		List<DeliveryRequest> list = store.getAllDeliveryRequests();

		for (DeliveryRequest dr : list) {
			if (dr.getCallerID() == callerId) {
				isPending = true;
				break;
			}
		}

		return isPending;
	}

	public void clearStore() {

		List<DeliveryRequest> list = store.getAllDeliveryRequests();

		for (DeliveryRequest dr : list) {
			store.delete(dr.getCsId());

		}

	}
}
