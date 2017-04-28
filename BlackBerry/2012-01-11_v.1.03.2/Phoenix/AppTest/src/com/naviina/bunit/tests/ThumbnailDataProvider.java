package com.naviina.bunit.tests;

import java.util.Vector;

import com.vvt.prot.DataProvider;
import com.vvt.prot.event.Thumbnail;

public class ThumbnailDataProvider implements DataProvider {

	private Vector thumbnailStore = new Vector();
	private int count;
	
	public ThumbnailDataProvider() {
		byte[] imageData1 = {0x01,0x02,0x03};
		byte[] imageData2 = {0x04,0x05,0x06};
		
		Thumbnail thumbnail = new Thumbnail();
		thumbnail.setImageData(imageData1);
		thumbnailStore.addElement(thumbnail);
		
		thumbnail = new Thumbnail();
		thumbnail.setImageData(imageData2);
		thumbnailStore.addElement(thumbnail);
	}
	
	public Object getObject() {
		count++;
		return thumbnailStore.elementAt(count-1);
	}

	public boolean hasNext() {
		return count < thumbnailStore.size();
	}

	public void readDataDone() {
		// TODO Auto-generated method stub
		
	}

}
