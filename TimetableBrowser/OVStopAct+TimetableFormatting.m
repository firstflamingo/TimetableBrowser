//
//  OVStopAct+TimetableFormatting.m
//  TimetableBrowser
//
//  Created by Berend Schotanus on 24-12-14.
//  Copyright (c) 2014 First Flamingo Enterprise B.V. All rights reserved.
//

#import "OVStopAct+TimetableFormatting.h"

NSDictionary *attributesForAllowance(BOOL actionAllowed);

@implementation OVStopAct (TimetableFormatting)

- (NSAttributedString *)arrivalAttributedString
{
    return [[NSAttributedString alloc] initWithString:stringFromRTime(self.arrival)
                                           attributes:attributesForAllowance(self.allowsAlighting)];

}

- (NSAttributedString *)departureAttributedString
{
    return [[NSAttributedString alloc] initWithString:stringFromRTime(self.departure)
                                           attributes:attributesForAllowance(self.allowsBoarding)];
}

@end


NSDictionary *attributesForAllowance(BOOL actionAllowed)
{
    if (actionAllowed) {
        return @{};
    } else {
        return @{NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle),
                 NSForegroundColorAttributeName: [NSColor lightGrayColor]};
    }
}

