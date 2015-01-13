//
//  DesktopViewController+Init.m
//  Compass[transparent]
//
//  Created by dmiau on 8/19/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "DesktopViewController+Init.h"
//#import "SettingsViewController.h"

@implementation DesktopViewController (Init)

#pragma mark initialization

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
        // Do something
        if((self = [super init])) {
            self.model = compassMdl::shareCompassMdl();
            
            // Get the pointer of render
            // At this point the render may not be fully initialized
            self.renderer = compassRender::shareCompassRender();
            
            pinVisible = FALSE;
            
            if (self.model == NULL)
                throw(runtime_error("compassModel is uninitialized"));            
            
            // Important, initialize NSMutableArray with empty cells
            tableCellCache = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < self.model->data_array.size(); ++i)
            {
                [tableCellCache addObject:[NSNull null]];
            }                        
            
            // Initialize iOSSyncFlag
            self.iOSSyncFlag = false;
            
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
            [self.UIConfigurations setObject:[NSNumber numberWithBool:false]
                                      forKey:@"UIAllowMultipleAnnotations"];
            [self.UIConfigurations setObject:@"Auto"
                                      forKey:@"UIOverviewScaleMode"];
        }
    }
    return self;
}



- (void) awakeFromNib
{
    
    // The following lines are only needed for 10.9 SDK.
    // 10.10 now injects ViewController to the reponder chain
//    //http://stackoverflow.com/questions/20061052/how-to-add-nsviewcontroller-to-a-responder-chain
//    [self setNextResponder:self.view];
//    [self.view.subviews enumerateObjectsUsingBlock:^(NSView *subview, NSUInteger idx, BOOL *stop) { [subview setNextResponder:self]; }];
    
    
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

    //-------------------
    // Initialized the mapView
    //-------------------
    [self initMapView];
    
    // Inject to AppDelegate
    AppDelegate *temp = [[NSApplication sharedApplication] delegate];
    temp.rootViewController = self;    
}

//-----------------
// initMapView may be called whenever configurations.json is reloaded
//-----------------
- (void) initMapView{
    [self updateMapDisplayRegion];
    
    // Provide the centroid of compass to the model
    [self updateModelCompassCenterXY];
    
    // Add pin annotations
    [self renderAnnotations];
    
    // Set the conventional compass to be invisible
    self.conventionalCompassVisible = false;
    
}

@end
