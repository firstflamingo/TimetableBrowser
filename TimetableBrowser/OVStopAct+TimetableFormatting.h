//
//  OVStopAct+TimetableFormatting.h
//  TimetableBrowser
//
//  Created by Berend Schotanus on 24-12-14.
//  Copyright (c) 2014 First Flamingo Enterprise B.V. All rights reserved.
//

#import "OVStopAct.h"
#import <Cocoa/Cocoa.h>

@interface OVStopAct (TimetableFormatting)

@property (nonatomic, readonly) NSAttributedString *arrivalAttributedString, *departureAttributedString;

@end
