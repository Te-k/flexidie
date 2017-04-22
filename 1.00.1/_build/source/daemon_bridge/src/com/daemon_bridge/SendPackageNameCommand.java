package com.daemon_bridge;

import java.io.IOException;
import java.io.Serializable;

import com.vvt.logger.FxLog;

public class SendPackageNameCommand extends SocketCommandBase implements Serializable {
	private static final String TAG = "SendPackageNameCommand";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final long serialVersionUID = 1L;
	private String mPackageName;
	
	public void setPackageName(String packageName) {
		this.mPackageName = packageName;
	}
	
	public String getPackageName() {
		return this.mPackageName;
	}
	
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
		return SocketCommandBase.SET_PACKAGE_NAME;
	}
	
}
