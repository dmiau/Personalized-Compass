//
//  compassRender+CompassComponents.cpp
//  Compass[transparent]
//
//  Created by Daniel on 2/18/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//
#include "commonInclude.h"
#include <cmath>
#include <algorithm>
#include "compassRender.h"

#ifdef __IPHONE__
typedef UIFont NSFont;
typedef UIColor NSColor;
#import "Texture2D.h"
#endif

void compassRender::drawCompassScaleBox(double longestDistInMeters){
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
                (compass_disk_radius/longestDistInMeters);
                
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
                (compass_disk_radius/longestDistInMeters);
            }
        }else{
            glPushMatrix();
            glRotatef(-model->camera_pos.orientation, 0, 0, -1);
            isBoundaryIndicatorDrawn = drawBoxInCompass
            (compass_disk_radius/longestDistInMeters);
            glPopMatrix();
        }
    }
    
    // ---------------
    // draw the hollow indicator
    // (to indicate that there is a boudary indicator
    // ---------------
    if (!isBoundaryIndicatorDrawn){
        glColor4f(1, 0, 0, 1);
        glPushMatrix();
        glTranslatef(0, 0, 2);
        drawCircle(0, 0, central_disk_radius/2, 50, true);
        glPopMatrix();
    }
}


void compassRender::drawCompassCentralCircle(){
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
}

void compassRender::drawCompassNorth(){
    // ---------------
    // draw the north indicator
    // ---------------
    
    if (fabs(model->tilt) < 0.1 ){
        //        glColor4f(50/256,
        //                  50/256,
        //                  50/256, 0.6);
        glColor4f(1,
                  0,
                  0, 1);
        
    }else{
        glColor4f(228/256,
                  101/256,
                  42/256, 1);
    }
    drawTriangle(1, 0, compass_disk_radius *
                 [model->configurations[@"north_indicator_to_compass_disk_ratio"] floatValue]);
}

void compassRender::drawCompassBackgroundDisk(){
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
