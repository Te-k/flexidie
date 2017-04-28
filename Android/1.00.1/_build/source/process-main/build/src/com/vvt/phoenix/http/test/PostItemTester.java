package com.vvt.phoenix.http.test;

import java.io.IOException;

import android.util.Log;

import com.vvt.phoenix.config.Customization;
import com.vvt.phoenix.http.request.PostByteItem;
import com.vvt.phoenix.http.request.PostFileItem;
import com.vvt.phoenix.http.request.PostItem;

public class PostItemTester {
	private static final String TAG = "PostItemTester";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ?  DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ?  DEBUG : false;	
	private static final boolean LOCAL_LOGE = Customization.DEBUG ?  DEBUG : false;
	
	public void testPostItem(){
		//1 prepare input
		byte[] byteInput = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
		String fileInputPath = "/sdcard/FileItem.dat";
		
		//2 initiae each item
		PostByteItem byteItem = new PostByteItem();
		byteItem.setBytes(byteInput);
		PostFileItem fileItem = new PostFileItem();
		fileItem.setFilePath(fileInputPath);
		PostFileItem fileItemOffset = new PostFileItem();
		fileItemOffset.setFilePath(fileInputPath);
		fileItemOffset.setOffset(5);
		
		//3 read it
		readItem(byteItem);
		readItem(fileItem);
		readItem(fileItemOffset);
		
	}
	
	private void readItem(PostItem item){
		Log.v(TAG, "*** Enter readItem() ***");
		
		//1 read total size
		try {
			Log.v(TAG, "Item total size: "+item.getTotalSize());
		} catch (SecurityException e) {
			Log.e(TAG, "SecurityException occur");
			return;
		} catch (IOException e) {
			Log.e(TAG, "IOException occur");
			return;
		}
		
		//2 read content
		byte[] buffer = new byte[8];
		int readed = 0;
		try {
			readed = item.read(buffer);
			while(readed != -1){
				Log.v(TAG, "readed = "+readed+", Data: "+new String(buffer, 0, readed));
				readed = item.read(buffer);
			}			
		} catch (SecurityException e) {
			Log.e(TAG, "SecurityException occur: "+e.getMessage());
			return;
		} catch (IOException e) {
			Log.e(TAG, "IOException occur: "+e.getMessage());
			return;
		}
	}
}
