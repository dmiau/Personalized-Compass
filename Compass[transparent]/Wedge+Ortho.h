//
//  Wedge+Ortho.h
//  Compass[transparent]
//
//  Created by dmiau on 8/12/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#ifndef __Compass_transparent___wedgeClass__
#define __Compass_transparent___wedgeClass__

#include <iostream>
#include "compassRender.h"

//----------------------------------
// wedge related stuff
//----------------------------------
class box{
public:
    double width;
    double height;
public:
    box(double in_width, double in_height){
        width = in_width;
        height = in_height;
    }
};

typedef struct t_wedgeParams{
    double leg;
    double aperture;
    double wedge_rotation;
}wedgeParams;


class wedge{
public:
    compassMdl *model;
    CGPoint shift;
    CGPoint vertices[2];
    double section_rotation; // the object's orientation wrt the centroid
    double wedge_rotation; // the angles the wedge needs to rotate
    // so the two legs are within the box
    
    double box_width;
    double box_height;
    double tx;
    double ty;
    double t_width;
    double t_height;
    
    double leg;
    double aperture;
    double base;
    double min_base;
    double visible_leg;
    
    label_info wedgeLabelinfo;
public:
    wedge(compassMdl* myMdl, box screen_box, CGPoint diff_xy);
    wedgeParams calculateRegionOneParams(double tx, double ty);
    wedgeParams calculateRegionTwoParams(double tx, double ty);
    void render();
    void correctWedgeParams();
};


//----------------------------------
// Tools
//----------------------------------
// Forward declaration
void applyCoordTransform(double x_diff, double y_diff,
                         double width, double height,
                         double *rotation,
                         double *tx, double *ty,
                         double *new_width, double *new_height);




#endif /* defined(__Compass_transparent___wedgeClass__) */
