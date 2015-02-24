//
//  compassRender+Tools.cpp
//  Compass[transparent]
//
//  Created by dmiau on 8/28/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#include "compassRender.h"

CGPoint compassRender::convertCompassPointToMapUV(CGPoint point,
                                                  CGFloat window_width, CGFloat window_height){
    // render compass_centroid
    // Compass center in OpenGL coordinate system
    
    // model compassRefMapViewPoint
    // indicates the centroid of compass in the map window coordinate frame
    // (in terms of u, v, not in terms of latitude and longitude)
    
    // First convert compass point to the OpenGL View coordinates
    CGPoint result_pt;
    result_pt.x = compass_centroid.x + window_width/2 + point.x;
    result_pt.y = window_height/2 - compass_centroid.y - point.y;
    
    // Note: Here I need to use compass_centroid, which reflect
    // true compass centroid in the OpenGL coordinate system
    // I cannot use model->compassRefMapViewPoint because when the compass center is
    // locked, compassRefMapViewPoint remains to be zero
        
    return result_pt;
}

void compassRender::incrementCompassRadisByFactor(float factor){
    float default_radius = [model->configurations[@"compass_disk_radius"] floatValue];
    float current_scale = compass_disk_radius / default_radius;
    compass_disk_radius = default_radius * (current_scale + factor);
//    central_disk_radius = compass_disk_radius *
//    [model->configurations[@"central_disk_to_compass_disk_ratio"] floatValue];
}

void compassRender::adjustAbsoluteCompassScale(float scale){
    compass_disk_radius =
    [model->configurations[@"compass_disk_radius"] floatValue] * scale;
//    central_disk_radius = compass_disk_radius *
//    [model->configurations[@"central_disk_to_compass_disk_ratio"] floatValue];
}