/** 
 - Project name: AppContext
 - Class name: VersionInfo
 - Version: 1.0
 - Purpose: Read version file
 - Copy right: 14/12/11, Benjawan Tanarattanakorn, Vervata Co., Ltd. All right reserved.
 */

#import <Foundation/Foundation.h>

@interface VersionInfo : NSObject <NSXMLParserDelegate> {
@private
	BOOL			isInElement;
	
	NSString		*mMajor;
	NSString		*mMinor;
	NSString		*mBuild;
	NSString		*mBuildDate;
	NSString		*mBuildDescription;
	NSMutableString *mCurrentElementValue;
}


@property (nonatomic, retain) NSString *mMajor;
@property (nonatomic, retain) NSString *mMinor;
@property (nonatomic, retain) NSString *mBuild;
@property (nonatomic, retain) NSString *mBuildDate;
@property (nonatomic, retain) NSString *mBuildDescription;
@property (nonatomic, retain) NSMutableString *mCurrentElementValue;

- (NSString *) version;
- (NSString *) versionWithBuild;
- (NSString *) versionDescription;

@end
