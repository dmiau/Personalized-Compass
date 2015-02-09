//
//  OSXPinAnnotationView.h
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/20/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CustomPointAnnotation.h"
#import "compassModel.h"

@class DesktopViewController;

@interface CalloutViewController : NSViewController

@property CustomPointAnnotation *annotation;
@property (weak) IBOutlet NSView *detailView;
@property (weak) IBOutlet NSTextField *landmark_name;
@property compassMdl* model;
@property DesktopViewController *rootViewController;

@property (weak, nonatomic) IBOutlet NSTextField *titleTextField;

@property (weak, nonatomic) IBOutlet NSButton *addButton;
@property (weak, nonatomic) IBOutlet NSButton *removeButton;
@property BOOL needUpdateAnnotation;
@property (weak) IBOutlet NSSegmentedControl *statusSegmentControl;


@property (weak, nonatomic) IBOutlet NSTextField *addressView;
@property (weak, nonatomic) IBOutlet NSTextField *noteTextField;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBund
           annotation: (CustomPointAnnotation*) annotation;
- (IBAction)dismissDialog:(id)sender;
- (IBAction)addLocation:(id)sender;
- (IBAction)removeLocation:(id)sender;
- (IBAction)toggleEnable:(id)sender;
- (IBAction)doneEditing:(id)sender;

@end


@interface OSXPinAnnotationView : MKPinAnnotationView{
    CalloutViewController *calloutViewController;
    bool detailViewVisible;
}
@property bool customCalloutStatus;
-(void)showCustomCallout:(bool)status;
-(void)showDetailCallout:(bool)status;
@end
