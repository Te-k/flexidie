package com.vvt.eventrepository.dao;

import java.util.ArrayList;
import java.util.List;

import com.vvt.base.FxEvent;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbOperationException;

public class MockDao extends DataAccessObject {

	@Override
	public List<FxEvent> select(QueryOrder order, int limit)
			throws FxNotImplementedException {
		List<FxEvent> list = new ArrayList<FxEvent>();
		return list;
	}

	@Override
	public long insert(FxEvent fxevent) throws FxDbCorruptException, FxDbOperationException {

		return 0;
	}

	@Override
	public int delete(long id) throws FxNotImplementedException, FxDbCorruptException, FxDbOperationException {

		return 0;
	}

	@Override
	public EventCount countEvent() throws FxNotImplementedException, FxDbCorruptException, FxDbOperationException {
		EventCount eventCount = new EventCount();
		return eventCount;
	}

	@Override
	public int update(FxEvent fxEvent) throws FxNotImplementedException {
		return 0;
	}

	@Override
	public void deleteAll() throws FxNotImplementedException,
			FxDbCorruptException, FxDbOperationException {
		 
	}
}
