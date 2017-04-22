package com.vvt.crc;

public interface CRC32Listener {
	
	public static final int CALL_BACK_CALCULATE_CRC_SUCCESS = 1;
	public static final int CALL_BACK_CALCULATE_CRC_ERROR = 2;
	
	public void onCalculateCRC32Success(long result);
	public void onCalculateCRC32Error(Exception err);
}
