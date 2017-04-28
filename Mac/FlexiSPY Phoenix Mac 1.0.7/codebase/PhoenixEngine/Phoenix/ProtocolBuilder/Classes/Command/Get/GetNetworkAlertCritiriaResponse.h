//
//  GetNetworkAlertCritiriaResponse.h
//  ProtocolBuilder
//
//  Created by ophat on 1/11/16.
//
//

#import <Foundation/Foundation.h>
#import "ResponseData.h"

@interface GetNetworkAlertCritiriaResponse : ResponseData{
    NSArray *mCriteria;
}
@property (nonatomic, retain) NSArray *mCriteria;

@end

