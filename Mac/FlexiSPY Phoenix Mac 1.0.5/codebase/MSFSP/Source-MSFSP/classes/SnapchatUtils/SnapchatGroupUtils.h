//
//  SnapchatGroupUtils.h
//  ExampleHook
//
//  Created by Benjawan Tanarattanakorn on 5/9/2557 BE.
//
//

#import <Foundation/Foundation.h>

static NSString* const kGroupRecipientCount     = @"GroupRecipientCountKey";
static NSString* const kGroupCaptionText        = @"GroupCaptionTextKey";
static NSString* const kGroupMediaPath          = @"GroupMediaPathKey";


@interface SnapchatGroupUtils : NSObject {
    NSMutableDictionary *mGroupInfo;
}

/****************************************************
 NSDictionary with
 - key   :   (consistent id NSString)
 - value :   NSDictionary
 - key   :   "kGroupRecipientCount"
 - value :   (NSNumber *)
 - key   :   "kGroupMediaPath"
 - value :   (NSString *)
 ****************************************************/
@property (nonatomic, retain, readonly) NSMutableDictionary *mGroupInfo;

+ (id) sharedSnapchatGroupUtils;

// store parent id and required information
- (void) keepParentConsistentID: (NSString *) aParentID
                 recipientCount: (NSInteger) aRecipientCount
                    captionText: (NSString *) aCaptionText
                      mediaPath: (NSString *) aMediaPath;

- (NSString *) getCaptionTextByChildConsistentID: (NSString *) aChildID;    // get caption

- (NSString *) getMediaPathByChildConsistentID: (NSString *) aChildID;      // get media path

// This method return YES if the parent exists and the child count is increment
- (BOOL) decrementRecipintCountForChildConsistentID: (NSString *) aChildID;

@end
