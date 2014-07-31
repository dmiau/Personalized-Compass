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
    // draw the triangle
    // ---------------
    glPushMatrix();
    for (int i = 0; i < indices_for_rendering.size(); ++i){
        int j = indices_for_rendering[i];

        //[todo] fix color map (increase the size?)
        glColor4f((float)model->color_map[j][0]/256,
                  (float)model->color_map[j][1]/256,
                  (float)model->color_map[j][2]/256, 1);

        data data_ = model->data_array[j];

        double distance = data_.distance / max_dist * half_canvas_size * 0.9;
        glTranslatef(0, 0, 0.001);
        drawTriangle(central_disk_radius, data_.orientation, distance);
    }
    glPopMatrix();
    // ---------------
    // draw the background (transparent) disk
    // ---------------
    glColor4f([model->configurations[@"disk_color"][0] floatValue]/255,
              [model->configurations[@"disk_color"][1] floatValue]/255,
              [model->configurations[@"disk_color"][2] floatValue]/255,
              [model->configurations[@"disk_color"][3] floatValue]/255);
    drawCircle(0, 0, half_canvas_size, 50, true);
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
                 half_canvas_size *
                 [model->configurations[@"north_indicator_ratio"] floatValue]);
    
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
    float outer_disk_radius =
    half_canvas_size *
    [model->configurations[@"outer_disk_ratio"] floatValue];
    drawCircle(0, 0, outer_disk_radius, 50, true);
    
    glPopMatrix();
}
