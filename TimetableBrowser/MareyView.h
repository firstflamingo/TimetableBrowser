//  Copyright (c) 2014 First Flamingo Enterprise B.V. / Bliksem Labs B.V.
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
//  MareyView.h
//  TimetableBrowser
//
//  Created by Stefan de Konink on 20-12-14.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>

@class OVJourneyPattern;

@interface MareyView : NSOpenGLView

@property (nonatomic, strong) OVJourneyPattern *pattern;

@end

static struct sth_stash* stash = NULL;
static int droidRegular;
static GLfloat scale_x = 1.0f;
static GLfloat scale_y = 1.0f;
static GLfloat *distances = NULL;
static GLfloat n_stops = 0;
