//
//  DesktopViewController.m
//  Compass[transparent]
//
//  Created by dmiau on 3/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController.h"
#import "AppDelegate.h"
#import "LocationCellView.h"
#import "OpenGLView.h"
#include <cmath>

@implementation DesktopViewController
@synthesize model;

#pragma mark ------------- menu items -------------

// This sorting thing does not quite work for some reason
// 
static NSComparisonResult myCustomViewAboveSiblingViewsComparator(id view1, id view2, void *context )
{
    if ([view1 isKindOfClass:[MKMapView class]]){
        NSLog(@"here1!");
        return NSOrderedAscending;
    }else if ([view2 isKindOfClass:[MKMapView class]]){
        NSLog(@"here2!");
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

@end
