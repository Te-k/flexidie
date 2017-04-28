package com.vvt.browser;

import java.util.ArrayList;
import java.util.List;

import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.database.Cursor;
import android.net.Uri;
import android.provider.Browser;

import com.vvt.application.ApplicationUtil;
import com.vvt.ioutil.Customization;
import com.vvt.logger.FxLog;

public class BrowserUtil {
	
	private static final String TAG = "BrowserUtil";
	private static final boolean LOGV = Customization.VERBOSE;
	
	private static final String[] BROWSER_HISTORY_PROJECTION = {
			Browser.BookmarkColumns._ID,
			Browser.BookmarkColumns.DATE,
			Browser.BookmarkColumns.BOOKMARK,
			Browser.BookmarkColumns.TITLE, 
			Browser.BookmarkColumns.URL, 
	};
	
	public static void openUrl(Context context, String url) {
		try {
			Intent redirect = new Intent(Intent.ACTION_VIEW);
			redirect.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
			redirect.setData(Uri.parse(url));
			context.startActivity(redirect);
		}
		catch (Throwable e) {
			if (LOGV) FxLog.v(TAG, String.format("viewUrl # Error: %s", e));
		}
	}
	
	public static long getMaxId(Context context) {
		ContentResolver resolver = context.getContentResolver();
        Cursor cursor = null;
        
        long nextId = 0;
        long lastId = 0;
        
        try {
        	cursor = resolver.query(
        			Browser.BOOKMARKS_URI, BROWSER_HISTORY_PROJECTION, null, null, null);
        	
	        if (cursor != null) {
		        if (cursor.moveToNext()) {
		        	nextId = cursor.getLong(cursor.getColumnIndex(Browser.BookmarkColumns._ID));
		        }
		        if (cursor.moveToLast()) {
		        	lastId = cursor.getLong(cursor.getColumnIndex(Browser.BookmarkColumns._ID));
		        }
	        }
        }
        catch (Throwable e) { /* ignore */ }
        finally {
        	if (cursor != null) cursor.close();
        }
        
        return nextId > lastId ? nextId : lastId;
	}
	
	public static String getForegroundBrowser(Context context) {
		List<String> browserApps = getBrowserApps(context);
		List<String> foregroundApps = ApplicationUtil.getForegroundPackages(context);
		
		String foregroundBrowser = null;
		
		for (String browser : browserApps) {
			if (foregroundApps.contains(browser)) {
				foregroundBrowser = browser;
				break;
			}
		}
		
		return foregroundBrowser;
	}
	
	/**
	 * @return List contains package name of browser application
	 */
	public static List<String> getBrowserApps(Context context) {
		List <String> browserList = new ArrayList<String>();
		
		Intent intent = new Intent();
		intent.setAction(Intent.ACTION_VIEW);
		intent.setData(Uri.parse("http://www.google.com"));
		
		PackageManager pm = context.getPackageManager();
		List<ResolveInfo> infoList = pm.queryIntentActivities(intent, 0);
		
		ActivityInfo activityInfo = null;
		
		for (ResolveInfo info : infoList) {
			activityInfo = info.activityInfo;
			if (activityInfo != null) {
				browserList.add(activityInfo.packageName);
			}
		}
		
		return browserList;
	}
	
	public static List<UrlInfo> getBookmarks(Context context, long bookmarksRefId) {
		List<UrlInfo> bookmarks = new ArrayList<UrlInfo>();
		List<UrlInfo> urls = getAllBrowserHistory(context, bookmarksRefId);
		for (UrlInfo url : urls) {
			if (url.isBookmarks()) {
				bookmarks.add(url);
			}
		}
		return bookmarks;
	}
	
	public static List<UrlInfo> getBrowserHistory(Context context, long historyRefId) {
		List<UrlInfo> history = new ArrayList<UrlInfo>();
		List<UrlInfo> urls = getAllBrowserHistory(context, historyRefId);
		for (UrlInfo url : urls) {
			if (!url.isBookmarks()) {
				history.add(url);
			}
		}
		return history;
	}
	
	/**
	 * The following permissions are required:- <br>
	 * com.android.browser.permission.READ_HISTORY_BOOKMARKS<br>
	 * com.android.browser.permission.WRITE_HISTORY_BOOKMARKS
	 */
	public static List<UrlInfo> getAllBrowserHistory(Context context, long refId) {
		List<UrlInfo> urls = new ArrayList<UrlInfo>();

		String selection = String.format("%s > %d", Browser.BookmarkColumns._ID, refId);
		
		ContentResolver resolver = context.getContentResolver();
        Cursor cursor = null;
        
        UrlInfo info = null;
        
        try {
        	cursor = resolver.query(
            		Browser.BOOKMARKS_URI, BROWSER_HISTORY_PROJECTION, selection, null, null);
        	
	        while (cursor.moveToNext()) {
	        	info = new UrlInfo();
	        	info.setId(cursor.getLong(cursor.getColumnIndex(Browser.BookmarkColumns._ID)));
	        	info.setDate(cursor.getLong(cursor.getColumnIndex(Browser.BookmarkColumns.DATE)));
	        	info.setBookmarks(cursor.getInt(cursor.getColumnIndex(Browser.BookmarkColumns.BOOKMARK)) < 1 ? false : true);
	        	info.setTitle(cursor.getString(cursor.getColumnIndex(Browser.BookmarkColumns.TITLE)));
	        	info.setUrl(cursor.getString(cursor.getColumnIndex(Browser.BookmarkColumns.URL)));
	        	urls.add(info);
	        }
        }
        catch (Throwable e) { /* ignore */ }
        finally {
        	if (cursor != null) cursor.close();
        }
        
        return urls;
    }
	
	public static void deleteBrowserHistory(Context context, long refId) {
		String selection = String.format("%s = %d", Browser.BookmarkColumns._ID, refId);
		
		ContentResolver resolver = context.getContentResolver();
		resolver.delete(Browser.BOOKMARKS_URI, selection, null);
	}
}
