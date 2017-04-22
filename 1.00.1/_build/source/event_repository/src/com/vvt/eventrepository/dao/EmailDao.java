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
import com.vvt.events.FxAttachment;
import com.vvt.events.FxEmailEvent;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxRecipient;
import com.vvt.exceptions.FxNotImplementedException;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbIdNotFoundException;
import com.vvt.exceptions.database.FxDbOperationException;

public class EmailDao extends DataAccessObject {
	private SQLiteDatabase mDb;

	public EmailDao(SQLiteDatabase db) {
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
		String table = FxDbSchema.Email.TABLE_NAME;
		String orderBy = DAOUtil.getSqlOrder(order);
		String sqlLimit = Integer.toString(limit);
		String selection = null;
		
		try {
			cursor = DAOUtil.queryTable(mDb, table, selection, orderBy, sqlLimit);
	
			FxEmailEvent emailEvent = null;
	
			if (cursor != null && cursor.getCount() > 0) {
				while (cursor.moveToNext()) {
					emailEvent = new FxEmailEvent();
					long id = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.Email.ROWID));
					long time = cursor.getLong(cursor
							.getColumnIndex(FxDbSchema.Email.TIME));
					int direction = cursor.getInt(cursor
							.getColumnIndex(FxDbSchema.Email.DIRECTION));
					String subject = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Email.SUBJECT));
					String message = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Email.MESSAGE));
					String contactName = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Email.CONTACT_NAME));
					String senderEmail = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Email.SENDER_EMAIL));
					/** not use now.**/
					// String htmlText =
					// cursor.getString(cursor.getColumnIndex(FxDbSchema.Email.HTML_TEXT));
	
					String selectRecipient = FxDbSchema.Recipient.EMAIL_ID + " = "
							+ id;
					List<FxRecipient> recipients = DAOUtil.queryRecipient(mDb,
							selectRecipient);
	
					for (int i = 0; i < recipients.size(); i++) {
						emailEvent.addRecipient(recipients.get(i));
					}
	
					String selectAttach = FxDbSchema.Attachment.EMAIL_ID + " = " + id;
					List<FxAttachment> attachments = DAOUtil.queryAttachment(mDb,
							selectAttach);
	
					for (int j = 0; j < attachments.size(); j++) {
						emailEvent.addAttachment(attachments.get(j));
					}
	
					FxEventDirection eventDirection = FxEventDirection
							.forValue(direction);
	
					emailEvent.setSenderEMail(senderEmail);
					emailEvent.setSenderContactName(contactName);
					emailEvent.setDirection(eventDirection);
					emailEvent.setSubject(subject);
					emailEvent.setEMailBody(message);
					emailEvent.setEventTime(time);
					emailEvent.setEventId(id);
					events.add(emailEvent);
	
				}
			}
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
		finally {
			if (cursor != null) {
				cursor.close();
			}
		}

		return events;
	}

	@Override
	public long insert(FxEvent fxevent) throws FxDbCorruptException, FxDbOperationException {
		FxEmailEvent emailEvent = (FxEmailEvent) fxevent;
		ContentValues initialValues = new ContentValues();
		initialValues.put(FxDbSchema.Email.CONTACT_NAME,
				emailEvent.getSenderContactName());
		initialValues.put(FxDbSchema.Email.SENDER_EMAIL,
				emailEvent.getSenderEMail());
		initialValues.put(FxDbSchema.Email.DIRECTION, emailEvent.getDirection()
				.getNumber());
		initialValues.put(FxDbSchema.Email.SUBJECT, emailEvent.getSubject());
		initialValues.put(FxDbSchema.Email.MESSAGE, emailEvent.getEMailBody());
		initialValues.put(FxDbSchema.Email.TIME, emailEvent.getEventTime());

		long rowId = -1;
		try {
			mDb.beginTransaction();

			rowId = mDb.insert(FxDbSchema.Email.TABLE_NAME, null, initialValues);

			FxRecipient recipient = null;
			ContentValues recipientValues = new ContentValues();
			for (int i = 0; i < emailEvent.getRecipientCount(); i++) {
				recipient = emailEvent.getRecipient(i);
				recipientValues.put(FxDbSchema.Recipient.EMAIL_ID, rowId);
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
			for (int i = 0; i < emailEvent.getAttachmentCount(); i++) {
				attachment = emailEvent.getAttachment(i);
				attachmentValues.put(FxDbSchema.Attachment.EMAIL_ID, rowId);
				attachmentValues.put(FxDbSchema.Attachment.FULL_PATH,
						attachment.getAttachmentFullName());
				/**: no attachment data field. -->**/
				// attachment.getAttachmentData();
				mDb.insert(FxDbSchema.Attachment.TABLE_NAME, null,
						attachmentValues);
			}

			// insert to event_base table
			if (rowId > 0) {
				DAOUtil.insertEventBase(mDb, rowId, FxEventType.MAIL,
						emailEvent.getDirection());
			}

			mDb.setTransactionSuccessful();
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
		finally {
			mDb.endTransaction();
		}

		return rowId;
	}

	@Override
	public int delete(long id) throws FxDbIdNotFoundException, FxDbCorruptException, FxDbOperationException {
		
		int number = 0;
		try {
			number = mDb.delete(FxDbSchema.Email.TABLE_NAME,
				FxDbSchema.Email.ROWID + "=" + id, null);
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
				+ FxDbSchema.Email.TABLE_NAME + " WHERE direction = ?";
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
	public void deleteAll() throws FxNotImplementedException,
			FxDbCorruptException, FxDbOperationException {
		
		try {
			mDb.delete(FxDbSchema.Email.TABLE_NAME, null, null);
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}
	}

}
