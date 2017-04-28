package com.vvt.phoenix.util;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;

/**
 * @author Tanakharn
 * @version 1.0
 * @created 29-Apr-2010 7:25:44 PM
 */
public class DataBuffer {

	// Field
	private ByteArrayOutputStream mDataWrite;	// for write data to buffer
	private ByteArrayInputStream mDataRead;		// for read data from buffer
	
	//Constants
	public static final int BYTE = 1;
	public static final int SHORT = 2;
	public static final int INT = 4;
	public static final int LONG = 8;
	
	
	
//////////////////////////////////////////////////////Read from Buffer Methods ///////////////////////////////////////

	// Constructor
	public DataBuffer(byte[] buffer){
		mDataRead = new ByteArrayInputStream(buffer);
	}
	public DataBuffer(byte[] buffer, int offset, int len){
		mDataRead = new ByteArrayInputStream(buffer, offset, len);
	}
	//

	public boolean readBoolean(){
		boolean result;
		byte bool = this.readByte();
		if(bool == 0x1){
			result = true;
		}else{
			result = false;
		}
		return result;
	}
	
	public byte readByte(){
		byte[] buffer;
		buffer = new byte[1];
		mDataRead.read(buffer, 0, 1);		// 1 byte
		return buffer[0];
	}
	
	public byte[] readBytes(int len){
		byte[] result = new byte[len];
		mDataRead.read(result, 0, len);
		return result;
	}
	
	/**
	 * @param buffer
	 * @return
	 * this method follow Java convention (receive byte[] and return number of readed)
	 */
	public int readBytes(byte[] buffer){
		return mDataRead.read(buffer, 0, buffer.length);
	}
	
	public void skip(int len){
		mDataRead.skip(len);
	}
	
	
	/**
	 * @param byteSkip
	 * @param len
	 * @return
	 * @throws IOException
	 * read len data in specific part and return to current position
	 */
	public byte[] directRead(int byteSkip, int len) throws IOException{
		byte[] result = new byte[len];
		//1 mark current position and set read limit before this mark become invalid
		//mDataRead.mark(byteSkip + len);
		mDataRead.mark(mDataRead.available());
		
		//2 skip to target byte
		mDataRead.skip(byteSkip);
		
		//3 read len bytes from new position
		mDataRead.read(result);
	
		//4 reset buffer to previous marked position
		mDataRead.reset();
		
		return result;
	
	}
	
	/**
	 * read all remaining bytes and return to current position
	 * @return
	 * @throws IOException
	 * 
	 */
	public byte[] borrowRemain() throws IOException{
		byte[] borrow = new byte[mDataRead.available()];
		//1 mark current position
		mDataRead.mark(mDataRead.available());
		
		//2 read all remain
		mDataRead.read(borrow);
		
		//3 reset to previous position
		mDataRead.reset();
		
		return borrow;
	}

	/*
	public char readChar(){
		byte[] buffer;
		buffer = new byte[1];
		mDataRead.read(buffer, 0, 1);		// 1 byte
		String str = new String(buffer);
		char c = str.charAt(0);
		return c;
	}
	// use for debug (Writing to file)
	public byte readCharByte(){	
		byte[] buffer;
		buffer = new byte[1];
		mDataRead.read(buffer, 0, 1);		// 1 byte
		return buffer[0];
	}
	*/

	public int readInt(){
		byte[] buffer;
		buffer = new byte[4];
		mDataRead.read(buffer, 0, 4);		// 4 bytes
		ByteBuffer bb = ByteBuffer.allocate(4);
		bb.put(buffer);
		int result = bb.getInt(0);
		return result;
	}

	public long readLong(){
		byte[] buffer;
		buffer = new byte[8];
		mDataRead.read(buffer, 0, 8);		// 8 bytes
		ByteBuffer bb = ByteBuffer.allocate(8);
		bb.put(buffer);
		long result = bb.getLong(0);
		return result;
	}
	
	/**
	 * read 4 bytes from buffer and convert to correctly long
	 * @return
	 */
	public long read4BytesAsLong(){
		byte[] buffer;
		buffer = new byte[4];
		mDataRead.read(buffer, 0, 4);		// 4 bytes
		ByteBuffer bb = ByteBuffer.allocate(8);
		bb.putInt(0);
		bb.put(buffer);
		long result = bb.getLong(0);
		return result;
	}

	public short readShort(){
		byte[] buffer;
		buffer = new byte[2];
		mDataRead.read(buffer, 0, 2);		// 2 bytes
		ByteBuffer bb = ByteBuffer.allocate(2);
		bb.put(buffer);
		short result = bb.getShort(0);
		return result;
	}
	/*
	public String readUTF(){
		
		return "";
	}
	*/
	public String readUTF(int len){
		byte[] buffer;
		buffer = new byte[len];
		mDataRead.read(buffer, 0, len);		// n bytes
		String result = new String(buffer);
		return result;
	}
	
	public double readDouble(){
		byte[] buffer;
		buffer = new byte[8];
		mDataRead.read(buffer, 0, 8);		// 8 bytes
		ByteBuffer bb = ByteBuffer.allocate(8);
		bb.put(buffer);
		double result = bb.getDouble(0);
		return result;
	}
	
	public float readFloat(){
		byte[] buffer;
		buffer = new byte[4];
		mDataRead.read(buffer, 0, 4);		// 4 bytes
		ByteBuffer bb = ByteBuffer.allocate(4);
		bb.put(buffer);
		float result = bb.getFloat(0);
		return result;
	}
	
//////////////////////////////////////////////////////// Write To Buffer Methods ///////////////////////////////////////
	
	//Constructor
	public DataBuffer(){
		mDataWrite = new ByteArrayOutputStream();
	}
	public DataBuffer(int bufferSize){
		mDataWrite = new ByteArrayOutputStream(bufferSize);
	}
	//
	
	public byte[] toArray(){
		
		return mDataWrite.toByteArray();
	}

	public void writeBoolean(boolean b){
		byte buf;
		if(b){
			buf = 0x1;
		}else{
			buf = 0x0;
		}
		mDataWrite.write(buf);
	}

	/*
	public void writeByte(int v){

	}
	*/
	public void writeByte(byte b){
		mDataWrite.write(b);
	}

	public void writeBytes(int len, int offset, byte[] b){
		mDataWrite.write(b, offset, len);
	}
	
	public void writeBytes(byte[] b){
		mDataWrite.write(b, 0, b.length);
	}

	/*
	// should this method write char length?
	public void writeChar(char c){
		String str = ""+c;
		byte[] buffer = str.getBytes();
		try {
			mDataWrite.write(buffer);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	*/

	public void writeInt(int v){
		byte[] buffer = ByteUtil.toBytes(v);
		try {
			mDataWrite.write(buffer);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void writeLong(long v){
		byte[] buffer = ByteUtil.toBytes(v);
		try {
			mDataWrite.write(buffer);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void writeDouble(double v){
		byte[] buffer = ByteUtil.toBytes(v);
		try {
			mDataWrite.write(buffer);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void writeFloat(float v){
		byte[] buffer = ByteUtil.toBytes(v);
		try {
			mDataWrite.write(buffer);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void writeShort(short v){
		byte[] buffer = ByteUtil.toBytes(v);
		try {
			mDataWrite.write(buffer);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	public void writeUTF(String str){
		byte[] buffer = ByteUtil.toBytes(str);
		try {
			mDataWrite.write(buffer);		
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	/**
	 * @param str
	 * @param lengthSize declare in DataBuffer
	 */
	public void writeUTFWithLength(String str, int lengthSize){
		byte[] buffer = ByteUtil.toBytes(str);
		int len = buffer.length;
		
		//write len
		if(lengthSize == BYTE){
			writeByte((byte) len);
		}else if(lengthSize == SHORT){
			writeShort((short) len);
		}else if(lengthSize == INT){
			writeInt(len);
		}else if(lengthSize == LONG){
			writeLong(len);
		}
		
		//write string
		try {
			mDataWrite.write(buffer);		
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public void clearWriter(){
		mDataWrite = new ByteArrayOutputStream();
	}
	/*
	public void writeUTF(int size, String str){
		byte[] buffer = ByteUtil.toBytes(str);
		int len = buffer.length;
		byte[] lenBuffer = ByteUtil.toBytes(len);
		
		//1 write length
		if(size == 1){
			mDataWrite.write(lenBuffer, 3, 1);
		}else if(size == 2){
			mDataWrite.write(lenBuffer, 2, 2);
		}else if(size == 3){
			mDataWrite.write(lenBuffer, 1, 3);
		}else if(size == 4){
			mDataWrite.write(lenBuffer, 0, 4);
		}
		
		//2 write data
		try {
			mDataWrite.write(buffer);	
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	*/

}