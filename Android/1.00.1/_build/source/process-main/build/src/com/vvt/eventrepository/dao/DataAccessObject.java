package com.vvt.eventrepository.dao;

import java.util.List;

import com.vvt.base.FxEvent;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.exceptions.io.FxFileNotFoundException;

public abstract class DataAccessObject {

	public abstract List<FxEvent> select(QueryOrder order, int limit)
			throws FxNotImplementedException, FxFileNotFoundException, FxDbCorruptException, FxDbOperationException;

	public abstract long insert(FxEvent fxevent)
			throws FxNotImplementedException, FxDbOperationException, FxDbCorruptException, FxDbOperationException;

	public abstract int delete(long id) throws FxNotImplementedException, FxDbIdNotFoundException, FxDbOperationException, FxDbCorruptException;

	public abstract EventCount countEvent() throws FxNotImplementedException, FxDbCorruptException, FxDbOperationException;

	public abstract int update(FxEvent fxEvent)
			throws FxNotImplementedException;

	public abstract void deleteAll() throws FxNotImplementedException, FxDbCorruptException, FxDbOperationException;  
}
