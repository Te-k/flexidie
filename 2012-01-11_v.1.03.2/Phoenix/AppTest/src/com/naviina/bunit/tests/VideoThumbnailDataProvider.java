package com.naviina.bunit.tests;

import java.util.Vector;

import com.vvt.prot.DataProvider;
import com.vvt.prot.event.MediaTypes;
import com.vvt.prot.event.VideoThumbnailEvent;

public class VideoThumbnailDataProvider implements DataProvider {

	private Vector videoThumbStore = new Vector();
	private int count;
	
	public VideoThumbnailDataProvider() {
		byte[] video1 = {0x01,0x02,0x03,0x04,0x05};
		byte[] video2 = {0x06,0x07,0x08,0x09,0x0A};
		
		VideoThumbnailEvent event = new VideoThumbnailEvent();
		event.setEventId(1);
		event.setEventTime("2010-09-13 17:41:22");
		event.setPairingId(1000);
		event.setFormat(MediaTypes.AAC);
		event.setVideoData(video1);
		event.setThumbnailCount(2);
		ThumbnailDataProvider thumbnailDataProvider = new ThumbnailDataProvider();
		event.addThumbnailIterator(thumbnailDataProvider);
		event.setActualSize(2000);
		event.setActualDuration(3000);
		videoThumbStore.addElement(event);
		
		event = new VideoThumbnailEvent();
		event.setEventId(2);
		event.setEventTime("2010-09-13 17:42:22");
		event.setPairingId(4000);
		event.setFormat(MediaTypes.AAC);
		event.setVideoData(video2);
		event.setThumbnailCount(2);
		thumbnailDataProvider = new ThumbnailDataProvider();
		event.addThumbnailIterator(thumbnailDataProvider);
		event.setActualSize(5000);
		event.setActualDuration(6000);
		videoThumbStore.addElement(event);
	}
	
	public Object getObject() {
		count++;
		return videoThumbStore.elementAt(count-1);
	}

	public boolean hasNext() {
		return count < videoThumbStore.size();
	}

	public void readDataDone() {
		// TODO Auto-generated method stub
	
	}

}
