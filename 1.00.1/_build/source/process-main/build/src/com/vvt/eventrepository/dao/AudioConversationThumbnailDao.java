package com.vvt.eventrepository.dao;

import java.util.ArrayList;
import java.util.List;

import android.database.sqlite.SQLiteDatabase;

import com.vvt.base.FxEvent;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbOperationException;

public class AudioConversationThumbnailDao extends DataAccessObject {

	public AudioConversationThumbnailDao(SQLiteDatabase db) {
	}

	@Override
	public List<FxEvent> select(QueryOrder order, int limit)
			throws FxNotImplementedException {
		List<FxEvent> list = new ArrayList<FxEvent>();
		return list;
	}

	@Override
	public long insert(FxEvent fxevent) throws FxNotImplementedException,
	 FxDbCorruptException, FxDbOperationException {
		throw new FxNotImplementedException();
	}

	@Override
	public int delete(long id) throws FxNotImplementedException {
		throw new FxNotImplementedException();
	}

	@Override
	public EventCount countEvent() throws FxNotImplementedException {
		throw new FxNotImplementedException();
	}

	@Override
	public int update(FxEvent fxEvent) throws FxNotImplementedException {
		throw new FxNotImplementedException();
	}

	@Override
	public void deleteAll() throws FxNotImplementedException {
		throw new FxNotImplementedException();
	}

}
