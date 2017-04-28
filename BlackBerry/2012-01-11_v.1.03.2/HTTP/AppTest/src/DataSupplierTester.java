
import java.util.Vector;

import net.rim.device.api.util.DataBuffer;

import com.vvt.std.Log;
import com.vvt.http.request.DataSupplier;
import com.vvt.http.request.PostByteItem;
import com.vvt.http.request.PostFileItem;
//import com.vvt.util.DataBuffer;

import com.vvt.std.FileUtil;

public class DataSupplierTester {
	
	private static final String TAG = "DataSupplierTester";
	
	public void testDataSupplier(){	
		Vector itemList = new Vector();
		
		//1 prepare intput
		byte[] byteInput = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
		String fInput1 = "file:///SDCard/vcard.vcf"; 
		String fInput2 = "file:///SDCard/byteOutput.txt";
		
		//2 add to array
		PostByteItem item1 = new PostByteItem();
		item1.setBytes(byteInput);
		PostFileItem item2 = new PostFileItem();
		item2.setFilePath(fInput1);
		PostFileItem item3 = new PostFileItem();
		item3.setFilePath(fInput2);
		item3.setOffset(5);
		 
		itemList.addElement(item1);
		itemList.addElement(item2);
		itemList.addElement(item3);
		
		//3 initiate DataSupplier
		DataSupplier supplier = new DataSupplier();
		
		//4 add data from request
		supplier.setDataItemList(itemList);
		
		//5 get size
		Log.debug(TAG,"Number of elements: "+supplier.getDataItemCount());
		
		try {
			Log.debug(TAG,"Total Data Size: "+supplier.getTotalDataSize());
		} catch(Exception e) {
			Log.error(TAG, "supplier.getTotalDataSize: "+e.getMessage());
			e.printStackTrace();
		}
		
		//6 read it
		DataBuffer supBuffer = new DataBuffer();
		byte[] buffer = new byte[8];
		try {
			int readed = supplier.read(buffer);
			while(readed != -1){
				supBuffer.write(buffer, 0, readed);
				readed = supplier.read(buffer);
			}
			FileUtil.writeToFile("file:///SDCard/DataSuppilerTester.txt", supBuffer.toArray());
		} catch (Exception e) {
			Log.error(TAG, ": "+e.getMessage());
			e.printStackTrace();
		}
	}
}
