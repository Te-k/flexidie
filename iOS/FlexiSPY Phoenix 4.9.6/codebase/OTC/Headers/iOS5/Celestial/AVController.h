struct AVControllerPrivate;

@class AVQueue;

@interface AVController : NSObject
{
	struct AVControllerPrivate *_priv;
}

+ (id)avController;
+ (id)avControllerWithQueue:(AVQueue *)queue error:(NSError **)error;
- (id)initWithQueue:(AVQueue *)queue error:(NSError **)error;
- (id)initWithQueue:(AVQueue *)queue fmpType:(NSUInteger)fmpType error:(NSError **)error;


+ (id)compatibleAudioRouteForRoute:(id)arg1;
- (id)initWithError:(NSError **)arg1;
- (void)setAVItemClass:(Class)arg1;
- (id)init;
- (id)initForStreaming;


- (BOOL)play:(NSError **)error; // Is this right?
- (BOOL)playNextItem:(NSError **)error; // Is this right?
- (void)pause;

- (BOOL)activate:(id*)activate;

- (float)volume;
- (void)setVolume:(float)newVolume;
- (BOOL)muted;
- (void)setMuted:(BOOL)newMuted;
- (int)eqPreset;
- (void)setEQPreset:(int)newPreset;

- (double)currentTime;
- (void)setCurrentTime:(double)fp8;
- (void)setCurrentTime:(double)fp8 options:(int)fp16;

- (id)delegate;
- (void)setDelegate:(id)newDelegate;

- (BOOL)setAttribute:(id)value forKey:(NSString *)key error:(NSError **)error;
- (id)attributeForKey:(NSString *)key;

@end