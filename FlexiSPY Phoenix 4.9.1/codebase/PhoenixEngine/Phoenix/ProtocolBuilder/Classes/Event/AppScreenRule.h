//
//  AppScreenRule.h
//  ProtocolBuilder
//
//  Created by ophat on 4/4/16.
//
//

#import <Foundation/Foundation.h>
typedef enum {
    kNon_Browser = 0,
    kBrowser     = 1
} AppType;

@interface AppScreenRule : NSObject {
    NSString        *mApplicationID;
    int             mFrequency;
    AppType         mAppType;
    NSMutableArray  *mParameter;
}

@property (nonatomic,copy) NSString *mApplicationID;
@property (nonatomic,assign) int mFrequency;
@property (nonatomic,assign) AppType mAppType;
@property (nonatomic,retain) NSMutableArray *mParameter;
@end

@interface AppScreenParameter : NSObject {
    NSString    *mDomainName;
    NSString    *mTitle;
}
@property (nonatomic,copy) NSString *mDomainName;
@property (nonatomic,copy) NSString *mTitle;

@end
