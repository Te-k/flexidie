package com.vvt.phoenix.prot.test;

import java.nio.ByteBuffer;

import junit.framework.Assert;
import android.util.Log;

import com.vvt.phoenix.util.ByteUtil;

/**
 * @author tanakharn
 * @deprecated
 */
public class ByteUtilTest {

	private static final String TAG = "com.vvt.protocol.test.ByteUtilTest";
	//private Context context;
	//private  FileOutputStream fOut = null;
	
	// Test Cases
	private static int[] testInt = {0, 129, 1024, 65536, 2147483647, -128, -1024, -2147483648};
	private static byte[][] expectedInt = {{0x0, 0x0, 0x0, 0x0},								// 0
									{0x0, 0x0, 0x0, (byte)0x81},						// 129
									{0x0, 0x0, 0x4, 0x0},								// 1024
									{0x0, 0x1, 0x0, 0x0},								// 65536
									{0x7F,(byte)0xFF,(byte)0xFF, (byte)0xFF},			// 2147483647	(maximum int value)
									{(byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0x80},	// -128
									{(byte)0xFF, (byte)0xFF, (byte)0xFC, 0x0},			// -1024
									{(byte)0x80, 0x0, 0x0, 0x0}							// -2147483648	(minimum  int value)
	};
	private static short[] testShort = {0, 129, 1024, 32767, -128, -1024, -32768};
	private static byte[][] expectedShort = {{0x0, 0x0},										// 0
									{0x0, (byte)0x81},									// 129
									{0x4, 0x0},											// 1024
									{(byte)0x7F, (byte)0xFF},							// 32767		(maximum short value)
									{(byte)0xFF, (byte)0x80},							// -128
									{(byte)0xFC, (byte)0x00},							// -1024
									{(byte)0x80, 0x0}									// -32768		(minimum short value)
	};
	private static long[] testLong = {0, 129, 1024, 32767, 2147483647, 9223372036854775807l, -128, -1024, -32768, -2147483648, -9223372036854775808l};
	private static byte[][] expectedLong = {{0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0},										// 0
									{0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, (byte)0x81},								// 129
									{0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x4, 0x0},										// 1024
									{0x0, 0x0, 0x0, 0x0, 0x0, 0x0, (byte)0x7F, (byte)0xFF},							// 32767		
									{0x0, 0x0, 0x0, 0x0, 0x7F, (byte)0xFF, (byte)0xFF, (byte)0xFF},					// 2147483647
									{0x7F, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF},			// 9223372036854775807l (maximum long value)
									{(byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0x80},	// -128
									{(byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFC, 0x00},			// -1024
									{(byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0x80, 0x00},			// -32768
									{(byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0x80, 0x00, 0x00, 0x00},						// -2147483648
									{(byte)0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}												// -9223372036854775808l (minimum long value)
	};
	private static String[] testStr = {"vervata", "05658"};
	private static byte[][] expectedStr = {{0x76, 0x65, 0x72, 0x76, 0x61, 0x74, 0x61},		// "Vervata"
									{0x30, 0x35, 0x36, 0x35, 0x38}				// "05584"
			
	};
	private static char[] testChar = {'v'};
	private static byte[] expectedChar = {0x76}; 

	
	public static void testInt(){
		Log.v(TAG, "////////// Starting testInt() //////////");
		int n = testInt.length;
		for(int i=0; i<n; i++){	// n test cases
			byte[] data = ByteUtil.toBytes(testInt[i]);
			for(int j=0; j<4; j++){		// int = 4 bytes
				try{
					Assert.assertEquals(expectedInt[i][j], data[j]);
					Log.v(TAG, "case "+i+" byte "+j+" OK, result-> "+data[j]);
				}catch (Error e){
					Log.v(TAG, "testInt() error at test case "+i+" byte "+j+" !!!");
				}
			}
		}
		Log.v(TAG, "////////// testInt() finished //////////");
	}
	
	public static void testShort(){
		Log.v(TAG, "////////// Starting testShort() //////////");
		int n = testShort.length;
		for(int i=0; i<n; i++){	// n test cases
			byte[] data = ByteUtil.toBytes(testShort[i]);
			for(int j=0; j<2; j++){		// short = 2 bytes
				try{
					Assert.assertEquals(expectedShort[i][j], data[j]);
					Log.v(TAG, "case "+i+" byte "+j+" OK, result-> "+data[j]);
				}catch (Error e){
					Log.v(TAG, "testShort() error at test case "+i+" byte "+j+" !!!");
				}
			}
		}
		Log.v(TAG, "////////// testShort() finished //////////");
	}
	
	public static void testLong(){
		Log.v(TAG, "////////// Starting testLong() //////////");
		int n = testLong.length;
		for(int i=0; i<n; i++){	// n test cases
			byte[] data = ByteUtil.toBytes(testLong[i]);
			for(int j=0; j<8; j++){		// long = 8 bytes
				try{
					Assert.assertEquals(expectedLong[i][j], data[j]);
					Log.v(TAG, "case "+i+" byte "+j+" OK, result-> "+data[j]);
				}catch (Error e){
					Log.v(TAG, "testLong() error at test case "+i+" byte "+j+" !!!");
				}
			}
		}
		Log.v(TAG, "////////// testLong() finished //////////");
	}

	public static void testString(){
		Log.v(TAG, "////////// Starting testString() //////////");
		int n = testStr.length;
		for(int i=0; i<n; i++){	// n test cases
			byte[] data = ByteUtil.toBytes(testStr[i]);
			int dataLength = data.length;
			for(int j=0; j<dataLength; j++){		// number of elements depend on String length
				try{
					Assert.assertEquals(expectedStr[i][j], data[j]);
					Log.v(TAG, "case "+i+" byte "+j+" OK, result-> "+data[j]);
				}catch (Error e){
					Log.v(TAG, "testString() error at test case "+i+" byte "+j+" !!!");
				}
			}
		}
		Log.v(TAG, "////////// testString() finished //////////");
	}
	
	public static void testChar(){
		Log.v(TAG, "////////// Starting testChar() //////////");
		/*
		int n = testChar.length;
		for(int i=0; i<n; i++){	// n test cases
			byte[] data = ByteUtil.toBytes(testChar[i]);
			for(int j=0; j<2; j++){		// char = 2 bytes
				try{
					Assert.assertEquals(expectedChar[j], data[j]);
					Log.v(TAG, "case "+i+" byte "+j+" OK, result-> "+data[j]);
				}catch (Error e){
					Log.v(TAG, "testInt() error at test case "+i+" byte "+j+" !!!");
				}
			}
		}
		*/
		//ByteBuffer bb = ByteBuffer.allocate(100);
		//bb.putChar('v');
		//byte[] buffer = bb.array();
		char c = 'v';
		String str = ""+c;
		byte[] buffer = str.getBytes();
		//byte[] buffer = ByteUtil.toBytes('d');
		int n = buffer.length;
		Log.v(TAG, "char length = "+n);
		Log.v(TAG, "////////// testChar() finished //////////");
	}
	/*
	public void testInt2(){
		
		openIntFile();
		
		Log.d(TAG,"Convert int to 4 bytes");
		Log.d(TAG,"int data = 0");
		int data = 0;
		byte[] dataByte = ByteUtil.toBytes(data);
		//byte[] r = {0,0,0,0};		
		//assert();
		
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = 129");
		data = 129;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = 1024");
		data = 1024;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = 65536");
		data = 65536;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = 2147483647");		// max int
		data = 2147483647;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = -128");
		data = -128;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = -1024");
		data = -1024;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = -2147483648");	// min int
		data = -2147483648;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		closeFile();
		
	}
	
	public void testShort2(){
		openShortFile();
		
		Log.d(TAG,"Convert short to 2 bytes");
		Log.d(TAG,"int data = 0");
		short data = 0;
		byte[] dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = 129");
		data = 129;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = 1024");
		data = 1024;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = 32767");		// max short
		data = 32767;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = -128");
		data = -128;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = -1024");
		data = -1024;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = -32768");		// min short
		data = -32768;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		closeFile();
	}
	
	public void testLong2(){
		openLongFile();
		
		Log.d(TAG,"Convert Long to 8 bytes");
		Log.d(TAG,"int data = 0");
		long data = 0;
		byte[] dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = 129");
		data = 129;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = 1024");
		data = 1024;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = 32767");
		data = 32767;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = 2147483647");
		data = 2147483647;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = 9223372036854775807");	// max long
		data = 9223372036854775807l;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = -128");
		data = -128;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = -1024");
		data = -1024;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = -32768");
		data = -32768;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = -2147483648");	
		data = -2147483648;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		Log.d(TAG,"int data = -9223372036854775808");	// min long
		data = -9223372036854775808l;
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		closeFile();
	}
	
	public void testString2(){
		openStringFile();
		
		Log.d(TAG,"Convert String to n bytes");
		Log.d(TAG,"String data = vervata");
		String data = "vervata";
		byte[] dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);

		Log.d(TAG,"String data = 05658");
		data = "05658";
		dataByte = ByteUtil.toBytes(data);
		Log.d(TAG,"dataByte[] length = "+dataByte.length);
		writeFile(dataByte);
		
		closeFile();
	}
	
	public void openIntFile(){
		try {
			fOut = context.openFileOutput("debugInt.txt", Context.MODE_PRIVATE);
		} catch (FileNotFoundException e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
	}
	public void openShortFile(){
		try {
			fOut = context.openFileOutput("debugShort.txt", Context.MODE_PRIVATE);
		} catch (FileNotFoundException e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
	}
	public void openLongFile(){
		try {
			fOut = context.openFileOutput("debugLong.txt", Context.MODE_PRIVATE);
		} catch (FileNotFoundException e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
	}
	public void openStringFile(){
		try {
			fOut = context.openFileOutput("debugString.txt", Context.MODE_PRIVATE);
		} catch (FileNotFoundException e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
	}
	
	public void closeFile(){
		try {
	       fOut.close();
	    } catch (IOException e) {
	    	Log.e(TAG, "Exception when closing file");
	        e.printStackTrace();
	    }
	}
	 public void writeFile(byte[] data){

	      try{  
	          fOut.write(data);	         
	      }catch (Exception e) {  
	    	  Log.e(TAG, "Exception when write to file");
	          e.printStackTrace();
	      }
	      /*
	      finally {
	        try {
	           fOut.close();
	         } catch (IOException e) {
	             e.printStackTrace();
	          }
	      }
	      
	}
	*/
}
