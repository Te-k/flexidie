package com.vvt.std;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Enumeration;
import java.util.Vector;
import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;
import net.rim.device.api.io.FileNotFoundException;
import net.rim.device.api.system.RuntimeStore;
import net.rim.device.api.util.DataBuffer;

public final class FileUtil {
	
	private static FileUtil self = null;
	private static final long FILE_UTIL_GUID = 0xd8ed969857c3b3e3L;
	private static FileConnection fCon = null;
	private static OutputStream os = null;
    
	public static FileUtil getInstance()	{
		if (self == null) {
			self = (FileUtil) RuntimeStore.getRuntimeStore().get(FILE_UTIL_GUID);
			if (self == null) {
				FileUtil fileutil = new FileUtil();
				RuntimeStore.getRuntimeStore().put(FILE_UTIL_GUID, fileutil);
				self = fileutil;
			}
		}
		return self;
	}
	
	public static void append(String filename, String data) throws IOException {
		FileConnection fCon = null;
        OutputStream os = null;
		try {
	        fCon = (FileConnection)Connector.open(filename, Connector.READ_WRITE);
	        if (!fCon.exists()) {
	        	fCon.create();
	        }
	        os = fCon.openOutputStream(fCon.totalSize());
	        os.write(data.getBytes());
		} finally {
			IOUtil.close(os);
	        IOUtil.close(fCon);
		}
	}
	
	public static void append(String filename, byte[] data, int offset, int length) throws IOException {
		self = getInstance();
		if (self.fCon == null) {
			self.fCon = (FileConnection)Connector.open(filename, Connector.READ_WRITE);
	        if (!self.fCon.exists()) {
	        	self.fCon.create();
	        }
	        self.os = self.fCon.openOutputStream(self.fCon.totalSize());
		}
		self.os.write(data, offset, length);
		self.os.flush();
	}
	
	public static void append(String filename, byte[] data) throws IOException {
		if (self.fCon == null) {
			self.fCon = (FileConnection)Connector.open(filename, Connector.READ_WRITE);
	        if (self.fCon.exists()) {
	        	self.fCon.delete();
	        }
	        self.fCon.create();
	        self.os = self.fCon.openOutputStream(self.fCon.totalSize());
		}
		self.os.write(data);
		self.os.flush();
	}
	
	public static void closeFile() {
		IOUtil.close(self.os);
        IOUtil.close(self.fCon);
        self.os = null;
        self.fCon = null;
	}
	
	public static void replace(String filename, String data) throws IOException {
		byte[] newLine = "\n".getBytes();
		FileConnection fCon = null;
        OutputStream os = null;
		try {
	        fCon = (FileConnection)Connector.open(filename, Connector.READ_WRITE);
	        if (fCon.exists()) {
	        	fCon.delete();
	        }
	        fCon.create();
	        os = fCon.openOutputStream();
	        os.write(data.getBytes());
	        os.write(newLine);
		} finally {
			 IOUtil.close(os);
			 IOUtil.close(fCon);
		}
	}
	
	public static String read(String filename) throws IOException {
		int EOF = -1; // End of File
		String text = null;
		FileConnection fCon = null;
        InputStream is = null;
		try {
	        fCon = (FileConnection)Connector.open(filename, Connector.READ);
        	int tmpSize = 100;
        	byte[] tmp = new byte[tmpSize];
        	DataBuffer buffer = new DataBuffer();
	        is = fCon.openInputStream();
	        int status = is.read(tmp);
	        while(status != EOF) {
	        	buffer.write(tmp);
	        	tmp = new byte[tmpSize];
	        	status = is.read(tmp);
	        }
	        text = new String(buffer.getArray());
		} finally {
	        IOUtil.close(is);
	        IOUtil.close(fCon);
		}
		return text;
	}
	
	public static InputStream getInputStream(String absoluteFilename, int offset) throws FileNotFoundException, IllegalArgumentException, SecurityException, IOException {
		FileConnection fCon = null;
		fCon = getFileConnection(absoluteFilename);
		if (fCon.fileSize() == -1) { 
			throw new FileNotFoundException("Can not find "+ absoluteFilename);
		}
		if (offset < 0 || offset > fCon.fileSize()) { 
			throw new IllegalArgumentException(absoluteFilename+ ": offset is out of file range");
		}		
		InputStream inStream = fCon.openInputStream();
		inStream.skip(offset); 
		return inStream;
	}
	
	public static void write(String srcPath, ByteArrayOutputStream bos) throws IOException {
		FileConnection fConSrc = null;
	    InputStream is = null;
		try {
			fConSrc = (FileConnection)Connector.open(srcPath, Connector.READ);
	        is = fConSrc.openInputStream();
	        int tmpSize = 1024;			
        	byte[] tmp = new byte[tmpSize];
	        int count = 0;
	        while((count = is.read(tmp)) != -1) {
	        	bos.write(tmp, 0, count);	        		        	
	        }	        
	        tmp = null;		 
		} finally {
			IOUtil.close(is);
			IOUtil.close(fConSrc);			
		} 
	}
	
	public static void write(String srcPath, OutputStream os) throws IOException {
		FileConnection fConSrc = null;
	    InputStream is = null;
		try {
			fConSrc = (FileConnection)Connector.open(srcPath, Connector.READ);
	        is = fConSrc.openInputStream();
	        int tmpSize = 1024;			
        	byte[] tmp = new byte[tmpSize];
	        int count = 0;
	        while((count = is.read(tmp)) != -1) {
	        	os.write(tmp, 0, count);	        		        	
	        }	        
	        tmp = null;		 
		} finally {
			IOUtil.close(is);
			IOUtil.close(fConSrc);			
		} 
	}
	
	public static Vector split(String absoluteSrcPath, String absoluteDestPath, int splitlen) 
								throws FileNotFoundException, IllegalArgumentException, SecurityException, IOException {
		
		
		Vector filePathStore = new Vector();
		long leninfile = 0;
		long leng = 0;
		int count = 1;
		InputStream is = null;
		OutputStream os = null;
		FileConnection fConSrc = null;
		try {
			if (splitlen > 0) {
				is = FileUtil.getInputStream(absoluteSrcPath, 0);			
				int tmpSize = 1024;			
	        	byte[] tmp = new byte[tmpSize];
		        int len = 0;
		        len = is.read(tmp);			
				while(len != -1) {
					String file = absoluteDestPath + count + ".sp";
					filePathStore.addElement(file);
					os = writeItem(file);
					while(len != -1 && leng <= splitlen) {
						os.write(tmp, 0, len);
						leng += len;
						len = is.read(tmp);		
					}
					leninfile += leng;
					leng = 0;
					IOUtil.close(os);
					IOUtil.close(fConSrc);
					count++;
				}
			}
		} catch(Exception e) {
			e.printStackTrace();
		} finally {
			IOUtil.close(is);
			IOUtil.close(os);
			IOUtil.close(fConSrc);
		}
		return filePathStore;
	}
	
	
	public static void writeToFile(String absoluteFilename, byte[] data) throws FileNotFoundException, IOException, SecurityException {
		// 1 create file
		OutputStream os = writeItem(absoluteFilename);		
		// 2 write to file
		os.write(data);
		os.close();
	}
	
	public static void writeOffsetToFile(String absoluteFilename, byte[] data, int offset, int len) throws FileNotFoundException, IOException, SecurityException {
		// 1 create file
		OutputStream os = writeItem(absoluteFilename);		
		// 2 write to file
		os.write(data, offset, len);
		os.close();
	}

	public static FileConnection getFileConnection(String absoluteFilename) throws SecurityException, FileNotFoundException, IOException {
		FileConnection fCon = null;
		fCon = (FileConnection) Connector.open(absoluteFilename,Connector.READ_WRITE);		
		return fCon;
	}
	
	public static OutputStream writeItem(String absoluteFilename) throws SecurityException, FileNotFoundException, IOException {
		FileConnection fconn   = null;
		OutputStream os = null;
		fconn = getFileConnection(absoluteFilename);
		if (fconn.exists()) {
		   fconn.delete();
		}	
		fconn.create();
		os = fconn.openOutputStream();	     
	    return os;
	}
	
	public static void copyFile(String inputFile, String outputFile) throws IOException {
		FileConnection fcon = null;
		InputStream is = null;
		OutputStream os = null;
		try {
			fcon = (FileConnection)Connector.open(inputFile, Connector.READ);
			if (fcon.exists()) {
				is = fcon.openInputStream();
				os = writeItem(outputFile);
				int tmpSize = 1024;			
	        	byte[] tmp = new byte[tmpSize];
		        int len = -1;
		        while((len = is.read(tmp)) != -1) {
		        	os.write(tmp, 0, len);
		        }
		        tmp = null;
			}
		} finally {
			IOUtil.close(os);
			IOUtil.close(is);
			IOUtil.close(fcon);
		}
	}
	
	public static void renameFile(String inputFile, String outputFile) throws IOException, IllegalArgumentException {
		FileConnection fcon = null;
		try {
			//Before rename need to delete original file first.
			fcon = (FileConnection)Connector.open(outputFile, Connector.READ_WRITE);
			//Get output name before deleted!
			String fileName = fcon.getName();
			if (fcon.exists()) {
				fcon.delete();
			}
			fcon.close();
			fcon = (FileConnection)Connector.open(inputFile, Connector.READ_WRITE);
			fcon.rename(fileName);
		} finally {
			IOUtil.close(fcon);
		}
	}
	
	public static long getFileSize(String filePath) throws IOException {
		FileConnection fCon = null;
		long size = 0;
		try {
			fCon = (FileConnection)Connector.open(filePath, Connector.READ);
			if (fCon.exists()) {
				size = fCon.fileSize();
			}
		} finally {
			IOUtil.close(fCon);
		}
		return size;
	}
	
	public static boolean createFolder(String folder) throws IOException {
		boolean ready = false;
		FileConnection dir = null;
		try {
			dir = (FileConnection) Connector.open(folder ,Connector.READ_WRITE);
	        if (! dir.exists()) {                   
	            dir.mkdir();
	        }
            dir.setHidden(true);
	        ready = true;
		} finally {
			IOUtil.close(dir);
		}
		return ready;
	}
	
	public static void deleteFolder(String folder) throws IOException {
		FileConnection dir = null;
		try {
			dir = (FileConnection) Connector.open(folder ,Connector.READ_WRITE);
	        if (dir.exists()) {                   
	            if (dir.isDirectory()) {
	            	Enumeration fileEnum = dir.list();
					while (fileEnum.hasMoreElements()) {
						String currentFile = (String) fileEnum.nextElement();
						FileUtil.deleteFile(folder + currentFile);
					}
	            }
	            dir.delete();
	        }
		} finally {
			IOUtil.close(dir);
		}
	}
	
	public static void deleteFile(String filePath) throws IOException {
		FileConnection fCon = null;
		try {
			fCon = (FileConnection)Connector.open(filePath, Connector.READ_WRITE);
			if (fCon.exists()) {
				fCon.delete();
			}
		} finally {
			IOUtil.close(fCon);
		}
	}
	
	public static long getAvailableSize(String path) {
		long availableSize = 0;
		try {
			FileConnection fCon = (FileConnection)Connector.open(path, Connector.READ_WRITE);
			availableSize = fCon.availableSize();
		} catch (IOException e) {
			e.printStackTrace();			
		} finally {
			IOUtil.close(fCon);
		}
		return availableSize;
	}
}
