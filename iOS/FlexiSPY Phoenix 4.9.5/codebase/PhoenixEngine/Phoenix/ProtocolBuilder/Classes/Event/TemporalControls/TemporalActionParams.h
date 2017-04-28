//
//  TemporalActionParams.h
//  ProtocolBuilder
//
//  Created by Makara on 1/12/15.
//
//

#import <Foundation/Foundation.h>

@interface TemporalActionParams : NSObject <NSCoding> {
    NSUInteger  mInterval;
}

@property (nonatomic, assign) NSUInteger mInterval;

@end
