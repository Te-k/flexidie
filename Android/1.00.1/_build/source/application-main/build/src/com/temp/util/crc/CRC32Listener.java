package com.temp.util.crc;

public interface CRC32Listener {
	public void onCalculateCRC32Success(long result);
	public void onCalculateCRC32Error(Exception err);
}
