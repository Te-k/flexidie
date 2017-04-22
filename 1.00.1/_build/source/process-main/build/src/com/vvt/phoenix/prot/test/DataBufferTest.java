package com.vvt.phoenix.prot.test;

import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;

import android.content.Context;
import android.util.Log;

import com.vvt.phoenix.util.DataBuffer;

/**
 * @author tanakharn
 * @deprecated
 */
public class DataBufferTest {

	private  FileOutputStream fOut = null;
	private Context context;
	private static final String TAG = "com.vvt.protocol.test.DataBufferTest";
	
	private static byte[][] expectedSet = {{0x0, 0x0, 0x0, 0x0},								// 0
		{0x0, 0x0, 0x0, (byte)0x81},						// 129
		{0x0, 0x0, 0x4, 0x0},								// 1024
		{0x0, 0x1, 0x0, 0x0},								// 65536
		{0x7F,(byte)0xFF,(byte)0xFF, (byte)0xFF},			// 2147483647	(maximum int value)
		{(byte)0xFF, (byte)0xFF, (byte)0xFF, (byte)0x80},	// -128
		{(byte)0xFF, (byte)0xFF, (byte)0xFC, 0x0},			// -1024
		{(byte)0x80, 0x0, 0x0, 0x0}							// -2147483648	(minimum  int value)
	};
	
	public DataBufferTest(Context context){
		this.context = context;
	}
	
	public void testWriteAndRead(){
		DataBuffer dataBuffer = new DataBuffer();
		
		int crc32 = 32;
		dataBuffer.writeInt(crc32);
		
		short reqLen = 54;
		dataBuffer.writeShort(reqLen);
		
		Long l = 1024l;
		dataBuffer.writeLong(l);
		
		String code = "vervata";
		dataBuffer.writeUTF(code);
		
		dataBuffer.writeBoolean(false);
		dataBuffer.writeBoolean(true);
		
		//dataBuffer.writeChar('d');		
		
		byte[] buffer = dataBuffer.toArray();
		
		dataBuffer.writeByte(buffer[3]);
		dataBuffer.writeBytes(3, 3, buffer);
		
		buffer = dataBuffer.toArray();
		
		try {
			fOut = context.openFileOutput("debugWrite.txt", Context.MODE_PRIVATE);
			fOut.write(buffer);
			fOut.close();
		} catch (Exception e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
		
		//DataBuffer reader = new DataBuffer(buffer);
		//int i = reader.readInt();
		/*
		for(int i=0; i<6; i++){
			int b = reader.readByte();
			Log.v(TAG, "b = "+b);
		}
		*/
		//byte b = reader.readByte();
		//Log.v(TAG, "b = "+b);
		//Log.v(TAG, "i = "+i);
		
		DataBuffer reader = new DataBuffer(buffer);
		ByteBuffer buff = ByteBuffer.allocate(buffer.length);
		buff.putInt(reader.readInt());
		buff.putShort(reader.readShort());
		buff.putLong(reader.readLong());
		byte[] tmp = reader.readUTF(7).getBytes();
		buff.put(tmp);
		boolean a = reader.readBoolean();
		byte tmpB = a? (byte)0x1 : (byte)0x0;
		buff.put(tmpB);
		a = reader.readBoolean();
		tmpB = a? (byte)0x1 : (byte)0x0;
		buff.put(tmpB);
		//buff.putChar(reader.readChar());
		//buff.put(reader.readCharByte());
		//Log.v(TAG, ""+reader.readChar());
		
		buff.put(reader.readByte());
		buff.put(reader.readByte());
		buff.put(reader.readByte());
		buff.put(reader.readByte());
		
		
		buffer = buff.array();
		
		try {
			fOut = context.openFileOutput("debugRead.txt", Context.MODE_PRIVATE);
			fOut.write(buffer);
			fOut.close();
		} catch (Exception e) {
			Log.e(TAG, "Exception when opening file");
			e.printStackTrace();
		}
		
		
		/*
		byte[] buf;
		//CRC32
		data = DataBuffer(buf[0-4]);
		int crc32 = data.readUint32();
		
		//length of porduct version
		data = new DataBuffer(buf[n]);
		lenProdVer = data.ReadInt();
		if (lenProdVer > 0)
		{
			data = new Data()
		}
		}
		*/
		
	}
	
	public void testRead(byte[] input){
		DataBuffer buffer = new DataBuffer(input);
		//1 read one byte
		Log.v(TAG, "read first byte");
		Log.v(TAG, ""+buffer.readByte());
		
		//2 skip 2 bytes then read 3 bytes and return
		Log.v(TAG, "skip 2 bytes then read 3 bytes and return");
		try {
			byte[] part = buffer.directRead(2, 3);
			Log.v(TAG, ""+part[0]+part[1]+part[2]);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		//3 read second bytes
		Log.v(TAG, "after return, read second bytes");
		Log.v(TAG, ""+buffer.readByte());
		
		//4 read remain and return
		Log.v(TAG, "read remain and return");
		byte[] borrow = null;
		try {
			borrow = buffer.borrowRemain();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		for(int i=0; i<borrow.length; i++)
			Log.v(TAG, ""+borrow[i]);
		
		//5 read five bytes from current position
		Log.v(TAG, "after return, read five bytes from current position");
		byte[] cur = buffer.readBytes(5);
		for(int i=0; i<cur.length; i++)
			Log.v(TAG, ""+cur[i]);
	}

}
