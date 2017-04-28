//
//  EmbeddedVoIPCallInfo.h
//  ProtocolBuilder
//
//  Created by Makara Khloth on 3/29/16.
//
//

#import "EmbeddedCallInfo.h"

@interface EmbeddedVoIPCallInfo : EmbeddedCallInfo{
    int mRecipientType;
}
@property (nonatomic, assign) int mRecipientType;
@end
