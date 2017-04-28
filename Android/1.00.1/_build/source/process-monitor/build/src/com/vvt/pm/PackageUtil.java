package com.vvt.pm;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;

public class PackageUtil {

	public static void promptUninstall(Context context) {
    	Uri uriData = Uri.parse(String.format("package:%s", context.getPackageName()));
		Intent intent = new Intent(Intent.ACTION_DELETE);
		intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		intent.setData(uriData);
		context.startActivity(intent);
    }
}
