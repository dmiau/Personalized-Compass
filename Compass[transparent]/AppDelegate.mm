//
//  AppDelegate.m
//  Compass[transparent]
//
//  Created by dmiau on 3/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "AppDelegate.h"
#import <MapKit/MapKit.h>

//static NSComparisonResult myCustomViewAboveSiblingViewsComparator(id view1, id view2, void * context )
//{
//    if ([view1 isKindOfClass:[NSOpenGLView class]])
//        return NSOrderedAscending;
//    else if ([view2 isKindOfClass:[NSOpenGLView class]])
//        return NSOrderedDescending;
//    return NSOrderedSame;
//}

@implementation AppDelegate

#pragma ----- Initialization -----
- (id)init {
    self = [super init];
    if (self) {
        // Initialize self.
        //        self.model = compassMdl::shareCompassMdl();
    }
    return self;
}


// View customization needs to be done here since NSViewController
// does not have a viewDidLoad method
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    [_window setBackgroundColor:[NSColor clearColor]];
//    [_window setOpaque:NO];
#ifdef WATCH
    NSLog(@"*************Smart watch build");
    //-------------------------
    //Layout
    //-------------------------
    // GUI formatting
    NSView *main_view = [[self window] contentView];
    
    // Drawing code here.
    
    NSArray *my_subviews = main_view.subviews; //[self subviews];
    //        NSRect img_rect;
    
    // Some tools I can use to specify the size of a view
    // NSMakeRect, CGRectMake
    NSRect img_rect;
    img_rect = NSMakeRect(0, 0, 609, 392);
    
    NSView *aView, *myMapView, *myOpenGLView, *myTableView, *myImgView;
    for (aView  in my_subviews){
        if ([aView isKindOfClass:[MKMapView class]]){
//            [aView setFrame:img_rect];
//            //            [aView display];
//            [aView setNeedsDisplay:YES];
            myMapView = aView;
        }else if ([aView isKindOfClass:[NSOpenGLView class]]){
            myOpenGLView = aView;
        }else if ([aView isKindOfClass:[NSScrollView class]]){
            myTableView = aView;
        }else if ([aView isKindOfClass:[NSView class]]){
            myImgView = aView;
        }
    }
    
    NSDictionary *viewsDictionary =
    NSDictionaryOfVariableBindings(myMapView, myOpenGLView, myTableView, myImgView);
    
    NSMutableArray *constraints_array = [[NSMutableArray alloc] init];
    
    [constraints_array addObject:
     [NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[myImgView]-10-[myTableView]-10-|"
                                             options:0 metrics:nil views:viewsDictionary]];
    [constraints_array addObject:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[myImgView]-10-|"
                                             options:0 metrics:nil views:viewsDictionary]];
//    [constraints_array addObject:
//     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[myTableView]-10-|"
//                                             options:0 metrics:nil views:viewsDictionary]];
    
//    // MapView constraints
//    [constraints_array addObject:
//     [NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[myMapView]-10-[myTableView]-10-|"
//                                             options:0 metrics:nil views:viewsDictionary]];
//    [constraints_array addObject:
//     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[myMapView]-10-|"
//                                             options:0 metrics:nil views:viewsDictionary]];
    
    for (id item in constraints_array){
        [main_view addConstraints:item];
    }

    compassMdl* model = compassMdl::shareCompassMdl();
    
    MKCoordinateRegion region;
    region.center.latitude = model->camera_pos.latitude;
    region.center.longitude = model->camera_pos.longitude;
    
    region.span.longitudeDelta = model->latitudedelta;
    region.span.latitudeDelta = model->longitudedelta;
    [(MKMapView*)myMapView setRegion:region];
    
#endif
    
}

#pragma mark -------- Debug info window
- (IBAction)showDebugInfo:(id)sender{
    
    if (!debugWindowController){
        debugWindowController =
        [[DebugWindowController alloc] initWithWindowNibName:@"DebugInfoWindow"];
    }
    [debugWindowController showWindow:nil];
    [[debugWindowController window] setIsVisible:YES];
//    [[debugWindowController debugTextOutlet] setString:@"Happy Birthday!"];
}

#pragma mark -------- Style selector window
- (IBAction)showStyleSelector:(id)sender{
    
    if (!styleWindowController){
        styleWindowController =
        [[NSWindowController alloc] initWithWindowNibName:@"StyleWindow"];
    }
    [styleWindowController showWindow:nil];
    [[styleWindowController window] setIsVisible:YES];
}
@end
