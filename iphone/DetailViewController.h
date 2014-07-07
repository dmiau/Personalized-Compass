//
//  DetailViewController.h
//  Compass[transparent]
//
//  Created by dmiau on 7/5/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "compassModel.h"

@interface DetailViewController : UIViewController

@property CustomPointAnnotation *annotation;
@property (weak, nonatomic) IBOutlet UITextView *addressView;
@property compassMdl* model;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;


- (IBAction)doneEditing:(id)sender;
- (IBAction)addLocation:(id)sender;

@end
