/*
 Makara: run time log selectors
 */

#import <CoreData/CoreData.h>

@class LineLocation, NSDictionary, NSURL, NLChatID, NLSharableObject, NSArray;

__attribute__((visibility("hidden")))
@interface ManagedChat : NSManagedObject {
	BOOL _changedSection;
	BOOL isAvailableOnAir;
	BOOL isOnAir;
	BOOL hasNewNote;
	NSArray* sharingImagesTemporary;
	LineLocation* sharingLocationTemporary;
	NSURL* sharingAudioTemporary;
	NSDictionary* sharingContactTemporary;
	NLSharableObject* sharingOBSTemporary;
	NSArray* sharingMessagesTemporary;
	unsigned albumNewState;
}
@property(readonly, assign, nonatomic) NLChatID* chatID;
@property(assign, nonatomic) unsigned albumNewState;
@property(assign, nonatomic) BOOL hasNewNote;
@property(readonly, assign, nonatomic) BOOL isOnAir;
@property(readonly, assign, nonatomic) BOOL isAvailableOnAir;
@property(retain, nonatomic) NSArray* sharingMessagesTemporary;
@property(retain, nonatomic) NLSharableObject* sharingOBSTemporary;
@property(retain, nonatomic) NSDictionary* sharingContactTemporary;
@property(retain, nonatomic) NSURL* sharingAudioTemporary;
@property(retain, nonatomic) LineLocation* sharingLocationTemporary;
@property(retain, nonatomic) NSArray* sharingImagesTemporary;
+(void)removeAllLastMessagesInManagedObjectContext:(id)managedObjectContext;
+(void)recomputeUnreadMessageCount;
+(int)computeUnreadMessageCountInContext:(id)context;
+(id)privateBlindedMessageWithMessage:(id)message;
+(id)lastMessageTextFromMessage:(id)message;
+(id)insertOrUpdateRoom:(id)room inManagedObjectContext:(id)managedObjectContext;
+(id)insertWithRoom:(id)room inManagedObjectContext:(id)managedObjectContext;
+(id)insertWithID:(id)anId members:(id)members lastUpdated:(id)updated alert:(BOOL)alert inManagedObjectContext:(id)managedObjectContext;
+(id)insertWithUser:(id)user inManagedObjectContext:(id)managedObjectContext;
+(id)insertWithGroup:(id)group inManagedObjectContext:(id)managedObjectContext;
+(id)skinnedChatsInManagedObjectContext:(id)managedObjectContext;
+(id)chatAutocreatedWithID:(id)anId inManagedObjectContext:(id)managedObjectContext;
+(id)chatWithMID:(id)mid inManagedObjectContext:(id)managedObjectContext;
+(id)chatWithID:(id)anId inManagedObjectContext:(id)managedObjectContext;
+(id)chatsWithSessionID:(unsigned char)sessionID inManagedObjectContext:(id)managedObjectContext;
+(id)chatsWithMID:(id)mid inManagedObjectContext:(id)managedObjectContext;
+(id)chatsInManagedObjectContext:(id)managedObjectContext;
+(void)configureDates;
+(void)configLocale;
+(BOOL)forwardMessagesWithSharableObjects:(id)sharableObjects chatObject:(id)object whenSendStarted:(id)started;
+(BOOL)forwardMessagesWithSharableObjects:(id)sharableObjects chatObject:(id)object;
+(void)notifyServerForAllUnsyncedChatsInContext:(id)context;
+(void)deleteAllUndecryptableMessagesWithCompletionHandler:(id)completionHandler;
//+(void)sendMessageWithChatObject:(id)chatObject text:(id)text requestSequence:(int)sequence image:(id)image thumbnail:(id)thumbnail location:(id)location latitude:(id)latitude sticker:(XXStruct_PILIWD)sticker contentType:(short)type metadata:(id)metadata;
+(id)newMessageWithThumbnail:(id)thumbnail chatObject:(id)object;
//-(void).cxx_destruct;
-(id)description;
-(void)resetData;
-(void)refreshAlert;
-(BOOL)isPrivateChat;
-(id)deleteAndSave;
-(void)prepareForDeletion;
-(void)updateLastReceivedMessageID:(id)anId;
-(void)adjustTotalUnreadBy:(int)by;
-(void)incrementChatMessagesUnread;
-(void)setEnable:(id)enable;
-(void)setUnread:(id)unread;
-(BOOL)isEmptyRoom;
-(int)midType;
-(id)titleWithMemberCount:(BOOL)memberCount;
-(id)fetchLastMessageObjectWithPredicate:(id)predicate;
-(id)fetchLastMessageSynced;
-(id)fetchLastMessage;
-(id)lastUpdatedString;
-(id)addMember:(id)member;
-(void)updateIfNecessaryWithMessage:(id)message;
-(id)messagesWithPredicate:(id)predicate includingDeletedMessages:(BOOL)messages ascending:(BOOL)ascending;
-(id)fetchRequestForMessagesWithPredicate:(id)predicate includingDeletedMessages:(BOOL)messages ascending:(BOOL)ascending;
-(id)updateWithRoom:(id)room;
-(id)initInsertedIntoManagedObjectContext:(id)context;
-(id)nameOfLogFile;
-(id)dataForLogFile;
-(id)chatLogSenderMidAndMessageIdForReport;
-(id)chatLogForReport;
-(id)chatLog;
-(void)syncAppBadgeOnContextSave;
-(void)syncChatAsReadUpToMessageWithID:(id)anId;
-(void)markChatAsReadAndNotifyServer;
-(BOOL)canMarkChatAsReadRemotely;
-(BOOL)canMarkChatAsReadLocally;
-(void)deleteUpToMessageID:(id)messageID temporaryID:(id)anId;
-(void)sendChatRemovedAndRemoveOnPrivateQueueIgnoringChatRemovedFailure:(BOOL)failure withCompletionHandler:(id)completionHandler;
-(void)markChatAsReadLocally;
-(void)notifyServerAsHavingReadUpToMessageWithID:(id)anId;
-(unsigned)fetchReceivedMessageCountAfterMessageWithID:(id)anId;

//
@property (nonatomic, copy) NSString *midString;
@property (nonatomic, copy) NSArray *sortedMembers;

@end

