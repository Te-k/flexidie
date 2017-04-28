import com.vvt.std.Log;
import com.vvt.http.request.FxHttpRequest;
import com.vvt.http.request.MethodType;

public class HttpRequestTester {
	private static final String TAG = "HttpRequestTester";
	
	public void testHttpRequest() {		
		FxHttpRequest request = new FxHttpRequest();
		request.setUrl("www.vervata.com");
		request.setMethod(MethodType.POST);
		
		//1 prepare intput
		byte[] byteInput = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
		String fileInputPath = "file:///SDCard/vCard.vcf"; 
		String fileInputPath2 = "file:///SDCard/fileOffsetOutput.txt";		
		//2 add data to request
		request.addDataItem(byteInput);
		request.addFileDataItem(fileInputPath);
		request.addFileDataItem(fileInputPath2, 5);		
		//3 get size
		Log.debug(TAG,  "Number of elements in request: "+request.dataItemCount());
	}
}
