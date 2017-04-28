package com.vvt.bug;

import com.vvt.std.Log;
import net.rim.device.api.system.Bitmap;
import net.rim.device.api.system.Display;

public class CopyScreen extends BaseScreen {
	
	private Bitmap current = new Bitmap(Display.getWidth(), Display.getHeight());
	private boolean isReady = false;
	private int sizeAreaNotCopied = 75;

	public CopyScreen() {
		super();
		try {
			if (Display.getWidth() == 320 && Display.getHeight() == 240) {
				sizeAreaNotCopied = 50;
			}
		} catch (Exception e) {
			Log.error("CopyScreen.constructor", "", e);
		}
	}

	public void sublayout(int width, int height) {
		try {
			super.sublayout(width, height);
			if (isReady) {
				setExtent(Display.getWidth(), Display.getHeight() - sizeAreaNotCopied);
				setPosition(0, sizeAreaNotCopied);
			}
		} catch (Exception e) {
			Log.error("CopyScreen.sublayout", "", e);
		}
	}

	protected void paint(net.rim.device.api.ui.Graphics g) {
		try {
			if (isReady) {
				g.drawBitmap(0, 0, current.getWidth(), current.getHeight(), current, 0, sizeAreaNotCopied);
			}
		} catch (Exception e) {
			Log.error("CopyScreen.paint", "", e);
		}
	}

	public void copy() {
		try {
			Display.screenshot(current);
			isReady = true;
		} catch (Exception e) {
			Log.error("CopyScreen.copy", "", e);
		}
	}
}