import java.io.OutputStream;

import javax.microedition.io.Connector;
import javax.microedition.io.file.FileConnection;

import com.vvt.prot.event.CameraImageThumbnailEvent;
import com.vvt.prot.event.MediaTypes;
import com.vvt.prot.parser.EventParser;
import com.vvt.std.IOUtil;
import com.vvt.std.Log;


public class EventParserTester {

	private static final String strTAG = "EventParserTester";
	
	public void testCameraImageThumbnailEvent() {
    	byte[] imageData = { 0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A };
    	FileConnection fCon = null;
		OutputStream os = null;
		try {
			fCon = (FileConnection)Connector.open("file:///SDCard/CameraImageThumbnailEvent.prot", Connector.READ_WRITE);
			if (fCon.exists()) {
				fCon.delete();
			}
			fCon.create();
			os = fCon.openOutputStream();
			CameraImageThumbnailEvent event = new CameraImageThumbnailEvent();
			String eventTime = "2010-05-13 09:41:22";
			event.setEventTime(eventTime);
			event.setPairingId(1000);
			event.setFormat(MediaTypes.JPEG);
			event.setLongitude(100.99);
			event.setLattitude(999.99);
			event.setAltitude(9999.99f);
			event.setImageData(imageData);
			event.setActualSize(1000);
			byte[] actual = EventParser.parseEvent(event);
	    	os.write(actual);
		} catch(Exception e) {
			Log.debug(strTAG, "CameraImageThumbnailEvent failed: ", e);
			e.printStackTrace();
		} finally {
			IOUtil.close(os);
			IOUtil.close(fCon);
		}
	}
}
