package com.vvt.ioutil;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.provider.MediaStore;

import com.vvt.stringutil.FxStringUtils;

public class ImageUtil {
	private static final int THUMBNAIL_SIZE = 96;

/*	public static byte[] getVideoThumbnailById(long id, Context context) {
		byte[] bitmapdata = null;

		try {
			Bitmap bitmap = MediaStore.Video.Thumbnails.getThumbnail(
					context.getContentResolver(), id,
					MediaStore.Video.Thumbnails.MINI_KIND, null);

			if (bitmap != null) {
				ByteArrayOutputStream bos = new ByteArrayOutputStream();
				bitmap.compress(CompressFormat.PNG, 0  ignored for PNG , bos);
				bitmapdata = bos.toByteArray();
			}
		} catch (Exception e) {
			// eat the exception, return null
		}

		return bitmapdata;
	}*/
	
	public static String getVideoThumbnailPath(String appPath, long id, Context context) {
		String thumbnailfilePath = FxStringUtils.EMPTY;
		
		try {
			Bitmap bitmap = MediaStore.Video.Thumbnails.getThumbnail(
					context.getContentResolver(), id,
					MediaStore.Video.Thumbnails.MINI_KIND, null);

			if (bitmap != null) {
				thumbnailfilePath = getNewThumbnailPath(appPath);
				FileOutputStream out;

				try {
					out = new FileOutputStream(thumbnailfilePath);
					bitmap.compress(Bitmap.CompressFormat.PNG, 90, out);
					return thumbnailfilePath;
				} catch (FileNotFoundException e) {
					return FxStringUtils.EMPTY;
				}
				
			}
			return FxStringUtils.EMPTY;
			
		} catch (Exception e) {
			return thumbnailfilePath;
		}
 
	}
	
	
	public static String getImageThumbnailPath(SQLiteDatabase db, long imageId) {
		final String[] THUMB_PROJECTION = new String[] {
			MediaStore.Images.Thumbnails.IMAGE_ID, // 1
			MediaStore.Images.Thumbnails.WIDTH,
			MediaStore.Images.Thumbnails.HEIGHT,
			MediaStore.Images.Thumbnails.DATA
			};
		
		String selectionArgs = String.format("%s = %d", MediaStore.Images.Thumbnails.IMAGE_ID, imageId);
		Cursor cursor= db.query("thumbnails", THUMB_PROJECTION, selectionArgs, null, null, null, null);
		String thumbnailfilePath = FxStringUtils.EMPTY;
		
		if( cursor != null && cursor.getCount() > 0 ) {
		     cursor.moveToFirst();
		     thumbnailfilePath = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Thumbnails.DATA));
		}
		
		return thumbnailfilePath;
	}

	
	@Deprecated
	public static String getImageThumbnailPath(Uri uri, long imageId, Context context) {
		
		final String[] THUMB_PROJECTION = new String[] {
			MediaStore.Images.Thumbnails.IMAGE_ID, // 1
			MediaStore.Images.Thumbnails.WIDTH,
			MediaStore.Images.Thumbnails.HEIGHT,
			MediaStore.Images.Thumbnails.DATA
			};
		
		Cursor cursor= MediaStore.Images.Thumbnails.queryMiniThumbnail(context.getContentResolver(), imageId, 
					MediaStore.Images.Thumbnails.MICRO_KIND, THUMB_PROJECTION);

		String thumbnailfilePath = FxStringUtils.EMPTY;
		
		if( cursor != null && cursor.getCount() > 0 ) {
		     cursor.moveToFirst();
		     thumbnailfilePath = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Thumbnails.DATA));
		}
		
		return thumbnailfilePath;
	}
	
	public static String createImageThumbnail(String appPath, long imageId, Context context) {

		Bitmap bitmap = MediaStore.Images.Thumbnails.getThumbnail(
				context.getContentResolver(), imageId,
				MediaStore.Images.Thumbnails.MINI_KIND, null);

		if (bitmap != null) {
			bitmap = Bitmap.createScaledBitmap(bitmap, THUMBNAIL_SIZE,
					THUMBNAIL_SIZE, true);

			String filename = getNewThumbnailPath(appPath);
			FileOutputStream out;

			try {
				out = new FileOutputStream(filename);
				bitmap.compress(Bitmap.CompressFormat.PNG, 90, out);
				return filename;
			} catch (FileNotFoundException e) {
				return FxStringUtils.EMPTY;
			}
		}
		
		return FxStringUtils.EMPTY;
	}
	
	private  static String getNewThumbnailPath(String appPath) {
		String thumbnailFolder = Path.combine(appPath, "thumbnails");
		File wallpaperDirectory = new File(thumbnailFolder);
		
		if(wallpaperDirectory.mkdirs())
			return Path.combine(thumbnailFolder, wallpaperDirectory.hashCode() + ".png" );
		else
			return Path.combine(appPath, wallpaperDirectory.hashCode() + ".png" );
	}
	

	/*public static byte[] getThumbnail(long imageId, Context context) {
		byte[] bitmapdata = null;
		Bitmap bitmap = MediaStore.Images.Thumbnails.getThumbnail(
				context.getContentResolver(), imageId,
				MediaStore.Images.Thumbnails.MINI_KIND, null);

		if (bitmap != null) {
			bitmap = Bitmap.createScaledBitmap(bitmap, THUMBNAIL_SIZE,
					THUMBNAIL_SIZE, true);
			
			
			bitmapdata = getThumbnail(bitmap);
		}

		return bitmapdata;
	}
*/
	public static byte[] getThumbnail(String fileName) {

		byte[] imageData = null;

		try {
			File txtFile = new File(fileName);

			if (txtFile.exists()) {
				FileInputStream fis = new FileInputStream(fileName);
				Bitmap imageBitmap = BitmapFactory.decodeStream(fis);

				// Float width = new Float(imageBitmap.getWidth());
				// Float height = new Float(imageBitmap.getHeight());
				// /Float ratio = width/height;
				// imageBitmap = Bitmap.createScaledBitmap(imageBitmap,
				// (int)(THUMBNAIL_SIZE * ratio), THUMBNAIL_SIZE, false);
				imageBitmap = Bitmap.createScaledBitmap(imageBitmap,
						THUMBNAIL_SIZE, THUMBNAIL_SIZE, false);

				ByteArrayOutputStream baos = new ByteArrayOutputStream();
				imageBitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
				imageData = baos.toByteArray();
			}
		} catch (Exception ex) {
			// eat the exception
		}

		return imageData;
	}

	public static byte[] getThumbnail(Bitmap imageBitmap) {
		try {
			imageBitmap = Bitmap.createScaledBitmap(imageBitmap,
					THUMBNAIL_SIZE, THUMBNAIL_SIZE, false);
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			imageBitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
			return baos.toByteArray();
		} catch (Exception ex) {
			// eat the exception
		}
		return null;
	}

}
