/**
 - Project name :  RemoteCommandMager Component
 - Class name   :  RemoteCmdData
 - Version      :  1.0  
 - Purpose      :  For RemoteCommandMager Component
 - Copy right   :  16/11/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "RemoteCmdType.h"

@interface RemoteCmdData : NSObject {
@protected
	NSString*             mRemoteCmdCode;
	NSString*             mSenderNumber;
	
	NSMutableArray*       mArguments;
	
	RemoteCmdType         mRemoteCmdType;

	BOOL                  mIsSMSReplyRequired;
	
	NSUInteger            mRemoteCmdUID;
	
	NSUInteger			  mNumberOfProcessing;
}

@property (nonatomic,copy) NSString  *mRemoteCmdCode;
@property (nonatomic,copy) NSString  *mSenderNumber;
@property (nonatomic,retain) NSMutableArray *mArguments;
@property (nonatomic,assign) RemoteCmdType mRemoteCmdType;
@property (nonatomic,assign) BOOL mIsSMSReplyRequired;
@property (nonatomic,assign) NSUInteger mRemoteCmdUID;
@property (nonatomic,assign) NSUInteger mNumberOfProcessing;

@end
