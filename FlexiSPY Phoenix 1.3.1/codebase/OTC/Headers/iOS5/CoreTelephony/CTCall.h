// Declarartions
#define CALL_NOTIFICATION_STATUS_INPROGRESS 1
#define CALL_NOTIFICATION_STATUS_ONHOLD 2
#define CALL_NOTIFICATION_STATUS_OUTGOING 3
#define CALL_NOTIFICATION_STATUS_INCOMING 4
#define CALL_NOTIFICATION_STATUS_TERMINATED 5

@class NSString;

@interface CTCall : NSObject
{
    NSString *_callState;
    NSString *_callID;
}

+ (id)callForCTCallRef:(struct __CTCall *)arg1;
@property(copy, nonatomic) NSString *callID; // @synthesize callID=_callID;
@property(copy, nonatomic) NSString *callState; // @synthesize callState=_callState;
- (unsigned int)hash;
- (BOOL)isEqual:(id)arg1;
- (id)description;
- (void)dealloc;

@end

