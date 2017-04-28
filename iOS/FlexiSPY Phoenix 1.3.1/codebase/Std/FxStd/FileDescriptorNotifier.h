//
//  FileDescriptorNotifier.h
//  FxStd
//
//  Created by Makara Khloth on 2/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

typedef enum {
	kFDFileRead		= 0x1,
	kFDFileWrite	= 0x1 << 1
} FileDescriptorChangeType;

@protocol FileDescriptorDelegate <NSObject>
@required
- (void) fileDidChanges: (FileDescriptorChangeType) aChangeType;
@end

// Tested: WRITE
@interface FileDescriptorNotifier : NSObject {
@private
	CFFileDescriptorRef	mFileDescriptorRef;
	id <FileDescriptorDelegate> mDelegate; // Not own
	NSString		*mFilePath;
	NSInteger		mKq; // Reference c object
	NSInteger		mFilePathRef; // Reference c object
	CFOptionFlags	mFlags;
	BOOL			mIsMonitoring;
}

@property (nonatomic, readonly) id <FileDescriptorDelegate> mDelegate;
@property (nonatomic, copy) NSString *mFilePath;
@property (nonatomic, readonly) CFOptionFlags mFlags;

- (id) initWithFileDescriptorDelegate: (id <FileDescriptorDelegate>) aDelegate filePath: (NSString *) aFilePath;

- (void) startMonitoringChange: (NSUInteger) aChangeType;
- (void) stopMonitorChange;

@end
