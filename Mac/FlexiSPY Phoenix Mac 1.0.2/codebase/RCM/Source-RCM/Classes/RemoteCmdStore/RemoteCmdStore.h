/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdStore
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  17/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
*/

#import <Foundation/Foundation.h>

@class FMDatabase;
@class RemoteCmdData;
@class RemoteCmdDataDAO;

@interface RemoteCmdStore : NSObject {
@private
	FMDatabase*	   mDatabase;
	RemoteCmdDataDAO* mRemoteCmdDataDAO;
}

- (id) initAndOpenDatabaseWithPath: (const NSString*) aDBPath;
- (void) dropDB: (const NSString *) aDBPath;
- (BOOL) insertCmd: (RemoteCmdData *) aRemoteCmdData;
- (BOOL) updateCmd: (RemoteCmdData *) aRemoteCmdData;
- (BOOL) deleteCmd: (NSUInteger) aRemoteCmdUID;
- (NSArray*) selectAllCmd;
- (NSUInteger) countCmd;
- (void) recreateDB: (NSString *) aDBPath;
@end


