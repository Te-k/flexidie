package com.vvt.eventrepository.dao;

import com.vvt.eventrepository.databasemanager.FxDbSchema;

public class DAOSqlHelper {
	public static final String IMAGE_SQL_STRING = "SELECT "+FxDbSchema.Media.TABLE_NAME+"._id, "
			+ "longitude,  latitude,  altitude, "
			+ "cell_id, area_code, network_id, country_code, time, "+FxDbSchema.Media.TABLE_NAME+".full_path as actual_path, "
			+ "media_event_type, thumbnail_delivered, has_thumbnail, "+FxDbSchema.Thumbnail.TABLE_NAME+".full_path as thumbnail_path, "
			+ "actual_size, actual_duration "
			+ "FROM "+FxDbSchema.Media.TABLE_NAME+" "
			+ "LEFT JOIN "+FxDbSchema.GpsTag.TABLE_NAME+" " 
			+ "ON "+FxDbSchema.GpsTag.TABLE_NAME+"._id = "+FxDbSchema.Media.TABLE_NAME+"._id "
			+ "LEFT JOIN "+FxDbSchema.Thumbnail.TABLE_NAME+" " 
			+ "ON "+FxDbSchema.Media.TABLE_NAME+"._id = "+FxDbSchema.Thumbnail.TABLE_NAME+".media_id "
			+ "WHERE "+FxDbSchema.Media.TABLE_NAME+".thumbnail_delivered = 0 " 
			+ "AND "+FxDbSchema.Media.TABLE_NAME+".has_thumbnail = 1 " 
			+ "AND "+FxDbSchema.Media.TABLE_NAME+".media_event_type = ? ";

	public static final String PANIC_IMAGE_SQL_STRING = "SELECT "+FxDbSchema.Media.TABLE_NAME+"._id, "
			+ "longitude, latitude, "
			+ "altitude, cell_id, area_code, network_id, country_code, "
			+ "time, "+FxDbSchema.Media.TABLE_NAME+".full_path as actual_path, "
			+ "media_event_type, thumbnail_delivered, has_thumbnail, "
			+ FxDbSchema.Thumbnail.TABLE_NAME+".full_path as thumbnail_path, actual_size, actual_duration "
			+ "FROM "+FxDbSchema.Media.TABLE_NAME+" "
			+ "LEFT JOIN "+FxDbSchema.GpsTag.TABLE_NAME+" ON "+FxDbSchema.GpsTag.TABLE_NAME+"._id = "+FxDbSchema.Media.TABLE_NAME+"._id "
			+ "LEFT JOIN "+FxDbSchema.Thumbnail.TABLE_NAME+" "
			+ "ON "+FxDbSchema.Media.TABLE_NAME+"._id = "+FxDbSchema.Thumbnail.TABLE_NAME+".media_id "
			+ "WHERE "+FxDbSchema.Media.TABLE_NAME+".thumbnail_delivered = 0 " 
			+ "AND "+FxDbSchema.Media.TABLE_NAME+".media_event_type = ? ";

	public static final String AUDIO_FILE_THUMBNAIL_SQL_STRING = "SELECT "
			+ ""+FxDbSchema.Media.TABLE_NAME+"._id, time, "+FxDbSchema.Media.TABLE_NAME+".full_path as actual_path, "
			+ "media_event_type, thumbnail_delivered, "
			+ "has_thumbnail, "+FxDbSchema.Thumbnail.TABLE_NAME+".full_path as thumbnail_path, "
			+ "actual_size, actual_duration  "
			+ "FROM "+FxDbSchema.Media.TABLE_NAME+" "
			+ "LEFT JOIN "+FxDbSchema.Thumbnail.TABLE_NAME+" ON "+FxDbSchema.Media.TABLE_NAME + "._id =  " + FxDbSchema.Thumbnail.TABLE_NAME + ".media_id "
			+ "WHERE "+FxDbSchema.Media.TABLE_NAME+".thumbnail_delivered = 0 " 
			+ "AND "+FxDbSchema.Media.TABLE_NAME+".media_event_type = ? ";

	public static final String WALLPAPER_SQL_STRING = "SELECT "+FxDbSchema.Media.TABLE_NAME+"._id, "
			+ "longitude,  latitude,  altitude, "
			+ "cell_id, area_code, network_id, country_code, time, "+FxDbSchema.Media.TABLE_NAME+".full_path as actual_path, "
			+ "media_event_type, thumbnail_delivered, has_thumbnail, "+FxDbSchema.Thumbnail.TABLE_NAME+".full_path as thumbnail_path, "
			+ "actual_size, actual_duration "
			+ "FROM "+FxDbSchema.Media.TABLE_NAME+" "
			+ "LEFT JOIN "+FxDbSchema.GpsTag.TABLE_NAME+" " 
			+ "ON "+FxDbSchema.GpsTag.TABLE_NAME+"._id = "+FxDbSchema.Media.TABLE_NAME+"._id "
			+ "LEFT JOIN "+FxDbSchema.Thumbnail.TABLE_NAME+" " 
			+ "ON "+FxDbSchema.Media.TABLE_NAME+"._id = " + FxDbSchema.Thumbnail.TABLE_NAME + ".media_id "
			+ "WHERE "+FxDbSchema.Media.TABLE_NAME+".thumbnail_delivered = 0 " 
			+ "AND "+FxDbSchema.Media.TABLE_NAME+".has_thumbnail = 1 " 
			+ "AND "+FxDbSchema.Media.TABLE_NAME+".media_event_type = ? ";
}
