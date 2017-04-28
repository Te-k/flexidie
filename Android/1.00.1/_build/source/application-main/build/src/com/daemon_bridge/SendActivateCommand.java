package com.daemon_bridge;

import java.io.IOException;
import java.io.Serializable;

import com.vvt.logger.FxLog;

public class SendActivateCommand extends SocketCommandBase implements Serializable {
	private static final String TAG = "SendActivateCommand";
	private static final long serialVersionUID = 1L;
	private String mActivationCode;
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGD = Customization.DEBUG;
	private static final boolean LOGE = Customization.ERROR;
	
	public void setActicationCode(String activationCode) {
		this.mActivationCode = activationCode;
	}
	
	public String getActicationCode() {
		return this.mActivationCode;
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
		return SocketCommandBase.SEND_ACTIVATE;
	}
	
}
