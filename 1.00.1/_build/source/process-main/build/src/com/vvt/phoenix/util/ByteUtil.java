package com.vvt.phoenix.util;

import java.io.UnsupportedEncodingException;
import java.nio.ByteBuffer;

import com.vvt.logger.FxLog;

import android.util.Log;

public class ByteUtil {
	
	private static final String TAG = "ByteUtil";
	
	//********************************************* convert primitive to bytes ************************//

	public static byte[] toBytes(short value){
		ByteBuffer buffer = ByteBuffer.allocate(2);
		buffer.putShort(value);
		
		return buffer.array();
	}
	
	public static byte[] toBytes(int value){
		ByteBuffer buffer = ByteBuffer.allocate(4);
		buffer.putInt(value);
		
		return buffer.array();
	}
	
	public static byte[] toBytes(long value){
		ByteBuffer buffer = ByteBuffer.allocate(8);
		buffer.putLong(value);
		
		return buffer.array();
	}	
	
	public static byte[] toBytes(double value){
		ByteBuffer buffer = ByteBuffer.allocate(8);
		buffer.putDouble(value);
		
		return buffer.array();
	}
	
	public static byte[] toBytes(float value){
		ByteBuffer buffer = ByteBuffer.allocate(4);
		buffer.putFloat(value);
		
		return buffer.array();
	}
	
	public static byte[] toBytes(String str){		
		byte[] result = null;
		
		try {
			result = str.getBytes("UTF-8");
		} catch (UnsupportedEncodingException e) {
			result = new byte[0];
			FxLog.e(TAG, String.format("> toBytes # Got UnsupportedEncodingException : %s", e.getMessage()));
		}
	
		return result;
	}
	

	//********************************************* convert bytes to primitive ************************//
	
	public static short toShort(byte[] bytes){
		ByteBuffer byteBuffer = ByteBuffer.allocate(bytes.length);
		byteBuffer.put(bytes);
		return byteBuffer.getShort(0);
	}
	
	public static int toInt(byte[] bytes){
		ByteBuffer byteBuffer = ByteBuffer.allocate(bytes.length);
		byteBuffer.put(bytes);
		return byteBuffer.getInt(0);
	}
	
	public static long toLong(byte[] bytes){
		ByteBuffer byteBuffer = ByteBuffer.allocate(bytes.length);
		byteBuffer.put(bytes);
		return byteBuffer.getLong(0);
	}
	
	public static float toFloat(byte[] bytes){
		ByteBuffer byteBuffer = ByteBuffer.allocate(bytes.length);
		byteBuffer.put(bytes);
		return byteBuffer.getFloat(0);
	}

	public static double toDouble(byte[] bytes){
		ByteBuffer byteBuffer = ByteBuffer.allocate(bytes.length);
		byteBuffer.put(bytes);
		return byteBuffer.getDouble(0);
	}
	
	public static String toString(byte[] bytes){
		String result = null;
		try {
			result = new String(bytes, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			FxLog.e(TAG, String.format("> toString # Got UnsupportedEncodingException : %s", e.getMessage()));
		}
		
		return result;
	}
}
