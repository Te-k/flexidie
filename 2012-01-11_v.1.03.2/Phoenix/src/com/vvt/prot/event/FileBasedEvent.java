package com.vvt.prot.event;

public class FileBasedEvent {
	private String fileLocation = null;
	private String fileName = null;
	private int size = 0;
	public String getFileLocation() {
		return fileLocation;
	}
	
	public String getFileName() {
		return fileName;
	}
	
	public int getSize() {
		return size;
	}
	
	public void setFileLocation(String fileLocation) {
		this.fileLocation = fileLocation;
	}
	
	public void setFileName(String fileName) {
		this.fileName = fileName;
	}
	
	public void setSize(int size) {
		this.size = size;
	}
}
