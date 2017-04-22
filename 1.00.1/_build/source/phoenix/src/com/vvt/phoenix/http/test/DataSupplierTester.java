// act as http component

package com.vvt.phoenix.http.test;

import java.io.IOException;
import java.util.ArrayList;

import android.util.Log;

import com.vvt.phoenix.config.Customization;
import com.vvt.phoenix.exception.DataCorruptedException;
import com.vvt.phoenix.http.request.DataSupplier;
import com.vvt.phoenix.http.request.PostByteItem;
import com.vvt.phoenix.http.request.PostFileItem;
import com.vvt.phoenix.http.request.PostItem;

public class DataSupplierTester {
	private static final String TAG = "DataSupplierTester";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ?  DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	
	public void testDataSupplier(){
		ArrayList<PostItem> itemList = new ArrayList<PostItem>();
		
		//1 prepare intput
		byte[] byteInput = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
		String fileInputPath = "/sdcard/FileItem.dat";
		String fileInputPath2 = "/sdcard/FileItem2.dat";
		
		/*//2 add to supplier
		supplier.add(byteInput);
		supplier.add(fileInputPath);
		supplier.add(fileInputPath2, 0);	//with offset
*/		
		//2 add to array
		PostByteItem item1 = new PostByteItem();
		item1.setBytes(byteInput);
		PostFileItem item2 = new PostFileItem();
		item2.setFilePath(fileInputPath);
		PostFileItem item3 = new PostFileItem();
		item3.setFilePath(fileInputPath2);
		item3.setOffset(5);
		
		itemList.add(item1);
		itemList.add(item2);
		itemList.add(item3);
		
////////////////////////////////////////////////////////////////// assume that above is Http //////////////////
		
		//3 initiate DataSupplier
		DataSupplier supplier = new DataSupplier();
		
		//4 add data from request
		supplier.setDataItemList(itemList);
		
		
		//3 get size
		Log.v(TAG, "Number of elements: "+supplier.getDataItemCount());
		try {
			Log.v(TAG, "Total Size: "+supplier.getTotalDataSize());
		} catch (SecurityException e1) {
			Log.e(TAG, "SecurityException occur: "+e1.getMessage());
			return;
		} catch (IOException e1) {
			Log.e(TAG, "IOException occur: "+e1.getMessage());
			return;
		}
		
		//4 read it
		byte[] buffer = new byte[8];
		try {
			int readed = supplier.read(buffer);
			while(readed != -1){
				Log.v(TAG, "readed = "+readed+", Data: "+new String(buffer, 0, readed));
				readed = supplier.read(buffer);
			}	
		} catch (IndexOutOfBoundsException e) {
			Log.e(TAG, "IndexOutOfBoundsException occur: "+e.getMessage());
			return;
		} catch (SecurityException e) {
			Log.e(TAG, "SecurityException occur: "+e.getMessage());
			return;
		} catch (DataCorruptedException e) {
			Log.e(TAG, "DataCorruptedException occur: "+e.getMessage());
			return;
		} catch (IOException e) {
			Log.e(TAG, "IOException occur: "+e.getMessage());
			return;
		}
		
		
	}
}
