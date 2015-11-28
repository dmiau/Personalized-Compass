//
//  CoreDataViewController.m
//  Compass[transparent]
//
//  Created by Hong Guo on 11/28/15.
//  Copyright © 2015 dmiau. All rights reserved.
//

#import "CoreDataViewController.h"

@implementation CoreDataViewController

@synthesize model;
//--------------
// Data source selector
//--------------
- (IBAction)toggleDataSource:(UISegmentedControl *)sender {
    
    switch ([sender selectedSegmentIndex]) {
        case 0:
//            model->filesys_type = IOS_DOC;
            NSLog(@"FUN 1");
            break;
        case 1:
//            if (!model->dbFilesystem.isReady){
//                [model->dbFilesystem linkDropbox:(UIViewController*)self];
//            }
//            if ([model->dbFilesystem.db_filesystem completedFirstSync]){
//                // reload
//                model->filesys_type = DROPBOX;
//            }else{
//                self.systemMessage.text = @"Dropbox is not ready. Try again later.";
//                self.dataSource.selectedSegmentIndex = 0;
//            }
            NSLog(@"FUN 2");
            break;
        default:
            NSLog(@"FUN 3");
            break;
    }
}

- (IBAction)resetCoreData:(id)sender {
    NSLog(@"reset core data");
}


- (IBAction)importData:(id)sender {
    NSLog(@"import to core data");
}

- (IBAction)exportData:(id)sender {
    NSLog(@"export data");
}







@end
