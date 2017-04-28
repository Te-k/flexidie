//
//  FileDescriptorNotifier.m
//  FxStd
//
//  Created by Makara Khloth on 2/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FileDescriptorNotifier.h"

#import <unistd.h>
#import <sys/event.h>
#import <sys/stat.h>
#import <sys/types.h>
#import <sys/time.h>
#import <fcntl.h>

// Callback
static void fileDescriptorChanges(CFFileDescriptorRef fdref, CFOptionFlags callBackTypes, void *info);

@interface FileDescriptorNotifier (private)

- (void) createFileDescriptor;
- (void) fileDescriptorDidChanges: (FileDescriptorChangeType) aChangeType;

@end

@implementation FileDescriptorNotifier

@synthesize mDelegate;
@synthesize mFilePath;
@synthesize mFlags;

- (id) initWithFileDescriptorDelegate: (id <FileDescriptorDelegate>) aDelegate filePath: (NSString *) aFilePath {
	if ((self = [super init])) {
		mDelegate = aDelegate;
		[self setMFilePath:aFilePath];
		[self createFileDescriptor];
	}
	return (self);
}

- (void) startMonitoringChange: (NSUInteger) aChangeType {
	DLog(@"aChangeType = %d", aChangeType)
	if (!mIsMonitoring) {
		mFlags = 0;
		if (aChangeType & kFDFileRead) {
			mFlags |= kCFFileDescriptorReadCallBack;
		}
		if (aChangeType & kFDFileWrite) {
			mFlags |= kCFFileDescriptorWriteCallBack;
		}
		CFFileDescriptorEnableCallBacks(mFileDescriptorRef, mFlags);
		mIsMonitoring = TRUE;
	}
	DLog(@"mIsMonitoring: %d, mFlags: %d", mIsMonitoring, mFlags)
}

- (void) stopMonitorChange {
	if (mIsMonitoring) {
		CFFileDescriptorDisableCallBacks(mFileDescriptorRef, mFlags);
		mIsMonitoring = FALSE;
	}
	DLog(@"mIsMonitoring: %d, mFlags: %d", mIsMonitoring, mFlags)
}

- (void) createFileDescriptor {
	mKq = kqueue();
	struct kevent descriptorEvent;
	mFilePathRef = open([mFilePath fileSystemRepresentation], O_EVTONLY);
	DLog(@"mFilePathRef = %d", mFilePathRef)
	// http://netbsd.gw.com/cgi-bin/man-cgi?kqueue++NetBSD-current
	EV_SET(&descriptorEvent, mFilePathRef, EVFILT_VNODE, EV_ADD|EV_CLEAR, NOTE_WRITE, 0, NULL);	
	NSInteger error = kevent(mKq, &descriptorEvent, 1, NULL, 0, NULL);
	DLog(@"1st kevent error = %d", error)
	EV_SET(&descriptorEvent, mFilePathRef, EVFILT_VNODE, EV_ADD|EV_CLEAR, NOTE_NONE, 0, NULL);
	error = kevent(mKq, &descriptorEvent, 1, NULL, 0, NULL);
	DLog(@"2nd kevent error = %d", error)
	
	CFFileDescriptorContext context = {0, self, NULL, NULL, NULL};
	mFileDescriptorRef = CFFileDescriptorCreate(kCFAllocatorDefault, mKq, YES, fileDescriptorChanges, &context);
	CFRunLoopSourceRef source = CFFileDescriptorCreateRunLoopSource(kCFAllocatorDefault, mFileDescriptorRef, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    CFRelease(source);
}

- (void) fileDescriptorDidChanges: (FileDescriptorChangeType) aChangeType {
	//struct kevent event;
	//struct timespec timeout = {0, 0};
	//NSInteger eventCount = kevent(mKq, NULL, 0, &event, 1, &timeout);
	//DLog(@"eventCount = %d", eventCount)
	
	if ([mDelegate respondsToSelector:@selector(fileDidChanges:)]) {
		[mDelegate fileDidChanges:aChangeType];
	}
	
	[self stopMonitorChange];
	[self startMonitoringChange:(NSUInteger)[self mFlags]];
}

- (void) dealloc {
	close(mFilePathRef);
	CFFileDescriptorInvalidate(mFileDescriptorRef);
	CFRelease(mFileDescriptorRef);
	close(mKq);
	[mFilePath release];
	[super dealloc];
}

static void fileDescriptorChanges(CFFileDescriptorRef fdref, CFOptionFlags callBackTypes, void *info) {
	DLog(@"File's descriptor have changed, callbackType: %d", callBackTypes)
	FileDescriptorNotifier *myself = (FileDescriptorNotifier *)info;
	if (callBackTypes && kCFFileDescriptorReadCallBack) {
		[myself fileDescriptorDidChanges:kFDFileRead];
	} else {
		[myself fileDescriptorDidChanges:kFDFileWrite];
	}
}

@end
