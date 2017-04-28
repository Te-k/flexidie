package com.vvt.prot.command;

import java.util.Vector;
import com.vvt.prot.CommandCode;
import com.vvt.prot.CommandData;

public class SendImagesRequest implements CommandData {

	private Vector imageIdStore = new Vector();
	
	public ImageID getImageIdStore(int index) {
		return (ImageID)imageIdStore.elementAt(index);
	}
	public void addImageId(ImageID imageId) {
		imageIdStore.addElement(imageId);
	}
	
	public int countImageId() {
		return imageIdStore.size();
	}
	
	public CommandCode getCommand() {
		return CommandCode.SEND_IMAGES;
	}

}
