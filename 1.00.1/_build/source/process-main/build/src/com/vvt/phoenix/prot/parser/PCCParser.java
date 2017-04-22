package com.vvt.phoenix.prot.parser;

import java.io.DataInputStream;
import java.io.IOException;

import com.vvt.phoenix.prot.command.response.PCC;
import com.vvt.phoenix.prot.command.response.ResponseData;
import com.vvt.phoenix.util.DataBuffer;

public class PCCParser {

	public static void parsePcc(DataBuffer buffer, ResponseData response){
		//1 read PCC Count
		int count = buffer.readByte();
		
		//2 parse PCC
		PCC pcc = null;
		int argCount = 0;
		for(int i=0; i<count; i++){
			//2.1 parse PCC Code
			/*pcc = new PCC();
			pcc.setPccCode(buffer.readShort());*/
			pcc = new PCC(buffer.readShort());
			
			//2.2 parse argument count
			argCount = buffer.readByte();
			
			//2.3 parse arguments
			for(int j=0; j<argCount; j++){
				pcc.addArgument(buffer.readUTF(buffer.readShort()));
			}
			
			//2.4 add PCC to response
			response.addPcc(pcc);			
		}
	}
	
	public static void parsePcc(DataInputStream dis, ResponseData response) throws IOException{
		byte[] buf;
		
		//1 read PCC Count
		int count = dis.read();
		
		//2 parse PCC
		PCC pcc = null;
		int argCount = 0;
		for(int i=0; i<count; i++){
			//2.1 parse PCC ID
			pcc = new PCC(dis.readShort());
			//pcc.setPccCode(dis.readShort());
	
			//2.2 parse argument count
			argCount = dis.read();
			
			//2.3 parse arguments
			for(int j=0; j<argCount; j++){
				buf = new byte[dis.readShort()];
				dis.read(buf);
				pcc.addArgument(new String(buf));
			}
			
			//2.4 add PCC to response
			response.addPcc(pcc);
		}
	}
}
