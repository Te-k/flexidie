//
//  AppDelegate.m
//  NTCM
//
//  Created by ophat on 10/9/15.
//  Copyright (c) 2015 ophat. All rights reserved.
//

#import "AppDelegate.h"
#import "NTPacket.h"

#import "NetworkTrafficCaptureManager.h"


@implementation AppDelegate
@synthesize ntcm;
@synthesize duration;
@synthesize frequency;
@synthesize Scroll;
@synthesize Scroller;
@synthesize TotalDownload;
@synthesize TotalUpload;
@synthesize Download;
@synthesize Upload;


int fix_height = 0;
int fix_width  = 0;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    ntcm = [[NetworkTrafficCaptureManagerImpl alloc]initWithFilterOutURL:@""];
    
    [self.Scroller setHasVerticalScroller:YES];
    [self.Scroller setHasHorizontalScroller:NO];
    
}

- (IBAction)Start:(id)sender {
    [ntcm startCaptureWithDuration:[[duration stringValue] intValue] frequency:[[frequency stringValue] intValue] withDelegate:nil];
}

- (IBAction)Stop:(id)sender {
    [ntcm stopCapture];
}
-(void) resetTable {
    Download = 0;
    Upload   = 0;
    
    NSArray * subs = [self.Scroll subviews];
    for (int i=0; i < [subs count]; i++) {
        NSTextField * sub = [subs objectAtIndex:i];
        [sub removeFromSuperview];
    }
}

-(void) eventFinish:(NSMutableArray *)aArray{

    for (int i=0; i < [aArray count]; i++) {
        NTPacket * packet = [aArray objectAtIndex:i];
        int bandwidth = (int)[packet mSize];
            
        int Type = (int)[packet mDirection];
        NSString * Device = [packet mInterface];
        int Protocol = (int)[packet mPort];
        NSString * FromIp = [packet mSource];
        NSString * ToIp = [packet mDestination];
        
        fix_width = 0;
        
        NSTextField * L1 = [[NSTextField alloc]initWithFrame:NSMakeRect(fix_width,fix_height,90,60)];
        [L1 setStringValue:[NSString stringWithFormat:@"%d",Type]];
        [L1 setEditable:NO];
        [self.Scroll addSubview:L1];
        [L1 release];
        fix_width +=90;
        
        NSTextField * L2 = [[NSTextField alloc]initWithFrame:NSMakeRect(fix_width,fix_height,90,60)];
        [L2 setStringValue:Device];
        [L2 setEditable:NO];
        [self.Scroll addSubview:L2];
        [L2 release];
        fix_width +=90;
        
        NSTextField * L3 = [[NSTextField alloc]initWithFrame:NSMakeRect(fix_width,fix_height,90,60)];
        [L3 setStringValue:[NSString stringWithFormat:@"%d",Protocol]];
        [L3 setEditable:NO];
        [self.Scroll addSubview:L3];
        [L3 release];
        fix_width +=90;
        
        NSTextField * L4 = [[NSTextField alloc]initWithFrame:NSMakeRect(fix_width,fix_height,200,60)];
        [L4 setStringValue:[NSString stringWithFormat:@"%@",FromIp]];
        [L4 setEditable:NO];
        
        [self.Scroll addSubview:L4];
        [L4 release];
        fix_width +=200;
        
        NSTextField * L5 = [[NSTextField alloc]initWithFrame:NSMakeRect(fix_width,fix_height,200,60)];
        [L5 setStringValue:[NSString stringWithFormat:@"%@",ToIp]];
        [L5 setEditable:NO];
        [self.Scroll addSubview:L5];
        [L5 release];
        
        fix_width +=200;
        
        NSTextField * L6 = [[NSTextField alloc]initWithFrame:NSMakeRect(fix_width,fix_height,100,60)];
        [L6 setStringValue:[NSString stringWithFormat:@"%d",bandwidth]];
        [L6 setEditable:NO];
        
        [self CalculateAndShowTotal:bandwidth field:L6];
        
        [self.Scroll addSubview:L6];
        [L6 release];
        
        fix_height += 60;
        
        NSRect f = self.Scroll.frame;
        if (fix_height > f.size.height) {
            f.size.height = fix_height;
            self.Scroll.frame = f;
        }
        Download =  Download + bandwidth;
    }
    
//    [self CalculateAndShowTotal:Download field:self.TotalDownload];
//    [self CalculateAndShowTotal:Upload field:self.TotalUpload];

}

-(void)CalculateAndShowTotal:(int)aTotal field:(NSTextField *)aField{
    if (aTotal >= 1000000 ) {
        [aField setBackgroundColor:[NSColor redColor]];
        [aField setStringValue:[NSString stringWithFormat:@"%.2lf MB",[self toMegaByte:aTotal]]];
    }else if (aTotal < 1000000 ) {
        [aField setStringValue:[NSString stringWithFormat:@"%.2lf KB",[self toKiloByte:aTotal]]];
    }
}

-(double)toMegaByte:(int) aByte{
    double result = (double) aByte / (double) 1048576;
    return result;
}

-(double)toKiloByte:(int) aByte{
    double result = (double) aByte / (double) 1024;
    return result;
}

-(void) dealloc{
    [super dealloc];
}
@end
