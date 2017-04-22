package com.vvt.callmanager.std;

import android.os.Parcel;

public class Response {
	
	public static final int RESPONSE_SOLICITED = 0;
    public static final int RESPONSE_UNSOLICITED = 1;
    
	/**
	 * Type of response e.g. solicited (0) or unsolicited (1).
	 */
	public int type;
	
	/**
	 * This value represent number of serial (solicited) or response (unsolicited).
	 */
	public int number;
	
	/**
	 * For solicited only
	 */
	public int error;
	
	public static Response obtain(Parcel p) {
		Response r = new Response();
		p.setDataPosition(4);
		r.type = p.readInt();
		r.number = p.readInt();
		if (r.type == 0) r.error = p.readInt();
		p.setDataPosition(0);
		return r;
	}
}
