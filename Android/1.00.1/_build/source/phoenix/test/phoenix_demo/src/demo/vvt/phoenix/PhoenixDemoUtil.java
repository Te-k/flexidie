package demo.vvt.phoenix;

import java.text.SimpleDateFormat;

import android.content.Context;
import android.telephony.TelephonyManager;

import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.Languages;

public class PhoenixDemoUtil {
	
	
	public static CommandMetaData createMetaDataForActivation(String activationCode, Context context){
		CommandMetaData metaData;

		metaData = new CommandMetaData();
		metaData.setProtocolVersion(1);
		metaData.setProductId(4202);
		metaData.setProductVersion("-1.00");
		
		metaData.setConfId(0);
		
		metaData.setDeviceId(getDeviceId(context));
		metaData.setActivationCode(activationCode);
		metaData.setLanguage(Languages.ENGLISH);
		metaData.setPhoneNumber(getPhoneNumber(context));
		metaData.setMcc(getMcc(context));
		metaData.setMnc(getMnc(context));
		metaData.setImsi(getImsi(context));
		metaData.setHostUrl("");
		metaData.setEncryptionCode(1);
		metaData.setCompressionCode(1);
		
		return metaData;
	}
	
	public static CommandMetaData createMetaData(int configId, String activationCode, Context context){
		CommandMetaData metaData;

		metaData = new CommandMetaData();
		metaData.setProtocolVersion(1);
		metaData.setProductId(4202);
		metaData.setProductVersion("-1.00");
		
		metaData.setConfId(configId);
		
		metaData.setDeviceId(getDeviceId(context));
		metaData.setActivationCode(activationCode);
		metaData.setLanguage(Languages.ENGLISH);
		metaData.setPhoneNumber(getPhoneNumber(context));
		metaData.setMcc(getMcc(context));
		metaData.setMnc(getMnc(context));
		metaData.setImsi(getImsi(context));
		metaData.setHostUrl("");
		metaData.setEncryptionCode(1);
		metaData.setCompressionCode(1);
		
		return metaData;
	}
	
	public static String getDeviceId(Context context){

		TelephonyManager teleMan = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
    	/*
    	 *  require permission android.permission.READ_PHONE_STATE
    	 */
    	String deviceId = teleMan.getDeviceId();
 
    	return deviceId;
	}
	
	public static String getImsi(Context context){

		TelephonyManager teleMan = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
    	String imsi = teleMan.getSubscriberId();
    	if(imsi == null){
    		imsi = "";
    	}
 
    	return imsi;
	}
	
	public static String getPhoneNumber(Context context){
		TelephonyManager teleMan = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
		String number = teleMan.getLine1Number();
		if(number == null){
			return "";
		}
		
		return number;
	}
	
	public static String getMcc(Context context){
		//return "06";
		//return String.valueOf(context.getResources().getConfiguration().mcc);
		
		TelephonyManager telMan = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
		String networkOperatorString = telMan.getNetworkOperator();
		String mcc;
		if (networkOperatorString.length() >= 4) {
			mcc = networkOperatorString.substring(0, 3);
		}else{
			mcc = "";
		}
		
		return mcc;
	}

	public static String getMnc(Context context){
		//return "01";
		//return String.valueOf(context.getResources().getConfiguration().mnc);
		
		TelephonyManager telMan = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
		String networkOperatorString = telMan.getNetworkOperator();
		String mnc;
		if (networkOperatorString.length() >= 4) {
			mnc = networkOperatorString.substring(3);
		}else{
			mnc = "";
		}
		
		return mnc;
	}
	
	public static String getCurrentEventTimeStamp(){
		String time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(System.currentTimeMillis());
		
		return time;
	}
	
	public static String getCurrentSmsTimeStamp(){
		String time = new SimpleDateFormat("dd-MM-yyyy HH:mm").format(System.currentTimeMillis());

		
		return time;
	}
}