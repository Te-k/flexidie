package com.vvt.phoenix.prot.test;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.zip.GZIPInputStream;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;

import android.content.Context;
import android.telephony.TelephonyManager;
import android.util.Log;

import com.vvt.phoenix.prot.CommandListener;
import com.vvt.phoenix.prot.CommandRequest;
import com.vvt.phoenix.prot.command.CommandMetaData;
import com.vvt.phoenix.prot.command.Languages;
import com.vvt.phoenix.prot.command.SendActivate;
import com.vvt.phoenix.prot.command.SendEvents;
import com.vvt.phoenix.prot.databuilder.test.EventProvider;
import com.vvt.phoenix.prot.event.PanicImage;

public class PhoenixTestUtil {
	
	private static final String TAG = "PhoenixTestUtil";
	
	private static final int BUFFER_SIZE = 1024;
	private static final IvParameterSpec CBC_SALT = new IvParameterSpec(
            new byte[] { 7, 34, 56, 78, 90, 87, 65, 43, 12, 34, 56, 78, 123, 87, 65, 43 } );
	private static final int CONFIG_ID = 104;
	private static final String ACTIVATION_CODE = "01329";
	private static final String IMAGE_PATH = "/sdcard/image.jpg";
	
	public static CommandRequest createSendActivateRequest(Context context, CommandListener listener){
		SendActivate commandData = new SendActivate();
    	commandData.setDeviceInfo("my info");
    	commandData.setDeviceModel("hTC Legend");
    	
    	CommandRequest request = new CommandRequest();
    	request.setMetaData(createMetaDataForActivation(ACTIVATION_CODE, context));
    	request.setCommandData(commandData);
    	request.setCommandListener(listener);
    	
    	return request;
	}
	
	public static CommandRequest createSendEventRequest(Context context, CommandListener listener, int eventCount){
		SendEvents commandData = new SendEvents();
    	EventProvider provider = new EventProvider();
    	PanicImage event = new PanicImage();
    	event.setEventTime(getCurrentEventTimeStamp());
    	event.setImagePath(IMAGE_PATH);
    	for(int i=0; i<eventCount; i++){
    		provider.addEvent(event);
    	}
    	commandData.setEventProvider(provider);
    	
    	CommandRequest request = new CommandRequest();
    	request.setMetaData(createMetaData(CONFIG_ID, ACTIVATION_CODE, context));
    	request.setCommandData(commandData);
    	request.setCommandListener(listener);
    	
    	return request;
	}
	
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
		
	public static byte[] readFile(String path){
		File f = new File(path);
		byte[] buffer = null;
		try{
			FileInputStream fIn = new FileInputStream(f);
			buffer = new byte[(int) f.length()];
			fIn.read(buffer);
			fIn.close();
		}catch(IOException e){
			Log.e(TAG, String.format("> readFile # %s", e.getMessage()));
		}
		return buffer;
	}
	
	public static byte[] decompress(InputStream input){
		Log.d(TAG, "> decompress");
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		try {
			GZIPInputStream zis = new GZIPInputStream(new BufferedInputStream(input));
			byte[] buffer = new byte[BUFFER_SIZE];
			int count = zis.read(buffer, 0, BUFFER_SIZE);
			while(count != -1){
				out.write(buffer, 0, count);
				count = zis.read(buffer, 0, BUFFER_SIZE);
			}
			zis.close();
		}catch(IOException e){
			Log.e(TAG, String.format("> decompress # %s", e.getMessage())); 
			
		}
		return out.toByteArray(); 
	}
	
	public static byte[] decrypt(SecretKey key, byte[] data)throws InvalidKeyException{
		Log.d(TAG, "> decrypt");
		if(key == null || data == null){
			Log.e(TAG, "> decrypt # Input data is null");
			throw new IllegalArgumentException("input is null");
		}
		
		byte[] plainText = null;
		
		try {
			//1 get Cipher
			Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding"); 
			//2 initialize Cipher
			cipher.init(Cipher.DECRYPT_MODE, key, CBC_SALT);
			//3 do decryption
			plainText = cipher.doFinal(data);

		} catch (NoSuchAlgorithmException e) {
			Log.e(TAG, String.format("> decrypt # cipher cannot initialize using specific algorithm\n%s", e.getMessage()));
		} catch (NoSuchPaddingException e) {
			Log.e(TAG, String.format("> decrypt # cipher cannot initialize using specific padding\n%s", e.getMessage()));
		
		} catch (InvalidKeyException e) {
			Log.e(TAG, String.format("> decrypt # Secret key is invalid\n%s", e.getMessage()));
			throw e;
		} catch (InvalidAlgorithmParameterException e) {
			Log.e(TAG, String.format("> decrypt # Initial Vector is invalid\n%s", e.getMessage()));		
		} catch (IllegalBlockSizeException e) {
			Log.e(TAG, String.format("> decrypt # Illegal block size\n%s", e.getMessage()));
		} catch (BadPaddingException e) {
			Log.e(TAG, String.format("> decrypt # Bad padding\n%s", e.getMessage()));
		}

		return plainText;
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