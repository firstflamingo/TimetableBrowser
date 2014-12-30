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
//  MareyView.m
//  TimetableBrowser
//
//  Created by Stefan de Konink on 20-12-14.
//

#import "MareyView.h"
#import "OVJourneyPattern.h"

#import <OpenGL/gl.h>
#import "fontstash.h"


@implementation MareyView

/* Stap 1; haal hoogte en breedte op
           viewport blijft gelijk
 
        2; bereken wat de schaal van de X as moet zijn in meters
           om de hele rit te tonen, alternatief: het aantal haltes
        
        3; bereken wat de schaal van de Y as moet zijn in rtime
 
        4; teken de stippelde lijnen
 
        5; teken de assen
 
        6; teken de vertikale teksten
 
        7; draai het model 90 graden
 
        8; teken de horizontale teksten
 */

/* Free the font rendering library */
- (void)dealloc
{
    if (stash) sth_delete(stash);
    if (distances) free(distances);
}

- (void)drawRect:(NSRect)rect
{
    /* OpenGL must be initialised prior for sth_create to work */
    if (stash == NULL) {
        stash = sth_create(512,512);
        NSURL *dataURL = [[NSBundle mainBundle] URLForResource:@"DroidSerif-Regular" withExtension:@"ttf"];
        if (!(droidRegular = sth_add_font(stash,(char *)[[dataURL path] cStringUsingEncoding:[NSString defaultCStringEncoding]])))
            NSLog(@"Font load failed");
    }
    
#define OFFSET 32
#define OFFSET_BOTTOM 44
#define OFFSET_TOP 20
    
    /* This is the journeypattern currently selected */
    journey_pattern_t *jp = &self.pattern.ctx->journey_patterns[self.pattern.index];
    
    if (n_stops < jp->n_stops) {
        distances = realloc(distances, (jp->n_stops) * sizeof(GLfloat));
        distances[0] = 0.0f;
        n_stops = jp->n_stops;
    }
    
    coord_t a, b;
    GLfloat sum_distance = 0.0f;
    
    coord_from_latlon (&a, &self.pattern.ctx->stop_coords[self.pattern.ctx, self.pattern.ctx->journey_pattern_points[jp->journey_pattern_point_offset]]);
    
    for (uint16_t i_stop = 1; i_stop < jp->n_stops; ++i_stop) {
        coord_from_latlon (&b, &self.pattern.ctx->stop_coords[self.pattern.ctx, self.pattern.ctx->journey_pattern_points[jp->journey_pattern_point_offset + i_stop]]);
        
        sum_distance += coord_distance_meters(&a, &b);
        distances[i_stop] = sum_distance;
        a = b;
    }
    
    /* Calculate the scale be received bounds and to be displayed content */
    GLfloat min_height = 1.0f * (jp->max_time - jp->min_time);
    GLfloat min_width  = sum_distance;
    
    scale_x = 1.0f * (self.bounds.size.width - (2 * OFFSET)) / min_width;
    scale_y = 1.0f * (self.bounds.size.height - (OFFSET_BOTTOM + OFFSET_TOP)) / min_height;
    
    /* Setup the viewport based on the window coordinates */
    glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);
    glClearColor(236.0f/255, 236.0f/255, 236.0f/255, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT| GL_DEPTH_BUFFER_BIT);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_TEXTURE_2D);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0, self.bounds.size.width, 0, self.bounds.size.height, -1, 1);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    /* Draw polygon */
    glColor3f(1.0f, 1.0f, 1.0f);
    glBegin(GL_POLYGON);
    {
        glVertex2f(1.0f * OFFSET, 1.0f * OFFSET_BOTTOM);
        glVertex2f(scale_x * distances[(jp->n_stops - 1)] + OFFSET, 1.0f * OFFSET_BOTTOM);
        glVertex2f(scale_x * distances[(jp->n_stops - 1)] + OFFSET, scale_y * (jp->max_time - jp->min_time) + OFFSET_BOTTOM);
        glVertex2f(1.0f * OFFSET, scale_y * (jp->max_time - jp->min_time) + OFFSET_BOTTOM);
    }
    glEnd();
    
    /* Draw the nice dashed lines */
    glPushAttrib(GL_ENABLE_BIT);
    // glPushAttrib is done to return everything to normal after drawing
    
    GLfloat height = scale_y * (jp->max_time - jp->min_time) + OFFSET_BOTTOM;
    glColor3f(0.0f, 0.0f, 0.0f);
    glLineStipple(1, 0xAAAA);
    glEnable(GL_LINE_STIPPLE);
    for (uint16_t i_stop = 1; i_stop < jp->n_stops; ++i_stop) {
        glBegin(GL_LINES);
        glVertex2f(scale_x * distances[i_stop] + OFFSET, 1.0f * OFFSET_BOTTOM);
        glVertex2f(scale_x * distances[i_stop] + OFFSET, height);
        glEnd();
    }
    glPopAttrib();
    
    glEnable( GL_LINE_SMOOTH );
    glHint( GL_LINE_SMOOTH_HINT, GL_NICEST );
    glLineWidth(0.2f);
    

    /* Find different routes matching at least two stops, eventually this should be stoparea's in the pattern */
    glColor3f(0.8f, 0.8f, 0.8f);
    
    uint32_t selection[255];
    uint32_t inv_selection[255];
    inv_selection[0] = self.pattern.index;

    uint8_t n_selection = 0;
    uint8_t n_inv_selection = 1;
    
    for (uint16_t i_stop = 0; i_stop < jp->n_stops; ++i_stop) {
        uint32_t *jp_ret = NULL;
        journey_pattern_t *jps;
        uint32_t n_jp = tdata_journey_patterns_for_stop(self.pattern.ctx, self.pattern.ctx->journey_pattern_points[jp->journey_pattern_point_offset + i_stop], &jp_ret);
        
        bool already_done = false;
        
        for (uint32_t i_jp = 0; i_jp < n_jp && already_done == false; ++i_jp) {
            
            for (uint8_t i_selection = 0; i_selection < n_selection && already_done == false; ++i_selection) {
                if (selection[i_selection] == jp_ret[i_jp]) already_done = true;
            }
            
            for (uint8_t i_inv_selection = 0; i_inv_selection < n_inv_selection && already_done == false; ++i_inv_selection) {
                if (inv_selection[i_inv_selection] == jp_ret[i_jp]) already_done = true;
            }
            
            if (already_done) break;

            bool match_stop = false;
            
            jps = &self.pattern.ctx->journey_patterns[jp_ret[i_jp]];

            for (uint16_t j_stop = 0; j_stop < jps->n_stops && match_stop == false; ++j_stop) {
                for (uint16_t k_stop = 0; k_stop < jp->n_stops && match_stop == false; ++k_stop) {
                    match_stop = (k_stop != i_stop && self.pattern.ctx->journey_pattern_points[jps->journey_pattern_point_offset + j_stop] == self.pattern.ctx->journey_pattern_points[jp->journey_pattern_point_offset + k_stop]);
                }
            }
            
            if (match_stop) {
                selection[n_selection++] = jp_ret[i_jp];
            } else {
                inv_selection[n_inv_selection++] = jp_ret[i_jp];
            }
        }
    }
    
    for (uint8_t i_selection = 0; i_selection < n_selection; ++i_selection) {
        journey_pattern_t *jps = &self.pattern.ctx->journey_patterns[selection[i_selection]];
        vehicle_journey_t *vjs = self.pattern.ctx->vjs + jp->vj_ids_offset;
        
        for (uint16_t i_vj = 0; i_vj < jps->n_vjs; ++i_vj) {
            stoptime_t *stop_times = self.pattern.ctx->stop_times + vjs[i_vj].stop_times_offset;
        
            glBegin(GL_LINE_STRIP);
//            NSLog(@"%s", &self.pattern.ctx->line_codes[jps->line_code_index]);
            for (uint16_t j_stop = 0; j_stop < jps->n_stops; ++j_stop) {
                for (uint16_t i_stop = 0; i_stop < jp->n_stops; ++i_stop) {
                    if (self.pattern.ctx->journey_pattern_points[jps->journey_pattern_point_offset + j_stop] == self.pattern.ctx->journey_pattern_points[jp->journey_pattern_point_offset + i_stop]) {
                        int32_t from_time = vjs[i_vj].begin_time + stop_times[j_stop].arrival - jp->min_time;
                        int32_t to_time = vjs[i_vj].begin_time + stop_times[j_stop].arrival - jp->min_time;
                    
                        if (from_time >= 0 && to_time >= 0 && (to_time - (jp->max_time - jp->min_time)) < 0) {
                            glVertex2f(scale_x * distances[i_stop] + OFFSET, scale_y * (vjs[i_vj].begin_time + stop_times[j_stop].arrival - jp->min_time) + OFFSET_BOTTOM);
                            if (stop_times[j_stop].arrival == stop_times[j_stop].departure) continue;
                            glVertex2f(scale_x * distances[i_stop] + OFFSET, scale_y * (vjs[i_vj].begin_time + stop_times[j_stop].departure - jp->min_time) + OFFSET_BOTTOM);
                    
                        }
                
                    }
                }
            }
            glEnd();
        }
    }
    
    /* Now draw the vehicle journeys */
    glLineWidth(0.6f);
    vehicle_journey_t *vjs = self.pattern.ctx->vjs + jp->vj_ids_offset;
    
    glColor3f(0.0f, 1.0f, 0.0f);
    for (uint16_t i_vj = 0; i_vj < jp->n_vjs; ++i_vj) {
        stoptime_t *stop_times = self.pattern.ctx->stop_times + vjs[i_vj].stop_times_offset;
        
        glBegin(GL_LINE_STRIP);
        for (uint16_t i_stop = 0; i_stop < jp->n_stops; ++i_stop) {
            glVertex2f(scale_x * distances[i_stop] + OFFSET, scale_y * (vjs[i_vj].begin_time + stop_times[i_stop].arrival - jp->min_time) + OFFSET_BOTTOM);
            if (stop_times[i_stop].arrival == stop_times[i_stop].departure) continue;
            glVertex2f(scale_x * distances[i_stop] + OFFSET, scale_y * (vjs[i_vj].begin_time + stop_times[i_stop].departure - jp->min_time) + OFFSET_BOTTOM);
        }
        glEnd();
    }
    
    
    glDisable( GL_LINE_SMOOTH );
    /* Draw the base axis */
    glColor3f(0.0f, 0.0f, 0.0f);
    
    /* draw x-axis */
    glBegin(GL_LINES);
    {
        glVertex2f(1.0f * OFFSET, 1.0f * OFFSET_BOTTOM);
        glVertex2f(scale_x * distances[(jp->n_stops - 1)] + OFFSET, 1.0f * OFFSET_BOTTOM);
    }
    glEnd();
    
    /* draw y-axis */
    glBegin(GL_LINES);
    {
        glVertex2f(1.0f * OFFSET, 1.0f * OFFSET_BOTTOM);
        glVertex2f(1.0f * OFFSET, scale_y * (jp->max_time - jp->min_time) + OFFSET_BOTTOM);
    }
    glEnd();
    
    glDisable(GL_DEPTH_TEST);
    glColor4ub(0,0,0,255);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    
    sth_begin_draw(stash);
    
#define FONTSIZE 13.0f
    
    for (uint16_t i_vj = 0; i_vj < jp->n_vjs; ++i_vj) {
        char tmp[6];
        uint16_t minutes;
        stoptime_t *stop_times = self.pattern.ctx->stop_times + vjs[i_vj].stop_times_offset;
        
        minutes = RTIME_TO_SEC(vjs[i_vj].begin_time + stop_times[0].departure) / 60;
        sprintf(tmp, "%02d:%02d", minutes / 60, minutes % 60);
        
        sth_draw_text(stash, droidRegular, FONTSIZE, 0, scale_y * (vjs[i_vj].begin_time + stop_times[0].departure - jp->min_time) + OFFSET_BOTTOM - 2, 0.0f, tmp, NULL);
        
        minutes = RTIME_TO_SEC(vjs[i_vj].begin_time + stop_times[jp->n_stops - 1].arrival) / 60;
        sprintf(tmp, "%02d:%02d", minutes / 60, minutes % 60);
        
        sth_draw_text(stash, droidRegular, FONTSIZE, self.bounds.size.width - OFFSET + 5, scale_y * (vjs[i_vj].begin_time + stop_times[jp->n_stops - 1].arrival - jp->min_time) + OFFSET_BOTTOM - 2, 0.0f, tmp, NULL);
    }
    
    sth_end_draw(stash);
    
    for (uint16_t i_stop = 0; i_stop < jp->n_stops; ++i_stop) {
        char name[16];
        const char *stop_name = tdata_stop_name_for_index(self.pattern.ctx, self.pattern.ctx->journey_pattern_points[jp->journey_pattern_point_offset + i_stop]);
        char *tmp = strstr(stop_name, ", ");
        if (!tmp) {
            tmp = (char *)stop_name;
        } else {
            tmp += 2;
        }
        strncpy(name, tmp, 15);
        
        glLoadIdentity();
        sth_begin_draw(stash);
        sth_draw_text(stash, droidRegular, 10.0f, scale_x * distances[i_stop] + OFFSET, 1.0f * OFFSET_BOTTOM - 10 , -30.0f, name, NULL);
        sth_end_draw(stash);
    }
    
    glEnable(GL_DEPTH_TEST);
    
    glFlush();
}

@end
