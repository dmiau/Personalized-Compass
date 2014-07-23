//
//  SnapshotDetailViewController.h
//  Compass[transparent]
//
//  Created by dmiau on 7/22/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "compassModel.h"

@interface SnapshotDetailViewController : UIViewController
@property compassMdl* model;
@property snapshot* mySnapshot;
@property int snapshot_id;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *noteTextField;
@property (weak, nonatomic) IBOutlet UITextView *addressView;
@property (weak, nonatomic) IBOutlet UITextView *dateTextField;

- (IBAction)doneEditing:(id)sender;
- (IBAction)dismissModalVC:(id)sender;
@end