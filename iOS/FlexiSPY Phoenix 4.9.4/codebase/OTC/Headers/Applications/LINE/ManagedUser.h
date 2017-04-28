/*
 Makara: run time log selectors
 */

#import <CoreData/CoreData.h>

@class NSString;

__attribute__((visibility("hidden")))
@interface ManagedUser : NSManagedObject {
	BOOL statusUpdated;
	BOOL hadNewPosts;
	BOOL isFreePhoneCallable;
	NSString* phoneNumberToDial;
}
@property(assign, nonatomic) BOOL isFreePhoneCallable;
@property(retain, nonatomic) NSString* phoneNumberToDial;
@property(retain, nonatomic) NSString* picturePath;
@property(assign, nonatomic) BOOL statusUpdated;
@property(assign, nonatomic) BOOL hadNewPosts;
+(id)chineseSortableName:(id)name;
+(id)koreanSortableName:(id)name;
+(id)japaneseSortableName:(id)name;
+(id)sortableName:(id)name name:(id)name2;
+(id)sortableNameByCurrrentLanguageWithName:(id)name;
+(void)deleteUndecryptableLocallyEncryptedData;
+(id)insertNonameUserWithMID:(id)mid inManagedObjectContext:(id)managedObjectContext;
+(id)insertWithContact:(id)contact inManagedObjectContext:(id)managedObjectContext;
+(id)insertWithBuddySearchResult:(id)buddySearchResult inManagedObjectContext:(id)managedObjectContext;
+(id)displayNameOfUserWithMID:(id)mid inContext:(id)context;
+(id)usersWithMids:(id)mids asFaults:(BOOL)faults inManagedObjectContext:(id)managedObjectContext;
+(id)usersWithMids:(id)mids inManagedObjectContext:(id)managedObjectContext;
+(id)userWithObjectID:(id)objectID inManagedObjectContext:(id)managedObjectContext;
+(id)userWithKey:(id)key autocreate:(BOOL)autocreate inManagedObjectContext:(id)managedObjectContext;
+(id)userWithKey:(id)key inManagedObjectContext:(id)managedObjectContext;
+(id)usersByAscendingFavoriteOrder:(BOOL)order inContext:(id)context;
+(int)numberOfFavoriteUsersInContext:(id)context;
+(long long)maxOfFavoriteOrderInContext:(id)context;
+(unsigned)numberOfFriendsInContext:(id)context;
+(id)addressBookUserInManagedObjectContext:(id)managedObjectContext;
+(id)predicateForOfficialAccount;
+(id)predicateForRecommendarationInvalidateUser;
+(id)predicateForInvalidateUser;
+(id)predicateForFavoriteUsers;
+(id)predicateForNotViewedRecommendedUsers;
+(id)predicateForNoFriendsWithAndPrediciate:(id)andPrediciate;
+(id)predicateForNoFriends;
+(id)predicateForFriendsWithAndPredicate:(id)andPredicate;
+(id)predicateForFriends;
//-(void).cxx_destruct;
-(id)description;
-(id)memberId;
-(void)updateSortableName;
-(void)setSortableName:(id)name;
-(void)setCustomName:(id)name;
-(void)setAddressbookName:(id)name;
-(void)setName:(id)name;
-(void)setStatusNewFriends;
-(BOOL)canOpenProfilePopup;
-(BOOL)canOpenUserHome;
-(BOOL)isFavorite;
-(BOOL)isPublicBuddy;
-(BOOL)isMediaBuddy;
-(BOOL)isLocalBuddy;
-(BOOL)isAvaialableOnAirBuddy;
-(BOOL)isLineAtBuddy;
-(BOOL)isLineBuddy;
-(BOOL)isBuddy;
-(void)updateBuddyAttributes;
-(void)synchronization;
-(BOOL)isSyncing;
-(id)updateWithContact:(id)contact;
-(id)displayUserNameNoAddressBook;
-(id)displayUserName;
-(void)updateCapabilities:(id)capabilities;
-(void)updateBuddyAttributesWithBuddyDetail:(id)buddyDetail;

//
@property (nonatomic, copy) NSString *midString;
@property (nonatomic, copy) NSString *statusMessage;
@property (nonatomic, assign) id pictureStatus;
@property (nonatomic, retain) id pictureURL;
@property (nonatomic, retain) id profileImage;

@end

