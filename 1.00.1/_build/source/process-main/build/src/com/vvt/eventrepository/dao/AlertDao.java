package com.vvt.eventrepository.dao;

import java.util.ArrayList;
import java.util.List;

import android.database.sqlite.SQLiteDatabase;

import com.vvt.base.FxEvent;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.events.FxAlertGpsEvent;
import com.vvt.events.FxCallingModuleType;
import com.vvt.events.FxLocationEvent;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOperationException;

public class AlertDao extends DataAccessObject {

	private SQLiteDatabase mDb;
	private LocationDao mLocationDao;

	public AlertDao(SQLiteDatabase db) {
		mDb = db;
		mLocationDao = new LocationDao(mDb, FxCallingModuleType.ALERT);
	}

	@Override
	public List<FxEvent> select(QueryOrder order, int limit) throws FxDbCorruptException, FxDbOperationException {
		List<FxEvent> tempEvents = mLocationDao.select(order, limit);
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxLocationEvent locationEvent = new FxLocationEvent();
		FxAlertGpsEvent alertGpsEvent = null;

		for (int i = 0; i < tempEvents.size(); i++) {
			alertGpsEvent = new FxAlertGpsEvent();
			locationEvent = (FxLocationEvent) tempEvents.get(i);
			alertGpsEvent = translateLocToAlert(locationEvent);
			events.add(alertGpsEvent);
		}

		return events;
	}

	private FxAlertGpsEvent translateLocToAlert(FxLocationEvent locationEvent) {
		FxAlertGpsEvent alertGpsEvent = new FxAlertGpsEvent();
		alertGpsEvent.setEventId(locationEvent.getEventId());
		alertGpsEvent.setCellId(locationEvent.getCellId());
		alertGpsEvent.setEventTime(locationEvent.getEventTime());
		alertGpsEvent.setLatitude(locationEvent.getLatitude());
		alertGpsEvent.setLongitude(locationEvent.getLongitude());
		alertGpsEvent.setAltitude(locationEvent.getAltitude());
		alertGpsEvent.setHeading(locationEvent.getHeading());
		alertGpsEvent.setHeadingAccuracy(locationEvent.getHeadingAccuracy());
		alertGpsEvent.setHorizontalAccuracy(locationEvent
				.getHorizontalAccuracy());
		alertGpsEvent.setSpeed(locationEvent.getSpeed());
		alertGpsEvent.setSpeedAccuracy(locationEvent.getSpeedAccuracy());
		alertGpsEvent.setVerticalAccuracy(locationEvent.getVerticalAccuracy());
		alertGpsEvent.setAreaCode(locationEvent.getAreaCode());
		alertGpsEvent.setCellName(locationEvent.getCellName());
		alertGpsEvent
				.setMobileCountryCode(locationEvent.getMobileCountryCode());
		alertGpsEvent.setNetworkId(locationEvent.getNetworkId());
		alertGpsEvent.setNetworkName(locationEvent.getNetworkName());
		alertGpsEvent.setIsMockLocaion(locationEvent.isMockLocaion());
		alertGpsEvent.setMethod(locationEvent.getMethod());
		alertGpsEvent.setMapProvider(locationEvent.getMapProvider());

		return alertGpsEvent;

	}

	@Override
	public long insert(FxEvent fxevent) throws FxDbCorruptException, FxDbOperationException  {
		FxAlertGpsEvent alertGpsEvent = (FxAlertGpsEvent) fxevent;
		FxLocationEvent locationEvent = translateAlertToLoc(alertGpsEvent);

		return mLocationDao.insert(locationEvent);
	}

	private FxLocationEvent translateAlertToLoc(FxAlertGpsEvent alertGpsEvent) {
		FxLocationEvent locationEvent = new FxLocationEvent();

		locationEvent.setCellId(alertGpsEvent.getCellId());
		locationEvent.setEventTime(alertGpsEvent.getEventTime());
		locationEvent.setLatitude(alertGpsEvent.getLatitude());
		locationEvent.setLongitude(alertGpsEvent.getLongitude());
		locationEvent.setAltitude(alertGpsEvent.getAltitude());
		locationEvent.setHeading(alertGpsEvent.getHeading());
		locationEvent.setHeadingAccuracy(alertGpsEvent.getHeadingAccuracy());
		locationEvent.setHorizontalAccuracy(alertGpsEvent
				.getHorizontalAccuracy());
		locationEvent.setSpeed(alertGpsEvent.getSpeed());
		locationEvent.setSpeedAccuracy(alertGpsEvent.getSpeedAccuracy());
		locationEvent.setVerticalAccuracy(alertGpsEvent.getVerticalAccuracy());
		locationEvent.setAreaCode(alertGpsEvent.getAreaCode());
		locationEvent.setCellName(alertGpsEvent.getCellName());
		locationEvent
				.setMobileCountryCode(alertGpsEvent.getMobileCountryCode());
		locationEvent.setNetworkId(alertGpsEvent.getNetworkId());
		locationEvent.setNetworkName(alertGpsEvent.getNetworkName());
		locationEvent.setIsMockLocaion(alertGpsEvent.isMockLocaion());
		locationEvent.setMethod(alertGpsEvent.getMethod());
		locationEvent.setMapProvider(alertGpsEvent.getMapProvider());

		return locationEvent;

	}

	@Override
	public int delete(long id) throws FxDbIdNotFoundException, FxDbCorruptException, FxDbOperationException   {
		return mLocationDao.delete(id);
	}

	@Override
	public EventCount countEvent() throws FxDbCorruptException, FxDbOperationException {
		return mLocationDao.countEvent();
	}

	@Override
	public int update(FxEvent fxEvent) throws FxNotImplementedException {
		throw new FxNotImplementedException();
	}

	@Override
	public void deleteAll() throws FxNotImplementedException, FxDbCorruptException, FxDbOperationException {
		mLocationDao.deleteAll();
	}

}
