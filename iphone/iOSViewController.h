//
//  iOSViewController.h
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/3/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <GLKit/GLKit.h>
#include "compassModel.h"
#include "compassRender.h"
#include <iostream>
#import "iOSGLKView.h"

@interface iOSViewController : UIViewController{
    BOOL pinVisible;
    NSArray *kml_files;
}

@property (weak) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet GLKView *glkView;


@property compassMdl* model;
@property compassRender* renderer;


- (void) updateMapDisplayRegion;

@end
