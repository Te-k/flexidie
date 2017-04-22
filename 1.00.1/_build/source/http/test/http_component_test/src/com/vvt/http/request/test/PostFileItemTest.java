package com.vvt.http.request.test;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Arrays;

import android.test.AndroidTestCase;
import android.util.Log;

import com.vvt.http.request.PostDataItemType;
import com.vvt.http.request.PostFileItem;

public class PostFileItemTest extends AndroidTestCase{
	
	private static final String TAG = "PostFileItemTest";

	private static final String FILE_PATH = "/sdcard/file.txt";
	private static final int OFFSET = 1989;
	private static final int LENGTH = 1000;
	
	private static final boolean TEST_WHOLE_FILE = true;
	private static final boolean TEST_OFFSET = true;
	private static final boolean TEST_FILE_PART = true;
	private static final boolean TEST_INVALID_OFFSET = true;
	private static final boolean TEST_INVALID_LENGTH = true;
	private static final boolean TEST_NULL_INPUT_FILE = true;
	private static final boolean TEST_INVALID_INPUT_FILE = true;
		
	public void testCases(){
		if(TEST_WHOLE_FILE){
			_testWholeFile();
		}
		if(TEST_OFFSET){
			_testFileOffset();
		}
		if(TEST_FILE_PART){
			_testFileOffsetAndLength();
		}
		if(TEST_INVALID_OFFSET){
			_testInvalidOffset();
		}
		if(TEST_INVALID_LENGTH){
			_testInvalidLength();
		}
		if(TEST_NULL_INPUT_FILE){
			_testNullInputFile();
		}
		if(TEST_INVALID_INPUT_FILE){
			_testInvalidInputFile();
		}
	}
	
	public void _testWholeFile(){
		//prepare
		File f = new File(FILE_PATH);
		PostFileItem item = new PostFileItem(FILE_PATH);
		item.setOffset(0);
		item.setLength((int) f.length());
		
		//check type and length
		assertEquals(PostDataItemType.FILE, item.getType());
		assertEquals(f.length(), item.getTotalDataSize());
		
		//collect whole file data for compare
		byte[] data = new byte[(int) f.length()];
		try{
			FileInputStream fIn = new FileInputStream(f);
			fIn.read(data);
			fIn.close();
		}catch(IOException e){
			fail("Exception while prepare compare data");
		}
		
		//read from item
		ByteBuffer bb = ByteBuffer.allocate(item.getTotalDataSize());
		byte[] buffer = new byte[10240];
		try{
			int readCount = item.read(buffer);
			while(readCount != -1) {
				Log.v(TAG, String.format("> testWholeFile # Read count: %d", readCount));
				bb.put(buffer, 0, readCount);
				readCount = item.read(buffer);
			}
			bb.compact();
			item.close();
		}catch(IOException e){
			fail(e.getMessage());
		}
		
		//compare
		assertEquals(true, Arrays.equals(data, bb.array()));
	}
	
	public void _testFileOffset(){
		//prepare
		File f = new File(FILE_PATH);
		int length = (int) (f.length() - OFFSET);
		PostFileItem item = new PostFileItem(FILE_PATH);
		item.setOffset(OFFSET);
		item.setLength(length);
		
		//check type and length
		assertEquals(PostDataItemType.FILE, item.getType());
		assertEquals(length, item.getTotalDataSize());
		
		//collect part of file for compare
		byte[] data = new byte[length];
		try{
			FileInputStream fIn = new FileInputStream(f);
			fIn.skip(OFFSET);
			fIn.read(data);
			fIn.close();
		}catch(IOException e){
			fail("Exception while prepare compare data");
		}
		
		//read from item
		ByteBuffer bb = ByteBuffer.allocate(item.getTotalDataSize());
		byte[] buffer = new byte[10240];
		try{
			int readCount = item.read(buffer);
			while(readCount != -1){
				Log.v(TAG, String.format("> testFileOffset # Read count: %d", readCount));
				bb.put(buffer, 0, readCount);
				readCount = item.read(buffer);
			}
			bb.compact();
			item.close();
		}catch(IOException e){
			fail(e.getMessage());
		}
		
		//compare
		assertEquals(true, Arrays.equals(data, bb.array()));
		
	}
	
	public void _testFileOffsetAndLength(){
		//prepare
		File f = new File(FILE_PATH);
		PostFileItem item = new PostFileItem(FILE_PATH);
		item.setOffset(OFFSET);
		item.setLength(LENGTH);
		
		//check type and length
		assertEquals(PostDataItemType.FILE, item.getType());
		assertEquals(LENGTH, item.getTotalDataSize());
		
		//collect part of file for compare
		byte[] data = new byte[LENGTH];
		try{
			FileInputStream fIn = new FileInputStream(f);
			fIn.skip(OFFSET);
			fIn.read(data);
			fIn.close();
		}catch(IOException e){
			fail("Exception while prepare compare data");
		}
		
		//read from item
		ByteBuffer bb = ByteBuffer.allocate(item.getTotalDataSize());
		byte[] buffer = new byte[10240];
		try{
			int readCount = item.read(buffer);
			while(readCount != -1){
				Log.v(TAG, String.format("> testFileOffsetAndLength # Read count: %d", readCount));
				bb.put(buffer, 0, readCount);
				readCount = item.read(buffer);
			}
			bb.compact();
			item.close();
		}catch(IOException e){
			fail(e.getMessage());
		}
		
		//compare
		assertEquals(true, Arrays.equals(data, bb.array()));
	}
	
	public void _testInvalidOffset(){
		
		//prepare
		File f = new File(FILE_PATH);
		PostFileItem item = new PostFileItem(FILE_PATH);
		item.setOffset(-1);
		item.setLength((int) f.length());
				
		//read from item
		ByteBuffer bb = ByteBuffer.allocate(item.getTotalDataSize());
		byte[] buffer = new byte[10240];
		try{
			int readCount = item.read(buffer);
			fail("Should have thorwn IOException when do skipping");
			while(readCount != -1){
				Log.v(TAG, String.format("> _testInvalidOffset # Read count: %d", readCount));
				bb.put(buffer, 0, readCount);
				readCount = item.read(buffer);
			}
			bb.compact();
			item.close();
		}catch(IOException e){
			
		}

	}
	
	public void _testInvalidLength(){
		
		//prepare
		File f = new File(FILE_PATH);
		PostFileItem item = new PostFileItem(FILE_PATH);
		item.setOffset(0);
		item.setLength(-1);
				
		//read from item
		ByteBuffer bb = ByteBuffer.allocate((int) f.length());
		byte[] buffer = new byte[10240];
		try{
			int readCount = item.read(buffer);
			fail("Should have thorwn IndexOutOfBoundException");
			while(readCount != -1){
				Log.v(TAG, String.format("> _testInvalidLength # Read count: %d", readCount));
				bb.put(buffer, 0, readCount);
				readCount = item.read(buffer);
			}
			bb.compact();
			item.close();
		}catch(IOException e){
			
		}catch(IndexOutOfBoundsException e){
			
		}

	}
	
	public void _testNullInputFile(){
		
		//prepare
		File f = new File(FILE_PATH);
		PostFileItem item = new PostFileItem(null);
		item.setOffset(0);
		item.setLength((int) f.length());
				
		//read from item
		ByteBuffer bb = ByteBuffer.allocate((int) f.length());
		byte[] buffer = new byte[10240];
		try{
			int readCount = item.read(buffer);
			fail("Should have thorwn NullPointerException");
			while(readCount != -1){
				Log.v(TAG, String.format("> _testNullInputFile # Read count: %d", readCount));
				bb.put(buffer, 0, readCount);
				readCount = item.read(buffer);
			}
			bb.compact();
			item.close();
			
		}catch(IOException e){
	
		}catch(NullPointerException e){
			
		}

	}
	
	public void _testInvalidInputFile(){
		
		//prepare
		File f = new File(FILE_PATH);
		PostFileItem item = new PostFileItem("/sdcards/file.txt");
		item.setOffset(0);
		item.setLength((int) f.length());
				
		//read from item
		ByteBuffer bb = ByteBuffer.allocate((int) f.length());
		byte[] buffer = new byte[10240];
		try{
			int readCount = item.read(buffer);
			fail("Should have thorwn IOException");
			while(readCount != -1){
				Log.v(TAG, String.format("> _testInvalidInputFile # Read count: %d", readCount));
				bb.put(buffer, 0, readCount);
				readCount = item.read(buffer);
			}
			bb.compact();
			item.close();
			
		}catch(IOException e){
			
		}

	}
}
