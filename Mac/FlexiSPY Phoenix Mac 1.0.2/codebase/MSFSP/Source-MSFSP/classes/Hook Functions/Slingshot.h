//
//  Slingshot.h
//  MSFSP
//
//  Created by Makara on 7/3/14.
//
//

#import <Foundation/Foundation.h>

#import "MSFSP.h"
#import "SlingshotUtils.h"

#import "SHSendShotOperation.h"
#import "SHShot.h"
#import "SHNetworkController.h"
#import "PFUser.h"
#import "SHDataService.h"
#import "SHShotDataCache.h"

void logShot(SHShot *shot) {
    DLog(@"image                    = %@", [shot image]);
    DLog(@"locationText             = %@", [shot locationText]);
    DLog(@"localMediaFileURL        = %@", [shot localMediaFileURL]);
    DLog(@"localMediaHighQualityFileURL = %@", [shot localMediaHighQualityFileURL]);
    DLog(@"isReply                  = %d", [shot isReply]);
    DLog(@"locked                   = %d", [shot locked]);
    DLog(@"direct                   = %d", [shot direct]);
    DLog(@"captionYPosition         = %f", [shot captionYPosition]);
    DLog(@"isNUX                    = %d", [shot isNUX]);
    DLog(@"isSelfie                 = %d", [shot isSelfie]);
    DLog(@"isPhoto                  = %d", [shot isPhoto]);
    DLog(@"isVideo                  = %d", [shot isVideo]);
    DLog(@"isReply                  = %d", [shot isReply]);
    DLog(@"hasDrawing               = %d", [shot hasDrawing]);
    DLog(@"hasLocalMediaReady       = %d", [shot hasLocalMediaReady]);
    DLog(@"hasLocation              = %d", [shot hasLocation]);
    DLog(@"longitude                = %f", [shot longitude]);
    DLog(@"latitude                 = %f", [shot latitude]);
    DLog(@"mediaFileName            = %@", [shot mediaFileName]);
    DLog(@"mediaHeight              = %f", [shot mediaHeight]);
    DLog(@"mediaMirror              = %d", [shot mediaMirror]);
    DLog(@"mediaSize                = %llu", [shot mediaSize]);
    DLog(@"mediaType                = %@", [shot mediaType]);
    DLog(@"mediaURI                 = %@", [shot mediaURI]);
    DLog(@"mediaWidth               = %f", [shot mediaWidth]);
    DLog(@"clientId                 = %@", [shot clientId]);
    DLog(@"capturedAtAbsoluteTime   = %@", [shot capturedAtAbsoluteTime]);
    DLog(@"capturedAtLocalTime      = %@", [shot capturedAtLocalTime]);
    DLog(@"caption                  = %@", [shot caption]);
    DLog(@"ownerIdentifier          = %@", [shot ownerIdentifier]);
    DLog(@"identifier               = %@", [shot identifier]);
    DLog(@"thumbnailImage           = %@", [shot thumbnailImage]);
    DLog(@"thumbnail's length       = %ld", (unsigned long)[[shot thumbnail] length]);
}

#pragma mark - SHNetworkController (outgoing capture) -

HOOK(SHNetworkController, sendShotOperation$didFailWithError$, void, id arg1, id arg2) {
    DLog(@"-------------------------- ^^^ sendShotOperation$didFailWithError$ ^^^ -------------------------------");
    DLog(@"arg1   = %@", arg1);
    DLog(@"arg2   = %@", arg2);
    CALL_ORIG(SHNetworkController, sendShotOperation$didFailWithError$, arg1, arg2);
}

// Sending Shot deliver successfully
HOOK(SHNetworkController, sendShotOperation$didSucceedWithUploadDuration$saveDuration$, void, id arg1, double arg2, double arg3) {
    DLog(@"-------------------------- ^^^ sendShotOperation$didSucceedWithUploadDuration$saveDuration$ ^^^ -------------------------------");
    DLog(@"arg1        = %@", arg1);
    DLog(@"arg2        = %f", arg2);
    DLog(@"arg3        = %f", arg3);
    CALL_ORIG(SHNetworkController, sendShotOperation$didSucceedWithUploadDuration$saveDuration$, arg1, arg2, arg3);
    
    SHSendShotOperation *shotOperation = arg1;
    SHShot *shot = [shotOperation shot];
    
    logShot(shot);
    
    [SlingshotUtils captureOutgoingShot:shot withSendOperation:shotOperation];
}

#pragma mark - SHShotDataCache (incoming capture) -

HOOK(SHShotDataCache, shotDataCacheOperation$didFailDownloadingForShot$error$shouldRetry$, void, id arg1, id arg2, id arg3, BOOL arg4) {
    DLog(@"-------------------------- ^^^ shotDataCacheOperation$didFailDownloadingForShot$error$shouldRetry$ ^^^ -------------------------------");
    DLog(@"arg1    = %@", arg1);
    DLog(@"arg2    = %@", arg2);
    DLog(@"arg3    = %@", arg3);
    DLog(@"arg4    = %d", arg4);
    CALL_ORIG(SHShotDataCache, shotDataCacheOperation$didFailDownloadingForShot$error$shouldRetry$, arg1, arg2, arg3, arg4);
}

/*
 a) Downloading Shot complete successfully
 b) Downloading react Shot complete successfully
    ** Note: Original Shot of react also call this method without ownerIdentifier thus we can filter out by this property; look inside captureIncomingShot: method
 */
HOOK(SHShotDataCache, shotDataCacheOperation$didFinishDownloadingForShot$withDuration$, void, id arg1, id arg2, double arg3) {
    DLog(@"-------------------------- ^^^ shotDataCacheOperation$didFinishDownloadingForShot$withDuration$ ^^^ -------------------------------");
    DLog(@"arg1    = %@", arg1);
    DLog(@"arg2    = %@", arg2);
    DLog(@"arg3    = %f", arg3);
    CALL_ORIG(SHShotDataCache, shotDataCacheOperation$didFinishDownloadingForShot$withDuration$, arg1, arg2, arg3);
    
    
    SHShot *shot = arg2;
    
    logShot(shot);
    
    [SlingshotUtils captureIncomingShot:shot];
}
