package com.daemon_bridge;

import java.io.IOException;
import java.io.Serializable;

import com.vvt.logger.FxLog;

public class GetLicenseStatusCommand extends SocketCommandBase implements Serializable {
	private static final long serialVersionUID = 418768203127577007L;
	private static final String TAG = "GetLicenseStatusCommand";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	@Override
	public CommandResponseBase execute()  {
		if(LOGV) FxLog.v(TAG, "# execute START ..");
		
		CommandResponseBase response = null;
		
		try {
			
			if(LOGV) FxLog.v(TAG, "# execute before writeSocket..");
			response = writeSocket();
			if(LOGV) FxLog.v(TAG, "# execute after writeSocket..");
			
			if(LOGD) FxLog.d(TAG, "writeSocket # ResponseCode is :" + response.getResponseCode());
		} catch (IOException e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		}
		
		if(LOGV) FxLog.v(TAG, "# execute END ..");
		return response;
	}

	
	@Override
	public int getCommandId() {
		return SocketCommandBase.GET_LICENSE_STATUS;
	}
	
}
