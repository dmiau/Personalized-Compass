//
//  wedgeClass.cpp
//  Compass[transparent]
//
//  Created by dmiau on 8/12/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "wedgeClass.h"

#include "commonInclude.h"
#include <vector>
#include <numeric>
#include <iostream>
#include <sstream>
#include <Box2D/Box2D.h>
#include "wedgeClass.h"


#ifndef __IPHONE__
#import "GLString.h"
#else
#import "GLString.h"
#import <GLKit/GLKit.h>
#endif

//----------------------------
// Wedge class
//----------------------------
wedge::wedge(compassMdl* myMdl, box screen_box, CGPoint diff_xy){
    
    //---------------------
    // Initialize parameters
    //---------------------
    model = myMdl;
    min_base = 100;
    
    //---------------------
    // Figure out if coordinate transform is needed
    //---------------------
    applyCoordTransform(diff_xy.x, diff_xy.y,
                        screen_box.width, screen_box.height,
                        &section_rotation, &tx, &ty,
                        &t_width, &t_height);
    
    //---------------------
    // Calculate wedge parameters
    //---------------------
    wedgeParams myWedgeParams;
    if ((ty <= t_height/2) && (ty >= -t_height/2)){
        myWedgeParams = calculateRegionTwoParams(tx, ty);
    }else{
        myWedgeParams = calculateRegionOneParams(tx, ty);
    }
    leg = myWedgeParams.leg;
    aperture = myWedgeParams.aperture;
    wedge_rotation = myWedgeParams.wedge_rotation;
    base = leg * sin(aperture/2)*2;
}


//-------------------------
// Region Two
//-------------------------
wedgeParams wedge::calculateRegionTwoParams(double tx, double ty){
    wedgeParams my_wedgeParams;
    
    // Check which region the point is in
    double off_screen_dist = tx - t_width/2;
    
    //-----------------
    // Calculate the scale parameter
    //-----------------
    
    float correction_x = [model->configurations[@"wedge_correction_x"]
                          floatValue];
    double corrected_off_screen_dist = off_screen_dist * correction_x;
    
    
    double l_leg = corrected_off_screen_dist + log((corrected_off_screen_dist + 20)/12)*10;
    
    double l_aperture = (5+corrected_off_screen_dist*0.3)/l_leg;
    l_leg = l_leg / correction_x;
    
    
    // Convert aperture and leg to instrusion and base
    double l_base = l_leg * sin(l_aperture/2) * 2;
    
    double l_wedge_rotation = 180;
    
    // Check if the wedge is within the screen box
    if ((ty + l_base/2 > t_height/2) || (ty - l_base/2 < -t_height/2) ){
        if ([model->configurations[@"wedge_style"] isEqualToString:@"modified"]){
            
            bool requiresFlipped = false;
            double correction_factor = 1;
            // Check if we need to pre flip the points
            // Note that we only perform calculation in the positive quadrant
            if (ty < 0){
                ty = -ty;
                requiresFlipped = true;
                correction_factor = -1;
            }
            
            
            //-----------------
            // In region 2
            //-----------------
            
            if (l_base < min_base){
                // Calculate the interaction of the leg and edge
                double x = tx - sqrt(pow(l_leg, 2) - pow((t_height/2 - ty), 2));
                double theta = atan2((t_height/2 - ty), (tx-x));
                l_wedge_rotation = 180 +
                (correction_factor * (l_aperture/2 - theta))/M_PI * 180;
            }else{
                // Apply base constraint first
                l_base = (t_height/2 - ty) * 2;
                l_aperture = asin(l_base/2/l_leg)*2;
                if (l_base < min_base){
                    l_base = min_base;
                    l_aperture = asin(l_base/2/l_leg)*2;
                    double x = tx - sqrt(pow(l_leg, 2) - pow((t_height/2 - ty), 2));
                    double theta = atan2((t_height/2 - ty), (tx-x));
                    l_wedge_rotation = 180 +
                    correction_factor * (l_aperture/2 - theta) /M_PI * 180;
                }
            }
            
            
            if (requiresFlipped){
                // Flip ty back
                ty = -ty;
            }
        }
        
    }
    
    my_wedgeParams.leg = l_leg;
    my_wedgeParams.aperture = l_aperture;
    my_wedgeParams.wedge_rotation = l_wedge_rotation;
    return my_wedgeParams;
}

//-------------------------
// Region One
//-------------------------
wedgeParams wedge::calculateRegionOneParams(double tx, double ty){
    wedgeParams my_wedgeParams;
    double l_leg, l_aperture, l_wedge_rotation;

    
    bool requiresFlipped = false;
    double correction_factor = 1;
    // Check if we need to pre flip the points
    // Note that we only perform calculation in the positive quadrant
    if (ty < 0){
        ty = -ty;
        requiresFlipped = true;
        correction_factor = -1;
    }
    

    //-----------------
    // In region 1
    //-----------------
    // see the 8.13 notes
    
    double dist = sqrt(pow(tx, 2) + pow(ty, 2));
    double a = asin(t_height/2/dist);
    double b = atan(t_height/t_width);
    double theta = atan(ty/tx);
    
    //-----------------
    // Calculat the initial condition,
    // if the point were at the border of region 1
    //-----------------
    
    wedgeParams initWedgeparams = calculateRegionTwoParams
    (dist * cos(a), t_height/2);
    l_leg = initWedgeparams.leg;
    l_aperture = initWedgeparams.aperture;
    double init_b = (initWedgeparams.wedge_rotation - 180)/180*M_PI;
    //----------------
    // this part has some issues
    double k = (theta - a)/(b-a);
    l_wedge_rotation = 180 + correction_factor/M_PI * 180 *
    ((1-k) * init_b + k * b);
    
    //----------------
    // Calculate the ending condition
    //----------------
    double mid_instrusion = dist
    - sqrt(pow(t_height, 2)+pow(t_width, 2))/2 + 100;
    double mid_leg = mid_instrusion / cos(l_aperture/2);

    l_leg = (1-k) * l_leg + k * mid_leg;
    
    //----------------
    // Set constraints to the base and legs
    //----------------
    
    if (requiresFlipped){
        // Flip ty back
        ty = -ty;
    }
    
    my_wedgeParams.leg = l_leg;
    my_wedgeParams.aperture = l_aperture;
    my_wedgeParams.wedge_rotation = l_wedge_rotation;
    return my_wedgeParams;
}

void wedge::render(){
    //-----------------
    // Draw the wedge
    //-----------------
    //        v2
    // v1
    //        v3
    glLineWidth(4);
    
    glPushMatrix();
    
    
    // Plot the triangle first, then rotate and translate
    glRotatef(section_rotation, 0, 0, 1);
    
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

//--------------
// Tools
//--------------
void applyCoordTransform(double x_diff, double y_diff,
                         double width, double height,
                         double *rotation,
                         double *tx, double *ty,
                         double *new_width, double *new_height)
{
    double orientation = atan2(y_diff, x_diff);
    double critical_angle = atan2(height, width);
    // The output of atan2 is [-pi, pi]
    // So the first angle check should be ok
    
    *new_width = width; *new_height = height;
    
    // Test four quadrant
    if (orientation < critical_angle
        && orientation >= - critical_angle)
    {
        *rotation = 0;
        *tx = x_diff; *ty = y_diff;
    }else{
        
        // Make sure orientation is always positive
        // The output of atan2 is [-pi, pi]
        if (orientation < 0) orientation += M_PI * 2;
        
        if (orientation < (M_PI - critical_angle)
            && orientation >= critical_angle)
        {
            *rotation = M_PI_2;
            *tx = y_diff; *ty = -x_diff;
            *new_width = height; *new_height = width;
        }else  if (orientation < (M_PI + critical_angle)
                   && orientation >= (M_PI - critical_angle))
        {
            *rotation = M_PI;
            *tx = -x_diff; *ty = -y_diff;
        }else{
            *rotation = M_PI * 3/2;
            *tx = -y_diff; *ty = x_diff;
            *new_width = height; *new_height = width;
        }
        
    }
    *rotation = *rotation / M_PI * 180; // convert to degree
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
}