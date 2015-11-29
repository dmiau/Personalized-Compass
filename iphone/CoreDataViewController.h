//
//  CoreDataViewController.h
//  Compass[transparent]
//
//  Created by Hong Guo on 11/28/15.
//  Copyright © 2015 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "compassModel.h"
#include "compassRender.h"

@interface CoreDataViewController : UIViewController

@property compassMdl* model;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dataSource;
@property (weak, nonatomic) IBOutlet UITextView *systemMessage;
@property (weak, nonatomic) NSArray *area;
@property (weak, nonatomic) NSArray *collections;

@end
