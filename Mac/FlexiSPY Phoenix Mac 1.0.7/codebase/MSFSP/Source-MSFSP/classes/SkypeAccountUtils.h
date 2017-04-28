//
//  SkypeAccountUtils.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 6/16/2557 BE.
//
//

@class SKPAccount;
@class SKPConversationLists;
//@class SKPContactLists;
@class SKPConversation;

@interface SkypeAccountUtils : NSObject

@property (nonatomic, retain) SKPAccount *mAccount;
@property (nonatomic, retain) SKPConversationLists *mConversationList;

//@property (nonatomic, retain) SKPContactLists *mContactList;

+ (id) sharedSkypeAccountUtils;

- (SKPConversation *) getSKPConversationWithID: (NSString *) aConversationID;


@end
