//
//  DesktopViewController+iOSEmulation.m
//  Compass[transparent]
//
//  Created by Daniel on 2/6/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "DesktopViewController.h"
#import "ConfigurationsWindowController.h"

@implementation DesktopViewController (iOSEmulation)
// Calculate the coordinates of the four corners of the emulated iOS display
// in OSX's screen coordinate system
- (void)calculateiOSScreenSize:(float)scale{
    
    // Cache the starting iOS_height and iOS_width, to provide the base
    // to calculate the scaled iOSFourCornersInNSView
    static float cached_iOS_height = self.renderer->em_ios_height;
    static float cached_iOS_width = self.renderer->em_ios_width;
    
    //    static MKCoordinateSpan cached_map_span = self.rootViewController.mapView.region.span;
    
    //ul, ur, br, bl
    float height = self.renderer->view_height;
    float width = self.renderer->view_width;
    
    //iOS screen size is 320x503
    float iOS_height = cached_iOS_height * scale;
    float iOS_width = cached_iOS_width * scale;
    
    //    //When one scales the emulated iOS screen, the map zoom level should be
    //    //adjusted accordingly. Note in my implementation, the iOS is always
    //    //the golden standard
    //
    //    MKCoordinateSpan new_map_span = MKCoordinateSpanMake(
    //        cached_map_span.latitudeDelta/scale, cached_map_span.longitudeDelta/scale);
    //    self.rootViewController.mapView.region.span = new_map_span;
    //
    //Generate iOSScreenStr
    
    if (self.configurationWindowController){
        self.configurationWindowController.iOSScreenStr = [NSString stringWithFormat:@"%.1fx%.1f x %.2f = %.2fx%.2f",
            cached_iOS_height, cached_iOS_width,
            scale, iOS_height, iOS_width];
    }
    
    CGPoint *tempFourCorners = self.renderer->iOSFourCornersInNSView;
    tempFourCorners[0].x = width/2 - iOS_width/2;
    tempFourCorners[0].y = height/2 - iOS_height/2;
    
    tempFourCorners[1].x = width/2 + iOS_width/2;
    tempFourCorners[1].y = height/2 - iOS_height/2;
    
    tempFourCorners[2].x = width/2 + iOS_width/2;
    tempFourCorners[2].y = height/2 + iOS_height/2;
    
    tempFourCorners[3].x = width/2 - iOS_width/2;
    tempFourCorners[3].y = height/2 + iOS_height/2;
}
@end
