package com.vvt.callmanager.filter;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;

import android.os.Parcel;
import android.util.Log;

import com.vvt.callmanager.std.CallInfo;


public class TestFilterHelper {
	
	public static final String TAG = "TestFilterHelper";
	
	public void testCreatingFlashDialingParcel() {
		String phoneNumber = "66817107411";
		Parcel p = FilterHelper.getFlashDialParcel(phoneNumber);
		byte[] data = p.marshall();
		Log.i(TAG, String.format("Parcel: %s", Arrays.toString(data)));
	}

	public void testParsingPhoneFromCdmaCallWaiting() {
    	String phoneNumber = 
    			FilterHelper.getPhoneNumberFromCdmaCallWaiting(
    					createParcel(cdma_call_waiting));
    	
    	Log.i(TAG, String.format("Phone Number: %s", phoneNumber));
    }
    
	public void testParsingCallInfo() {
        // GSM
		parsingCall(createParcel(one_active));
        parsingCall(createParcel(one_alerting));
		parsingCall(createParcel(one_active_one_waiting_1));
        parsingCall(createParcel(one_active_one_waiting_2));
        parsingCall(createParcel(one_active_one_waiting_3));
        parsingCall(createParcel(one_onhold_one_active));
        parsingCall(createParcel(one_unknown)); // unknown number
        parsingCall(createParcel(one_active_unknown_waiting)); // unknown number
        
        // CDMA
        parsingCall(createParcel(perfecto_verizon_idle));
        parsingCall(createParcel(perfecto_verizon_one_incoming));
    }
    
    private void parsingCall(Parcel p) {
    	ArrayList<CallInfo> calls = CallInfo.getCallInfo(p);
        Log.i(TAG, String.format("calls: %s", calls.toString()));
    }
    
    private Parcel createParcel(short[] data) {
    	ByteBuffer buffer = ByteBuffer.allocate(data.length);
    	for (short s : data) {
    		buffer.put((byte)s);
    	}
    	
    	Parcel p = Parcel.obtain();
        p.unmarshall(buffer.array(), 0, data.length);
        return p;
    }
	
	public short[] one_active = {
			0, 0, 0, 92, 0, 0, 0, 0, 130, 0, 0, 0, 0, 0, 0, 0, 
			1, 0, 0, 0, // no. of call
			0, 0, 0, 0, // state
			1, 0, 0, 0, // index
			129, 0, 0, 0, // toa
			0, 0, 0, 0, 
			0, 0, 0, 0, // isMT
			0, 0, 0, 0, 
			1, 0, 0, 0, // voiceSetting
			0, 0, 0, 0, 
			10, 0, 0, 0, 48, 0, 56, 0, 53, 0, 48, 0, 53, 0, 56, 0, 56, 0, 52, 0, 54, 0, 48, 0, 0, 0, 0, 0, 
			0, 0, 0, 0, 
			255, 255, 255, 255, 
			0, 0, 0, 0, 
			0, 0, 0, 0};

	short one_alerting[] = { 
			0, 0, 0, 100, 0, 0, 0, 0, 183, 0, 0, 0, 0, 0, 0, 0, 
			1, 0, 0, 0, 
			3, 0, 0, 0, // state
			1, 0, 0, 0, // index
			145, 0, 0, 0, // toa
			0, 0, 0, 0, 
			0, 0, 0, 0, // isMt
			0, 0, 0, 0, 
			1, 0, 0, 0, // voiceSetting
			0, 0, 0, 0, 
			0, 0, 0, 0, 
			12, 0, 0, 0, 43, 0, 54, 0, 54, 0, 56, 0, 53, 0, 48, 0, 53, 0, 56, 0, 56, 0, 52, 0, 54, 0, 48, 0, 0, 0, 0, 0, 
			0, 0, 0, 0, 
			255, 255, 255, 255, 
			0, 0, 0, 0, 
			0, 0, 0, 0 };

	public short[] one_active_one_waiting_1 = { 0, 0, 0, 152, 0, 0, 0, 0, 8, 8, 8, 8, 0, 0, 0, 0, 
    		2, 0, 0, 0, // no. of calls
    		0, 0, 0, 0, // state
    		1, 0, 0, 0, // index
    		129, 0, 0, 0, // toa
    		0, 0, 0, 0, 
    		0, 0, 0, 0, // isMT
    		0, 0, 0, 0, 
    		1, 0, 0, 0, // voiceSetting
    		0, 0, 0, 0, 
    		0, 0, 0, 0, 
    		3, 0, 0, 0, 49, 0, 56, 0, 49, 0, 0, 0, 
    		0, 0, 0, 0, 
    		255, 255, 255, 255, 
    		0, 0, 0, 0, 
    		5, 0, 0, 0, // state
    		2, 0, 0, 0, // index
    		129, 0, 0, 0, // toa
    		0, 0, 0, 0, 
    		1, 0, 0, 0, // isMT
    		0, 0, 0, 0, 
    		1, 0, 0, 0, // voiceSetting
    		0, 0, 0, 0, 
    		0, 0, 0, 0, 
    		10, 0, 0, 0, 48, 0, 56, 0, 53, 0, 48, 0, 53, 0, 56, 0, 56, 0, 52, 0, 54, 0, 48, 0, 0, 0, 0, 0, 
    		0, 0, 0, 0, 
    		255, 255, 255, 255, 
    		0, 0, 0, 0 };
    
    public short[] one_active_one_waiting_2 = {
    		0, 0, 0, 168, 0, 0, 0, 0, 97, 0, 0, 0, 0, 0, 0, 0, 
			2, 0, 0, 0, 
			0, 0, 0, 0, // state
			1, 0, 0, 0, // index
			129, 0, 0, 0, // toa
			0, 0, 0, 0, 
			0, 0, 0, 0, // isMt
			0, 0, 0, 0, 
			1, 0, 0, 0, // voiceSetting
			0, 0, 0, 0, 
			10, 0, 0, 0, 48, 0, 56, 0, 53, 0, 48, 0, 53, 0, 56, 0, 56, 0, 52, 0, 54, 0, 48, 0, 0, 0, 0, 0, 
			0, 0, 0, 0, 
			255, 255, 255, 255, 
			0, 0, 0, 0, 
			0, 0, 0, 0, 
			5, 0, 0, 0, //state
			2, 0, 0, 0, //index
			161, 0, 0, 0, // toa
			0, 0, 0, 0, 
			1, 0, 0, 0, // isMt
			0, 0, 0, 0, 
			1, 0, 0, 0, // voiceSetting
			0, 0, 0, 0, 
			10, 0, 0, 0, 48, 0, 56, 0, 49, 0, 55, 0, 49, 0, 48, 0, 55, 0, 52, 0, 49, 0, 49, 0, 0, 0, 0, 0, 
			0, 0, 0, 0, 
			255, 255, 255, 255, 
			0, 0, 0, 0, 
			0, 0, 0, 0};

	short one_active_one_waiting_3[] = { 
			0, 0, 0, 152, 0, 0, 0, 0, 8, 8, 8, 8, 0, 0, 0, 0, 
			2, 0, 0, 0, // no. of calls
			0, 0, 0, 0, // state
			1, 0, 0, 0, // index
			129, 0, 0, 0, // toa
			0, 0, 0, 0, 
			0, 0, 0, 0, // isMt
			0, 0, 0, 0, 
			0, 0, 0, 0, // voiceSetting
			0, 0, 0, 0, 
			3, 0, 0, 0, 49, 0, 56, 0, 49, 0, 0, 0, 
			0, 0, 0, 0, 
			255, 255, 255, 255, 
			0, 0, 0, 0, 
			0, 0, 0, 0, 
			5, 0, 0, 0, // state
			2, 0, 0, 0, // index
			129, 0, 0, 0, // toa
			0, 0, 0, 0, 
			1, 0, 0, 0, // isMt
			0, 0, 0, 0, 
			0, 0, 0, 0, // voiceSetting
			0, 0, 0, 0, 
			10, 0, 0, 0, 48, 0, 56, 0, 53, 0, 48, 0, 53, 0, 56, 0, 56, 0, 52, 0, 54, 0, 48, 0, 0, 0, 0, 0, 
			0, 0, 0, 0, 
			255, 255, 255, 255, 
			0, 0, 0, 0, 
			0, 0, 0, 0 };

	public short[] one_onhold_one_active = {0, 0, 0, 168, 0, 0, 0, 0, 64, 1, 0, 0, 0, 0, 0, 0, 
    		2, 0, 0, 0, // no. of calls
    		1, 0, 0, 0, // state
    		1, 0, 0, 0, // index
    		255, 0, 0, 0, // toa
    		0, 0, 0, 0, 
    		0, 0, 0, 0, // isMT	
    		0, 0, 0, 0, 	
    		1, 0, 0, 0, // voiceSetting	
    		0, 0, 0, 0, 	
    		10, 0, 0, 0, 48, 0, 56, 0, 53, 0, 48, 0, 53, 0, 56, 0, 56, 0, 52, 0, 54, 0, 48, 0, 0, 0, 0, 0, 	
    		2, 0, 0, 0, // readInt	
    		0, 0, 0, 0, 0, 0, 0, 0, // readString	
    		2, 0, 0, 0, // readInt	
    		0, 0, 0, 0, // state	
    		2, 0, 0, 0, // index	
    		255, 0, 0, 0, // toa
    		0, 0, 0, 0, 	
    		0, 0, 0, 0, // isMT	
    		0, 0, 0, 0, 	
    		1, 0, 0, 0, // voiceSetting
    		0, 0, 0, 0, 	
    		10, 0, 0, 0, 48, 0, 56, 0, 54, 0, 54, 0, 57, 0, 56, 0, 48, 0, 56, 0, 48, 0, 55, 0, 0, 0, 0, 0, 	
    		2, 0, 0, 0, 	
    		0, 0, 0, 0, 	
    		0, 0, 0, 0, 	
    		2, 0, 0, 0};
    
    public short[] one_unknown = {
    		0, 0, 0, 72, 0, 0, 0, 0, 8, 8, 8, 8, 0, 0, 0, 0, 
			1, 0, 0, 0, // no. of call
			4, 0, 0, 0, // state
			1, 0, 0, 0, // index
			0, 0, 0, 0, // toa
			0, 0, 0, 0, 
			1, 0, 0, 0, // isMT
			0, 0, 0, 0, 
			1, 0, 0, 0, // voiceSetting
			0, 0, 0, 0, 
			0, 0, 0, 0, 
			0, 0, 0, 0, 0, 0, 0, 0, // phone number
			255, 255, 255, 255, 
			0, 0, 0, 0, 
			0, 0, 0, 0};

	short one_active_unknown_waiting[] = {
    		0, 0, 0, 144, 0, 0, 0, 0, 8, 8, 8, 8, 0, 0, 0, 0, 
    		2, 0, 0, 0, // no. of call
    		0, 0, 0, 0, // state
    		1, 0, 0, 0, // index
    		128, 0, 0, 0, // toa
    		1, 0, 0, 0, 
    		1, 0, 0, 0, // isMt
    		0, 0, 0, 0, 
    		1, 0, 0, 0, // voiceSetting
    		0, 0, 0, 0, 
    		10, 0, 0, 0, 48, 0, 56, 0, 49, 0, 56, 0, 48, 0, 53, 0, 56, 0, 55, 0, 51, 0, 57, 0, 
    		0, 0, 0, 0, 
    		0, 0, 0, 0, 
    		255, 255, 255, 255, 
    		0, 0, 0, 0, 
    		0, 0, 0, 0, 
    		5, 0, 0, 0, // state
    		2, 0, 0, 0, // index
    		0, 0, 0, 0, // toa
    		1, 0, 0, 0, 
    		1, 0, 0, 0, // isMt
    		0, 0, 0, 0, 
    		1, 0, 0, 0, // voiceSetting
    		0, 0, 0, 0, 
    		255, 255, 255, 255, 
    		1, 0, 0, 0, 
    		255, 255, 255, 255, 
    		0, 0, 0, 0, 
    		0, 0, 0, 0	
    };
    
    public short[] perfecto_verizon_idle = { 
    		0, 0, 0, 76, 0, 0, 0, 0, 159, 0, 0, 0, 0, 0, 0, 0, 
    		1, 0, 0, 0, // no. of call
    		0, 0, 0, 0, // state
    		254, 0, 0, 0, // index
    		129, 0, 0, 0, // toa
    		0, 0, 0, 0, 
    		0, 0, 0, 0, // isMt
    		0, 0, 0, 0, 
    		0, 0, 0, 0, // voiceSetting
    		0, 0, 0, 0, 
    		4, 0, 0, 0, 35, 0, 55, 0, 55, 0, 55, 0, 
    		0, 0, 0, 0, 
    		0, 0, 0, 0, 
    		255, 255, 255, 255, 
    		0, 0, 0, 0 };
    
    public short[] perfecto_verizon_one_incoming = { 
    		0, 0, 0, 148, 0, 0, 0, 0, 155, 0, 0, 0, 0, 0, 0, 0, 
    		2, 0, 0, 0, 
    		4, 0, 0, 0, 
    		1, 0, 0, 0, 
    		129, 0, 0, 0, 
    		0, 0, 0, 0, 
    		1, 0, 0, 0, 
    		0, 0, 0, 0, 
    		1, 0, 0, 0, 
    		0, 0, 0, 0, 
    		10, 0, 0, 0, 52, 0, 52, 0, 51, 0, 53, 0, 52, 0, 53, 0, 52, 0, 57, 0, 52, 0, 49, 0, 
    		0, 0, 0, 0, 
    		0, 0, 0, 0, 
    		255, 255, 255, 255, 
    		0, 0, 0, 0, 
    		0, 0, 0, 0, 
    		254, 0, 0, 0, 
    		129, 0, 0, 0, 
    		0, 0, 0, 0, 
    		0, 0, 0, 0, 
    		0, 0, 0, 0, 
    		0, 0, 0, 0, 
    		0, 0, 0, 0, 
    		4, 0, 0, 0, 35, 0, 55, 0, 55, 0, 55, 0, 
    		0, 0, 0, 0, 
    		0, 0, 0, 0, 
    		255, 255, 255, 255, 
    		0, 0, 0, 0 };
    
    public short[] cdma_call_waiting = { 0, 0, 0, 64, 1, 0, 0, 0, 1, 4, 0, 0, 10, 0, 0, 0, 55, 0, 49, 0, 51, 0, 56, 0, 57, 0, 56, 0, 49, 0, 51, 0, 54, 0, 51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	
}
