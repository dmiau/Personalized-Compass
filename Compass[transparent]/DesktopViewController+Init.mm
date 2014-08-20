//
//  DesktopViewController+Init.m
//  Compass[transparent]
//
//  Created by dmiau on 8/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController+Init.h"

@implementation DesktopViewController (Init)

#pragma mark initialization

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        // Do something
        if((self = [super init])) {
            self.model = compassMdl::shareCompassMdl();
            
            // Get the pointer to render
            // At this point the render may not be fully initialized
            self.renderer = compassRender::shareCompassRender();
            
            pinVisible = FALSE;
            
            if (self.model == NULL)
                throw(runtime_error("compassModel is uninitialized"));
            
            // Collect a list of kml files
            NSString *path = [[[NSBundle mainBundle]
                               pathForResource:@"montreal.kml" ofType:@""]
                              stringByDeletingLastPathComponent];
            
            NSArray *dirFiles = [[NSFileManager defaultManager]
                                 contentsOfDirectoryAtPath: path error:nil];
            kml_files = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.kml'"]];
            
            // Important, initialize NSMutableArray with empty cells
            tableCellCache = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < self.model->data_array.size(); ++i)
            {
                [tableCellCache addObject:[NSNull null]];
            }                        
            
            //--------------------
            // Initialize a list of UI configurations
            //--------------------
            self.UIConfigurations = [[NSMutableDictionary alloc] init];
            [self.UIConfigurations setObject:[NSNumber numberWithBool:false]
                                      forKey:@"UIRotationLock"];
            [self.UIConfigurations setObject:[NSNumber numberWithBool:false]
                                      forKey:@"UIBreadcrumbDisplay"];
            [self.UIConfigurations setObject:@"Development"
                                      forKey:@"UIToolbarMode"];
            [self.UIConfigurations setObject:[NSNumber numberWithBool:false]
                                      forKey:@"UIToolbarNeedsUpdate"];
            [self.UIConfigurations setObject:[NSNumber numberWithBool:false]
                                      forKey:@"UIAcceptsPinCreation"];
            [self.UIConfigurations setObject:[NSNumber numberWithBool:false]
                                      forKey:@"UICompassTouched"];
            [self.UIConfigurations setObject:[NSNumber numberWithBool:true]
                                      forKey:@"UICompassInteractionEnabled"];
            [self.UIConfigurations setObject:[NSNumber numberWithBool:false]
                                      forKey:@"UICompassCenterLocked"];
            [self.UIConfigurations setObject:@"Auto"
                                      forKey:@"UIOverviewScaleMode"];
        }
    }
    return self;
}



- (void) awakeFromNib
{
    //http://stackoverflow.com/questions/20061052/how-to-add-nsviewcontroller-to-a-responder-chain
    [self setNextResponder:self.view];
    [self.view.subviews enumerateObjectsUsingBlock:^(NSView *subview, NSUInteger idx, BOOL *stop) { [subview setNextResponder:self]; }];
    
    // Insert code here to initialize your application
    
    [[self mapView] setScrollEnabled:YES];
    [self mapView].showsZoomControls =YES;
    //    [self mapView].showsCompass =YES;
    [self mapView].rotateEnabled = YES;
    
    self.renderer->mapView = [self mapView];
    
    [self addObserver:self forKeyPath:@"mapUpdateFlag"
              options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionNew) context:NULL];
    
    
    //http://stackoverflow.com/questions/10796058/is-it-possible-to-continuously-track-the-mkmapview-region-while-scrolling-zoomin?lq=1
    
    _updateUITimer = [NSTimer timerWithTimeInterval:0.1
                                             target:self
                                           selector:@selector(vcTimerFired)
                                           userInfo:nil
                                            repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:_updateUITimer forMode:NSRunLoopCommonModes];
    
    [self.kmlComboBox setStringValue:
     [self.model->location_filename
      lastPathComponent]];
    
    [self updateMapDisplayRegion];
    
    // Provide the compass centroid information to the model
    self.model->compassCenterXY =
    [self.mapView convertPoint: NSMakePoint(self.compassView.frame.size.width/2,
                                            self.compassView.frame.size.height/2)
                      fromView:self.compassView];
    //-----------------
    // Add annotation to the map
    //-----------------
    [self renderAnnotations];
    
    //-----------------
    // Provide compassXY to the model
    //-----------------
    [self updateModelCompassCenterXY];
    
    //-------------------
    // Add the setting panel
    //-------------------
    
    // Note this method needs to be here
    NSArray *view_array;
    
//    [[NSBundle mainBundle] loadNibNamed:@"settingsView"
//                                  owner:self
//                        topLevelObjects:&view_array];
//    
//    NSLog(@"done!");
//    CGRect screenRect = [[NSScreen mainScreen] bounds];
//    CGFloat screenWidth = screenRect.size.width;
//    CGFloat screenHeight = screenRect.size.height;
//    
//    for (UIView *aView in view_array){
//        [aView setHidden:YES];
//        view_size_vector.push_back(aView.frame.size);
//        // iphone's screen size: 568x320
//        aView.frame = CGRectMake(0, screenHeight - 44 - aView.frame.size.height,
//                                 aView.frame.size.width, aView.frame.size.height);
//        if ([[aView restorationIdentifier] isEqualToString:@"ViewPanel"]){
//            self.viewPanel = aView;
//        }else if ([[aView restorationIdentifier] isEqualToString:@"ModelPanel"]){
//            self.modelPanel = aView;
//        }else if ([[aView restorationIdentifier] isEqualToString:@"WatchPanel"]){
//            self.watchPanel = aView;
//        }else if ([[aView restorationIdentifier] isEqualToString:@"DebugPanel"]){
//            self.debugPanel = aView;
//        }else if ([[aView restorationIdentifier] isEqualToString:@"WatchSidebar"]){
//            self.watchSidebar = aView;
//        }
//    }
//    [self.view addSubview:self.watchSidebar];
//    [self.view addSubview:self.debugPanel];
//    [self.view addSubview:self.watchPanel];
//    [self.view addSubview:self.modelPanel];
//    [self.view addSubview:self.viewPanel];
//    
//    //    [self.watchPanel removeFromSuperview];
//    //    [self.view insertSubview:self.watchPanel aboveSubview:self.watchSidebar];
}

@end