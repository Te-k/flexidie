package com.fx.dalvik.gmail;

public class GmailDatabaseHelper {
	
	public static final String TABLE_CONVERSATIONS = "conversations";
	public static final String COLUMN_ID = "_id";
	public static final String COLUMN_DATE = "date";
	public static final String COLUMN_MAX_MSG_ID = "maxMessageId";
	
	public static final String TABLE_MESSAGES = "messages";
	public static final String COLUMN_NAME = "name";
	public static final String COLUMN_LABELS_ID = "labels_id";
	public static final String COLUMN_LABEL_IDS = "labelIds";
	public static final String COLUMN_MSG_ID = "messageId";
	public static final String COLUMN_CONVERSATION = "conversation";
	public static final String COLUMN_FROM = "fromAddress";
	public static final String COLUMN_TO = "toAddresses";
	public static final String COLUMN_CC = "ccAddresses";
	public static final String COLUMN_BCC = "bccAddresses";
	public static final String COLUMN_REPLY_TO = "replyToAddresses";
	public static final String COLUMN_DATE_SENT = "dateSentMs";
	public static final String COLUMN_DATE_RECEIVED = "dateReceivedMs";
	public static final String COLUMN_SUBJECT = "subject";
	public static final String COLUMN_BODY = "body";
	public static final String COLUMN_ATTACHMENTS = "joinedAttachmentInfos";
	
	public static final String LABEL_INBOX = "^i";
	public static final String LABEL_SENT = "^f";
	public static final String SELECT_INBOX = "label:^i";
	public static final String SELECT_SENT = "label:^f";
	
}
