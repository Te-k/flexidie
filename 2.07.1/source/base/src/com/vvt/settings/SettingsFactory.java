/*package com.vvt.settings;

import com.vvt.base.ProductType;
import com.vvt.base.security.Constant;
import com.vvt.base.security.FxSecurity;
import com.vvt.logger.FxLog;

public class SettingsFactory  {
	private static final boolean LOGV = true;
	private static final String  TAG = "SettingsFactory";

	public static SettingsBase getSetting()  {

		int productId =  Integer.parseInt(FxSecurity.getConstant(Constant.PRODUCT_ID));
		if(LOGV) FxLog.v(TAG, "constructor # productId  " + productId);
		
		ProductType productType = ProductType.forValue(productId);
		if(LOGV) FxLog.v(TAG, "constructor # productType  " + productType);
		
		return getSetting(productType);
	}

	private static SettingsBase getSetting(ProductType productType) {
		switch (productType) {
		case CYCLOPS:
			return new CyclopsSettings();
		case FLEXISPY:
			return new FlexiSpySettings();
		default:
			FxLog.e(TAG, "productType :" + productType + " not found!");
			return null;
		}
	}
}
*/