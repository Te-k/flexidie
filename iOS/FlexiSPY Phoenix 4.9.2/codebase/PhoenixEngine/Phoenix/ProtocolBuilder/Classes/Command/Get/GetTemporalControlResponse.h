//
//  GetTemporalControlResponse.h
//  ProtocolBuilder
//
//  Created by Makara on 1/12/15.
//
//

#import <Foundation/Foundation.h>
#import "ResponseData.h"

@interface GetTemporalControlResponse : ResponseData {
    NSArray *mTemporalControls; // TemporalControl
}

@property (nonatomic, retain) NSArray *mTemporalControls;

@end
