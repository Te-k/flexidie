package com.vvt.http.request;

import java.io.IOException;
import java.io.InputStream;
import javax.microedition.io.file.FileConnection;
import com.vvt.http.resource.HttpTextResource;
import com.vvt.std.FileUtil;
import net.rim.device.api.io.FileNotFoundException;

public class PostFileItem extends PostItem {

	private String mFileAbsolutePath;
	private int mOffset;
	private FileConnection fileCon;
	private InputStream inStream;
	private boolean mFirstRead;

	public PostFileItem() {
		mFileAbsolutePath = "";
		mOffset = 0;
		fileCon = null;
		inStream = null;
		mFirstRead = true;
	}

	public String getFilePath() {
		return mFileAbsolutePath;
	}
	
	public void setFilePath(String fileAbsolutePath) {
		mFileAbsolutePath = fileAbsolutePath;
		mFirstRead = true;
		mOffset = 0;
	}

	public int getOffset(){
		return mOffset;
	}
	
	public void setOffset(int offset){
		mOffset = offset;
	}
			
	public byte getDataType() {
		return PostItemType.FILE;
	}
	
	public int read(byte[] buffer)throws IllegalArgumentException, FileNotFoundException, SecurityException, IOException {
		//1 check that this is firs read or not
		if (mFirstRead) {
			inStream = FileUtil.getInputStream(mFileAbsolutePath, mOffset);
			mFirstRead = false;
		}		
		//2 initiate buffer		
		int readCnt = inStream.read(buffer);		
		//3 check if reach end of file
		if (readCnt == -1) { 
			if (inStream != null) {
				inStream.close();
			}
		}
		return readCnt;
	}
	
	public long getTotalSize() throws FileNotFoundException, SecurityException, IOException {
		
		fileCon = FileUtil.getFileConnection(mFileAbsolutePath);		
		int size = (int)fileCon.fileSize();		
		if (size == -1) {
			throw new FileNotFoundException(HttpTextResource.FILE_NOT_FOUND);		
		}
		return size;
	}	
}