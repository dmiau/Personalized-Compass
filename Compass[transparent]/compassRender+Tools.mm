//
//  compassRender+Tools.cpp
//  Compass[transparent]
//
//  Created by dmiau on 8/28/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#include "compassRender.h"

CGPoint compassRender::convertCompassPointToMapUV(CGPoint point){
    // render compass_centroid
    // Compass center in OpenGL coordinate system
    
    // model compassCenterXY
    // indicates the centroid of compass in the map window coordinate frame
    // (in terms of u, v, not in terms of latitude and longitude)
    
    // First convert compass point to the OpenGL View coordinates
    
    CGPoint result_pt;
    result_pt.x = model->compassCenterXY.x + point.x;
    result_pt.y = model->compassCenterXY.y - point.y;
    return result_pt;
}