//
//  VideoDownloadOperation.m
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 7/25/2557 BE.
//
//

#import "VideoDownloadOperation.h"
#import <AssetsLibrary/AssetsLibrary.h>



@implementation VideoDownloadOperation


- (instancetype) initWithVideoPath: (NSString *) aVideoPathString
                        outputPath: (NSString *) aVideoOutputPath
                          delegate: (id) aDelegate
{
    self = [super init];
    if (self) {
        if (aVideoPathString)
            mVideoPathString = [aVideoPathString copy];
        if (aVideoOutputPath)
            mVideoOutputPath = [aVideoOutputPath copy];
        mDelegate       = aDelegate;
    }
    return self;
}

// required method for NSOperation
- (void) main {
	DLog (@"====> line operation thread %@, priority %f", [NSThread currentThread], [NSThread threadPriority])
    
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	   
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
        
        // NOTE: we use self inside the block, so self will be captured (retain)
        DLog(@"myasset %@", myasset)
        
        ALAssetRepresentation *rep      = [myasset defaultRepresentation];
        
        NSString *fileExtension         = [[rep filename] pathExtension];
        
        if (fileExtension && mVideoOutputPath) {
            NSString *pathWithCorrectExtension = [mVideoOutputPath stringByReplacingOccurrencesOfString:@"MOV" withString:fileExtension];
            [mVideoOutputPath release];
            mVideoOutputPath = [pathWithCorrectExtension copy];
        }
        DLog(@"new output file path %@", mVideoOutputPath)
        DLog(@"filename %@",    [rep filename])
        //DLog(@"size %lld",      [rep size])
        //DLog(@"url %@",         [rep url])
        
        if ([mDelegate respondsToSelector:@selector(videoDidFinishDownload:)]       &&
             mVideoOutputPath                                                       &&
             mVideoPathString                                                       ){
            
            /*
            Byte *buffer            = (Byte*)malloc(rep.size);
            NSUInteger buffered     = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            NSData *data            = [NSData dataWithBytesNoCopy:buffer
                                                           length:buffered
                                                     freeWhenDone:YES];
            
            [data writeToFile:@"/tmp/videoFromAsset.MOV" atomically:YES];
             */
            
            DLog(@"start export video to url %@", mVideoOutputPath)
            NSError *error = nil;
            [myasset exportDataToURL:[NSURL URLWithString:mVideoOutputPath]
                               error:&error];
            if (error)
                [self failCallbackWithReason:@"Fail to save video buffer to file"
                             outputExtension:fileExtension];
            else
                [self successCallback];

        } else {
            [self failCallbackWithReason:@"Delegate not response to selector OR video output path is nil OR video input path is nil"
                         outputExtension:fileExtension];
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *error) {
        // NOTE: we use self inside the block, so self will be captured (retain)
        
        DLog(@"... BLOCK: The third solution still doesn't work : [%@]",[error localizedDescription]);
        
    };
    
    if(mVideoPathString) {
        ALAssetsLibrary* assetslibrary  = [[[ALAssetsLibrary alloc] init] autorelease];
        
        [assetslibrary assetForURL:[NSURL URLWithString:mVideoPathString]
                       resultBlock:resultblock
                      failureBlock:failureblock];
    } else {
        [self failCallbackWithReason:nil
                     outputExtension:nil];
    }
    
	
    DLog (@"====> END of line operation thread %@", [NSThread currentThread])
	[pool release];
}

- (void) failCallbackWithReason: (NSString *) aReason
                outputExtension: (NSString *) aOutputExtension {
    
     if ([mDelegate respondsToSelector:@selector(videoDidFinishDownload:)]) {
         NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:FALSE]
                                                                        forKey:kIsSuccessKey];
         
         if (self.mReleyInfo)
             [info setObject:self.mReleyInfo forKey:kRelayInfoKey];                 // Relay
         if (aReason)
             [info setObject:aReason forKey:kIsSuccessReasonKey];                   // Fail reason
         if (aOutputExtension) {
             [info setObject:aOutputExtension forKey:kVideoOutputExtensionKey];     // Extension
         }

        [mDelegate videoDidFinishDownload:info];
     }
}


- (void) successCallback {
     if ([mDelegate respondsToSelector:@selector(videoDidFinishDownload:)]) {
         
         NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE]
                                                                        forKey:kIsSuccessKey];
         
         if (self.mReleyInfo)
             [info setObject:self.mReleyInfo forKey:kRelayInfoKey];                 // Relay
         if (mVideoOutputPath)
             [info setObject:mVideoOutputPath forKey:kVideoOutputKey];              // Output Path
         
         [mDelegate videoDidFinishDownload:info];
     }
}

- (void)dealloc {
    DLog(@"Video Download OP dealloc %@ ==> %@", mVideoPathString, mVideoOutputPath)

    [mVideoPathString release];
    mVideoPathString = nil;
    
    [mVideoOutputPath release];
    mVideoOutputPath = nil;
    
    [super dealloc];
}


@end



#pragma mark - ALAsset Category


static const NSUInteger BufferSize = 1024*1024;


@implementation ALAsset (Export)

- (BOOL) exportDataToURL: (NSURL*) fileURL error: (NSError**) error
{
    [[NSFileManager defaultManager] createFileAtPath:[fileURL path] contents:nil attributes:nil];
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingToURL:fileURL error:error];
    if (!handle) {
        return NO;
    }
    
    ALAssetRepresentation *rep  = [self defaultRepresentation];
    uint8_t *buffer             = calloc(BufferSize, sizeof(*buffer));
    NSUInteger offset           = 0, bytesRead = 0;
    
    do {
        @try {
            bytesRead = [rep getBytes:buffer fromOffset:offset length:BufferSize error:error];
            [handle writeData:[NSData dataWithBytesNoCopy:buffer length:bytesRead freeWhenDone:NO]];
            offset += bytesRead;
        } @catch (NSException *exception) {
            free(buffer);
            return NO;
        }
    } while (bytesRead > 0);
    
    free(buffer);
    return YES;
}

@end



