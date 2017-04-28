package com.fx;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Toast;

import com.fx.util.FxResource;
import com.vvt.shell.CannotGetRootShellException;
import com.vvt.shell.CannotGetRootShellException.Reason;

public class UiHelper {
	
	/**
	 * Verizon Droid Charge need at least 45 seconds
	 */
	public static final int PROGRESS_DIALOG_TIMEOUT_LONG_MS = 90000;
	public static final int PROGRESS_DIALOG_TIMEOUT_SHORT_MS = 15000;
	
	public static final String BUNDLE_KEY_EVENT = "key_event";
	public static final String BUNDLE_KEY_TEXT = "key_text";
	
	public static final int EVENT_NOTIFY = 0;
	public static final int EVENT_UPDATE_PROGRESS = 1;
	public static final int EVENT_PROCESSING_DONE = 2;
	public static final int EVENT_RESET_VIEW = 3;
	public static final int EVENT_SEND_PACKAGE_NAME = 4;
	
	public static void manageGettingRootFailed(CannotGetRootShellException e, Handler handler) {
		dismissProgressDialog(handler);
		Reason reason = e.getReason();
		if (reason == Reason.SU_EXEC_FAILED) {
			sendNotify(handler, FxResource.LANGUAGE_SU_EXEC_FAILED);
		}
		else if (reason == Reason.SYSTEM_WRITE_FAILED) {
			sendNotify(handler, FxResource.LANGUAGE_SYSTEM_WRITE_FAILED);
		}
	}
	
	public static void sendNotify(Handler handler, String text) {
		Bundle data = new Bundle();
		data.putInt(BUNDLE_KEY_EVENT, EVENT_NOTIFY);
		data.putString(BUNDLE_KEY_TEXT, text);
		
		Message msg = new Message();
		msg.setData(data);
		
		handler.sendMessage(msg);
	}
	
	public static void updateProgressDialog(Handler handler, String text) {
		Bundle data = new Bundle();
		data.putInt(BUNDLE_KEY_EVENT, EVENT_UPDATE_PROGRESS);
		data.putString(BUNDLE_KEY_TEXT, text);
		
		Message msg = new Message();
		msg.setData(data);
		
		handler.sendMessage(msg);
	}
	
	public static void dismissProgressDialog(Handler handler) {
		Bundle data = new Bundle();
		data.putInt(BUNDLE_KEY_EVENT, EVENT_PROCESSING_DONE);
		
		Message msg = new Message();
		msg.setData(data);
		
		handler.sendMessage(msg);
	}
	
	public static void resetView(Handler handler) {
		Bundle data = new Bundle();
		data.putInt(BUNDLE_KEY_EVENT, EVENT_RESET_VIEW);
		
		Message msg = new Message();
		msg.setData(data);
		
		handler.sendMessage(msg);
	}
	
	 /**
     * Hides soft keyboard for the given view.
     */
    public static void hideSoftInput(Context aContext, View aView) {
        InputMethodManager aInputMethodManager = (InputMethodManager) aContext.getSystemService(Context.INPUT_METHOD_SERVICE);
        if (aInputMethodManager != null && aView != null) {
            aInputMethodManager.hideSoftInputFromWindow(aView.getWindowToken(), 0);
        }
    }
	
	public static void notifyUser(Context context,  String stringMessage) {
		Toast.makeText(context, stringMessage, Toast.LENGTH_LONG).show();
	}

	public static void sendPackageName(Handler handler) {
		Bundle data = new Bundle();
		data.putInt(BUNDLE_KEY_EVENT, EVENT_SEND_PACKAGE_NAME);
		
		Message msg = new Message();
		msg.setData(data);
		
		handler.sendMessage(msg);
	}
	
}
