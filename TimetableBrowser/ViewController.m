//
//  ViewController.m
//  TimetableBrowser
//
//  Created by Berend Schotanus on 21-12-14.
//  Copyright (c) 2014 First Flamingo Enterprise B.V. All rights reserved.
//

#import "ViewController.h"
#import "OVDataController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (OVDataController *)dataController
{
    return [OVDataController sharedInstance];
}

@end
