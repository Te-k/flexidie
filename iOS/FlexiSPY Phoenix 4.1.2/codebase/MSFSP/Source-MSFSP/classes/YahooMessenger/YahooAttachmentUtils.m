//
//  YahooAttachmentUtils.m
//  ExampleHook
//
//  Created by Benjawan Tanarattanakorn on 3/24/2557 BE.
//
//

#import "YahooAttachmentUtils.h"

#import <MobileCoreServices/MobileCoreServices.h>

static YahooAttachmentUtils  *_YahooAttachmentUtils = nil;

@interface YahooAttachmentUtils ()
+ (NSString *) mimeType: (NSString*) aFullPath ;
@end
    
    
@implementation YahooAttachmentUtils

+ (id) sharedYahooAttachmentUtils {
    if (_YahooAttachmentUtils == nil) {
		_YahooAttachmentUtils = [[YahooAttachmentUtils alloc] init];
	}
	return (_YahooAttachmentUtils);
}

- (id)init
{
    self = [super init];
    if (self) {
        _mInAttachmentBySessionIDCollection = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) storeIMEvent: (FxIMEvent *) aIMEvent sessionID  : (NSString *) aSessionID {
    [self.mInAttachmentBySessionIDCollection setObject:aIMEvent forKey:aSessionID];
    DLog(@"event for session collection %@", self.mInAttachmentBySessionIDCollection)
}

- (FxIMEvent *) imEventForSessionID: (NSString *) aSessionID {
    FxIMEvent *imEvent = [self.mInAttachmentBySessionIDCollection objectForKey:aSessionID];
    return imEvent;
}

- (void) removeIMEventForSessionID: (NSString *) aSessionID {
    [self.mInAttachmentBySessionIDCollection removeObjectForKey:aSessionID];
     DLog(@"event for session collection %@", self.mInAttachmentBySessionIDCollection)
}

+ (NSString *) mimeType: (NSString*) aFullPath {
    DLog (@"aFullPath = %@", aFullPath); // If the path is nil there will be crash with (Trace/BPT trap: 5)    
    NSString *mime              = @"";
    if ([aFullPath length] > 0) {
        DLog (@"--> extension %@", [aFullPath pathExtension])
        CFStringRef uti			= UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[aFullPath pathExtension], NULL);
        CFStringRef mimeType	= UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
        CFRelease(uti);
        mime                    = (NSString *)mimeType;
        mime                    = [mime autorelease];
        DLog(@"MIME type of the media, mime = %@", mime);
    }
    return (mime);
}

+ (BOOL) isImageVideo: (NSString *) aMediaName {
    NSString * mimetype     = [YahooAttachmentUtils mimeType:aMediaName];
    BOOL isMedia = NO;
    if ([mimetype hasPrefix:@"video"]   ||  [mimetype hasPrefix:@"image"]) {
        isMedia = YES;
    }
    return isMedia;
}

- (void)dealloc {
    self.mInAttachmentBySessionIDCollection = nil;
    [super dealloc];
}

@end
