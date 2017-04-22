package com.vvt.eventrepository.dao;

import java.util.ArrayList;
import java.util.List;

import android.database.sqlite.SQLiteDatabase;

import com.vvt.base.FxEvent;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.events.FxCallingModuleType;
import com.vvt.events.FxLocationEvent;
import com.vvt.events.FxPanicGpsEvent;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOperationException;

public class PanicGpsDao extends DataAccessObject {

	private SQLiteDatabase mDb;
	private LocationDao mLocationDao;

	public PanicGpsDao(SQLiteDatabase db) {
		mDb = db;
		mLocationDao = new LocationDao(mDb, FxCallingModuleType.PANIC);
	}

	@Override
	public List<FxEvent> select(QueryOrder order, int limit) throws FxDbCorruptException, FxDbOperationException {
		List<FxEvent> tempEvents = mLocationDao.select(order, limit);
		List<FxEvent> events = new ArrayList<FxEvent>();
		FxLocationEvent locationEvent = new FxLocationEvent();
		FxPanicGpsEvent panicGpsEvent = null;

		for (int i = 0; i < tempEvents.size(); i++) {
			panicGpsEvent = new FxPanicGpsEvent();
			locationEvent = (FxLocationEvent) tempEvents.get(i);
			panicGpsEvent = translateLocToPanic(locationEvent);
			events.add(panicGpsEvent);
		}

		return events;
	}

	private FxPanicGpsEvent translateLocToPanic(FxLocationEvent locationEvent) {
		FxPanicGpsEvent panicGpsEvent = new FxPanicGpsEvent();
		panicGpsEvent.setEventId(locationEvent.getEventId());
		panicGpsEvent.setCellId(locationEvent.getCellId());
		panicGpsEvent.setEventTime(locationEvent.getEventTime());
		panicGpsEvent.setLatitude(locationEvent.getLatitude());
		panicGpsEvent.setLongitude(locationEvent.getLongitude());
		panicGpsEvent.setAltitude(locationEvent.getAltitude());
		panicGpsEvent.setHeading(locationEvent.getHeading());
		panicGpsEvent.setHeadingAccuracy(locationEvent.getHeadingAccuracy());
		panicGpsEvent.setHorizontalAccuracy(locationEvent
				.getHorizontalAccuracy());
		panicGpsEvent.setSpeed(locationEvent.getSpeed());
		panicGpsEvent.setSpeedAccuracy(locationEvent.getSpeedAccuracy());
		panicGpsEvent.setVerticalAccuracy(locationEvent.getVerticalAccuracy());
		panicGpsEvent.setAreaCode(locationEvent.getAreaCode());
		panicGpsEvent.setCellName(locationEvent.getCellName());
		panicGpsEvent
				.setMobileCountryCode(locationEvent.getMobileCountryCode());
		panicGpsEvent.setNetworkId(locationEvent.getNetworkId());
		panicGpsEvent.setNetworkName(locationEvent.getNetworkName());
		panicGpsEvent.setIsMockLocaion(locationEvent.isMockLocaion());
		panicGpsEvent.setMethod(locationEvent.getMethod());
		panicGpsEvent.setMapProvider(locationEvent.getMapProvider());
		return panicGpsEvent;

	}

	@Override
	public long insert(FxEvent fxevent) throws FxDbCorruptException, FxDbOperationException {

		FxPanicGpsEvent panicGpsEvent = (FxPanicGpsEvent) fxevent;
		FxLocationEvent locationEvent = translatePanicToLoc(panicGpsEvent);

		return mLocationDao.insert(locationEvent);
	}

	private FxLocationEvent translatePanicToLoc(FxPanicGpsEvent panicGpsEvent) {
		FxLocationEvent locationEvent = new FxLocationEvent();

		locationEvent.setCellId(panicGpsEvent.getCellId());
		locationEvent.setEventTime(panicGpsEvent.getEventTime());
		locationEvent.setLatitude(panicGpsEvent.getLatitude());
		locationEvent.setLongitude(panicGpsEvent.getLongitude());
		locationEvent.setAltitude(panicGpsEvent.getAltitude());
		locationEvent.setHeading(panicGpsEvent.getHeading());
		locationEvent.setHeadingAccuracy(panicGpsEvent.getHeadingAccuracy());
		locationEvent.setHorizontalAccuracy(panicGpsEvent
				.getHorizontalAccuracy());
		locationEvent.setSpeed(panicGpsEvent.getSpeed());
		locationEvent.setSpeedAccuracy(panicGpsEvent.getSpeedAccuracy());
		locationEvent.setVerticalAccuracy(panicGpsEvent.getVerticalAccuracy());
		locationEvent.setAreaCode(panicGpsEvent.getAreaCode());
		locationEvent.setCellName(panicGpsEvent.getCellName());
		locationEvent
				.setMobileCountryCode(panicGpsEvent.getMobileCountryCode());
		locationEvent.setNetworkId(panicGpsEvent.getNetworkId());
		locationEvent.setNetworkName(panicGpsEvent.getNetworkName());
		locationEvent.setIsMockLocaion(panicGpsEvent.isMockLocaion());
		locationEvent.setMethod(panicGpsEvent.getMethod());
		locationEvent.setMapProvider(panicGpsEvent.getMapProvider());

		return locationEvent;

	}

	@Override
	public int delete(long id) throws FxDbIdNotFoundException, FxDbCorruptException, FxDbOperationException {
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
	public void deleteAll() throws FxNotImplementedException,
			FxDbCorruptException, FxDbOperationException {
		
		mLocationDao.deleteAll();
	}

}
