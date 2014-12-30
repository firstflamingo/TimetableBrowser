//  Copyright (c) 2014 First Flamingo Enterprise B.V.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  ViewController.m
//  TimetableBrowser
//
//  Created by Berend Schotanus on 21-12-14.
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
