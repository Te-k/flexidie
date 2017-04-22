package com.vvt.phoenix.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import android.content.Context;

import com.vvt.phoenix.config.Customization;
import com.vvt.phoenix.exception.DataCorruptedException;
import com.vvt.phoenix.util.DataBuffer;

/**
 * Class Utility help you read-write file and read file with specific offset
 * position in file
 * 
 * @author Tanakharn
 * 
 */
public class FileUtil {
	// Debug Information
	private static final String TAG = "com.vvt.io.FileIO";
	private static final boolean DEBUG = true;
	private static final boolean LOCAL_LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGD = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOCAL_LOGE = Customization.DEBUG ? DEBUG : false;

	// Fields
	private static final int BUFFER_SIZE = Customization.BUFFER_SIZE;


	// ////////////////////////////////////////////////////////////// Read Section ///////////////////////////////////////////
	/**
	 * Get FileInputStream (not create) of the specific file. CAUTION: Caller must close
	 * stream by themselves.
	 * 
	 * @param absoluteFilename
	 *            Name of given file in absolute path
	 * @return FileInputStream
	 * @throws FileNotFoundException
	 *             If can not find the given file
	 * @throws SecurityException
	 *             if can not access the given file
	 */
	public static FileInputStream getFileInputStream(String absoluteFilename)
			throws FileNotFoundException, SecurityException {
		// 1 open file
		FileInputStream fIn = null;
		fIn = new FileInputStream(absoluteFilename);

		return fIn;
	}

	/**
	 * Get FileInputStream (not create) of the specific file that ready to read in specific
	 * position. CAUTION: Caller must close stream by themselves.
	 * 
	 * @param absoluteFilename
	 *            Name of given file in absolute path
	 * @param offset
	 *            Number of offset
	 * @return FileInputStream
	 * @throws IllegalArgumentException
	 *             if the given offset is out of range
	 * @throws FileNotFoundException
	 *             if can not find the given file
	 * @throws IOException
	 *             if error occur while seeking to offset position
	 * @throws SecurityException
	 *             if can not access the given file
	 */
	public static FileInputStream getFileInputStream(String absoluteFilename, int offset)
			throws IllegalArgumentException, FileNotFoundException,
			SecurityException, IOException {

		// 1 get file object
		File file = new File(absoluteFilename);

		// 2 calculate file size
		int fileSize = -1;
		fileSize = (int) file.length();
		if (fileSize == 0)throw new FileNotFoundException(TAG + ": Can not find "+ absoluteFilename);
		

		// 3 validate offset
		if (offset < 0 || offset >= fileSize) throw new IllegalArgumentException("offset "+offset+" is out of "+absoluteFilename+" range");

		// 4 initiate FileInputStream
		FileInputStream fIn = null;
		fIn = new FileInputStream(file);


		// 5 skip to offset
		fIn.skip(offset);


		return fIn;
	}

	/**
	 * Read whole file and return in bytes array.
	 * 
	 * @param absoluteFilename
	 *            Name of given file in absolute path
	 * @return byte[]
	 * @throws FileNotFoundException
	 *             If can not find the given file
	 * @throws IOException
	 *             If error occur while reading or closing file
	 * @throws SecurityException
	 *             if can not access the given file
	 */
	public static byte[] readBytes(String absoluteFilename)
			throws FileNotFoundException, IOException, SecurityException {
		// 1 get FileInputStream
		FileInputStream fIn = null;
		fIn = getFileInputStream(absoluteFilename);


		// 2 read all bytes
		DataBuffer buffer = new DataBuffer();
		byte[] buf = new byte[BUFFER_SIZE];
		int readed = 0;
		readed = fIn.read(buf);
		while (readed != -1) {
			buffer.writeBytes(readed, 0, buf);
			readed = fIn.read(buf);
		}
		fIn.close();


		return buffer.toArray();

	}

	/**
	 * Read from offset to end of file and return in bytes array.
	 * 
	 * @param absoluteFilename
	 *            Name of given file in absolute path
	 * @param offset
	 *            Number of offset
	 * @return byte[]
	 * @throws IllegalArgumentException
	 *             If the given offset is out of range
	 * @throws FileNotFoundException
	 *             If can not find the given file
	 * @throws IOException
	 *             If error occur while seeking to offset position, or error
	 *             occur while reading or closing FileInpuStream
	 * @throws SecurityException
	 *             if can not access the given file
	 */
	public static byte[] readBytes(String absoluteFilename, int offset)
			throws IllegalArgumentException, FileNotFoundException,
			SecurityException, IOException {
		// 1 get FileInputStream that already set offset
		FileInputStream fIn = null;
		fIn = getFileInputStream(absoluteFilename, offset);


		// 2 read remaining bytes
		DataBuffer buffer = new DataBuffer();
		byte[] buf = new byte[BUFFER_SIZE];
		int readed = 0;
		readed = fIn.read(buf);
		while (readed != -1) {
			buffer.writeBytes(readed, 0, buf);
			readed = fIn.read(buf);
		}
		fIn.close();


		return buffer.toArray();

	}

	/**
	 * Read whole file and return in bytes array.
	 * 
	 * @param absoluteFilename
	 *            Name of given file in absolute path
	 * @return byte[]
	 * @throws FileNotFoundException
	 *             If can not find the given file
	 * @throws IOException
	 *             If error occur while reading or closing file
	 * @throws SecurityException
	 *             if can not access the given file
	 */
	public static byte[] readBytes(FileInputStream fIn)
			throws FileNotFoundException, IOException, SecurityException {
		// 1 read all bytes
		DataBuffer buffer = new DataBuffer();
		byte[] buf = new byte[BUFFER_SIZE];
		int readed = 0;
		readed = fIn.read(buf);
		while (readed != -1) {
			buffer.writeBytes(readed, 0, buf);
			readed = fIn.read(buf);
		}
		fIn.close();


		return buffer.toArray();

	}

	/**
	 * Read from offset to end of file and return in bytes array.
	 * 
	 * @param fIn
	 *            FileInputStream to read
	 * @param offset
	 *            Number of offset
	 * @return byte[]
	 * @throws FileNotFoundException
	 *             If can not find the given file
	 * @throws IOException
	 *             If error occur while seeking to offset position, or error
	 *             occur while reading or closing FileInpuStream
	 * @throws SecurityException
	 *             if can not access the given file
	 */
	public static byte[] readBytes(FileInputStream fIn, int offset)
			throws  FileNotFoundException,
			SecurityException, IOException {
		// 1 skip to offset
		fIn.skip(offset);
		
		// 2 read remaining bytes
		DataBuffer buffer = new DataBuffer();
		byte[] buf = new byte[BUFFER_SIZE];
		int readCount = 0;
		readCount = fIn.read(buf);
		while (readCount != -1) {
			buffer.writeBytes(readCount, 0, buf);
			readCount = fIn.read(buf);
		}
		fIn.close();


		return buffer.toArray();

	}
	// ////////////////////////////////////////////////////////////// Write Section ///////////////////////////////////////////
	/**
	 * Writing bytes data to the given file. CAUTION: If the given file has
	 * already exit, this method will erase and creating new one.
	 * 
	 * @param absoluteFilename
	 *            Name of the given file in absolute path
	 * @param data
	 *            Byte array of data to store in the file
	 * @throws FileNotFoundException
	 *             If error occur while opening or creating the given file
	 * @throws IOException
	 *             If error occur while writing or closing the given file
	 * @throws SecurityException
	 *             if can not access the given file
	 */
	public static void writeToFile(String absoluteFilename, byte[] data)
			throws FileNotFoundException, IOException, SecurityException {
		// 1 create file
		FileOutputStream fOut = null;
		fOut = new FileOutputStream(absoluteFilename, false); // false for not append operation

		// 2 write to file
		fOut.write(data);
		fOut.close();


	}

	/**
	 * Append bytes data to the end of given file. If the given file has already
	 * exit, this method will append data to end of the file. Otherwise this
	 * method will creating new file.
	 * 
	 * @param absoluteFilename
	 *            Name of the given file iin absolute path
	 * @param data
	 *            Byte array of data to append to the file
	 * @throws FileNotFoundException
	 *             If error occur while opening or creating the given file
	 * @throws IOException
	 *             If error occur while writing or closing the given file
	 * @throws SecurityException
	 *             if can not access the given file
	 */
	public static void appendToFile(String absoluteFilename, byte[] data)
			throws FileNotFoundException, IOException, SecurityException {
		// 1 create file
		FileOutputStream fOut = null;
		fOut = new FileOutputStream(absoluteFilename, true); // true for append operation


		// 2 write to file
		fOut.write(data);
		fOut.close();

	}
	
	/**
	 * Create or re-create (if already exit) the given file and return FileOutputStream
	 * CAUTION: Caller must close stream by themselves.
	 * 
	 * @param absoluteFilename
	 * @return
	 * @throws FileNotFoundException	if file cannot be opened for writing.
	 * @throws SecurityException		if a SecurityManager is installed and it denies the write request.
	 */
	public static FileOutputStream getFileOutputStream(String absoluteFilename) throws FileNotFoundException, SecurityException
	 {
		// 1 create file
		FileOutputStream fOut = null;
		fOut = new FileOutputStream(absoluteFilename, false); // false for not append operation
		
		return fOut;
	}
	
	// ////////////////////////////////////////////////////////////// Make Directory ///////////////////////////////////////////
	public static boolean makeDirectory(String path){
		File file = new File(path);
		return file.mkdirs();
	}

}
