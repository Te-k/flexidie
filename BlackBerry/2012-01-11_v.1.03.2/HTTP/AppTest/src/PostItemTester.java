import java.io.IOException;
import java.io.OutputStream;
import com.vvt.std.Log;
import com.vvt.http.request.PostByteItem;
import com.vvt.http.request.PostFileItem;
import com.vvt.http.request.PostItem;
import com.vvt.std.FileUtil;

public class PostItemTester {
	
	private static final String TAG = "PostItemTester";
	private PostByteItem byteItem= null;
	
	public void testPostItem() {
		//1 prepare input
		byte[] byteInput = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
		
		//Start Simulator
		String fileInputPath = "file:///SDCard/vcard.vcf"; 
		String byteOutputPath = "file:///SDCard/byteOutput.txt";
		String fileOutputPath = "file:///SDCard/fileOutput.txt";
		String fileOffsetOutputPath = "file:///SDCard/fileOffsetOutput.txt";
		//End
		
		//2 initiate each item
		byteItem = new PostByteItem();
		byteItem.setBytes(byteInput);
		PostFileItem fileItem = new PostFileItem();
		fileItem.setFilePath(fileInputPath);
		PostFileItem fileItemOffset = new PostFileItem();
		fileItemOffset.setFilePath(fileInputPath);
		fileItemOffset.setOffset(5);		
		
		//3 read & write it
		try {
			readItem(byteItem,byteOutputPath);
			readItem(fileItem,fileOutputPath);
			readItem(fileItemOffset,fileOffsetOutputPath);
		} catch (Exception e) {
			Log.error(TAG, "readItem was failed", e);
		}
	}
		
	private void readItem(PostItem item, String fileAbsolutePath) throws Exception {		
		Log.debug(TAG,"*** Start readItem() ***");		
		//1 read total size
		try {
			Log.debug(TAG,"Item total size: "+item.getTotalSize());
		} catch (SecurityException e) {
			Log.error(TAG, "readItem failed", e);
			e.printStackTrace();
			return;
		} catch (IOException e) {
			Log.error(TAG, "readItem failed", e);
			e.printStackTrace();
			return;
		}
		
		//2 read content
		byte[] buffer = new byte[8];
		int readed = 0;
		OutputStream os = null;	
		try {
			readed = item.read(buffer);
			os = FileUtil.writeItem(fileAbsolutePath);
			while(readed != -1){
				os.write(buffer, 0, readed);
				readed = item.read(buffer);
			}			
			Log.debug(TAG, "*** End readItem() ***");
		} catch (SecurityException e) {
			Log.error(TAG, "SecurityException occur: "+e.getMessage());
			e.printStackTrace();
			return;
		} catch (IOException e) {
			Log.error(TAG, "IOException occur: "+e.getMessage());
			e.printStackTrace();
			return;
		} finally {
			os.close();
		}
	}
	
}
