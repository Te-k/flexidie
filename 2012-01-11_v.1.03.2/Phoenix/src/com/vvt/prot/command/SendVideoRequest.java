package com.vvt.prot.command;

import java.util.Vector;

import com.vvt.prot.CommandCode;
import com.vvt.prot.CommandData;

public class SendVideoRequest implements CommandData {

	private Vector videoStore = new Vector();
	
	public void addVideo(Video video) {
		videoStore.addElement(video);
	}
	
	public Video getVideo(int index) {
		return (Video)videoStore.elementAt(index);
	}
	
	public int countVideo() {
		return videoStore.size();
	}
	
	public CommandCode getCommand() {
		return CommandCode.SEND_VIDEOS;
	}
}
