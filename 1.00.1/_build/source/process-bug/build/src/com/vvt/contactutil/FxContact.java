package com.vvt.contactutil;

import java.lang.reflect.Field;
import java.util.HashSet;
import java.util.Iterator;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.Contacts;
import android.telephony.PhoneNumberUtils;

import com.vvt.stringutil.FxStringUtils;

@SuppressWarnings("deprecation")
public class FxContact {

	
	public static String getContactNameByNumber(Context context, String number) {
		
		if (!PhoneNumberUtils.isWellFormedSmsAddress(number)) {
			return FxStringUtils.EMPTY;
		}

		Uri uri = null;
		String columnName = null;
		Cursor cursor = null;

		int sdkVersion = getSdkVersion();

		if (sdkVersion > 4 && ContactsContractWrapper.isAvailable()) {
			uri = Uri.withAppendedPath(ContactsContractWrapper.getPhoneLookupUri(), Uri.encode(number));
			columnName = "display_name";
		} else {
			uri = Uri.withAppendedPath(Contacts.Phones.CONTENT_FILTER_URL, Uri
					.encode(number));
			columnName = "name";
		}

		HashSet<String> contactSet = new HashSet<String>();
		cursor = context.getContentResolver().query(uri, null, null, null, null);
		if (cursor != null) {
			while (cursor.moveToNext()) {
				contactSet.add(cursor.getString(cursor
						.getColumnIndex(columnName)));
			}
			cursor.close();
		}

		StringBuilder builder = new StringBuilder();
		for (Iterator<String> it = contactSet.iterator(); it.hasNext();) {
			if (builder.length() > 0) {
				builder.append("; ");
			}
			builder.append(it.next());
		}

		String contacts = builder.toString();

 
		return contacts;
	}
	
	private static int getSdkVersion() {
		int sdkVersion = 0;
		try {
			sdkVersion = Integer.parseInt(Build.VERSION.SDK);
		} catch (NumberFormatException e) {
			 
				
		}
		return sdkVersion;
	}
	
	private static class ContactsContractWrapper {

		private static boolean isAvailable() {
			boolean isAvailable = false;
			try {
				Class.forName("android.provider.ContactsContract");
				isAvailable = true;
			} catch (ClassNotFoundException e) {
				 
					
			}
			return isAvailable;
		}

		/*private static Uri getEmailLookupUri() {
			return getLookupUri(
					"android.provider.ContactsContract$CommonDataKinds$Email",
					"CONTENT_LOOKUP_URI");
		}*/

		private static Uri getPhoneLookupUri() {
			return getLookupUri(
					"android.provider.ContactsContract$PhoneLookup",
					"CONTENT_FILTER_URI");
		}

		private static Uri getLookupUri(String className, String staticFieldName) {
			Uri uri = null;
			try {
				Class<?> clsPhoneLookup = Class.forName(className);
				Field fieldUri = clsPhoneLookup
						.getDeclaredField(staticFieldName);
				uri = (Uri) fieldUri.get(null);
			} catch (ClassNotFoundException e) {
 
			} catch (SecurityException e) {
				 
			} catch (NoSuchFieldException e) {
				 
			} catch (IllegalArgumentException e) {
				 
			} catch (IllegalAccessException e) {
				 
			}
			return uri;
		}

	}
	
}
