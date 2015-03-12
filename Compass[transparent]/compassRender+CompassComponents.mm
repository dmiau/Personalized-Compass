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
            glLineWidth(3);
            glColor4f([model->configurations[@"scale_box_color"][0] floatValue]/255.0,
                      [model->configurations[@"scale_box_color"][1] floatValue]/255.0,
                      [model->configurations[@"scale_box_color"][2] floatValue]/255.0,
                      [model->configurations[@"scale_box_color"][3] floatValue]/255.0);
            
            if (compass_centroid.x != 0 || compass_centroid.y != 0){
                // May need to shift the disk if the compass is not at the center
                
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
                    // Draw the scale circle
                    glRotatef(-model->camera_pos.orientation, 0, 0, -1);
                    
                    CGPoint refGLPoint;
                    refGLPoint.x = model->compassRefMapViewPoint.x - view_width/2;
                    refGLPoint.y = view_height/2 - model->compassRefMapViewPoint.y;
                    
                    drawCircle(-refGLPoint.x/radius * boundary_radius,
                               -refGLPoint.y/radius * boundary_radius,
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
        glColor4f([model->configurations[@"scale_box_color"][0] floatValue]/255.0,
                  [model->configurations[@"scale_box_color"][1] floatValue]/255.0,
                  [model->configurations[@"scale_box_color"][2] floatValue]/255.0,
                  [model->configurations[@"scale_box_color"][3] floatValue]/255.0);
        glPushMatrix();
        glTranslatef(0, 0, 2);
        drawCircle(0, 0, central_disk_radius/2, 50, true);
        glPopMatrix();
    }
}

//--------------
// The center circle of the compass
//--------------

void compassRender::drawCompassCentralCircle(){
    // ---------------
    // Draw the center circle
    // ---------------
    
    if (!compassRefDot.isVisible){
        glColor4f([model->configurations[@"circle_color"][0] floatValue]/255,
                  [model->configurations[@"circle_color"][1] floatValue]/255,
                  [model->configurations[@"circle_color"][2] floatValue]/255,
                  1);
    }else{
        glColor4f(1, 0, 0, 1);
    }
    
    // draw the center circle
    glPushMatrix();
    // Translate to the front to avoid broken polygon
    glTranslatef(0, 0, 1);
    drawCircle(0, 0, central_disk_radius, 50, true);
    glPopMatrix();
}


//--------------
// Compass Reference Point
//--------------

void CompassRefDot::render(){

    switch (deviceType) {
        case PHONE:
            glColor4f(0, 0, 1, 0.7);
            drawCircle(0, 0, 6, 50, YES);
            glColor4f(1, 1, 1, 0.3);
            drawCircle(0, 0, 8, 50, YES);
            glColor4f(0, 0, 0, 0.3);
            drawCircle(0, 0, 9, 50, YES);
            break;
        case WATCH:
            glColor4f(0, 0, 1, 0.7);
            drawCircle(0, 0, 3, 50, YES);
            break;
        case DESKTOP:
            glColor4f(0, 0, 1, 0.7);
            drawCircle(0, 0, 6, 50, YES);
            glColor4f(1, 1, 1, 0.3);
            drawCircle(0, 0, 8, 50, YES);
            glColor4f(0, 0, 0, 0.3);
            drawCircle(0, 0, 9, 50, YES);
            break;
        default:
            break;
    }
    

}

//--------------
// Draw the north indicator
//--------------
void compassRender::drawCompassNorth(){
    // ---------------
    // draw the north indicator
    // ---------------
   
    glColor4f(0.5,0.5, 0.5, 1);
    // Note the radius is fixed to 1
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
    
    if (isCompassTouched){
        glColor4f(0.5, 0.5, 0.5, 1);
        drawCircle(0, 0, compass_disk_radius, 50, true);
    }else{        
        drawCircle(0, 0, compass_disk_radius, 50, true);
    }
    glPopMatrix();
}

void compassRender::drawInteractiveLine(){
    glLineWidth(4);
    glColor4f(1, 0, 0, 1);
    
    Vertex3D    vertex1 = Vertex3DMake(0, 0, 0);
    Vertex3D    vertex2 = Vertex3DMake(500*cos(interactiveLineRadian),
                                       500*sin(interactiveLineRadian), 0);
    Line3D  line = Line3DMake(vertex1, vertex2);
    glVertexPointer(3, GL_FLOAT, 0, &line);
    glDrawArrays(GL_LINES, 0, 2);
}

//--------------------
// Central Cross
//--------------------
void Cross::applyDeviceStyle(DeviceType deviceType){
    switch (deviceType) {
        case PHONE:
            thickness = 4;
            radius = 35;
            break;
        case WATCH:
            thickness = 4;
            radius = 20;
            break;
        case DESKTOP:
            thickness = 2;
            radius = 25;
            break;
        default:
            break;
    }
}

void Cross::render(){
    glLineWidth(thickness);
    glColor4f(1, 0, 0, 1);
    
    Vertex3D    vertex1 = Vertex3DMake(radius, 0, 0);
    Vertex3D    vertex2 = Vertex3DMake(-radius, 0, 0);
    Line3D  line = Line3DMake(vertex1, vertex2);
    glVertexPointer(3, GL_FLOAT, 0, &line);
    glDrawArrays(GL_LINES, 0, 2);
    
    Vertex3D    vertex3 = Vertex3DMake(0, radius, 0);
    Vertex3D    vertex4 = Vertex3DMake(0, -radius, 0);
    Line3D  line1 = Line3DMake(vertex3, vertex4);
    glVertexPointer(3, GL_FLOAT, 0, &line1);
    glDrawArrays(GL_LINES, 0, 2);
}
