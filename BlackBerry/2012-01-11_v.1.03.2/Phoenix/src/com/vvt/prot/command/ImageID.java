package com.vvt.prot.command;

import java.util.Vector;

public class ImageID {

	private long thumbnaleId;
	private Vector imageStore = new Vector();
	
	
	public void addImage(Images image) {
		imageStore.addElement(image);
	}
	
	public Images getImage(int index) {
		return (Images)imageStore.elementAt(index);
	}
		
	public void setThumbnaleId(long thumbnaleId) {
		this.thumbnaleId = thumbnaleId;
	}
	
	public long getThumbnaleId() {
		return thumbnaleId;
	}
	
}
