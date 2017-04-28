package com.fx.maind.commands;

import com.daemon_bridge.CommandResponseBase;
import com.daemon_bridge.GetProductInfoCommand;
import com.daemon_bridge.GetProductInfoCommandResponse;
import com.fx.maind.ref.Customization;
import com.vvt.daemon.appengine.AppEngine;
import com.vvt.logger.FxLog;
import com.vvt.productinfo.ProductInfo;

public class GetProductInfoCommandProcess {
	private static final String TAG = "GetProductInfoCommandProcess";
	private static final boolean VERBOSE = true;
	private static boolean LOGV = Customization.DEBUG ? VERBOSE : false;
	
	
	public static CommandResponseBase execute(AppEngine appEngine, GetProductInfoCommand getProductInfoCommand) {
		if(LOGV) FxLog.d(TAG, "# execute START");
		
		GetProductInfoCommandResponse commandResponse  = null;
		
		try {
			ProductInfo productInfo = appEngine.getProductInfo();
			int productId = productInfo.getProductId();
			String productVersion = productInfo.getProductVersion();
			
			commandResponse= new GetProductInfoCommandResponse(CommandResponseBase.SUCCESS);
			commandResponse.setProductId(productId);
			commandResponse.setProductVersion(productVersion);
		}
		catch(Throwable t) {
			if(LOGV) FxLog.e(TAG, t.toString());
			commandResponse = new GetProductInfoCommandResponse(CommandResponseBase.ERROR);
		}
		
		if(LOGV) FxLog.d(TAG, "# execute EXIT");
		return commandResponse;
	}

}
