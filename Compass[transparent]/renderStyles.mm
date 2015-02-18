//
//  renderStyles.cpp
//  Compass[transparent]
//
//  Created by Daniel Miau on 4/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//
#include "commonInclude.h"
#include "compassRender.h"
#include <vector>
#include <numeric>
#include <iostream>
#include <sstream>
using namespace std;

#pragma mark ------------ Tools
// http://stackoverflow.com/questions/650162/why-switch-statement-cannot-be-applied-on-strings
style_enum compassRender::hashStyleStr (NSString *inString) {
    if ([inString isEqualToString:@"BIMODAL"]) return BIMODAL;
    if ([inString isEqualToString:@"REAL_RATIO"]) return REAL_RATIO;
    if ([inString isEqualToString:@"THRESHOLD_STICK"]) return THRESHOLD_STICK;
    if ([inString isEqualToString:@"WEDGE"]) return WEDGE;
    throw(runtime_error("Unknown style string."));
}

//-------------------
// This function renders the filtered landmakrs in the specified style
//-------------------
int compassRender::applyStyle(style_enum style_type,
                              vector<int> &indices_for_rendering){
    switch (style_type) {
        case BIMODAL:
            renderStyleBimodal(indices_for_rendering);
            break;
        case REAL_RATIO:
            renderStyleRealRatio(indices_for_rendering);
            break;
        case THRESHOLD_STICK:
            renderStyleThresholdSticks(indices_for_rendering);
            break;
        case WEDGE:
            renderStyleWedge(indices_for_rendering);
            break;
        default:
            throw(runtime_error("Unknow style"));
            break;
    }
    return EXIT_SUCCESS;
}

#pragma mark ------------ styles

//------------------------------------
// Real Ratio
//------------------------------------
void compassRender::renderStyleRealRatio(vector<int> &indices_for_rendering){

    if (indices_for_rendering.size() > 0){
        // ------------------
        // Preprocesing:
        // Find out the longest distance for normalization
        // ------------------
        vector <double> t_dist_list;
        for (int i = 0; i < indices_for_rendering.size(); ++i){
            int j = indices_for_rendering[i];
            t_dist_list.push_back(model->data_array[j].distance);
        }
        std::vector<double>::iterator result =
        std::max_element(t_dist_list.begin(),
                         t_dist_list.end());
        max_dist = *result;
        
        // ---------------
        // draw the scale box
        // ---------------
        drawCompassScaleBox(*result);
    }
    // ---------------
    // Draw the center circle
    // ---------------
    drawCompassCentralCircle();
    
    // ---------------
    // draw the triangle
    // ---------------
    glPushMatrix();
    for (int i = -1; i < (int)indices_for_rendering.size(); ++i){
        data data_;
        if (i == -1){
            if (model->user_pos.isEnabled && !model->user_pos.isVisible){
                glColor4f(0, 1, 0, 1);
                data_ = model->user_pos;
            }else{
                continue;
            }
        }else{
            int j = indices_for_rendering[i];
            
            //[todo] fix color map (increase the size?)
            glColor4f(
                      [model->configurations[@"landmark_color"][0] floatValue]/256,
                      [model->configurations[@"landmark_color"][1] floatValue]/256,
                      [model->configurations[@"landmark_color"][2] floatValue]/256,
                      [model->configurations[@"landmark_color"][3] floatValue]/256);
            
            data_ = model->data_array[j];
            
            double distance = data_.distance / max_dist * compass_disk_radius;
            glTranslatef(0, 0, 0.001);
            drawTriangle(central_disk_radius, data_.orientation, distance);
        }
    }
    glPopMatrix();
    
    // ---------------
    // draw the north indicator
    // ---------------
    drawCompassNorth();
    
    // ---------------
    // draw the background (transparent) disk
    // ---------------
    drawCompassBackgroundDisk();
}

//------------------------------------
// ThresholdSticks
//------------------------------------
void compassRender::renderStyleThresholdSticks(vector<int> &indices_for_rendering){
    
}

void compassRender::renderBareboneCompass(){
    // ---------------
    // Draw the center circle
    // ---------------
    glColor4f([model->configurations[@"circle_color"][0] floatValue]/255,
              [model->configurations[@"circle_color"][1] floatValue]/255,
              [model->configurations[@"circle_color"][2] floatValue]/255,
              1);
    
    // draw the center circle
    glPushMatrix();
    // Translate to the front to avoid broken polygon
    glTranslatef(0, 0, 1);
    drawCircle(0, 0, central_disk_radius, 50, true);
    glPopMatrix();
    
    
    // ---------------
    // draw the north indicator
    // ---------------
    glColor4f(50/256,
              50/256,
              50/256, 0.5);
    drawTriangle(central_disk_radius/6, 0,
                 compass_disk_radius *
                 [model->configurations[@"north_indicator_to_compass_disk_ratio"] floatValue]);
    
    // ---------------
    // draw the background (transparent) disk
    // ---------------
    float alpha = 0;
        
    glPushMatrix();
    if (model->tilt == 0)
        alpha = [model->configurations[@"disk_color"][3] floatValue]/255;
    else
        alpha = 1;
    glColor4f([model->configurations[@"disk_color"][0] floatValue]/255,
              [model->configurations[@"disk_color"][1] floatValue]/255,
              [model->configurations[@"disk_color"][2] floatValue]/255,
              alpha);
    glTranslatef(0, 0, -1);
    // the radius of the outer disk
    drawCircle(0, 0, compass_disk_radius, 50, true);
    
    glPopMatrix();
}
