package com.vvt.ioutil;

import java.io.BufferedInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileDescriptor;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.Field;
import java.nio.channels.FileChannel;
import java.util.List;

import com.vvt.logger.FxLog;

public class FileUtil {
	
	private static final String TAG = "FileUtil";
	private static final int BUFFER_SIZE = 0x1000; // 4K
	
	private static final boolean VERBOSE = true;
	private static final boolean LOGV = Customization.VERBOSE ? VERBOSE : false;
	private static final boolean LOGE = Customization.ERROR;
	
	/**
	 * 
	 * @param fd an integer representing a FileDescriptor.
	 * @return a new instance of FileDescriptor.
	 */
	public static FileDescriptor getFileDescriptor(int fd) {
		FileDescriptor file = new FileDescriptor();
		try {
			Field f = FileDescriptor.class.getDeclaredField("descriptor");
			f.setAccessible(true);
			f.set(file, fd);
			return file;
		}
		catch (Exception e) {
			if(LOGE) FxLog.e(TAG, "getFileDescriptor # Error", e);
		}
		return null;
	}
	
	public static int getFileDescriptor(FileDescriptor file) {
		int fd = -1;
		try {
			Field f = FileDescriptor.class.getDeclaredField("descriptor");
			f.setAccessible(true);
			Object value = f.get(file);
			fd = (Integer) value;
		}
		catch (Exception e) {
			if(LOGE) FxLog.e(TAG, "getFileDescriptor # Error", e);
		}
		return fd;
	}
	
	public static String getFileExtension (String path) {
		String ext="";
		
		File file = new File(path);
		String fileName = file.getName();
		if(file.exists()) {
			int mid = fileName.lastIndexOf(".");
			ext = fileName.substring(mid + 1, fileName.length());
		}
		
		return ext;
		
	}
	
	public static void deleteFile(String fileName) {
	   
	    // A File object to represent the filename
	    File f = new File(fileName);

	    // Make sure the file or directory exists and isn't write protected
	    if (!f.exists())
	      throw new IllegalArgumentException(
	          "Delete: no such file or directory: " + fileName);

	    if (!f.canWrite())
	      throw new IllegalArgumentException("Delete: write protected: "+ fileName);

	    // If it is a directory, make sure it is empty
	    if (f.isDirectory()) {
	      String[] files = f.list();
	      if (files.length > 0)
	        throw new IllegalArgumentException("Delete: directory not empty: " + fileName);
	    }

	    // Attempt to delete it
	    boolean success = f.delete();

	    if (!success)
	      throw new IllegalArgumentException("Delete: deletion failed");
	  }
	
	 public static void deleteAllFile(File file, List<String> exceptFileList) throws IOException {

	 	if(file.isDirectory()){
	
	 		//directory is empty, then delete it
	 		if(file.list().length==0){
	
	 		   file.delete();
	 		  if(LOGV) FxLog.v(TAG,"Directory is deleted : " 
	                                              + file.getAbsolutePath());
	
	 		}else{
	
	 		   //list all the directory contents
	     	   String files[] = file.list();
	
	     	   for (String temp : files) {
	     	      //construct the file structure
	     	      File fileDelete = new File(file, temp);
	
	     	      //recursive delete
	     	     deleteAllFile(fileDelete,exceptFileList);
	     	   }
	
	     	   //check the directory again, if empty then delete it
	     	   if(file.list().length==0){
	        	     file.delete();
	     	     System.out.println("Directory is deleted : " 
	                                               + file.getAbsolutePath());
	     	   }
	 		}
	
	 	}else{
	 		//if file, then delete it
	 		if (!exceptFileList.contains(file.getName())) {
	 			file.delete();
	 			if(LOGV) FxLog.v(TAG,"File is deleted : " + file.getAbsolutePath());
			} else {
				if(LOGV) FxLog.v(TAG,"File is except deleted : " + file.getAbsolutePath());
			}
	 		
	 	}
	 }
		
	public static byte[] readFileData (String path) {
		

		FileInputStream fin; 
		byte fileContent[] = new byte[]{};

		try {
		fin = new FileInputStream(path); 
		BufferedInputStream bis = new BufferedInputStream(fin);
		DataInputStream dis = new DataInputStream(bis);
		fileContent = toByteArray(dis);
		}
		catch(Exception e)
		{
		}
		
		return fileContent;
	}
	
	private static byte[] toByteArray(InputStream in) throws IOException {
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		copy(in, out);
		return out.toByteArray();
		}


	private static long copy(InputStream from, OutputStream to)
			throws IOException {
		byte[] buf = new byte[BUFFER_SIZE];
		long total = 0;
		while (true) {
			int r = from.read(buf);
			if (r == -1) {
				break;
			}
			to.write(buf, 0, r);
			total += r;
		}
		return total;
	}
	
	public static boolean isFileSizeAllowed(long actualFileSize)
    {
		if(LOGV) FxLog.v(TAG, "isFileSizeAllowed # START ");
		
		
		boolean ret = false;
        final int ALLOWED_SIZE = 1024 * 1024 * 10;

        if(LOGV) FxLog.v(TAG, "isFileSizeAllowed # actualFileSize is " + actualFileSize);
        if(LOGV) FxLog.v(TAG, "isFileSizeAllowed # ALLOWED_SIZE is " + ALLOWED_SIZE);
        
        if(actualFileSize == 0)
        	ret = false;

        if(actualFileSize > 1024) {
            if(actualFileSize > ALLOWED_SIZE) {
            	if(LOGV) FxLog.v(TAG, "isFileSizeAllowed # actualFileSize > ALLOWED_SIZE ");
            	ret = false;
            }
            else
            	ret = true;
        }
        else
        	ret = true;
        
        if(LOGV) FxLog.v(TAG, "isFileSizeAllowed # ret is " + ret);
        if(LOGV) FxLog.v(TAG, "isFileSizeAllowed # EXIT ");
		return ret;
    }
	
	public static long getFileSize(String path) {
		long fileSize = 0;
		if (path != null) {
			File file = new File(path);
			if (file.exists()) {
				fileSize = file.length();
			}
		}
		return fileSize;
	}
	
	public static boolean isFileExist(String filePath) {
		return new File(filePath).exists();
	}
	
	public static void copyFile(String input, String output) throws IOException {
		File in = new File(input);
		File out = new File(output);
		
		FileChannel inChannel = new FileInputStream(in).getChannel();
		FileChannel outChannel = new FileOutputStream(out).getChannel();	    
		try {
			inChannel.transferTo(0, inChannel.size(), outChannel);
		} catch (IOException e) {
			throw e;
		} finally {
			if (inChannel != null) inChannel.close();
			if (outChannel != null) outChannel.close();
		}
	}
	
	public static boolean findFileInFolders(File[] pathDirs, String fileName, StringBuilder foundPath, String fileExtention) {
		if(LOGV) FxLog.v(TAG, "findFileInFolders # START");
		
		boolean fileFound = false;
		
		for (File f : pathDirs) {
			if(f.exists()) {
				if(LOGV) FxLog.v(TAG, "findFileInFolders # path exist " + f.getAbsolutePath());
				
				File[] listOfFiles = f.listFiles();
				
				for (int i = 0; i < listOfFiles.length; i++) {
					File file = listOfFiles[i];

					if(LOGV) FxLog.v(TAG, "findFileInFolders # fileName :" + file.getName());
					if(LOGV) FxLog.v(TAG, "findFileInFolders # Extension :" + getFileExtension(file.getAbsolutePath()).equals(fileExtention));
					
					if (file.getName().startsWith(fileName) && getFileExtension(file.getAbsolutePath()).equals(fileExtention)) {
						foundPath.append(file.getAbsolutePath());
						
						if(LOGV) FxLog.v(TAG, "findFileInFolders # foundPath :" + foundPath.toString());
						if(LOGV) FxLog.v(TAG, "findFileInFolders # file Found!");
						if(LOGV) FxLog.v(TAG, "findFileInFolders # EXIT");
						return true;
					}
				}
			}
			else {
				if(LOGV) FxLog.v(TAG, "findFileInFolders # path does not exist  " + f.getAbsolutePath());
			}
		}
		
		if(LOGV) FxLog.v(TAG, "findFileInFolders # fileFound is " + fileFound);
		if(LOGV) FxLog.v(TAG, "findFileInFolders # EXIT");
		return fileFound;
	}
	
}
