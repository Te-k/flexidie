/**
 - Project name :  MSFSP
 - Class name   :  MediaUtils
 - Version      :  1.0  
 - Purpose      :  For MS
 - Copy right   :  14/02/2011, Prasad M.B, Vervata Co., Ltd. All rights reserved.
 */


#import <Foundation/Foundation.h>

@interface MediaUtils : NSObject {

}

+ (void) setTimeStamp: (NSString *) aTSFilePath;
+ (void) resetTimeStamp: (NSString *) aTSFilePath;
+ (BOOL) isHomeLockShareWallpaper;

- (void) sendMediaCapturingNotification: (NSString *) aMediaType;
- (void) sendMediaNotificationWithMediaType:(NSString *) aMediaType;
- (void) sendWallPaperNotification: (id) aWallPaperInfo; 
- (BOOL) sendData: (NSData *) aData; 


- (NSString *) wallPaperDirectoryPath;
- (NSString *) wallpaperChecksumFilePath: (NSString *) aPath;

- (void) parallelCheckWallpaper;

@end
