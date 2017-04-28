#import <Cocoa/Cocoa.h>

static void WaitForWindowServerSession(void){
    do {
        NSDictionary *  sessionDict;
        
        sessionDict = CFBridgingRelease( CGSessionCopyCurrentDictionary() );
        if (sessionDict != nil) {
            break;
        }
        
        sleep(1);
    } while (YES);
    
}

static void InstallHandleSIGTERMFromRunLoop(void){
    static dispatch_once_t   sOnceToken;
    static dispatch_source_t sSignalSource;
    
    dispatch_once(&sOnceToken, ^{
        signal(SIGTERM, SIG_IGN);
        
        sSignalSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGTERM, 0, dispatch_get_main_queue());
        assert(sSignalSource != NULL);
        
        dispatch_source_set_event_handler(sSignalSource, ^{
            assert([NSThread isMainThread]);
            
            [[NSApplication sharedApplication] terminate:nil];
        });
        
        dispatch_resume(sSignalSource);
    });
}

int main(int argc, char *argv[]){
    int             retVal;
    NSTimeInterval  delay;
    
    // Register the default defaults, so to speak.
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
      @"DelayStartup":               @0.0,
      @"WaitForWindowServerSession": @NO,
      @"ForceOrderFront":            @YES,
      @"CleanExit":                  @YES
    }];
    
    // Handle various options startup options.
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"WaitForWindowServerSession"]) {
        WaitForWindowServerSession();
    }
    
    delay = [[NSUserDefaults standardUserDefaults] doubleForKey:@"DelayStartup"];
    if (delay > 0.0) {
        [NSThread sleepForTimeInterval:delay];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CleanExit"]) {
        InstallHandleSIGTERMFromRunLoop();
    }
    
    retVal = NSApplicationMain(argc, (const char **) argv);
    
    return retVal;
}
