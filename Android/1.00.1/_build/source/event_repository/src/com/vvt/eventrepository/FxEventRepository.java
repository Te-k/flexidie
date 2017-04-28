package com.vvt.eventrepository;

import java.util.List;

import com.vvt.base.FxEvent;
import com.vvt.eventrepository.eventresult.EventCountInfo;
import com.vvt.eventrepository.eventresult.EventKeys;
import com.vvt.eventrepository.eventresult.EventResultSet;
import com.vvt.eventrepository.querycriteria.QueryCriteria;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.FxNullNotAllowedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbNotOpenException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.exceptions.io.FxFileNotFoundException;
import com.vvt.exceptions.io.FxFileSizeNotAllowedException;

/**
 * @author aruna
 * @version 1.0
 * @created 01-Sep-2011 04:15:57
 */

/***
 * Caller interface to the repository
 */
public interface FxEventRepository {

	public EventResultSet getRegularEvents(QueryCriteria criteria)
			throws FxNullNotAllowedException, FxNotImplementedException,
			FxDbNotOpenException, FxFileNotFoundException, FxDbOperationException;

	public EventResultSet getMediaEvents(QueryCriteria criteria)
			throws FxNullNotAllowedException, FxNotImplementedException,
			FxFileNotFoundException, FxDbNotOpenException, FxDbCorruptException, FxDbOperationException;

	public void insert(FxEvent events) throws FxNullNotAllowedException,
			FxDbNotOpenException, FxNotImplementedException, FxDbOperationException;

	public void insert(List<FxEvent> events) throws FxNullNotAllowedException,
			FxDbNotOpenException, FxNotImplementedException, FxDbOperationException;

	public void delete(EventKeys evKeys) throws FxDbNotOpenException,
			FxNotImplementedException, FxNullNotAllowedException,
			FxDbIdNotFoundException, FxDbOperationException;

	public EventCountInfo getCount() throws FxNotImplementedException,
			FxDbNotOpenException, FxDbCorruptException, FxDbOperationException;

	public int getTotalEventCount() throws FxDbNotOpenException, FxDbCorruptException, FxDbOperationException;

	public void addRepositoryChangeListener(RepositoryChangeListener listener,
			RepositoryChangePolicy policy) throws FxNullNotAllowedException;

	public void removeRepositoryChangeListener(RepositoryChangeListener listener);

	public void deleteActualMedia(long paringId) throws FxDbIdNotFoundException;

	public FxEvent validateMedia(long paringId) throws FxNotImplementedException, FxDbOperationException, FxFileNotFoundException, FxDbIdNotFoundException, FxFileSizeNotAllowedException;
	
	public FxEvent getActualMedia(long paringId) throws FxNotImplementedException, FxDbOperationException;
	
	public void updateMediaThumbnailStatus(long id, boolean status)
			throws FxDbIdNotFoundException, FxDbOperationException;
	
	public void addDatabaseCorruptExceptionListener(DatabaseCorruptExceptionListener listener);

	public long getDBSize();
}