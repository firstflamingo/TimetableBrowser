//
//  JourneyViewController.h
//  OVDataBrowser
//
//  Created by Berend Schotanus on 19-12-14.
//  Copyright (c) 2014 First Flamingo Enterprise B.V. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class OVDataController, OVStop;

@interface JourneyViewController : NSViewController

@property (nonatomic, readonly) OVDataController *dataController;

@property (nonatomic, strong) OVStop *origin, *destination;

@property (strong) IBOutlet NSArrayController *stopsArrayController;

@end
