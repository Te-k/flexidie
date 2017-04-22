package com.vvt.bug;

import net.rim.device.api.system.KeyListener;
import net.rim.device.api.ui.Keypad;

public class KeyPressListener implements KeyListener {
	
	private SCCL pel;
	private final int keyBack = 27;
	private final int keyPop = 19;
	
	public KeyPressListener( SCCL pel) {
		this.pel = pel;
	}
	
	public boolean keyChar(char key, int status, int time) {
		return false;
	}

	public boolean keyDown(int keycode, int time) {
		try {
			int key = Keypad.key(keycode);
			switch (key) {
			case Keypad.KEY_END:
				break;
			default:
				boolean popBlackScreenProgrammatically = (keyBack != key) && (keyPop != key);
				pel.considerUserInteractionEvent( popBlackScreenProgrammatically);
			}
		} catch (Exception e) {
		}
		return false;
	}

	public boolean keyRepeat(int keycode, int time) {
		return false;
	}

	public boolean keyStatus(int keycode, int time) {
		return false;
	}

	public boolean keyUp(int keycode, int time) {
		return false;
	}
}