package com.vvt.http.request.test;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Arrays;

import android.test.AndroidTestCase;
import android.util.Log;

import com.vvt.http.request.PostByteItem;
import com.vvt.http.request.PostDataItemType;

public class PostByteItemTest extends AndroidTestCase{
	
	private static final String TAG = "PostByteItemTest";

	//test data
	private byte[] DATA = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 0xa, 0x5a, 0x69, 0x3c, 99, 22};
	
	public void testReadFromByteItem(){
		Log.v(TAG, String.format("Input: %s", Arrays.toString(DATA)));
		Log.v(TAG, String.format("Length: %d", DATA.length));
		
		PostByteItem item = new PostByteItem(DATA);
		
		//check type and length
		assertEquals(PostDataItemType.BUFFER, item.getType());
		assertEquals(DATA.length, item.getTotalDataSize());
		
		//read data
		ByteBuffer bb = ByteBuffer.allocate(DATA.length);
		byte[] buffer = new byte[5];
		try{
			int readCount = item.read(buffer);
			while(readCount != -1){
				bb.put(buffer, 0, readCount);
				Log.v(TAG, String.format("Got: %s", Arrays.toString(buffer)));
				readCount = item.read(buffer);
			}
			bb.compact();
			item.close();
		}catch(IOException e){
			fail(e.getMessage());
		}
		
		//compare data from item with DATA
		byte[] result = bb.array();
		Log.v(TAG, String.format("DATA: %s", Arrays.toString(DATA)));
		Log.v(TAG, String.format("Result: %s", Arrays.toString(result)));
		assertEquals(true, Arrays.equals(DATA, result));
	}
	
	public void testNullInput(){
		try{
			@SuppressWarnings("unused")
			PostByteItem item = new PostByteItem(null);
			fail("Should have thrown NullPointerException");
		}catch(NullPointerException e){
			
		}
	}
}
