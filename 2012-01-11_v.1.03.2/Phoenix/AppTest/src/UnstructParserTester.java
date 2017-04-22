import net.rim.device.api.util.DataBuffer;

import com.vvt.prot.parser.UnstructParser;
import com.vvt.prot.unstruct.request.KeyExchangeRequest;
import com.vvt.std.Log;


public class UnstructParserTester {
	private static final String strTAG = "UnstructParserTester";
	//Real Device
	//private static final String Path = "file:///store/home/user/";
	//Emulator
	private static final String Path = "file:///SDCard/";
	
	public void runUnstructParser() {		
		try {
			System.out.print("******* What ********");
			
			String filename = "runUnstructParser.dat";
			DataBuffer buffer = new DataBuffer();
			KeyExchangeRequest keyExReq = new KeyExchangeRequest();
			
			keyExReq.setCode(1);
			keyExReq.setEncodeType(1);
			buffer.write(UnstructParser.parseRequest(keyExReq));
			
			if (Log.isDebugEnable()) {
				Log.debug(strTAG, "UnstructParser passed!");
				//FileUtil.writeToFile(Path+filename, buffer.toArray());
				
			}
		} catch (Exception e) {
			Log.error(strTAG, "runUnstructParser failed!: ",e);
		}
	}
}
