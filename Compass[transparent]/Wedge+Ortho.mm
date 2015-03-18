//
//  Wedge+Ortho.cpp
//  Compass[transparent]
//
//  Created by dmiau on 8/12/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "Wedge+Ortho.h"

#include "commonInclude.h"
#include <vector>
#include <numeric>
#include <iostream>
#include <sstream>
#include <Box2D/Box2D.h>


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
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];   
    model = myMdl;
#ifndef __IPHONE__
    min_base = [prefs doubleForKey:@"OSX_wedge_min_base"];
    // This is roughly 1/7 the screen size
    max_intrusion = [prefs doubleForKey:@"OSX_wedge_max_intrusion"];
    edge_padding   = [prefs doubleForKey:@"OSX_wedge_edge_padding"];
#else
    min_base = [prefs doubleForKey:@"iOS_wedge_min_base"];
    max_intrusion = [prefs doubleForKey:@"iOS_wedge_max_intrusion"];
    edge_padding   = [prefs doubleForKey:@"iOS_wedge_edge_padding"];
#endif
    
    // Place holder
    intrusions[0] = -100;
    intrusions[1] = -100;
    axis_intrusion = -100;

    
    //---------------------
    // Figure out if coordinate transform is needed
    //---------------------
    
    // We rotate the display such that the object of interest is in the
    // positive x quadrant.
    // section_rotation specifies how the screen should be rotated back.
    applyCoordTransform(diff_xy.x, diff_xy.y,
                        screen_box.width, screen_box.height,
                        &section_rotation, &tx, &ty,
                        &t_width, &t_height);
    
    // Need to pad the screen to make the visible area "smaller"
    // so the rotating is smoother (somehow padding is necessary to make it work)
    t_height = t_height - 2 *edge_padding;
    t_width = t_width - 2 *edge_padding;
    
    //---------------------
    // Calculate wedge parameters
    //---------------------
    wedgeParams myWedgeParams;
    if ((ty <= (t_height/2))
        && (ty >= -(t_height/2)))
    {
        // Region Two is the edge case, the easy case
        myWedgeParams = calculateRegionTwoParams(tx, ty);
    }else{
        // Region One is the corner case, the hard case
        myWedgeParams = calculateRegionOneParams(tx, ty);
    }
    
    leg = myWedgeParams.leg;
    aperture = myWedgeParams.aperture;
    wedge_rotation = myWedgeParams.wedge_rotation;
    base = leg * sin(aperture/2)*2;
}


//-------------------------
// Region Two (the edge case, the easy case)
//-------------------------
wedgeParams wedge::calculateRegionTwoParams(double tx, double ty){
    wedgeParams my_wedgeParams;
    
    // the distance of an off-screen point p to the edge of the display
    double off_screen_dist = tx - t_width/2;
    
    //-----------------
    // The following part is kind of a hack.
    // The original wedge paper calcualtes the length of the leg, and the
    // aperture based on the distance of an off-screen object. (The distance
    // is measured from the edge of the screen to the object).
    // In addition, the original formula was based on pixels (as opposed to
    // the actual length of an off-screen object. The pixel size varies from
    // device to device, thus here I add a correction factor to convert the
    // suggested leg length to soemthing that is practical to an iPhone.
    //
    // However, I think a better way to parameterize is to calculate the
    // intrusion, the base. And all parameters should be based on actual distances.
    //-----------------
    
    float correction_x = [model->configurations[@"wedge_correction_x"]
                          floatValue];
    double corrected_off_screen_dist = off_screen_dist * correction_x;
    
    
    // This seems to be the part that needs to be modified.
    double l_leg = corrected_off_screen_dist +
    log((corrected_off_screen_dist + 20)/12)*10;
    
    double l_aperture = (5+corrected_off_screen_dist*0.3)/l_leg;
    l_leg = l_leg / correction_x;
    
    
    // Convert aperture and leg to instrusion and base
    double l_base = l_leg * sin(l_aperture/2) * 2;
    
    // Calculate intrusion here
    axis_intrusion = l_leg * cos(l_aperture/2) - off_screen_dist;
    
    double l_wedge_rotation = 180; // 0 degree is in the +X OpenGL direction
    
    // Check if the wedge is within the screen box
    // When the base base becomes outside of the screen box,
    // we need to either make the base smaller, or slightly rotate the wedge.
    if ((ty + l_base/2 > (t_height/2))
        || (ty - l_base/2 < -(t_height/2)) )
    {
    
        //-----------------
        // The edge of the base goes off-screen, we need to do something
        //-----------------
        
        bool requiresFlipped = false;
        double correction_factor = 1;
        // Check if we need to pre flip the points
        // Note that we only perform calculation in the positive quadrant
        if (ty < 0){
            ty = -ty;
            requiresFlipped = true;
            correction_factor = -1;
        }
        
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
            
            // Make sure the base is always of cerntain minimal length
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
    
    // Apply leg contraint
    // Calculate the leg length based on the aperture and minimal visible
    // instrusion
    
    // Note the 2 edge_paddings are added back so two intrusions can be calculated
    // correctly.
    double corrected_leg =
    applyVisibleIntrusionConstraint(DoublePointMake(t_width + edge_padding*2, t_height+ edge_padding*2), DoublePointMake(tx, ty),
        l_wedge_rotation,  l_aperture, max_intrusion);
    
    // Here we fix the intrusion for ALL locations
//    if (l_leg> corrected_leg)
        l_leg = corrected_leg;
    
    
    my_wedgeParams.leg = l_leg;
    my_wedgeParams.aperture = l_aperture;
    my_wedgeParams.wedge_rotation = l_wedge_rotation;
    return my_wedgeParams;
}

//-------------------------
// Region One (the corner and hard region)
//-------------------------
wedgeParams wedge::calculateRegionOneParams(double tx, double ty){
    wedgeParams my_wedgeParams;
    double l_leg, l_aperture, l_wedge_rotation;

    
    bool requiresFlipped = false;
    double correction_factor = 1;
    // Check if we need to pre flip the points
    // Note that we only perform calculation in the positive quadrant
    if (ty < 0)
    {
        ty = -ty;
        requiresFlipped = true;
        correction_factor = -1;
    }

    /*
    
                   .     Region 1
     |           .
     _______________________
     |        . |     .      Region 2
     |      .   |  .
     |    .    .|
     |  .  .    |
     |.         |
    ________________________
    
    The smaller angle corresponding to the triangle in region1 is a
    The bigger angle corresponding to the triangle in region2 is b
    Mid ref direciton is the direction of the line passing through the 
    corner of the screen boundary
    */
    
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
    // if the point were at the border of region two
    //-----------------
    
    wedgeParams initWedgeparams = calculateRegionTwoParams
    (dist * cos(a), t_height/2);
    l_leg = initWedgeparams.leg;
    l_aperture = initWedgeparams.aperture; // So the aperture is fixed
    
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
    - sqrt(pow(t_height, 2)+pow(t_width, 2))/2 + 100; // The last 100 is rather arbitrary
    double mid_leg = mid_instrusion / cos(l_aperture/2);

    l_leg = (1-k) * l_leg + k * mid_leg;
    
    //-----------------------------
    // Calculate the leg length based on the aperture and minimal visible
    // instrusion
    //-----------------------------
    // Note the 2 edge_paddings are added back so two intrusions can be calculated
    // correctly.
    
    double corrected_leg =
    applyVisibleIntrusionConstraint(DoublePointMake(t_width + edge_padding*2, t_height+ edge_padding*2),
                            DoublePointMake(tx, ty*correction_factor),
                                    l_wedge_rotation,  l_aperture, max_intrusion);
//    if (l_leg> corrected_leg)
        l_leg = corrected_leg;
        
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
#ifdef __IPHONE__
    glLineWidth(4);
#else
    glLineWidth(2);
#endif
    
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
    
    
    //----------------
    // Populate wedge label info
    //----------------
    CGPoint xy = CGPointMake(leg*cos(aperture/2), 0);
    xy = rotateCCW(xy, wedge_rotation);
    xy.x = xy.x + tx; xy.y = xy.y + ty;
    xy = rotateCCW(xy, section_rotation);

    wedgeLabelinfo.centroid = xy;
    wedgeLabelinfo.aperture = aperture;
    wedgeLabelinfo.leg = leg;
    wedgeLabelinfo.distance = sqrt(pow(xy.x, 2) + pow(xy.y, 2));
    wedgeLabelinfo.orientation = -atan2(xy.y, xy.x) /M_PI * 180 + 90;
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

//--------------
// Show wedge information
//--------------
void wedge::showInfo(){
    cout << "================" << endl;
    cout << "(tx, ty): " << tx << ", " << ty << endl;
    cout << "Base: " << base << endl;
    cout << "Aperture: " << aperture / M_PI * 180 << endl;
    cout << "Axis intrusion: " << axis_intrusion << endl;
}


//------------------
// Based on the display size, calculated wedge paparemters,
// adjust the leg length to ensure minial visible intrusions
//------------------
double applyVisibleIntrusionConstraint(DoublePoint wh, DoublePoint diff_xy,
                                       double wedge_rotation_deg, double aperture, double min_visible_intrusion)
{
    // Find the intersections with the display edge
    bool flip = false;
    if (diff_xy.y < 0){
        diff_xy.y = -diff_xy.y;
        wedge_rotation_deg = 360 - wedge_rotation_deg;
        flip = true;
    }
    
    // A wedge (in the first quadrant) intersects with the edge of the screen at
    // two points, called the outer point and the inner point
    DoublePoint outer, inner;
    
    // Calculate the outer point
    
    // Need to check the uppoer point is on the vertical edge or the horizontal edge
    
    // Check the vertical edge first
    outer.x = wh.x/2;
    outer.y = tan(wedge_rotation_deg/180*M_PI - aperture/2) * (outer.x - diff_xy.x) +
    diff_xy.y;
    
    if (outer.y > wh.y/2){
        // The outer point is on the horizontal edge
        outer.y = wh.y/2;
        outer.x = 1/tan(wedge_rotation_deg/180*M_PI - aperture/2) * (outer.y - diff_xy.y) +
        diff_xy.x;
    }
    
    // Calculate the inner point
    inner.x = wh.x/2;
    inner.y = tan(wedge_rotation_deg/180*M_PI + aperture/2) * (inner.x - diff_xy.x) +
    diff_xy.y;
    
    // Find the coordinates corresponding to the minimal intursion
    double inner_leg_length, outer_leg_length;
    inner_leg_length = sqrt(pow(inner.x - diff_xy.x, 2) +
                            pow(inner.y - diff_xy.y, 2));
    
    outer_leg_length = sqrt(pow(outer.x - diff_xy.x, 2) +
                            pow(outer.y - diff_xy.y, 2));
    
    // Pick the longest leg as the suggested leg
    
    return max(inner_leg_length, outer_leg_length) + min_visible_intrusion;
}



