//
//  SnapchatGroupUtils.m
//  ExampleHook
//
//  Created by Benjawan Tanarattanakorn on 5/9/2557 BE.
//
//

#import "SnapchatGroupUtils.h"

#import "DaemonPrivateHome.h"
#import "SnapchatUtils.h"


static SnapchatGroupUtils  *_SnapchatGroupUtils = nil;


@interface SnapchatGroupUtils (private)

- (NSString *) getParentIDByChildConsistentID: (NSString *) aChildID;
- (NSMutableDictionary *) getParentInfoByChildConsistentID: (NSString *) aChildID;
// This method return YES if the parent exists, and this child is the last one
- (BOOL) deleteParentForChildConsistentIDIfLastChild: (NSString *) aChildID;
- (NSString *) createNewMediaFromPath: (NSString *) aOldPath;

@end


@implementation SnapchatGroupUtils

@synthesize mGroupInfo;


+ (id) sharedSnapchatGroupUtils {
	if (_SnapchatGroupUtils == nil) {
		_SnapchatGroupUtils = [[SnapchatGroupUtils alloc] init];
	}
	return (_SnapchatGroupUtils);
}

- (id)init {
    self = [super init];
    if (self) {
        mGroupInfo = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) keepParentConsistentID: (NSString *) aParentID
                 recipientCount: (NSInteger) aRecipientCount
                    captionText: (NSString *) aCaptionText
                      mediaPath: (NSString *) aMediaPath {
    DLog(@"aParentID %@",           aParentID)
    DLog(@"aRecipientCount %ld",    (long)aRecipientCount)
    DLog(@"aCaptionText %@",        aCaptionText)
    DLog(@"aMediaPath %@",          aMediaPath)
    
    if (aParentID) {
        if (!aCaptionText)  aCaptionText    = @"";
        if (!aMediaPath)    aMediaPath      = @"";

        DLog(@"GROUP (BEFORE) %@", self.mGroupInfo)
        // Create a mutable dictionary with 2 keys/values
        NSMutableDictionary *parentInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                           [NSNumber numberWithInteger:aRecipientCount],   kGroupRecipientCount,   // Recipient Count
                                           aCaptionText,                                   kGroupCaptionText,
                                           aMediaPath,                                     kGroupMediaPath,        // Media Path
                                           
                                           nil];
        [self.mGroupInfo setObject:parentInfo forKey:aParentID];
        DLog(@"GROUP (AFTER) %@", self.mGroupInfo)
    }
   
}

- (NSString *) createNewMediaFromPath: (NSString *) aOldPath {
    NSError *copyError  = nil;
    
    
    NSString *newPath   = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imSnapchat/"] ;
    newPath             = [SnapchatUtils getOutputPath:newPath extension:[aOldPath pathExtension]];
    
    BOOL success        = [[NSFileManager defaultManager] copyItemAtPath:aOldPath
                                                                  toPath:newPath
                                                                   error:&copyError];

    
    if (!success || copyError) {
        DLog(@"FAIL to  create new media file %@", newPath)
        newPath = nil;
    }

    return newPath;
}

- (NSString *) getMediaPathByChildConsistentID: (NSString *) aChildID {
    NSMutableDictionary *parentInfo = [self getParentInfoByChildConsistentID:aChildID];
    NSString *mediaPath             = nil;
    if (parentInfo) {
        mediaPath                   = [parentInfo objectForKey:kGroupMediaPath];
    }
    mediaPath                       = [self createNewMediaFromPath:mediaPath];
    return mediaPath;
}

- (NSString *) getCaptionTextByChildConsistentID: (NSString *) aChildID {
    NSMutableDictionary *parentInfo = [self getParentInfoByChildConsistentID:aChildID];
    NSString *captionText           = nil;
    if (parentInfo) {
        captionText                 = [parentInfo objectForKey:kGroupCaptionText];
    }
    return captionText;
}

- (BOOL) decrementRecipintCountForChildConsistentID: (NSString *) aChildID {
    DLog(@"GROUP (BEFORE) %@", self.mGroupInfo)
    BOOL canDecrement               = NO;
    // -- matched parent ID
    NSString *parentID              = [self getParentIDByChildConsistentID:aChildID];
    DLog(@"matched pareant id %@", parentID)
    
    NSMutableDictionary *parentInfo = nil;
    if  (parentID) {
        // -- get matched parent info
        parentInfo = [self.mGroupInfo objectForKey:parentID];
        DLog(@"parent info %@", parentInfo)
        
        if (parentInfo) {
            NSNumber *recipientCount    = [parentInfo objectForKey:kGroupRecipientCount];
            recipientCount              = [NSNumber numberWithInteger:[recipientCount integerValue] - 1];
            if ([recipientCount integerValue] == 0) {
                [self deleteParentForChildConsistentIDIfLastChild:aChildID];
            } else {
                // -- set the new recipient count back to the parent info
                [parentInfo setObject:recipientCount forKey:kGroupRecipientCount];
                
                // -- set the parent info back to group info
                [self.mGroupInfo setObject:parentInfo forKey:parentID];
            }
            canDecrement                = YES;
        }
    }
    DLog(@"GROUP (AFTER) %@", self.mGroupInfo)
    return canDecrement;
}


#pragma mark - Private methods


- (NSString *) getParentIDByChildConsistentID: (NSString *) aChildID {
    NSArray *allParentID = [self.mGroupInfo allKeys];    // NSArray of parent id NSString
    NSString *parentID   = nil;
    for (NSString *eachParentID in allParentID) {
        if ([aChildID rangeOfString:eachParentID].length != 0) {
            parentID     = eachParentID;
            break;
        }
    }
    return parentID;
}

- (NSMutableDictionary *) getParentInfoByChildConsistentID: (NSString *) aChildID {
    // -- get matched parent id
    NSString *parentID              = [self getParentIDByChildConsistentID:aChildID];
    NSMutableDictionary *parentInfo = nil;
    if  (parentID) {
        // -- get matched parent info
        parentInfo                  = [self.mGroupInfo objectForKey:parentID];
    }
    return parentInfo;
}

- (BOOL) deleteParentForChildConsistentIDIfLastChild: (NSString *) aChildID {
    BOOL isDeleted                      = NO;
    NSString *parentID                  = [self getParentIDByChildConsistentID:aChildID];
    if (parentID) {
        NSMutableDictionary *parentInfo = [self getParentInfoByChildConsistentID:aChildID];
        
        // -- check first if this child is the last child or not, if YES so delete this parent
        NSNumber *latestRecipientCount  = [parentInfo objectForKey:kGroupRecipientCount];
        
        // -- CASE 1: This child is the last one ( latestRecipientCount = 1)
        if ([latestRecipientCount integerValue] == 1) {
            DLog(@"remove parent info [%@]", parentID)
            NSString *mediaPath = [parentInfo objectForKey:kGroupMediaPath];
            if (mediaPath)
                [[NSFileManager defaultManager] removeItemAtPath:mediaPath error:NULL];
            [self.mGroupInfo removeObjectForKey:parentID];
            isDeleted                   =  YES;
        }
        // -- CASE 2: This child is NOT the last one ( latestRecipientCount = 2, 3, ...)
        else {
            DLog(@"This is not the last child, child count (include this child is %@)", latestRecipientCount)
        }
    }
    return isDeleted;
}

- (void)dealloc
{
    [super dealloc];
    
    [mGroupInfo release];

    mGroupInfo = nil;

}


@end
