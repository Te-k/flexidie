//
//  SendNetworkAlertCritiria.h
//  ProtocolBuilder
//
//  Created by ophat on 1/11/16.
//
//

#import <Foundation/Foundation.h>
#import "CommandData.h"
@interface SendNetworkAlert : NSObject <CommandData>{
    NSArray *mClientAlerts; 
}
@property (nonatomic, retain) NSArray *mClientAlerts;

@end
