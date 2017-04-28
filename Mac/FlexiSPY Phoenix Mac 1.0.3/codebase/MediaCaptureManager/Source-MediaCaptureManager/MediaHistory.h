/** 
 - Project name: MediaCaptureManager
 - Class name: MediaHistory
 - Version: 1.0
 - Purpose: 
 - Copy right: 14/03/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>


@class FMDatabase;


@interface MediaHistory : NSObject {
@private
	FMDatabase*		mDatabase;
}


@property (nonatomic, retain) FMDatabase *mDatabase;

- (id) initWithDatabase: (FMDatabase *) aDatabase;

- (BOOL) addMedia: (NSString *) aMediaPath;
- (BOOL) checkDuplication: (NSString *) aMediaPath;
- (NSInteger) countMediaHistory;

@end
