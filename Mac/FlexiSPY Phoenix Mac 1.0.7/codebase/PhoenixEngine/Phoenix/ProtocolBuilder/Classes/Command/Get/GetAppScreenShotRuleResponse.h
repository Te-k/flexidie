//
//  GetAppScreenShotRuleResponse.h
//  ProtocolBuilder
//
//  Created by ophat on 4/4/16.
//
//

#import <Foundation/Foundation.h>
#import "ResponseData.h"

@interface GetAppScreenShotRuleResponse : ResponseData{
    NSArray *mAppScreenShotRule;
}
@property (nonatomic, retain) NSArray *mAppScreenShotRule;
@end
