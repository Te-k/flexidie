//
//  EvaluationFrame.h
//  NetworkTrafficAlertManager
//
//  Created by ophat on 1/7/16.
//  Copyright (c) 2016 ophat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EvaluationFrame : NSObject{
    NSMutableArray     *mClientAlertRemoteHost;
}
@property (nonatomic, retain) NSMutableArray * mClientAlertRemoteHost;
@end
