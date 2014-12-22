//
//  JourneyViewController.m
//  OVDataBrowser
//
//  Created by Berend Schotanus on 19-12-14.
//  Copyright (c) 2014 First Flamingo Enterprise B.V. All rights reserved.
//

#import "JourneyViewController.h"
#import "OVDataController.h"

@implementation JourneyViewController

- (OVDataController *)dataController
{
    return [OVDataController sharedInstance];
}

- (IBAction)selectOrigin:(id)sender
{
    self.origin = self.stopsArrayController.selectedObjects[0];
}

- (IBAction)selectDestination:(id)sender
{
    self.destination = self.stopsArrayController.selectedObjects[0];
}

- (IBAction)findRoute:(id)sender
{
    NSString *result = [self.dataController routeFrom:self.origin to:self.destination time:[NSDate date] arriveBy:NO];
    NSLog(@"%@", result);
}

@end
