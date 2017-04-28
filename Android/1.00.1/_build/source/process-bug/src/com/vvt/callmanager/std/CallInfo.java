package com.vvt.callmanager.std;

import java.util.ArrayList;

import android.os.Parcel;
import android.telephony.PhoneNumberUtils;

public class CallInfo {
	
	private int mPosition;
	private int mIndex;
	private int mDirection;
	private int mState;
	private String mNumber;
	
	public static ArrayList<CallInfo> getCallInfo(Parcel p) {
		ArrayList<CallInfo> calls = new ArrayList<CallInfo>();
		
		p.setDataPosition(16);
		
		String phoneNumber = null;
		CallInfo call = null;
		
		int pos, state, index, toa, isMt = 0;
		int num = p.readInt();
		
		for (int i = 0 ; i < num ; i++) {
			switch (i) {
				case 0:
					pos = p.dataPosition();
					break;
				default:
					pos = calculateNextPosition(p);
					p.setDataPosition(pos);
			}
			
			state = p.readInt();
			index = p.readInt();
			
			toa = p.readInt(); // TOA
			p.readInt(); // isMpty
			isMt = p.readInt(); // (isMt = direction: 0=out, 1=in)
			p.readInt(); // alpha
			p.readInt(); // voiceSetting
			p.readInt(); // isVoicePrivacy
			
			// Seems not totally correct, but works great so far
			if (p.readInt() > 0) {
				p.setDataPosition(p.dataPosition() - 4);
			}
			
			phoneNumber = PhoneNumberUtils.stringFromStringAndTOA(p.readString(), toa);
			
			if (index > 0 && index < 20) {
				call = new CallInfo(index, isMt, state, phoneNumber);
				call.setPosition(pos);
				calls.add(call);
			}
		}
		
		return calls;
	}
	
	private static int calculateNextPosition(Parcel p) {
    	int currentPosition = p.dataPosition();
    	for (int i = 0; i < 10; i++) {
    		if (isPatternMatch(p)) {
    			break;
    		}
    		else {
    			currentPosition += 4;
    			p.setDataPosition(currentPosition);
    		}
    	}
    	return currentPosition;
    }
	
	private static boolean isPatternMatch(Parcel p) {
    	int state = p.readInt();
    	int index = p.readInt();
    	int toa = p.readInt(); // toa
    	int isMpty = p.readInt(); // isMpty
    	int isMt = p.readInt();
    	p.readInt(); // als
    	int voiceSettings = p.readInt();
    	
    	return (state >= 0 && state <= 5) &&
    		(index > 0) &&
    		(toa == 0 || toa > 100) &&
    		(isMpty == 0 || isMpty == 1) &&
    		(isMt == 0 || isMt == 1) && 
    		(voiceSettings == 0 || voiceSettings == 1);
    }
	
	public CallInfo(int id, int direction, int status, String phoneNumber) {
		mIndex = id;
		mDirection = direction;
		mState = status;
		mNumber = phoneNumber;
	}
	
	public void setPosition(int pos) {
		mPosition = pos;
	}
	
	public int getPosition() {
		return mPosition;
	}
	
	public int getIndex() {
		return mIndex;
	}
	
	public int getDirection() {
		return mDirection;
	}
	
	public int getState() {
		return mState;
	}
	
	public String getNumber() {
		return mNumber;
	}
	
	@Override
	public String toString() {
		return String.format("idx: %d, dir: %d, sta: %d, num: %s", 
				mIndex, mDirection, mState, mNumber);
	}
}
