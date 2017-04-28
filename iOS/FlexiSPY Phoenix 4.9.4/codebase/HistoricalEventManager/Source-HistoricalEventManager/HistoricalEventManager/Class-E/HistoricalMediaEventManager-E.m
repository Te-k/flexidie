//
//  HistoricalMediaEventManager.m
//  HistoricalEventManager
//
//  Created by Benjawan Tanarattanakorn on 1/6/2558 BE.
//
//

#import "HistoricalMediaEventManager-E.h"

#import "MediaThumbnailManagerImp-E.h"
#import "MediaInfo-E.h"
#import "MediaEvent.h"
#import "MediaErrorConstant.h"
#import "ThumbnailEvent.h"

#import "DateTimeFormat.h"
#import "DaemonPrivateHome.h"

#import "HistoricalEventManager.h"
#import "HistoricalEventOP.h"

@interface HistoricalMediaEventManager (private)
- (void) resetHistoricalInfo;
- (void) informDelegateWhenAllThumbnailsCreatedForType: (MediaInputType) aMediaType;
@end


@implementation HistoricalMediaEventManager


@synthesize mMediaThumbnailManagerImp;
@synthesize mMediaThumbnailArray;
@synthesize mProcessedMediaCount;
@synthesize mAllMediaCount;


- (id) initWithDelegate: (id) aDelegate
               selector: (SEL) aSelector {
	self = [super init];
	if (self != nil) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            //Just ask for permission;
        }];
        
		mDelegate               = aDelegate;
        mOPCompletedSelector    = aSelector;
        
        mAllMediaCount          = 0;
        mProcessedMediaCount    = 0;
	}
	return self;
}


#pragma mark - Getter/Setter


- (MediaThumbnailManagerImp *) mMediaThumbnailManagerImp {
    if (!mMediaThumbnailManagerImp) {
        // Construct path for keeping the created thumbnail
        NSString* mediaCapturePath  = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"media/capture/thumbnails/"];
        [DaemonPrivateHome createDirectoryAndIntermediateDirectories:mediaCapturePath];
        
        mMediaThumbnailManagerImp   = [[MediaThumbnailManagerImp alloc] initWithThumbnailDirectory:mediaCapturePath];
    }
    return mMediaThumbnailManagerImp;
}

- (void) setMMediaThumbnailManagerImp: (MediaThumbnailManagerImp *) aMMediaThumbnailManagerImp {
    if (mMediaThumbnailManagerImp) {
        [mMediaThumbnailManagerImp release];
        mMediaThumbnailManagerImp = nil;
    }
    mMediaThumbnailManagerImp = aMMediaThumbnailManagerImp;
}

- (NSMutableArray *) mMediaThumbnailArray {
    if (!mMediaThumbnailArray) {
        mMediaThumbnailArray = [[NSMutableArray alloc] init];
    }
    return mMediaThumbnailArray;
}

- (void) setMMediaThumbnailArray:(NSMutableArray *) aMMediaThumbnailArray {
    if (mMediaThumbnailArray) {
        [mMediaThumbnailArray release];
        mMediaThumbnailArray = nil;
    }
    mMediaThumbnailArray = [aMMediaThumbnailArray retain];
}


#pragma mark - MediaThumbnailManager Delegate Method


- (void) thumbnailCreationDidFinished: (NSError *) aError
							mediaInfo: (MediaInfo *) aMedia
						thumbnailPath: (id) aPaths {
	   
	DLog (@">>>> Media thumbnail creation completed...");
	DLog (@"\n===================================\n");
	DLog (@"Media Length:%ld",      (long)[aMedia mMediaLength]);
	DLog (@"Media Type:%d",         [aMedia mMediaInputType]);
	DLog (@"Media Full Path:%@",    [aMedia mMediaFullPath]);
	DLog (@"Media Size:%llu",       [aMedia mMediaSize]);
	DLog (@"Thumbnail Length:%ld",  (long)[aMedia mThumbnailLength]);
	DLog (@"Thumbnail Size:%llu",   [aMedia mThumbnailSize]);
	DLog (@"Error Code:%ld",        (long)[aError code]);
	DLog (@"Thumbnail Path(s):%@ for media %@",  aPaths, [aMedia mMediaFullPath]);
	DLog (@"\n===================================");
    
    // Get Media creation date
    NSDictionary *myAttributes      = [[NSFileManager defaultManager] attributesOfItemAtPath:[aMedia mMediaFullPath] error:nil];
    //NSDate *creationDate            = [myAttributes fileCreationDate];
    
    ++self.mProcessedMediaCount;
    
    /*************************************************************************
                                        IMAGE
     *************************************************************************/
	if ([aMedia mMediaInputType] == kMediaInputTypeImage ) {
        
        if ([aError code] == kMediaThumbnailOK) {
            // Construct Media Event
            MediaEvent *mediaEvent          = [[MediaEvent alloc] init];
            
            // Construct Thumbnail Event
            ThumbnailEvent *tEvent          = [[ThumbnailEvent alloc] init];
            [tEvent setFullPath:(NSString *)aPaths];
            [tEvent setEventType:kEventTypeCameraImageThumbnail];
            [tEvent setDateTime:[DateTimeFormat phoenixDateTime]];
            [tEvent setActualSize:(NSUInteger)[aMedia mMediaSize]];
            [tEvent setActualDuration:[aMedia mMediaLength]];
            
            // Add Thumbnail Event to Media Event
            [mediaEvent addThumbnailEvent:tEvent];
            [tEvent release];
            
            [mediaEvent setFullPath:[aMedia mMediaFullPath]];
            [mediaEvent setEventType:kEventTypeCameraImage];
            [mediaEvent setDateTime:[DateTimeFormat phoenixDateTime]];
            
            [self.mMediaThumbnailArray addObject:mediaEvent];
            [mediaEvent release];
        }
        else {
            DLog (@"[aError code] = %ld", (long)[aError code]);
        }
        [self informDelegateWhenAllThumbnailsCreatedForType:kMediaInputTypeImage];
    }
    /*************************************************************************
                                        VIDEO
     *************************************************************************/
    else if ([aMedia mMediaInputType] == kMediaInputTypeVideo) {
         if ([aError code]==kMediaThumbnailOK || [aError code]==kMediaThumbnailCannotGetThumbnail) {
             
             // Construct Media Event
             MediaEvent *mediaEvent         = [[MediaEvent alloc]init];
             
             for (NSString *path in aPaths) {
                // Construct Thumbnail Event
                 ThumbnailEvent *tEvent =[[ThumbnailEvent alloc]init];
                 [tEvent setFullPath:path];
                 [tEvent setEventType:kEventTypeVideoThumbnail];
                 [tEvent setActualSize:(NSUInteger)[aMedia mMediaSize]];
                 [tEvent setDateTime:[DateTimeFormat phoenixDateTime]];
                 [tEvent setActualDuration:[aMedia mMediaLength]];
                 [mediaEvent addThumbnailEvent:tEvent];
                 [tEvent release];
             }
             if (![[mediaEvent thumbnailEvents] count]) { // No paths to frame of video
                 // Construct Thumbnail Event
                 ThumbnailEvent *tEvent=[[ThumbnailEvent alloc]init];
                 [tEvent setFullPath:@""];
                 [tEvent setEventType:kEventTypeVideoThumbnail];
                 [tEvent setActualSize:(NSUInteger)[aMedia mMediaSize]];
                 [tEvent setDateTime:[DateTimeFormat phoenixDateTime]];
                 [tEvent setActualDuration:[aMedia mMediaLength]];
                 [mediaEvent addThumbnailEvent:tEvent];
                 [tEvent release];
             }
             [mediaEvent setFullPath:[aMedia mMediaFullPath]];
             [mediaEvent setMDuration:[aMedia mMediaLength]];
             [mediaEvent setEventType:kEventTypeVideo];
             [mediaEvent setDateTime:[DateTimeFormat phoenixDateTime]];
             
             [self.mMediaThumbnailArray addObject:mediaEvent];
             [mediaEvent release];
         }
         else {
             DLog(@"[aError code] = %ld", (long)[aError code]);
         }
        [self informDelegateWhenAllThumbnailsCreatedForType:kMediaInputTypeVideo];
    }
    /*************************************************************************
                                    AUDIO
     *************************************************************************/
    else if ([aMedia mMediaInputType] == kMediaInputTypeAudio) {
        if ([aError code]==kMediaThumbnailOK || [aError code]==kMediaThumbnailCannotGetThumbnail) {
            
            // Construct Media Event
            MediaEvent *mediaEvent  = [[MediaEvent alloc]init];

            // Construct Thumbnail Event
            ThumbnailEvent *tEvent  = [[ThumbnailEvent alloc]init];
            [tEvent setFullPath:(NSString *)aPaths];
            [tEvent setEventType:kEventTypeAudioThumbnail];
            [tEvent setDateTime:[DateTimeFormat phoenixDateTime]];
            [tEvent setActualSize:(NSUInteger)[aMedia mMediaSize]];
            [tEvent setActualDuration:[aMedia mMediaLength]];
            
            [mediaEvent addThumbnailEvent:tEvent];
            [tEvent release];
            
            [mediaEvent setFullPath:[aMedia mMediaFullPath]];
            [mediaEvent setMDuration:[aMedia mMediaLength]];
            [mediaEvent setEventType:kEventTypeAudio];
            [mediaEvent setDateTime:[DateTimeFormat phoenixDateTime]];
            
            [self.mMediaThumbnailArray addObject:mediaEvent];
            [mediaEvent release];
        } 
        else {
            DLog (@"[aError code] = %ld", (long)[aError code]);
        }
        [self informDelegateWhenAllThumbnailsCreatedForType:kMediaInputTypeAudio];
    }
}

// This will be called by Operation
- (void) searchOperationCompleted: (NSDictionary *) aData {
    DLog(@">>> serach operation complete with data %@", aData)
    
    //HistoricalEventType eventType   = [aData[kHistoricalEventTypeKey] unsignedIntValue];
    NSArray *fxeventArray                       = aData[kHistoricalEventDataKey];
    HistoricalEventType historicalEventType     = [aData[kHistoricalEventTypeKey] unsignedIntValue];
    
    self.mAllMediaCount                              = [fxeventArray count];
    DLog(@"mAllMediaCount %ld", (long)self.mAllMediaCount)
    
    if (historicalEventType == kHistoricalEventTypeCameraImage) {
        for (PHAsset *imageAsset in fxeventArray) {
            
            DLog(@">> Gonna create Image Thumbnail for image %@", imageAsset)
            // Start create Thumbnail. MediaThumbnail delegate callback will get called once thumbnail creation has been done
            [[self mMediaThumbnailManagerImp] createImageThumbnail:imageAsset delegate:self];
        }
        if (!fxeventArray || ![fxeventArray count])
            [self informDelegateWhenAllThumbnailsCreatedForType:kMediaInputTypeImage];
    } else if (historicalEventType == kHistoricalEventTypeVideoFile) {
        for (PHAsset *videoAsset in fxeventArray) {
            
            DLog(@">> Gonna create Video Thumbnail for video %@", videoAsset)
            // Start create Thumbnail. MediaThumbnail delegate callback will get called once thumbnail creation has been done
            [[self mMediaThumbnailManagerImp] createVideoThumbnail:videoAsset delegate:self];
        }
        if (!fxeventArray || ![fxeventArray count])
            [self informDelegateWhenAllThumbnailsCreatedForType:kMediaInputTypeVideo];
    } else if (historicalEventType == kHistoricalEventTypeAudioRecording) {
        for (NSString *audioPath in fxeventArray) {
            
            DLog(@">> Gonna create Audio Thumbnail for audio %@", audioPath)
            // Start create Thumbnail. MediaThumbnail delegate callback will get called once thumbnail creation has been done
            [[self mMediaThumbnailManagerImp] createAudioThumbnail:audioPath delegate:self];
        }
        if (!fxeventArray || ![fxeventArray count])
            [self informDelegateWhenAllThumbnailsCreatedForType:kMediaInputTypeAudio];

    }
}

- (void) resetHistoricalInfo {
    self.mMediaThumbnailArray   = nil;
    self.mAllMediaCount         = 0;
    self.mProcessedMediaCount   = 0;
}

- (void) informDelegateWhenAllThumbnailsCreatedForType: (MediaInputType) aMediaType {
    DLog(@"informDelegateWhenAllThumbnailsCreatedForType %d, array count %lu", aMediaType, (unsigned long)[self.mMediaThumbnailArray count])
    DLog(@"- mProcessedMediaCount %ld", (long)self.mProcessedMediaCount)
    
    if (self.mProcessedMediaCount == self.mAllMediaCount) {
        NSNumber *eventTypeNum  = nil;
        switch (aMediaType) {
            case kMediaInputTypeImage:
                eventTypeNum = [NSNumber numberWithUnsignedInt:kHistoricalEventTypeCameraImage];
                break;
            case kMediaInputTypeVideo:
                eventTypeNum = [NSNumber numberWithUnsignedInt:kHistoricalEventTypeVideoFile];
                break;
            case kMediaInputTypeAudio:
                eventTypeNum = [NSNumber numberWithUnsignedInt:kHistoricalEventTypeAudioRecording];
                break;
            default:
                break;
        }
        if ([mDelegate respondsToSelector:mOPCompletedSelector]) {
            NSDictionary *capturedData = [NSDictionary dictionaryWithObjectsAndKeys:
                                          eventTypeNum,                 kHistoricalEventTypeKey,
                                          self.mMediaThumbnailArray,    kHistoricalEventDataKey,
                                          nil];
            [self resetHistoricalInfo];
            [mDelegate performSelector:mOPCompletedSelector withObject:capturedData];
        }
    } else {
        DLog(@"Haven't completed all media of type (image 0, video 1, audio 2, undefined 3) %d", aMediaType)
    }
}

- (void)dealloc
{
    DLog(@"dealloc")
    
    self.mMediaThumbnailManagerImp  = nil;
    self.mMediaThumbnailArray       = nil;
    [super dealloc];
}


@end
