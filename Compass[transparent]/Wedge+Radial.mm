//
//  Wedge+Radial.cpp
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/14/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#include "Wedge+Radial.h"

// Before calling drawOneSide, the location needs to be rotated such that it
// fells into the positive triangle
void compassRender::drawOneSide(double rotation, double width, double height,
                                double tx, double ty,
                                double *out_leg, double *out_aperture)
{
    double dist = sqrt(pow(tx, 2) + pow(ty, 2));
    
    // parameters:
    // screen_dist is the distance from the center to the poitn where the
    // the line that connects the center and the landmark intersect with
    // the screen border.
    double screen_dist, wedge_rotation, max_aperture;
    calculateDistInBox(height, width,
                       tx, ty,
                       &screen_dist, &wedge_rotation, &max_aperture);
    
    // We will use rotation and max_aperture from calculateDistInBox
    if (watchMode){
        screen_dist = [model->configurations[@"watch_radius"] floatValue];
    }
    double off_screen_dist = dist - screen_dist;
    
    // distance needs to be corrected
    
    // -----------------------
    // The parameters here may need to be tweeked)
    // -----------------------
    
    // I believe the parameters from the paper was based the following
    // parameters:
    //
    // Here are the specs of an Compag iPad:
    // 3"x4" (x 1.33), dpi: 105
    //
    // However, the interface was emulated on a computer monitor,
    // and the paper indicates the screen is 33% larger than the original
    // screen.
    // A typical screen's resolution is 72-96 dpi
    // 3"x4" x 1.33 x 72 = 287.28 x 374
    
    // This means that I need to apply a scale parameter before using
    // the orignal formula to calculate the leg and aperture
    
    //-----------------
    // Calculate the scale parameter
    //-----------------
    
    float correction_x = [this->model->configurations[@"wedge_correction_x"]
                          floatValue];
    double corrected_off_screen_dist = off_screen_dist * correction_x;
    
    
    double leg = corrected_off_screen_dist + log((corrected_off_screen_dist + 20)/12)*10;
    
    double aperture = (5+corrected_off_screen_dist*0.3)/leg;
    leg = leg / correction_x;
    
    //-------------------
    // Apply constraints
    //-------------------
    
    if (!watchMode){
        //---------------------
        // The normal case
        //---------------------
        if (aperture > max_aperture)
        {
            // Calculate the distance of base
            double base = leg*sin(max_aperture/2)*2;
            if (base < 100)
                // When the aperture > max_aperture and
                // base is smal (<100),
                // it means the wedge is at the corner of the display.
                // In this case, the base can not be continously decreasing.
                // Therefore we need to set the aperture in a way that the 

                aperture = atan2(50, leg) * 2;
            else
                aperture = max_aperture;
        }
        
//        // Calculate the leg length based on the aperture and minimal visible
//        // instrusion
//        leg = applyVisibleIntrusionConstraint(CGPointMake(width, height),
//            CGPointMake(tx, ty), wedge_rotation, aperture, 100);
    }else{
        //---------------------
        // Constraint of the watch mode
        //---------------------
        double max_leg = 0.0;
        
        // This part can be optimized later
        float radius = [model->configurations[@"watch_radius"] floatValue];
                
        float max_half_base = sqrt(pow(radius, 2) - pow(radius * 0.75, 2)) * 0.90;
        max_aperture = atan2(max_half_base, dist - radius * 0.75);
        max_leg = sqrt(pow(dist - radius*0.75, 2) + pow(max_half_base, 2));
        
        if (aperture > max_aperture){
            aperture = max_aperture;
            leg = max_leg;
        }
    }

    
    *out_aperture = aperture; *out_leg = leg;
    
    //-----------------
    // Draw the wedge
    //-----------------
    //        v2
    // v1
    //        v3
#ifdef __IPHONE__
    glLineWidth(4);
#else
    glLineWidth(2);
#endif
    
    glPushMatrix();
    
    // Plot the triangle first, then rotate and translate
    glRotatef(rotation, 0, 0, 1);
    
    glTranslatef(tx, ty, 0);
    glRotatef(wedge_rotation, 0, 0, 1);
    
    Vertex3D    vertex1 = Vertex3DMake(0, 0, 0);
    Vertex3D    vertex2 = Vertex3DMake(leg * cos(aperture/2),
                                       leg * sin(aperture/2), 0);
    
    Vertex3D    vertex3 = Vertex3DMake(leg * cos(aperture/2),
                                       -leg * sin(aperture/2), 0);
    
    TriangleLine3D  triangle = TriangleLine3DMake(vertex1, vertex2, vertex3);
    glVertexPointer(3, GL_FLOAT, 0, &triangle);
    glDrawArrays(GL_LINE_STRIP, 0,4);
    
    glPopMatrix();
}


void calculateDistInBox(double height, double width,
                        double tx, double ty,
                        double* dist, double* rotation, double* max_aperture)
{
    
    double xx, yy, theta, a2, b2, c, c2;
    // (xx, yy) is the intersection point
    xx = width/2;
    yy = ty/tx * xx;
    // dist is the distance from the centroid to the intersection point
    *dist = sqrt(pow(xx, 2) + pow(yy, 2));
    *rotation = atan2(ty, tx) * 180/M_PI + 180;
    
    // calculate maximal alloable aperture
    // k denotes how close the wedge can touch the boundary
    double k = 0.9;
    c = height/2*k - fabs(yy); c2 = pow(c, 2);
    if (ty >=0){
        b2 = (pow(tx-xx, 2) + pow(ty-height/2*k, 2));
    }else{
        b2 = (pow(tx-xx, 2) + pow(ty+height/2*k, 2));
    }
    
    a2 = pow(tx-xx, 2) + pow(ty-yy, 2);
    theta = acos((a2 + b2 -c2)/(2*sqrt(a2*b2)));
    *max_aperture = 2 * theta;
    
    // Note the aperture cannot be too small either    
}


