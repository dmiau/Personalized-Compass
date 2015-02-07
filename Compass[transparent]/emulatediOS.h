//
//  emulatediOS.h
//  Compass[transparent]
//
//  Created by Daniel on 2/7/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#ifndef __Compass_transparent___emulatediOS__
#define __Compass_transparent___emulatediOS__

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


//----------------------------------
// emulated iOS
//----------------------------------
class compassRender; // Forward declration

class emulatediOS{
public:
    CGPoint centroid;
    CLLocationCoordinate2D latlon;
    float width;
    float height;
    float radius;
    bool isCircle;
    bool is_enabled;
    bool is_touched;
public:
    // Default constructor
    emulatediOS(){
        
    };
    void render(compassRender* render, bool isMaskOn);
    bool isTouched(CGPoint pointInOpenGL);
};

#endif /* defined(__Compass_transparent___emulatediOS__) */
