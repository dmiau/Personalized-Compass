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
            //[todo] fix color map (increase the size?)
            glColor4f((float)model->color_map[i][0]/256,
                      (float)model->color_map[i][1]/256,
                      (float)model->color_map[i][2]/256, 1);
            
            int j = indices_for_rendering[i];
            data_ = model->data_array[j];
        }
    
        // **Select appropriate radius and distance based on mode
        
        float base_radius = 0.0;
        double distance;
        
        if (data_.distance <= mode_max_dist_array[0]){
            base_radius = central_disk_radius;
            distance = data_.distance /
            mode_max_dist_array[0] * compass_disk_radius;
        }else{
            base_radius = central_disk_radius/4;
            
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
        
        // Need to draw on different depth to avoid broken polygon
        glTranslatef(0, 0, 0.0001);
        drawTriangle(base_radius, data_.orientation,
                     distance);
    }
    glPopMatrix();
    
    // ---------------
    // draw the north indicator
    // ---------------

    if (fabs(model->tilt) < 0.1 ){
        glColor4f(50/256,
                  50/256,
                  50/256, 0.6);
    }else{
        glColor4f(228/256,
                  101/256,
                  42/256, 1);
    }
    drawTriangle(1, 0, compass_disk_radius *
                 [model->configurations[@"north_indicator_to_compass_disk_ratio"] floatValue]);
    
    // ---------------
    // draw the box
    // ---------------
    bool isBoundaryIndicatorDrawn = false;
    
    if (fabs(model->tilt - 0) < 0.1 ){
        
        if (watchMode){
            
            // May need to shift the disk if the compass is not at the center
            
            
            if (compass_centroid.x != 0 || compass_centroid.y != 0){
                
                //[todo] need to clean up this part
                
                glPushMatrix();
                
                double renderD2realDRatio =
                (compass_disk_radius/mode_max_dist_array[0]);
                
                CLLocationDistance box_width = getMapWidthInMeters();
                float radius = [model->configurations[@"watch_radius"] floatValue];
                
                double boundary_radius = box_width * renderD2realDRatio
                * radius / mapView.frame.size.width;
                
                if (boundary_radius <= central_disk_radius)
                {
                    isBoundaryIndicatorDrawn = false;
                }else{
                    // Draw the circle
                    glLineWidth(2);
                    glColor4f(1, 0, 0, 0.5);
                    glRotatef(-model->camera_pos.orientation, 0, 0, -1);
                    drawCircle(-compass_centroid.x/radius * boundary_radius,
                               -compass_centroid.y/radius * boundary_radius,
                               boundary_radius, 50, false);
                    isBoundaryIndicatorDrawn = true;
                }
                glPopMatrix();
            }else{
                isBoundaryIndicatorDrawn = drawBoundaryCircle
                (compass_disk_radius/mode_max_dist_array[0]);
            }
        }else{
            glPushMatrix();
            glRotatef(-model->camera_pos.orientation, 0, 0, -1);
            isBoundaryIndicatorDrawn = drawBoxInCompass
            (compass_disk_radius/mode_max_dist_array[0]);
            glPopMatrix();
        }
    }
    
    // ---------------
    // draw the hollow indicator
    // (to indicate that there is a boudary indicator
    // ---------------
    if (!isBoundaryIndicatorDrawn){
////        glPushMatrix();
//        glColor4f(1, 1, 1, 1);
////        glTranslatef(0, 0, 2);
////        drawCircle(0, 0, central_disk_radius/1.5, 50, true);
////        glPopMatrix();
//    }else{
        glColor4f(1, 0, 0, 1);
        glPushMatrix();
        glTranslatef(0, 0, 2);
        drawCircle(0, 0, central_disk_radius/2, 50, true);
        glPopMatrix();
    }

    
    
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
    float alpha = 0;
    
    glPushMatrix();
    if (model->tilt == 0)
        alpha = [model->configurations[@"disk_color"][3] floatValue]/255;
    else
        alpha = 0.7;
    
    glColor4f([model->configurations[@"disk_color"][0] floatValue]/255,
              [model->configurations[@"disk_color"][1] floatValue]/255,
              [model->configurations[@"disk_color"][2] floatValue]/255,
              alpha);
    glTranslatef(0, 0, -1);
    drawCircle(0, 0, compass_disk_radius, 50, true);
    
    glPopMatrix();
}