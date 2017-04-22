package com.apptest.resource;

import com.vvt.prot.CommandMetaData;
import com.vvt.prot.command.CompressionType;
import com.vvt.prot.command.EncryptionType;
import com.vvt.prot.command.Languages;
import com.vvt.prot.command.TransportDirectives;
import com.vvt.std.Constant;
import com.vvt.std.PhoneInfo;

public class Configuration {

	private static int productType = 0; // 0 = Cyclops, 1 = FeelSecure 
	private static final int CYCLOPS_PRODUCT_ID = 4103; //FeelSecure
	private static final int FEEL_SECURE_PRODUCT_ID = 4203; //FeelSecure
	private static final String ACTIVATION_CODE = "013918";
	private static final String FEEL_SECURE_URL = "http://192.168.2.201:8880/Rainbow-WAR-FeelSecureCore/gateway";
	private static final String CYCLOPS_URL = "http://202.176.88.55:8880/Phoenix-WAR-CyclopsCore/gateway";
	
	public static String getServerUrl() {
		String url = CYCLOPS_URL;
		if (productType == 1) {
			url = FEEL_SECURE_URL;
		}
		return url;
	}
	
	public static final CommandMetaData initCommandMetaData(int confid) {
		CommandMetaData cmdMetaData = new CommandMetaData();
		cmdMetaData.setProtocolVersion(1);
		cmdMetaData.setProductId(getProductId());
		cmdMetaData.setProductVersion("1.0");
		cmdMetaData.setConfId(confid);
		cmdMetaData.setDeviceId(PhoneInfo.getIMEI());
		cmdMetaData.setActivationCode(ACTIVATION_CODE);
		cmdMetaData.setLanguage(Languages.ENGLISH);
		cmdMetaData.setPhoneNumber(PhoneInfo.getOwnNumber());
		cmdMetaData.setMcc(Constant.EMPTY_STRING + PhoneInfo.getMCC());
		cmdMetaData.setMnc(Constant.EMPTY_STRING + PhoneInfo.getMNC());
		cmdMetaData.setImsi(PhoneInfo.getIMSI());
		cmdMetaData.setTransportDirective(TransportDirectives.NON_RESUMABLE);
		cmdMetaData.setEncryptionCode(EncryptionType.NO_ENCRYPTION.getId());
		cmdMetaData.setCompressionCode(CompressionType.NO_COMPRESS.getId());
		return cmdMetaData;
	}
	
	private static int getProductId() {
		int productId = CYCLOPS_PRODUCT_ID;
		if (productType == 1) {
			productId = FEEL_SECURE_PRODUCT_ID;
		}
		return productId;
	}
}
