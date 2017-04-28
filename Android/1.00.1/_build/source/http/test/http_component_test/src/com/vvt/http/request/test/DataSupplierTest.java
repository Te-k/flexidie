package com.vvt.http.request.test;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;

import android.test.AndroidTestCase;
import android.util.Log;

import com.vvt.http.request.DataSupplier;
import com.vvt.http.request.PostByteItem;
import com.vvt.http.request.PostDataItem;
import com.vvt.http.request.PostFileItem;

public class DataSupplierTest extends AndroidTestCase{
	
	//Debugging
	private static final String TAG = "DataSupplierTest";
	
	//test cases
	private static final boolean TEST_ONE_BYTE_ITEM = true;
	private static final boolean TEST_ONE_FILE_ITEM = true;
	private static final boolean TEST_ONE_BYTE_ONE_FILE_ITEM = true;
	private static final boolean TEST_NULL_ITEM_LIST = true;
	private static final boolean TEST_NULL_DATA_ITEM = true;
	private static final boolean TEST_COMPLICATED_DATA = true;
	
	//constants
	private byte[] DATA = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 0xa, 0x5a, 0x69, 0x3c, 99, 22};
	//Need sum file to push in /sdcard/file.txt and file item - specify part -> offset = 100, length = 500
	private static final String FILE_PATH = "/sdcard/file.txt";
	private static final int OFFSET = 199;
	private static final int LENGTH = 500;
	
	public void testCases(){
		if(TEST_ONE_BYTE_ITEM){
			_testOneByteItem();
		}
		if(TEST_ONE_FILE_ITEM){
			_testOneFileItem();
		}
		if(TEST_ONE_BYTE_ONE_FILE_ITEM){
			_testOneByteOneFile();
		}
		if(TEST_NULL_ITEM_LIST){
			_testNullDataItemList();
		}
		if(TEST_NULL_DATA_ITEM){
			_testNullDataItem();
		}
		if(TEST_COMPLICATED_DATA){
			_testComplicatedData();
		}
	}
	
	public void _testOneByteItem(){
		//prepare data
		PostByteItem item = new PostByteItem(DATA);
		ArrayList<PostDataItem> itemList = new ArrayList<PostDataItem>();
		itemList.add(item);
		
		//create supplier
		DataSupplier supplier = new DataSupplier();
		supplier.setPostDataItem(itemList);
		
		//check total size
		assertEquals(DATA.length, supplier.getTotalDataSize());
		
		//read data from supplier
		ByteBuffer bb = ByteBuffer.allocate(item.getTotalDataSize());
		byte[] buffer = new byte[10240];
		try{
			int readCount = supplier.read(buffer);
			while(readCount != -1){
				bb.put(buffer, 0, readCount);
				readCount = supplier.read(buffer);
			}
			bb.compact();
		}catch(IOException e){
			fail(e.getMessage());
		}
		
		//compare DATA with buffer from supplier
		assertEquals(true, Arrays.equals(DATA, bb.array()));
	}
	
	public void _testOneFileItem(){
		//prepare data
		File f = new File(FILE_PATH);
		PostFileItem item = new PostFileItem(FILE_PATH);
		item.setOffset(0);
		item.setLength((int) f.length());
		ArrayList<PostDataItem> itemList = new ArrayList<PostDataItem>();
		itemList.add(item);
		
		//create supplier
		DataSupplier supplier = new DataSupplier();
		supplier.setPostDataItem(itemList);
		
		//check total size
		assertEquals(f.length(), supplier.getTotalDataSize());
		
		//read data from supplier
		ByteBuffer bb = ByteBuffer.allocate((int) f.length());
		byte[] buffer = new byte[10240];
		try{
			int readCount = supplier.read(buffer);
			while(readCount != -1){
				bb.put(buffer, 0, readCount);
				readCount = supplier.read(buffer);
			}
			bb.compact();
		}catch(IOException e){
			fail(String.format("IOException occurs while reading data from supplier : %s", e.getMessage()));
		}
		
		//compare FILE data with buffer from supplier
		buffer = new byte[(int) f.length()];
		try{
			FileInputStream fInStream = new FileInputStream(f);
			fInStream.read(buffer);
			fInStream.close();
		}catch(IOException e){
			fail(String.format("IOException occurs while reading whole file to buffer", e.getMessage()));
		}
		assertEquals(true, Arrays.equals(buffer, bb.array()));
	}
	
	public void _testOneByteOneFile(){
		//prepare data
		PostByteItem byteItem = new PostByteItem(DATA);
		File f = new File(FILE_PATH);
		PostFileItem fileItem = new PostFileItem(FILE_PATH);
		fileItem.setOffset(0);
		fileItem.setLength((int) f.length());
		ArrayList<PostDataItem> itemList = new ArrayList<PostDataItem>();
		itemList.add(byteItem);
		itemList.add(fileItem);
		
		//create supplier
		DataSupplier supplier = new DataSupplier();
		supplier.setPostDataItem(itemList);
		
		//check total size
		long expectedDataLength = DATA.length + f.length();
		assertEquals(expectedDataLength, supplier.getTotalDataSize());
		
		//read data from supplier
		ByteBuffer supplierBB = ByteBuffer.allocate((int) expectedDataLength);
		byte[] buffer = new byte[10240];
		try{
			int readCount = supplier.read(buffer);
			while(readCount != -1){
				supplierBB.put(buffer, 0, readCount);
				readCount = supplier.read(buffer);
			}
			supplierBB.compact();
		}catch(IOException e){
			fail(String.format("IOException occurs while reading data from supplier", e.getMessage()));
		}
		
		//compare FILE data with buffer from supplier
		ByteBuffer actualBB = ByteBuffer.allocate((int) expectedDataLength);
		//append DATA
		actualBB.put(DATA, 0, DATA.length);
		//append FILE
		buffer = new byte[(int) f.length()];
		try{
			FileInputStream fInStream = new FileInputStream(f);
			fInStream.read(buffer);
			fInStream.close();
		}catch(IOException e){
			fail(String.format("IOException occurs while reading whole file to buffer", e.getMessage()));
		}
		actualBB.put(buffer, 0, buffer.length);
		actualBB.compact();
		//Let's compare
		assertEquals(true, Arrays.equals(actualBB.array(), supplierBB.array()));
	}
	
	/**
	 * Test set list of data items as NULL value
	 */
	public void _testNullDataItemList(){
		//create supplier
		DataSupplier supplier = new DataSupplier();
		supplier.setPostDataItem(null);
		
		try{
			supplier.getTotalDataSize();
			fail("Should have thrown NullPointerException");
		}catch(NullPointerException e){
			Log.e(TAG, String.format("> _testNullDataItemList # NullPointerException: %s", e.toString()));
		}
	}
	
	/**
	 * Test set one data item as NULL value
	 */
	public void _testNullDataItem(){
		//prepare data
		PostByteItem item = new PostByteItem(DATA);
		ArrayList<PostDataItem> itemList = new ArrayList<PostDataItem>();
		itemList.add(item);
		itemList.add(null);
		
		//create supplier
		DataSupplier supplier = new DataSupplier();
		supplier.setPostDataItem(null);
		
		try{
			supplier.getTotalDataSize();
			fail("Should have thrown NullPointerException");
		}catch(NullPointerException e){
			Log.e(TAG, "> _testNullDataItem # NullPointerException");
			e.printStackTrace();
		}
	}
	
	/**
	 * Test data supplier with mix of items
	 */
	public void _testComplicatedData(){
		//1 prepare data
		
		// byte item
		PostByteItem byteItem1 = new PostByteItem(DATA);
		
		// file item - whole file
		File f = new File(FILE_PATH);
		PostFileItem fileItem1 = new PostFileItem(FILE_PATH);
		fileItem1.setOffset(0);
		fileItem1.setLength((int) f.length());
		
		// file item - with offset
		PostFileItem fileItem2 = new PostFileItem(FILE_PATH);
		fileItem2.setOffset(OFFSET);
		fileItem2.setLength((int) (f.length() - OFFSET));
		
		// file item - specify part -> offset = 100, length = 500
		PostFileItem fileItem3 = new PostFileItem(FILE_PATH);
		fileItem3.setOffset(OFFSET);
		fileItem3.setLength(LENGTH);
		
		// add all items to list
		ArrayList<PostDataItem> itemList = new ArrayList<PostDataItem>();
		itemList.add(byteItem1);
		itemList.add(fileItem1);
		itemList.add(fileItem2);
		itemList.add(fileItem3);
		
		//2 create supplier
		DataSupplier supplier = new DataSupplier();
		supplier.setPostDataItem(itemList);
		
		//3 check total size
		// expected length = DATA length + whole file length + (whole file length - offset) + file part length
		long expectedSize = DATA.length + f.length() + (f.length() - OFFSET) + LENGTH;
		assertEquals(expectedSize, supplier.getTotalDataSize());
		
		//4 read data from supplier
		ByteBuffer supplierBB = ByteBuffer.allocate((int) expectedSize);
		byte[] buffer = new byte[10240];
		try{
			int readCount = supplier.read(buffer);
			while(readCount != -1){
				supplierBB.put(buffer, 0, readCount);
				readCount = supplier.read(buffer);
			}
			supplierBB.compact();
		}catch(IOException e){
			fail(String.format("IOException occurs while reading data from supplier", e.getMessage()));
		}
		
		//5 compare FILE data with buffer from supplier
		ByteBuffer actualBB = ByteBuffer.allocate((int) expectedSize);
		
		//append DATA
		actualBB.put(DATA, 0, DATA.length);
		
		//append whole FILE
		buffer = new byte[(int) f.length()];
		try{
			FileInputStream fInStream = new FileInputStream(f);
			fInStream.read(buffer);
			fInStream.close();
			actualBB.put(buffer, 0, buffer.length);
		}catch(IOException e){
			fail(String.format("IOException occurs while reading whole file to buffer", e.getMessage()));
		}
		
		//append file with offset
		try{
			FileInputStream fInStream = new FileInputStream(f);
			fInStream.skip(OFFSET);
			int count = fInStream.read(buffer);
			fInStream.close();
			actualBB.put(buffer, 0, count);
		}catch(IOException e){
			fail(String.format("IOException occurs while reading whole file to buffer", e.getMessage()));
		}
		
		//append file part
		try{
			FileInputStream fInStream = new FileInputStream(f);
			fInStream.skip(OFFSET);
			for(int i=0; i<LENGTH; i++){
				actualBB.put((byte) fInStream.read());
			}
			fInStream.close();
		}catch(IOException e){
			fail(String.format("IOException occurs while reading whole file to buffer", e.getMessage()));
		}
		
		actualBB.compact();
		
		//Let's compare
		assertEquals(true, Arrays.equals(actualBB.array(), supplierBB.array()));
	}

}
