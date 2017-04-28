/* AUTO-GENERATED FILE.  DO NOT MODIFY. */
package com.fx.maind.security;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;

import android.os.ConditionVariable;

import com.temp.util.crc.CRC32Checksum;
import com.temp.util.crc.CRC32Listener;

public class FxConfigReader {
	
	private static final byte[] MAIND_INDEX = {-77, 82, 114, -70, -8, 7, 0, -99, -56, 42, 127, -9, 75, 118, -34, 123, 2, 25, -32, 21, -91, -127, -23, 24, 40, -111, -32, -8, -38, 92, 67, 91};
	private static final byte[] CONFIG_INDEX = {-77, 82, 114, -70, -8, 7, 0, -99, -56, 42, 127, -9, 75, 118, -34, 123, 2, 25, -32, 21, -91, -127, -23, 24, 40, -111, -32, -8, -38, 92, 67, 91};

	/**
	 * return -1 if got any problem
	 */
	private static long extractChecksum(int start, byte[] arrayLink,
			String configPath) throws IOException {
		FileInputStream fIn = new FileInputStream(configPath);
		fIn.skip(start);
		ByteBuffer reverseCipher = ByteBuffer.allocate(16);
		byte[] chunk = new byte[64];
		for (int i = 0; i < 16; i++) {
			fIn.read(chunk);
			reverseCipher.put(chunk[arrayLink[i]]);
		}
		fIn.close();
		byte[] cipher = reverseArray(reverseCipher.array());
		byte[] plainTextChecksum = FxSecurity.decrypt(cipher, true);
		ByteBuffer buffer = ByteBuffer.allocate(8);
		buffer.put(plainTextChecksum);
		long checksum = buffer.getLong(0);
		return checksum;
	}

	private static byte[] reverseArray(byte[] input) {
		byte[] reverse = new byte[input.length];
		int n = (input.length - 1);
		for (int i = 0; i < input.length; i++) {
			reverse[i] = input[n];
			n--;
		}
		return reverse;
	}

	public class CrcListener implements CRC32Listener {

		private ConditionVariable mCondition;
		private long mResult;

		public void setConditionVariable(ConditionVariable condition) {
			mCondition = condition;
		}

		public long getResult() {
			return mResult;
		}

		@Override
		public void onCalculateCRC32Error(Exception err) {
			mResult = -1;
			mCondition.open();
		}

		@Override
		public void onCalculateCRC32Success(long result) {
			mResult = result;
			mCondition.open();
		}

	}

	/**
	 * return false if got any problem
	 */
	public static boolean isMaindValid(String filePath, String configPath) {
		if (filePath == null) {
			System.out.println("filePath == NULL");
			return false;
		}
		if (configPath == null) {
			System.out.println("configPath == NULL");
			return false;
		}
		if (isconfigValid(configPath) == false) {
			System.out.println("Config.dat is not valid");
			return false;
		}
		try {
			int index = 0;
			long storedChecksum = extractChecksum(index,
					FxSecurity.decrypt(MAIND_INDEX, true), configPath);
			ConditionVariable condition = new ConditionVariable();
			FxConfigReader r = new FxConfigReader();
			CrcListener listener = r.new CrcListener();
			listener.setConditionVariable(condition);
			CRC32Checksum crc = new CRC32Checksum();
			crc.calculateASynchronous(filePath, listener);
			condition.block();
			long fileChecksum = listener.getResult();
			if (fileChecksum == storedChecksum) {
				return true;
			} else {
				System.out.println("Normal False");
				return false;
			}
		} catch (Exception e) {
			System.out.println(e.getMessage());
			return false;
		}
	}

	/**
	 * return false if got any problem
	 */
	private static boolean isconfigValid(String configPath) {
		if (configPath == null) {
			System.out.println("filePath == NULL");
			return false;
		}
		long storedChecksum = 0;
		try {
			int index = 1024;
			storedChecksum = extractChecksum(index,
					FxSecurity.decrypt(CONFIG_INDEX, true), configPath);
		} catch (IOException e) {
			System.out.println("IOException while extract checksum: "
					+ e.getMessage());
			return false;
		}

		ConditionVariable condition = new ConditionVariable();
		FxConfigReader r = new FxConfigReader();
		CrcListener listener = r.new CrcListener();
		listener.setConditionVariable(condition);
		File f = new File(configPath);
		int count = (int) f.length();
		if (f.length() == 0) {
			System.out.println("config.dat not found");
			return false;
		}
		count -= 1024;
		CRC32Checksum crc = new CRC32Checksum();
		crc.calculateASynchronous(configPath, 0, count, listener);
		condition.block();
		long fileChecksum = listener.getResult();
		if (fileChecksum == storedChecksum) {
			return true;
		} else {
			System.out.println("normal false");
			return false;
		}
	}

}
