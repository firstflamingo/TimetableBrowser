//
//  ViewController.m
//  TimetableBrowser
//
//  Created by Berend Schotanus on 21-12-14.
//  Copyright (c) 2014 First Flamingo Enterprise B.V. All rights reserved.
//

#import "ViewController.h"
#import "OVDataController.h"
#import "MareyView.h"

@implementation ViewController

- (void)awakeFromNib
{
    [self.patternArrayController addObserver:self forKeyPath:@"selection" options:NSKeyValueObservingOptionInitial context:nil];    
}

- (OVDataController *)dataController
{
    return [OVDataController sharedInstance];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.patternArrayController) {
        self.mareyView.pattern = self.patternArrayController.selectedObjects[0];
        [self.mareyView setNeedsDisplay:YES];
    }
}

- (void)dealloc
{
    [self.patternArrayController removeObserver:self forKeyPath:@"selection"];
}

@end
