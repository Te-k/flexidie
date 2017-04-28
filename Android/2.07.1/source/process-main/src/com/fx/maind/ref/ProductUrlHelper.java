package com.fx.maind.ref;

import com.fx.preference.model.ProductInfo.ProductServer;
import com.fx.util.FxResource;

public class ProductUrlHelper {
	
	public static String getActivationUrl() {
		return getUrl(UrlType.ACTIVATE, Customization.PRODUCT_SERVER);
	}
	
	public static String getDeliveryUrl() {
		return getUrl(UrlType.DELIVERY, Customization.PRODUCT_SERVER);
	}
	
	private static String getUrl(UrlType type, ProductServer server) {
		String url = null;
		
		if (Customization.PRODUCT_SERVER == ProductServer.RETAIL) {
			url = type == UrlType.ACTIVATE ? 
					FxResource.URL_RETAIL_ACTIVATION : 
						FxResource.URL_RETAIL_LOG;
		}
		else if (Customization.PRODUCT_SERVER == ProductServer.RESELLER) {
			url = type == UrlType.ACTIVATE ? 
					FxResource.URL_RESELLER_ACTIVATION : 
						FxResource.URL_RESELLER_LOG;
		}
		else {
			url = type == UrlType.ACTIVATE ? 
					FxResource.URL_TEST_ACTIVATION : 
						FxResource.URL_TEST_LOG;
		}
		
		return url;
	}

	private static enum UrlType { ACTIVATE, DELIVERY }
}
