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
@interface RemoteCmdDataDAO : NSObject {
@private
	FMDatabase*	mDatabase;
}
@property (nonatomic,retain) FMDatabase *mDatabase;

- (id) initWithDatabase: (FMDatabase*) aDatabase; 
- (BOOL) insert: (RemoteCmdData*) aRemoteCmdData;
- (BOOL) update: (RemoteCmdData*) aRemoteCmdData;
- (BOOL) remove: (NSUInteger) aRemoteCmdData;
- (NSMutableArray*) selectAll;
- (NSUInteger) count;
@end
