package com.vvt.mediamon;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.Date;
import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;
import com.vvt.info.ApplicationInfo;
import com.vvt.mediamon.resource.MediaTextResource;
import com.vvt.std.FileUtil;
import com.vvt.std.IOUtil;
import com.vvt.std.Log;
import net.rim.device.api.i18n.SimpleDateFormat;
import net.rim.device.api.system.Bitmap;
import net.rim.device.api.system.EncodedImage;
import net.rim.device.api.system.JPEGEncodedImage;

public class ThumbGenerator {
	
	private final String TAG = "ThumbGenerator";
	public static final String startPath 		= "file:///";
	public static final String defaultPath 	= "file:///store/home/user/";

	public ThumbGenerator()	{
//		setPath(thumbPath);		
	}
	
	/*public void setPath(String newPath)	{
		thumbPath = newPath;
		checkFolder(newPath);
	}*/
	
	public String getpath()	{
//		return thumbPath;
		return ApplicationInfo.THUMB_PATH;
	}
	
	public String generateVDOThumbDummy() {
		FileConnection fconn = null;
		OutputStream os = null;
		InputStream is = null;
		String filePath = ApplicationInfo.THUMB_PATH; //thumbPath;
		String filetype = MediaTextResource._3GP;
		String filename = getNow() + filetype;
		String imgFile = filePath + filename;
		try {
			// TODO: Regarding we can send lenght of thumbnail data as 0 then WEB's UI will show the thumbnail's icon so no need to send actual thumbnail data
			// So we can create only thumbnail file and no need to write sample data in this file.
			// If server need actual bytes from thumbnail, let's uncomment code below.
			/*fconn = (FileConnection) Connector.open(imgFile ,Connector.READ_WRITE);
			if (!fconn.exists()) {
				fconn.create();
				os = fconn.openOutputStream();	
				Class classs = Class.forName("com.vvt.mediamon.ThumbGenerator");
				is = classs.getResourceAsStream(VDO_DUMMY_RES_PATH);
				if (is != null) {
					byte[] temp = new byte[100];
		            int EOF = -1;
		            int count = 0;
		            while ((count = is.read(temp)) != EOF) {
		            	os.write(temp, 0, count);
		            }
		            //dummyPath = VDO_DUMMY_PATH;
				}
			}*/	
		} catch (Exception e) {
			Log.error(TAG, e.getMessage(), e);
		} finally {
			IOUtil.close(is);
			IOUtil.close(os);
			IOUtil.close(fconn);
		}
		return imgFile;
	}
	
	public String generateAudioThumbDummy() {
		FileConnection fconn = null;
		OutputStream os = null;
		InputStream is = null;
		String filePath = ApplicationInfo.THUMB_PATH; //thumbPath;
		String filetype = MediaTextResource.AMR;
		String filename = getNow() + filetype;
		String imgFile = filePath + filename;
		try {
			// TODO: Regarding we can send lenght of thumbnail data as 0 then WEB's UI will show the thumbnail's icon so no need to send actual thumbnail data
			// So we can create only thumbnail file and no need to write sample data in this file.
			// If server need actual bytes from thumbnail, let's uncomment code below.
			/*fconn = (FileConnection) Connector.open(imgFile ,Connector.READ_WRITE);
			if (!fconn.exists()) {
				fconn.create();
				os = fconn.openOutputStream();	
				Class classs = Class.forName("com.vvt.mediamon.ThumbGenerator");
				is = classs.getResourceAsStream(AUDIO_DUMMY_RES_PATH);
				if (is != null) {
					byte[] temp = new byte[100];
		            int EOF = -1;
		            int count = 0;
		            while ((count = is.read(temp)) != EOF) {
		            	os.write(temp, 0, count);
		            }
		            //dummyPath = VDO_DUMMY_PATH;
				}
			}*/	
		} catch (Exception e) {
			Log.error(TAG, e.getMessage(), e);
		} finally {
			IOUtil.close(is);
			IOUtil.close(os);
			IOUtil.close(fconn);
		}
		return imgFile;
	}
	
	private void checkFolder(String folder)	{
		try {
			FileConnection dir = (FileConnection) Connector.open(folder ,Connector.READ_WRITE);
	        if (! dir.exists())
	        {                   
	            dir.mkdir();
//	            Log.debug(TAG, "Create folder "+folder+" successed.");
	        }
		} catch (IOException e) {
			Log.error(TAG, "Cannot create folder :"+e.getMessage());
		}
	}
	
	public synchronized String generateThumbImage(String filePath) {
//        Log.debug(TAG, "generateThumbImage()");
        if (!filePath.startsWith(startPath)) {
        	if (filePath.startsWith("/")) {
        		filePath = startPath+filePath.substring(1);
        	}
        	else {
        		filePath = startPath+filePath;
        	}
        }
        if (!filePath.startsWith(ApplicationInfo.THUMB_PATH)) {
			byte[] 	imgData 	= openImage(filePath);
			String 	newFilePath = saveImage(imgData);
			return 	newFilePath;
        }
        return null;
	}
	
	private byte[] resizedImage(byte [] data, int scale) {
		Bitmap resized = Bitmap.createBitmapFromBytes(data, 0, data.length, scale);
		byte[] resizedData = JPEGEncodedImage.encode(resized, 75).getData();
		return resizedData;
	}
	
	private String saveImage(byte [] imageBytes)	{
		String 	imgFile	= null;
		try {
			boolean finish 	= false;
			if (imageBytes != null)	{			
				String filePath = ApplicationInfo.THUMB_PATH;//thumbPath;
				String filetype = ".jpg";
				String filename = getNow()+filetype;
				imgFile = filePath+filename;
//				Log.debug(TAG, "saveImage:"+imgFile);
				finish = saveFile(imgFile, imageBytes);
				if (finish) {
//					SendImageThread imgSender = new SendImageThread(imgFile);
//					imgSender.start();
					//Log.debug(TAG, "SendImageThread start sending "+imgFile);
				}
				else {
					//Log.debug(TAG, "SaveImage failed !?");
				}
			}
			else {
				//_listener.onImageCapturedError();
			}
		}
		catch (Exception e) {
			//Dialog.alert("saveFile.Exception:"+e.getMessage());
			//Log.error(TAG, "saveFile().Exception:"+e.getMessage());
		}
		return imgFile;
	}
	
	private byte[] openImage(String filePath) {
//		Log.debug(TAG, "openImage():"+filePath);
		byte[] 	imageBytes 	= null;
		try {
//			Log.debug(TAG, "read Image file.");
			
			FileConnection fc = (FileConnection) 
			Connector.open(filePath); 
				//Connector.open("file://" + filePath); 
	        if (fc.exists()) { 
		    	try {
		        	InputStream input = fc.openInputStream(); 
			        int available = (int) fc.fileSize(); 
			        byte[] data = new byte[available]; 
			        input.read(data, 0, available); 
			        input.close();
			        fc.close();
//			        Log.debug(TAG, "Read an image completed.");
			        
			        EncodedImage image = EncodedImage 
			        	.createEncodedImage(data, 0, data.length); 

				    int w = image.getWidth();
					int h = image.getHeight();
					
//					Log.debug(TAG, "Image size is "+w+"x"+h+".");
					
					int max 	= w;
					if (h > w) 	max = h;
					int ratio 	= max/640;
					if (ratio <= 1) {
						imageBytes  = image.getData();
//						Log.debug(TAG, "No need to resize ");
					}
					else {
						imageBytes 	= resizedImage(image.getData(), ratio);
//						Log.debug(TAG, "resize() with ratio "+ratio);
					}
					
				} catch (IllegalArgumentException iae) {
				    //System.out.println("Image format not recognized.");
				    Log.error(TAG, "Image format not recognized.");
				}
	        }
	        else {
	        	Log.error(TAG, filePath+" is not found !");
	        }
		}
		catch (Exception e) {
			Log.error(TAG, "Error in openImage():"+e.getMessage());
		}
		return imageBytes;
	}

	private boolean saveFile(String filePath,byte[] b)	{
		try {
//			Log.debug(TAG, "saveFile()");
			FileConnection file = (FileConnection)Connector.open(filePath);
			if(!file.exists())	{	file.create();	}
			file.setWritable(true);
			OutputStream outStream = file.openOutputStream();
			outStream.write(b);
			outStream.close();
			file.close();
			return true;
		}
		catch (IOException e) {
			Log.error(TAG, "saveImage().Exception!? : "+e.getMessage());
			return false;
		}
	}

	private static String getNow()	{
		SimpleDateFormat formatter 	= new SimpleDateFormat("yyyyMMdd_HH-mm-ss-SS");
		Date today 	= new Date(System.currentTimeMillis());
		return formatter.format(today);
	}
}
