//
//  BreadcrumbDetailViewController.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 7/24/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "BreadcrumbDetailViewController.h"

@interface BreadcrumbDetailViewController ()

@end

@implementation BreadcrumbDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.model = compassMdl::shareCompassMdl();
    old_name = self.filename;
    self.filenameTextField.text = self.filename;
    self.noteTextField.text = self.model->history_notes;
    self.dataCount.text =
    [NSString stringWithFormat:@"%lu",
     self.model->breadcrumb_array.size()];
    self.dateLabel.text =
    self.model->breadcrumb_array.back().date_str;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)doneEditing:(id)sender {
    [self.filenameTextField resignFirstResponder];
    [self.noteTextField resignFirstResponder];
    new_name = self.filenameTextField.text;
    self.model->history_notes = self.noteTextField.text;
}

- (IBAction)clickedSaveButton:(UIButton*)sender {
    bool rename_status;
    
    //-------------
    // Save and then rename
    //-------------
    if (self.model->filesys_type == DROPBOX){
        rename_status = [self.model->dbFilesystem writeFileWithName:old_name Content:genHistoryString(self.model)];
        
        rename_status = [self.model->dbFilesystem renameFilename:old_name withName:new_name];
    }else{
        rename_status = [self.model->docFilesystem writeFileWithName:old_name Content:genHistoryString(self.model)];
        rename_status = [self.model->docFilesystem renameFilename:old_name withName:new_name];
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File System Error"
                                                    message:@"Fail to rename the history file."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    if (!rename_status){
        [alert show];
    }else{
        sender.enabled = false;
    }

}

@end
