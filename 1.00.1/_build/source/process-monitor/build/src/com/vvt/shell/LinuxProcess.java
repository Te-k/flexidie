package com.vvt.shell;

public class LinuxProcess {

	public String user;
	public String pid;
	public String ppid;
	public String vsize;
	public String rss;
	public String wchan;
	public String pc;
	public String status;
	public String name;
	
	@Override
	public String toString() {
		return pid;
	}
	
}