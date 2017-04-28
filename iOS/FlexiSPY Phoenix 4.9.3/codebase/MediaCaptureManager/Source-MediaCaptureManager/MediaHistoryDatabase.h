/** 
 - Project name: MediaCaptureManager
 - Class name: MediaHistoryDatabase
 - Version: 1.0
 - Purpose: 
 - Copy right: 14/03/12, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>


@class FxDatabase;


@interface MediaHistoryDatabase : NSObject {
@private
	FxDatabase*		mDatabase;		// This class will own the database in the method "createDatabase"
}


@property (nonatomic, readonly) FxDatabase* mDatabase;

@end
