package com.vvt.crc;

import com.vvt.ioutil.Customization;
import com.vvt.logger.FxLog;

public class CheckSumUtil {
	private static final String TAG = "CheckSumUtil";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	public static String getCheckSum(String cmd, String imei, String activationCode, String tail) {
		if(LOGV) FxLog.v(TAG, "getCheckSum # ENTER ...");
				
		String strCrc32 = null;

		try {
			String data = cmd + imei + activationCode + tail;
			long crc32 = CRC32Checksum.calculate(data.getBytes("UTF-8"));
			strCrc32 = Integer.toHexString((int) crc32).toUpperCase();

		} catch (Exception e) {
			if(LOGE) FxLog.e(TAG, e.toString());
		}

		if(LOGV) FxLog.v(TAG, "getCheckSum # EXIT ...");
		return strCrc32;
	}
}
