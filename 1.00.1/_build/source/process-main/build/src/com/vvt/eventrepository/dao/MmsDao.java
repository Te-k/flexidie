package com.vvt.eventrepository.dao;

import java.io.File;
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
import com.vvt.events.FxAttachment;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxMMSEvent;
import com.vvt.events.FxRecipient;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOperationException;
import com.vvt.ioutil.FileUtil;
import com.vvt.logger.FxLog;

public class MmsDao extends DataAccessObject {
	
	private static final String TAG = "MmsDao";
	private SQLiteDatabase mDb;

	public MmsDao(SQLiteDatabase db) {
		mDb = db;
	}

	@Override
	public List<FxEvent> select(QueryOrder order, int limit) throws FxDbCorruptException, FxDbOperationException {
		List<FxEvent> events = new ArrayList<FxEvent>();
		events = selectRegularEvent(order, limit);
		return events;
	}

	private List<FxEvent> selectRegularEvent(QueryOrder order, int limit) throws FxDbCorruptException, FxDbOperationException {

		List<FxEvent> events = new ArrayList<FxEvent>();
		Cursor cursor = null;
		String table = FxDbSchema.Mms.TABLE_NAME;
		String orderBy = DAOUtil.getSqlOrder(order);
		String sqlLimit = Integer.toString(limit);
		String selection = null;
		
		try {
			cursor = DAOUtil.queryTable(mDb, table, selection, orderBy, sqlLimit);
	
			FxMMSEvent mmsEvent = null;
	
			if (cursor != null && cursor.getCount() > 0) {
				while (cursor.moveToNext()) {
					mmsEvent = new FxMMSEvent();
					long id = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.Mms.ROWID));
					long time = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.Mms.TIME));
					int direction = cursor.getInt(cursor
							.getColumnIndex(FxDbSchema.Mms.DIRECTION));
					String contactName = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Mms.CONTACT_NAME));
					String senderNumber = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Mms.SENDER_NUMBER));
	
					String selectRecipient = FxDbSchema.Recipient.MMS_ID + " = "
							+ id;
					List<FxRecipient> recipients = DAOUtil.queryRecipient(mDb,
							selectRecipient);
	
					for (int i = 0; i < recipients.size(); i++) {
						mmsEvent.addRecipient(recipients.get(i));
					}
	
					String selectAttach = FxDbSchema.Attachment.MMS_ID + " = " + id;
					List<FxAttachment> attachments = DAOUtil.queryAttachment(mDb,
							selectAttach);
	
					String fullPath = null;
					byte fileContent[] = null;
					
					for (int j = 0; j < attachments.size(); j++) {
						
						FxAttachment attachment = attachments.get(j);
						fileContent = new byte[] {};
						fullPath = attachment.getAttachmentFullName();
						
						if (fullPath != null) {
							File file = new File(fullPath);
							if (file.exists()) {
								fileContent = FileUtil.readFileData(fullPath);
							}
						}
						
						attachment.setAttachmentData(fileContent);
						mmsEvent.addAttachment(attachment);
					}
	
					FxEventDirection eventDirection = FxEventDirection
							.forValue(direction);
	
					mmsEvent.setSenderNumber(senderNumber);
					mmsEvent.setContactName(contactName);
					mmsEvent.setDirection(eventDirection);
					/**: no attachment data field.**/
					mmsEvent.setSubject("Unknown");
					mmsEvent.setEventTime(time);
					mmsEvent.setEventId(id);
					events.add(mmsEvent);
	
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
		FxMMSEvent mmsEvent = (FxMMSEvent) fxevent;
		ContentValues initialValues = new ContentValues();
		initialValues.put(FxDbSchema.Mms.SENDER_NUMBER,
				mmsEvent.getSenderNumber());
		initialValues.put(FxDbSchema.Mms.CONTACT_NAME,
				mmsEvent.getContactName());
		initialValues.put(FxDbSchema.Mms.DIRECTION, mmsEvent.getDirection()
				.getNumber());
		initialValues.put(FxDbSchema.Mms.TIME, mmsEvent.getEventTime());

		long rowId = -1;
		try {
			mDb.beginTransaction();

			rowId = mDb.insert(FxDbSchema.Mms.TABLE_NAME, null, initialValues);

			FxRecipient recipient = null;
			ContentValues recipientValues = new ContentValues();
			for (int i = 0; i < mmsEvent.getRecipientCount(); i++) {
				recipient = mmsEvent.getRecipient(i);
				recipientValues.put(FxDbSchema.Recipient.MMS_ID, rowId);
				recipientValues.put(FxDbSchema.Recipient.RECIPIENT_TYPE,
						recipient.getRecipientType().getNumber());
				recipientValues.put(FxDbSchema.Recipient.RECIPIENT,
						recipient.getRecipient());
				recipientValues.put(FxDbSchema.Recipient.CONTACT_NAME,
						recipient.getContactName());
				mDb.insert(FxDbSchema.Recipient.TABLE_NAME, null,
						recipientValues);

			}

			FxAttachment attachment = null;
			ContentValues attachmentValues = new ContentValues();
			for (int i = 0; i < mmsEvent.getAttachmentCount(); i++) {
				attachment = mmsEvent.getAttachment(i);
				attachmentValues.put(FxDbSchema.Attachment.MMS_ID, rowId);
				attachmentValues.put(FxDbSchema.Attachment.FULL_PATH,
						attachment.getAttachmentFullName());
				/** : no attachment data field. **/
				mDb.insert(FxDbSchema.Attachment.TABLE_NAME, null,
						attachmentValues);
			}

			// insert to event_base table
			if (rowId > 0) {
				DAOUtil.insertEventBase(mDb, rowId, FxEventType.MMS,
						mmsEvent.getDirection());
			}

			mDb.setTransactionSuccessful();

		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		} finally {
			mDb.endTransaction();
		}

		return rowId;
	}

	@Override
	public int delete(long id) throws FxDbIdNotFoundException, FxDbCorruptException, FxDbOperationException {
		int number = -1; 
		
		
		try {
			String selectAttach = FxDbSchema.Attachment.MMS_ID + " = " + id;
			List<FxAttachment> attachments = DAOUtil.queryAttachment(mDb, selectAttach);
			
			String fullPath = null;
			for (int i = 0; i < attachments.size(); i++) {
				fullPath = attachments.get(i).getAttachmentFullName();
				try {
					FileUtil.deleteFile(fullPath);
				}catch (IllegalArgumentException ex) {
					FxLog.e(TAG, ex.getMessage(),ex);
				}
			}
			
			String selection = FxDbSchema.Mms.ROWID + "=" + id;
			number = mDb.delete(FxDbSchema.Mms.TABLE_NAME,selection, null);
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
		
		return number;

	}

	@Override
	public EventCount countEvent() throws FxDbCorruptException, FxDbOperationException {
		String queryString = "SELECT COUNT(*) as count FROM "
				+ FxDbSchema.Mms.TABLE_NAME + " WHERE direction = ?";
		EventCount eventCount = DAOUtil.getEventCount(mDb, queryString);
		return eventCount;
	}

	@SuppressWarnings("serial")
	@Override
	public int update(FxEvent fxEvent) throws FxNotImplementedException {
		throw new FxNotImplementedException() {
		};
	}

	@Override
	public void deleteAll() throws FxDbCorruptException, FxDbOperationException {
		
		try {
			List<FxAttachment> attachments = DAOUtil.queryAttachment(mDb, null);
			
			String fullPath = null;
			for (int i = 0; i < attachments.size(); i++) {
				fullPath = attachments.get(i).getAttachmentFullName();
				try {
					FileUtil.deleteFile(fullPath);
				}catch (IllegalArgumentException ex) {
					FxLog.e(TAG, ex.getMessage(),ex);
				}
			}
			
			mDb.delete(FxDbSchema.Mms.TABLE_NAME, null, null);
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
	}

}
