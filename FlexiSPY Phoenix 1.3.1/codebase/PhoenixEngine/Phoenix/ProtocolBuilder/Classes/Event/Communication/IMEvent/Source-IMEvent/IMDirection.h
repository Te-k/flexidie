//
//  IMDirection.h
//  IMEvent
//
//  Created by Ophat on 2/1/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
	kDirectionUnknown  =0,
	kDirectionIN       =1,
	kDirectionOUT      =2,
	kDirectionMissCall =3,
	kDirectionLocalIM  =4
}IMDirection;