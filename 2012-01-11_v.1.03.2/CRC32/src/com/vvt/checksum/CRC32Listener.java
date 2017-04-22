package com.vvt.checksum;

public interface CRC32Listener {

	public void CRC32Completed(long value);

	public void CRC32Error(String errorMsg);
	
}
