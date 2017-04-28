package com.vvt.eventrepository.dao;

import java.util.ArrayList;
import java.util.List;

import android.content.ContentValues;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteDatabaseCorruptException;

import com.vvt.base.FxEventType;
import com.vvt.eventrepository.databasemanager.FxDbSchema;
import com.vvt.eventrepository.eventresult.EventCount;
import com.vvt.eventrepository.querycriteria.QueryOrder;
import com.vvt.events.FxAttachment;
import com.vvt.events.FxEventDirection;
import com.vvt.events.FxParticipant;
import com.vvt.events.FxRecipient;
import com.vvt.events.FxRecipientType;
import com.vvt.exceptions.database.FxDbCorruptException;
import com.vvt.exceptions.database.FxDbOperationException;

public class DAOUtil {

	public static String getSqlOrder(QueryOrder order) {
		String orderBy = "_id DESC";
		if (order == QueryOrder.QueryOldestFist) {
			orderBy = "_id ASC";
		}
		return orderBy;
	}

	public static Cursor queryTable(SQLiteDatabase db, String table,
			String selection, String orderBy, String limit) throws FxDbCorruptException, FxDbOperationException {

		Cursor cursor = null;
		
		try {
			cursor = db.query(table, null, selection, null, null, null, orderBy,limit);
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		}  

		return cursor;
	}
	
	public static List<FxParticipant> queryPaticipant(SQLiteDatabase db,
			String selection) throws FxDbCorruptException, FxDbOperationException {

		List<FxParticipant> participants = new ArrayList<FxParticipant>();

		Cursor cursor = null;
		try {
			cursor = db.query(FxDbSchema.ParticipantsColumns.TABLE_NAME, null,
				selection, null, null, null, null);

			FxParticipant participant = null;
		
		
			if (cursor != null && cursor.getCount() > 0) {
				while (cursor.moveToNext()) {
					participant = new FxParticipant();
					String name = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.ParticipantsColumns.NAME));
					String uid = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.ParticipantsColumns.UID));
	
					participant.setName(name);
					participant.setUid(uid);
	
					participants.add(participant);
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

		return participants;
	}

	public static List<FxRecipient> queryRecipient(SQLiteDatabase db,
			String selection) throws FxDbCorruptException, FxDbOperationException {

		List<FxRecipient> recipients = new ArrayList<FxRecipient>();

		Cursor cursor = null;
		try {
			cursor = db.query(FxDbSchema.Recipient.TABLE_NAME, null,
				selection, null, null, null, null);

			FxRecipient recipient = null;
		
		
			if (cursor != null && cursor.getCount() > 0) {
				while (cursor.moveToNext()) {
					recipient = new FxRecipient();
					String contactName = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Recipient.CONTACT_NAME));
					int recipientType = cursor.getInt(cursor
							.getColumnIndex(FxDbSchema.Recipient.RECIPIENT_TYPE));
					String reciver = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Recipient.RECIPIENT));
	
					recipient.setRecipientType(getRecipientType(recipientType));
					recipient.setContactName(contactName);
					recipient.setRecipient(reciver);
	
					recipients.add(recipient);
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

		return recipients;
	}

	public static FxRecipientType getRecipientType(int type) {

		FxRecipientType recipientType = null;

		if (type == FxRecipientType.CC.getNumber()) {
			recipientType = FxRecipientType.CC;
		} else if (type == FxRecipientType.BCC.getNumber()) {
			recipientType = FxRecipientType.BCC;
		} else {
			recipientType = FxRecipientType.TO;
		}
		return recipientType;
	}

	public static List<FxAttachment> queryAttachment(SQLiteDatabase db,
			String selection) throws FxDbCorruptException, FxDbOperationException {

		List<FxAttachment> attachments = new ArrayList<FxAttachment>();

		Cursor cursor = null;
		try {
			cursor = db.query(FxDbSchema.Attachment.TABLE_NAME, null,
					selection, null, null, null, null);
	
			FxAttachment attachment = null;
		
		
			if (cursor != null && cursor.getCount() > 0) {
				while (cursor.moveToNext()) {
					attachment = new FxAttachment();
					String fullPath = cursor.getString(cursor
							.getColumnIndex(FxDbSchema.Attachment.FULL_PATH));
	
					attachment.setAttachemntFullName(fullPath);
					attachment.setAttachmentData(new byte[] {});
					attachments.add(attachment);
	
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

		return attachments;
	}

	public static EventCount getEventCount(SQLiteDatabase db, String queryString) throws FxDbCorruptException, FxDbOperationException {
		int incomming = 0;
		int outgoing = 0;
		int missing = 0;
		int unknown = 0;
		int local_im = 0;
		Cursor cursor = null;
		try {
			cursor = db.rawQuery(queryString, new String[] { Integer
					.toString(FxEventDirection.IN.getNumber()) });
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				incomming = cursor.getInt(cursor.getColumnIndex("count"));
			}
	
			cursor = db.rawQuery(queryString, new String[] { Integer
					.toString(FxEventDirection.OUT.getNumber()) });
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				outgoing = cursor.getInt(cursor.getColumnIndex("count"));
			}
	
			cursor = db.rawQuery(queryString, new String[] { Integer
					.toString(FxEventDirection.MISSED_CALL.getNumber()) });
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				missing = cursor.getInt(cursor.getColumnIndex("count"));
			}
	
			cursor = db.rawQuery(queryString, new String[] { Integer
					.toString(FxEventDirection.UNKNOWN.getNumber()) });
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				unknown = cursor.getInt(cursor.getColumnIndex("count"));
			}
	
			cursor = db.rawQuery(queryString, new String[] { Integer
					.toString(FxEventDirection.LOCAL_IM.getNumber()) });
			if (cursor != null && cursor.getCount() > 0) {
				cursor.moveToFirst();
				local_im = cursor.getInt(cursor.getColumnIndex("count"));
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
		eventCount.setInCount(incomming);
		eventCount.setOutCount(outgoing);
		eventCount.setMissedCount(missing);
		eventCount.setUnknownCount(unknown);
		eventCount.setLocal_im(local_im);
		eventCount.setTotalCount(incomming + outgoing + missing + unknown
				+ local_im);

		return eventCount;
	}

	public static long insertEventBase(SQLiteDatabase db, long id,
			FxEventType eventType, FxEventDirection direction) throws FxDbCorruptException, FxDbOperationException {
		// insert to event_base table
		ContentValues eventBaseValues = new ContentValues();
		eventBaseValues.put(FxDbSchema.EventBase.EVENT_ID, id);
		eventBaseValues.put(FxDbSchema.EventBase.EVENT_TYPE,
				eventType.getNumber());
		eventBaseValues.put(FxDbSchema.EventBase.DIRECTION,
				direction.getNumber());
		
		long rowId = -1;
		try {
			rowId = db.insert(FxDbSchema.EventBase.TABLE_NAME, null,
					eventBaseValues);
		} catch (SQLiteDatabaseCorruptException cex) {
			throw new FxDbCorruptException(cex.getMessage()); 	
		} catch (Throwable t) {
			throw new FxDbOperationException(t.getMessage(), t);
		} 
		return rowId;
	}

}
