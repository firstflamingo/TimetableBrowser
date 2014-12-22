//
//  MareyView.h
//  Timetable Browser
//
//  Created by Stefan de Konink on 20-12-14.
//  Copyright (c) 2014 Bliksem Labs B.V. All rights reserved.
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
