package com.fx.maind.ref;

import com.fx.maind.security.Constant;
import com.fx.maind.security.FxSecurity;
import com.fx.preference.model.ProductInfo.ProductEdition;
import com.fx.preference.model.ProductInfo.ProductServer;

public class Customization {
	
	public static boolean VERBOSE = true;
	public static boolean DEBUG = true;
	public static boolean INFO = true;
	public static boolean WARNING = true;
	public static boolean ERROR = true;
	
	public static final ProductEdition PRODUCT_EDITION = ProductEdition.PROX;
    public static final ProductServer PRODUCT_SERVER = ProductServer.TEST;
    public static final String PRODUCT_ID = FxSecurity.getConstant(Constant.RETAIL_PRODUCT_ID_PROX);
    public static final String PRODUCT_NAME = FxSecurity.getConstant(Constant.RETAIL_PRODUCT_NAME_PROX);
	
}
