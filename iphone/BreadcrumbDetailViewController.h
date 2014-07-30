//
//  BreadcrumbDetailViewController.h
//  Compass[transparent]
//
//  Created by Daniel Miau on 7/24/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "compassModel.h"

@interface BreadcrumbDetailViewController : UIViewController{
    NSString *old_name;
    NSString *new_name;
}

@property compassMdl* model;
@property  NSString* filename;
@property (weak, nonatomic) IBOutlet UITextField *filenameTextField;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UITextView *noteTextField;

- (IBAction)doneEditing:(id)sender;

- (IBAction)clickedSaveButton:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *dataCount;
- (IBAction)dismissModalVC:(id)sender;
@end
