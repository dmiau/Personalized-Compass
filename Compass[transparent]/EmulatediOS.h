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

@class DesktopViewController;

//----------------------------------
// emulated iOS
//----------------------------------
class compassRender; // Forward declration
class compassMdl;

class EmulatediOS{
public:
    CGPoint centroid_in_opengl;
    CLLocationCoordinate2D centroid_latlon;
    CLLocationCoordinate2D four_latlon[4];
    float width;    // emulated ios screen width (in pixels)
    float height;   // emulated ios screen height (in pixels)
    float radius;   // emulated watch radius

    float cached_width;    // emulated ios screen width (in pixels)
    float cached_height;   // emulated ios screen height (in pixels)
    float cached_radius;   // emulated watch radius
    
    float true_ios_width;       // ios view width (in pixels)
    float true_ios_height;      // ios view height (in pixels)
    float true_watch_radius;    // watch radius (in pixels)
    
    bool is_circle;
    bool is_enabled;
    bool is_mask_enabled;
    bool is_touched;
    bool accept_touch;
public:
    EmulatediOS(){}; // Default constructor
    EmulatediOS(compassMdl* model);
    void render(compassRender* render);
    bool isTouched(CGPoint pointInOpenGL);
    bool acceptTouch();
    bool acceptTouch(bool state);
    void changeSizeByScale(float scale);
    void updateFourLatLon(double labLon4x2Double[4][2]);
    void calculateFourLatLon(MKMapView *mapView);
    MKCoordinateRegion caculateCoordinateRegionForDesktop
    (DesktopViewController *rootViewController);
};

#endif /* defined(__Compass_transparent___emulatediOS__) */