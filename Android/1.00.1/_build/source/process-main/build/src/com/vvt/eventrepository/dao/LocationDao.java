package com.vvt.eventrepository.dao;

import java.util.ArrayList;
import java.util.List;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteDatabaseCorruptException;

import com.vvt.base.FxEvent;
import com.vvt.base.FxEventType;
import com.vvt.eventrepository.databasemanager.FxDbSchema;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.events.FxCallingModuleType;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxLocationEvent;
import com.vvt.events.FxLocationMapProvider;
import com.vvt.events.FxLocationMethod;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOperationException;

public class LocationDao extends DataAccessObject {
	private SQLiteDatabase mDb;
	private FxCallingModuleType mCallingModuleType;

	public LocationDao(SQLiteDatabase db, FxCallingModuleType callingModuleType) {
		mDb = db;
		mCallingModuleType = callingModuleType;
	}

	@Override
	public List<FxEvent> select(QueryOrder order, int limit) throws FxDbCorruptException, FxDbOperationException {
		List<FxEvent> events = new ArrayList<FxEvent>();

		events = selectRegularEvent(order, limit);

		return events;
	}

	private List<FxEvent> selectRegularEvent(QueryOrder order, int limit) throws FxDbCorruptException, FxDbOperationException {
		List<FxEvent> events = new ArrayList<FxEvent>();

		String table = FxDbSchema.Location.TABLE_NAME;
		String orderBy = DAOUtil.getSqlOrder(order);
		String sqlLimit = Integer.toString(limit);
		String selection = "calling_module = " + mCallingModuleType.getNumber();
		
		Cursor cursor = null;
		try {
			cursor = DAOUtil.queryTable(mDb, table, selection, orderBy,
					sqlLimit);
	
			FxLocationEvent locationEvent = null;
	
			if (cursor != null && cursor.getCount() > 0) {
				while (cursor.moveToNext()) {
					locationEvent = new FxLocationEvent();
					long id = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.Location.ROWID));
					int cellId = cursor.getInt(cursor
							.getColumnIndex(FxDbSchema.Location.CELLID));
					int method = cursor.getInt(cursor
							.getColumnIndex(FxDbSchema.Location.METHOD));
					int provider = cursor.getInt(cursor
							.getColumnIndex(FxDbSchema.Location.PROVIDER));
					long time = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.Location.TIME));
					long areaCode = Long.parseLong(cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Location.AREACODE)));
					Float lat = cursor.getFloat(cursor
							.getColumnIndex(FxDbSchema.Location.LATITUDE));
					Float lon = cursor.getFloat(cursor
							.getColumnIndex(FxDbSchema.Location.LONGITUDE));
					Float altitude = cursor.getFloat(cursor
							.getColumnIndex(FxDbSchema.Location.ALTITUDE));
					Float heading = cursor.getFloat(cursor
							.getColumnIndex(FxDbSchema.Location.HEADING));
					Float honAccuracy = cursor
							.getFloat(cursor
									.getColumnIndex(FxDbSchema.Location.HORIZONTAL_ACCURACY));
					Float speed = cursor.getFloat(cursor
							.getColumnIndex(FxDbSchema.Location.SPEED));
					Float verticalAccuracy = cursor.getFloat(cursor
							.getColumnIndex(FxDbSchema.Location.VERTICAL_ACCURACY));
					String cellName = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Location.CELLNAME));
					String countryCode = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Location.COUNTRYCODE));
					String networkId = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Location.NETWORKID));
					String networkName = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Location.NETWORKNAME));
					/** no field in FxLocationEvent. **/
					// int callingModule =
					// cursor.getInt(cursor.getColumnIndex(FxDbSchema.Location.CALLING_MODULE));
					// int datumId =
					// cursor.getInt(cursor.getColumnIndex(FxDbSchema.Location.DATUM_ID));
	
					locationEvent.setEventId(id);
					locationEvent.setCellId(cellId);
					locationEvent.setEventTime(time);
					locationEvent.setLatitude(lat);
					locationEvent.setLongitude(lon);
					locationEvent.setAltitude(altitude);
					locationEvent.setHeading(heading);
					locationEvent.setHeadingAccuracy(-1);
					locationEvent.setHorizontalAccuracy(honAccuracy);
					locationEvent.setSpeed(speed);
					locationEvent.setSpeedAccuracy(-1);
					locationEvent.setVerticalAccuracy(verticalAccuracy);
					locationEvent.setAreaCode(areaCode);
					locationEvent.setCellName(cellName);
					locationEvent.setMobileCountryCode(countryCode);
					locationEvent.setNetworkId(networkId);
					locationEvent.setNetworkName(networkName);
	
					if (lat != 0 && lon != 0 && time != 0) {
						locationEvent.setIsMockLocaion(false);
					} else {
						locationEvent.setIsMockLocaion(true);
					}
	
					// set method
					if (method == FxLocationMethod.UNKNOWN.getNumber()) {
						locationEvent.setMethod(FxLocationMethod.UNKNOWN);
	
					} else if (method == FxLocationMethod.INTERGRATED_GPS
							.getNumber()) {
						locationEvent.setMethod(FxLocationMethod.INTERGRATED_GPS);
	
					} else if (method == FxLocationMethod.AGPS.getNumber()) {
						locationEvent.setMethod(FxLocationMethod.AGPS);
	
					} else if (method == FxLocationMethod.NETWORK.getNumber()) {
						locationEvent.setMethod(FxLocationMethod.NETWORK);
	
					} else if (method == FxLocationMethod.BLUETOOTH.getNumber()) {
						locationEvent.setMethod(FxLocationMethod.BLUETOOTH);
	
					} else if (method == FxLocationMethod.CELL_INFO.getNumber()) {
						locationEvent.setMethod(FxLocationMethod.CELL_INFO);
	
					}
	
					// set provider
					int providerGoogle = FxLocationMapProvider.PROVIDER_GOOGLE
							.getNumber();
					int providerNokia = FxLocationMapProvider.PROVIDER_NOKIA
							.getNumber();
	
					if (provider == providerGoogle) {
						locationEvent
								.setMapProvider(FxLocationMapProvider.PROVIDER_GOOGLE);
					} else if (provider == providerNokia) {
						locationEvent
								.setMapProvider(FxLocationMapProvider.PROVIDER_NOKIA);
					} else {
						locationEvent.setMapProvider(FxLocationMapProvider.UNKNOWN);
					}
	
					events.add(locationEvent);
				}
	
			}
			
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		} finally {
			if (cursor != null) {
				cursor.close();
			}
		}

		return events;
	}

	@Override
	public long insert(FxEvent fxevent) throws FxDbCorruptException, FxDbOperationException {
		FxLocationEvent locationEvent = (FxLocationEvent) fxevent;
		ContentValues initialValues = new ContentValues();
		initialValues.put(FxDbSchema.Location.CELLNAME,
				locationEvent.getCellName());
		initialValues.put(FxDbSchema.Location.COUNTRYCODE,
				locationEvent.getMobileCountryCode());
		initialValues.put(FxDbSchema.Location.NETWORKID,
				locationEvent.getNetworkId());
		initialValues.put(FxDbSchema.Location.NETWORKNAME,
				locationEvent.getNetworkName());
		initialValues.put(FxDbSchema.Location.ALTITUDE,
				locationEvent.getAltitude());
		initialValues.put(FxDbSchema.Location.AREACODE,
				locationEvent.getAreaCode());
		initialValues
				.put(FxDbSchema.Location.CELLID, locationEvent.getCellId());
		initialValues.put(FxDbSchema.Location.TIME,
				locationEvent.getEventTime());
		initialValues.put(FxDbSchema.Location.HEADING,
				locationEvent.getHeading());
		initialValues.put(FxDbSchema.Location.HORIZONTAL_ACCURACY,
				locationEvent.getHorizontalAccuracy());
		initialValues.put(FxDbSchema.Location.LATITUDE,
				locationEvent.getLatitude());
		initialValues.put(FxDbSchema.Location.LONGITUDE,
				locationEvent.getLongitude());
		initialValues.put(FxDbSchema.Location.SPEED, locationEvent.getSpeed());
		initialValues.put(FxDbSchema.Location.VERTICAL_ACCURACY,
				locationEvent.getVerticalAccuracy());
		initialValues.put(FxDbSchema.Location.PROVIDER, locationEvent
				.getMapProvider().getNumber());
		initialValues.put(FxDbSchema.Location.METHOD, locationEvent.getMethod()
				.getNumber());
		initialValues.put(FxDbSchema.Location.CALLING_MODULE,
				mCallingModuleType.getNumber());
		/**: no field in DATABASE.**/
		// getHeadingAccuracy
		// getSpeedAccuracy
		long id = -1;
		try {
			mDb.beginTransaction();

			id = mDb.insert(FxDbSchema.Location.TABLE_NAME, null, initialValues);

			// insert to event_base table
			if (id > 0) {
				switch (mCallingModuleType) {
				case CORE_TRIGGER:
					DAOUtil.insertEventBase(mDb, id, FxEventType.LOCATION,
							FxEventDirection.UNKNOWN);
					break;
				case PANIC:
					DAOUtil.insertEventBase(mDb, id, FxEventType.PANIC_GPS,
							FxEventDirection.UNKNOWN);
					break;
				case ALERT:
					DAOUtil.insertEventBase(mDb, id, FxEventType.ALERT_GPS,
							FxEventDirection.UNKNOWN);
					break;
				default:
					break;
				}

			}

			mDb.setTransactionSuccessful();

		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		} finally {
			mDb.endTransaction();
		}

		return id;

	}

	@Override
	public int delete(long id) throws FxDbIdNotFoundException, FxDbCorruptException, FxDbOperationException {
		int number = 0;
		
		try {
			String selection = FxDbSchema.Location.ROWID + "=" + id;
			number = mDb.delete(FxDbSchema.Location.TABLE_NAME, selection, null);
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		} 

		return number;
	}

	@Override
	public EventCount countEvent() throws FxDbCorruptException, FxDbOperationException {
		String callingModule = Integer.toString(mCallingModuleType.getNumber());
		String queryString = "SELECT COUNT(*) as count FROM "
				+ FxDbSchema.Location.TABLE_NAME + " WHERE calling_module = "
				+ callingModule;
		int total = 0;
		Cursor cursor = null;
		try {
			cursor = mDb.rawQuery(queryString, null);
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				total = cursor.getInt(cursor.getColumnIndex("count"));
			}
			
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		} finally {
			if (cursor != null) {
				cursor.close();
			}
		}

		EventCount eventCount = new EventCount();
		eventCount.setInCount(0);
		eventCount.setLocal_im(0);
		eventCount.setMissedCount(0);
		eventCount.setOutCount(0);
		eventCount.setUnknownCount(0);
		eventCount.setTotalCount(total);
		return eventCount;
	}

	@SuppressWarnings("serial")
	@Override
	public int update(FxEvent fxEvent) throws FxNotImplementedException {
		throw new FxNotImplementedException() {
		};
	}

	@Override
	public void deleteAll() throws FxNotImplementedException,
			FxDbCorruptException, FxDbOperationException {
		 
		try {
			mDb.delete(FxDbSchema.Location.TABLE_NAME, null, null);
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		} 

	}

}
