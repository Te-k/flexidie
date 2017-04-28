package com.vvt.phoenix.util.test;

import java.io.UnsupportedEncodingException;
import java.util.Arrays;

import android.test.AndroidTestCase;
import android.util.Log;

import com.vvt.phoenix.util.ByteUtil;

public class ByteUtilTest extends AndroidTestCase{
	
	private static final String TAG = "ByteUtilTest";
	private static final boolean TEST_SHORT_TO_BYTES = true;
	private static final boolean TEST_INT_TO_BYTES = true;
	private static final boolean TEST_LONG_TO_BYTES = true;
	private static final boolean TEST_FLOAT_TO_BYTES = true;
	private static final boolean TEST_DOUBLE_TO_BYTES = true;
	private static final boolean TEST_STRING_TO_BYTES = true;
	
	private static final boolean TEST_BYTES_TO_SHORT = true;
	private static final boolean TEST_BYTES_TO_INT = true;
	private static final boolean TEST_BYTES_TO_LONG = true;
	private static final boolean TEST_BYTES_TO_FLOAT = true;
	private static final boolean TEST_BYTES_TO_DOUBLE = true;
	private static final boolean TEST_BYTES_TO_STRING = true;

	public void testCases(){
		
		// test convert from primitives to byte arrays
		
		if(TEST_SHORT_TO_BYTES){
			_testShortToBytes();
		}
		if(TEST_INT_TO_BYTES){
			_testIntToBytes();
		}
		if(TEST_LONG_TO_BYTES){
			_testLongToBytes();
		}
		if(TEST_FLOAT_TO_BYTES){
			_testFloatToBytes();
		}
		if(TEST_DOUBLE_TO_BYTES){
			_testDoubleToBytes();
		}
		if(TEST_STRING_TO_BYTES){
			_testStringToBytes();
		}
		
		// test convert from byte arrays to primitives
		
		if(TEST_BYTES_TO_SHORT){
			_testBytesToShort();
		}
		if(TEST_BYTES_TO_INT){
			_testBytesToInt();
		}
		if(TEST_BYTES_TO_LONG){
			_testBytesToLong();
		}
		if(TEST_BYTES_TO_FLOAT){
			_testBytesToFloat();
		}
		if(TEST_BYTES_TO_DOUBLE){
			_testBytesToDouble();
		}
		if(TEST_BYTES_TO_STRING){
			_testBytesToString();
		}
	}
	
	// ************************************** test cases for test convert from primitives to byte arrays **************************** //
	
	private void _testShortToBytes(){
		Log.d(TAG, "_testShortToBytes");
		//max value
		short value = Short.MAX_VALUE;
		byte[] expected = {0x7F, (byte) 0xFF};
		byte[] result = ByteUtil.toBytes(value);
		assertEquals(true, Arrays.equals(expected, result));
		
		//min value
		value = Short.MIN_VALUE;
		expected[0] = (byte) 0x80;
		expected[1] = (byte) 0x00;
		result = ByteUtil.toBytes(value);
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testIntToBytes(){
		Log.d(TAG, "_testIntToBytes");
		//max value
		int value = Integer.MAX_VALUE;
		byte[] expected = {0x7F, (byte) 0xFF, (byte) 0xFF, (byte) 0xFF};
		byte[] result = ByteUtil.toBytes(value);
		assertEquals(true, Arrays.equals(expected, result));
		assertEquals(true, Arrays.equals(toByta(Integer.MAX_VALUE), result));
		
		//min value
		value = Integer.MIN_VALUE;
		expected[0] = (byte) 0x80;
		expected[1] = (byte) 0x00;
		expected[2] = (byte) 0x00;
		expected[3] = (byte) 0x00;
		result = ByteUtil.toBytes(value);
		assertEquals(true, Arrays.equals(expected, result));
		
	}
	
	private void _testLongToBytes(){
		Log.d(TAG, "_testLongToBytes");
		//max value
		long value = Long.MAX_VALUE;
		byte[] expected = {0x7F, (byte) 0xFF, (byte) 0xFF, (byte) 0xFF, (byte) 0xFF, (byte) 0xFF, (byte) 0xFF, (byte) 0xFF};
		byte[] result = ByteUtil.toBytes(value);
		assertEquals(true, Arrays.equals(expected, result));
		
		//min value
		value = Long.MIN_VALUE;
		expected[0] = (byte) 0x80;
		expected[1] = (byte) 0x00;
		expected[2] = (byte) 0x00;
		expected[3] = (byte) 0x00;
		expected[4] = (byte) 0x00;
		expected[5] = (byte) 0x00;
		expected[6] = (byte) 0x00;
		expected[7] = (byte) 0x00;
		result = ByteUtil.toBytes(value);
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testFloatToBytes(){
		Log.d(TAG, "_testFloatToBytes");
		// max value
		float value = Float.MAX_VALUE;
		byte[] expected = toByta(Float.floatToRawIntBits(Float.MAX_VALUE));
		byte[] result = ByteUtil.toBytes(value);
		assertEquals(true, Arrays.equals(expected, result));

		//min value
		value = Float.MIN_VALUE;
		expected = toByta(Float.floatToRawIntBits(Float.MIN_VALUE));
		result = ByteUtil.toBytes(value);
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testDoubleToBytes(){
		Log.d(TAG, "_testDoubleToBytes");
		// max value
		double value = Double.MAX_VALUE;
		byte[] expected = toByta(Double.doubleToRawLongBits(Double.MAX_VALUE));
		byte[] result = ByteUtil.toBytes(value);
		assertEquals(true, Arrays.equals(expected, result));

		//min value
		value = Double.MIN_VALUE;
		expected = toByta(Double.doubleToRawLongBits(Double.MIN_VALUE));
		result = ByteUtil.toBytes(value);
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	private void _testStringToBytes(){
		Log.d(TAG, "_testStringToBytes");
		String str = "I'm Johnny";
		byte[] expected = null;
		try {
			expected = str.getBytes("UTF-8");
		} catch (UnsupportedEncodingException e) {
			fail(e.getMessage());
		}
		byte[] result = ByteUtil.toBytes(str);
		assertEquals(true, Arrays.equals(expected, result));
	}
	
	// ************************************** test cases for test convert from primitives to byte arrays **************************** //
	
	private void _testBytesToShort(){
		Log.d(TAG, "_testBytesToShort");
		// max value
		byte[] value = {0x7F, (byte) 0xFF};
		short expected = Short.MAX_VALUE;
		short result = ByteUtil.toShort(value);
		assertEquals(expected, result);
		
		// min value
		value[0] = (byte) 0x80;
		value[1] = (byte) 0x00;
		expected = Short.MIN_VALUE;
		result = ByteUtil.toShort(value);
		assertEquals(expected, result);
	}
	
	private void _testBytesToInt(){
		Log.d(TAG, "_testBytesToInt");
		// max value
		byte[] value = {0x7F, (byte) 0xFF, (byte) 0xFF, (byte) 0xFF};
		int expected = Integer.MAX_VALUE;
		int result = ByteUtil.toInt(value);
		assertEquals(expected, result);
		
		// min value
		value[0] = (byte) 0x80;
		value[1] = (byte) 0x00;
		value[2] = (byte) 0x00;
		value[3] = (byte) 0x00;
		expected = Integer.MIN_VALUE;
		result = ByteUtil.toInt(value);
		assertEquals(expected, result);
	}
	
	private void _testBytesToLong(){
		Log.d(TAG, "_testBytesToLong");
		// max value
		byte[] value = {0x7F, (byte) 0xFF, (byte) 0xFF, (byte) 0xFF, (byte) 0xFF, (byte) 0xFF, (byte) 0xFF, (byte) 0xFF};
		long expected = Long.MAX_VALUE;
		long result = ByteUtil.toLong(value);
		assertEquals(expected, result);
		
		// min value
		value[0] = (byte) 0x80;
		value[1] = (byte) 0x00;
		value[2] = (byte) 0x00;
		value[3] = (byte) 0x00;
		value[4] = (byte) 0x00;
		value[5] = (byte) 0x00;
		value[6] = (byte) 0x00;
		value[7] = (byte) 0x00;
		expected = Long.MIN_VALUE;
		result = ByteUtil.toLong(value);
		assertEquals(expected, result);
	}
	
	private void _testBytesToFloat(){
		Log.d(TAG, "_testBytesToFloat");
		// max value
		byte[] value = toByta(Float.floatToRawIntBits(Float.MAX_VALUE));
		float expected = Float.MAX_VALUE;
		float result = ByteUtil.toFloat(value);
		assertEquals(expected, result);
		
		// min value
		value = toByta(Float.floatToRawIntBits(Float.MIN_VALUE));
		expected = Float.MIN_VALUE;
		result = ByteUtil.toFloat(value);
		assertEquals(expected, result);
	}
	
	private void _testBytesToDouble(){
		Log.d(TAG, "_testBytesToDouble");
		// max value
		byte[] value = toByta(Double.doubleToRawLongBits(Double.MAX_VALUE));
		double expected = Double.MAX_VALUE;
		double result = ByteUtil.toDouble(value);
		assertEquals(expected, result);
		
		// min value
		value = toByta(Double.doubleToRawLongBits(Double.MIN_VALUE));
		expected = Double.MIN_VALUE;
		result = ByteUtil.toDouble(value);
		assertEquals(expected, result);
	}
	
	private void _testBytesToString(){
		Log.d(TAG, "_testBytesToString");
		String expected = "Hi How are you?\n\r\t";
		byte[] value = null;
		try {
			value = expected.getBytes("UTF-8");
		} catch (UnsupportedEncodingException e) {
			fail(e.getMessage());
		}
		String result = ByteUtil.toString(value);
		assertEquals(expected, result);
	}
	
	
	// ************************************** utilities methods **************************** //
	
	private byte[] toByta(int data) {
	    return new byte[] {
	        (byte)((data >> 24) & 0xff),
	        (byte)((data >> 16) & 0xff),
	        (byte)((data >> 8) & 0xff),
	        (byte)((data >> 0) & 0xff),
	    };
	}
	private byte[] toByta(long data) {
	    return new byte[] {
	    	(byte)((data >> 56) & 0xff),
		    (byte)((data >> 48) & 0xff),
		    (byte)((data >> 40) & 0xff),
		    (byte)((data >> 32) & 0xff),
	        (byte)((data >> 24) & 0xff),
	        (byte)((data >> 16) & 0xff),
	        (byte)((data >> 8) & 0xff),
	        (byte)((data >> 0) & 0xff),
	    };
	}
}
