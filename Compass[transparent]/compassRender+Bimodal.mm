//
//  compassRender+Bimodal.mm
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/16/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//
#include "commonInclude.h"
#include "compassRender.h"
#include <vector>
#include <numeric>
#include <iostream>
#include <sstream>
using namespace std;

//------------------------------------
// Bimodal
//------------------------------------
void compassRender::renderStyleBimodal(vector<int> &indices_for_rendering){

    vector<double> mode_max_dist_array =
    model->clusterData(indices_for_rendering);
    
    if (mode_max_dist_array.size() < 1){
        renderBareboneCompass();
        return;
    }
    
    // ---------------
    // Draw the center circle
    // ---------------
    drawCompassCentralCircle();


    
    
    // ---------------
    // draw the triangle
    // ---------------
    
    glPushMatrix();
    // Note that the index starts from -1
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
            //----------------
            // For each landmark, pick a color from the list 
            //----------------
            glColor4f(
                      [model->configurations[@"landmark_color"][0] floatValue]/256,
                      [model->configurations[@"landmark_color"][1] floatValue]/256,
                      [model->configurations[@"landmark_color"][2] floatValue]/256,
                      [model->configurations[@"landmark_color"][3] floatValue]/256);
            
            
            int j = indices_for_rendering[i];
            data_ = model->data_array[j];
        }
    
        // **Select appropriate radius and distance based on mode
        
        float base_radius = 0.0;
        double distance;
        
        if (data_.distance <= mode_max_dist_array[0]){
            //-----------
            // Close
            //-----------
            base_radius = central_disk_radius;
            distance = data_.distance /
            mode_max_dist_array[0] * compass_disk_radius;
        }else{
            //-----------
            // Far
            //-----------
            base_radius = central_disk_radius/4;
            base_radius = max((float)1.0, base_radius);
            
            glColor4f(48/256,
                      217/256,
                      86/256, 1);
            
            if (i == -1 && model->user_pos.isEnabled == true){
                glColor4f(0, 1, 0, 1);
            }
            
            distance = compass_disk_radius *
            data_.distance / mode_max_dist_array[1];
            if (data_.distance / mode_max_dist_array[1] > 1)
            {
                NSLog(@"Something wrong. Ratio: %f",
                      data_.distance / mode_max_dist_array[1]);
            }
        }

#ifdef __IPHONE__
        glPushMatrix();
        if (data_.distance <= mode_max_dist_array[0]){
            glTranslatef(0, 0, -1);
        }else{

        }
        drawRectangle(1, data_.orientation,
                      distance);
        glPopMatrix();
#else
        // Need to draw on different depth to avoid broken polygon
        glTranslatef(0, 0, 0.0001);
        // ---------------
        // Draw the line
        // ---------------
        glLineWidth(1);
        
        glPushMatrix();
        glRotatef(data_.orientation, 0, 0, -1);
        Vertex3D    vertex1 = Vertex3DMake(0, 0, 0);
        Vertex3D    vertex2 = Vertex3DMake(0,
                                           distance, 0);
        Line3D  line = Line3DMake(vertex1, vertex2);
        glVertexPointer(3, GL_FLOAT, 0, &line);
        glDrawArrays(GL_LINES, 0, 2);
        
        glPopMatrix();
#endif
    }
    glPopMatrix();
    
    // ---------------
    // draw the scale box
    // ---------------
    drawCompassScaleBox(mode_max_dist_array[0]);
    
    // ---------------
    // draw the north indicator
    // ---------------
    drawCompassNorth();
    

    
    // ---------------
    // draw the scale indicator (for Binodal mode)
    // ---------------
    if (mode_max_dist_array.size() == 2){
        // Only need to draw the scale indicator in bimodal mode
#ifdef __IPHONE__
         glLineWidth(2);
#else
         glLineWidth(1);
#endif
        glColor4f(0, 0, 0, 1);
        drawCircle(0, 0, compass_disk_radius, 50, false);
    }
    
    // ---------------
    // draw the background (transparent) disk
    // ---------------
    
    glPushMatrix();
//    glTranslatef(0, 0, 0.1);
    drawCompassBackgroundDisk();
    glPopMatrix();
}