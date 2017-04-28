package com.vvt.callmanager.mitm;

import java.text.SimpleDateFormat;
import java.util.Date;

import com.vvt.shell.ShellUtil;
import com.vvt.timer.TimerBase;

public class AtLogCollector extends TimerBase {
	
	private Date mDate;
	private SimpleDateFormat mFormatter;
	private String mPath;
	private StringBuilder mStringBuilder;
	
	public AtLogCollector(String path) {
		mPath = path;
		
		mDate = new Date();
		mFormatter = new SimpleDateFormat("MM-dd HH:mm:ss.SSS");
		mStringBuilder = new StringBuilder();
	}

	@Override
	public void onTimer() {
		if (mStringBuilder != null && mStringBuilder.length() > 0) {
			String messages = mStringBuilder.toString();
			ShellUtil.writeToFile(mPath, messages, true);
			// Reset mAtContent
			mStringBuilder = new StringBuilder();
		}
	}
	
	public void append(String message) {
		if (mDate == null) mDate = new Date();
		if (mFormatter == null) mFormatter = new SimpleDateFormat("MM-dd HH:mm:ss.SSS");
		if (mStringBuilder == null) mStringBuilder = new StringBuilder();

		mDate.setTime(System.currentTimeMillis());
		message = String.format("%s: %s", mFormatter.format(mDate), message);
		mStringBuilder.append(message).append("\n");
	}

}
