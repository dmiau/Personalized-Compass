//
//  CoreDataViewController.m
//  Compass[transparent]
//
//  Created by Hong Guo on 11/28/15.
//  Copyright © 2015 dmiau. All rights reserved.
//

#import "CoreDataViewController.h"
#import "AppDelegate.h"
#include "compassRender.h"
#import "iOSViewController.h"


@implementation CoreDataViewController

@synthesize model;

//-------------------
// Initialization
//-------------------
- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.model = compassMdl::shareCompassMdl();
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    // Initialize data source indicator
    if (model->filesys_type == IOS_DOC)
        self.dataSource.selectedSegmentIndex = 0;
    else if (model->filesys_type == DROPBOX)
        self.dataSource.selectedSegmentIndex = 1;
    else
        self.dataSource.selectedSegmentIndex = 2;
}



//--------------
// Data source selector
//--------------
- (IBAction)toggleDataSource:(UISegmentedControl *)sender {
    
    switch ([sender selectedSegmentIndex]) {
        case 0:
            model->filesys_type = IOS_DOC;
            break;
        case 1:
            if (!model->dbFilesystem.isReady){
                [model->dbFilesystem linkDropbox:(UIViewController*)self];
            }
            if ([model->dbFilesystem.db_filesystem completedFirstSync]){
                // reload
                model->filesys_type = DROPBOX;
            }else{
                self.dataSource.selectedSegmentIndex = 0;
            }
            break;
        default:
            break;
    }
}

- (IBAction)refreshConfiguraitons:(id)sender {
    if (self.model->filesys_type == DROPBOX){
        
    }else{
        [self.model->docFilesystem
         copyBundleConfigurations];
    }
    
    // reload
    readConfigurations(self.model);
    
    //-------------------
    // Set the rootViewController
    //-------------------
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    
    UINavigationController *myNavigationController =
    app.window.rootViewController;
    
    iOSViewController* rootViewController =
    [myNavigationController.viewControllers objectAtIndex:0];
    
    
    compassRender* renderer = compassRender::shareCompassRender();
    
    renderer->loadParametersFromModelConfiguration();
    
    renderer->initRenderView(rootViewController.glkView.frame.size.width,
                                  rootViewController.glkView.frame.size.height);
    
    [rootViewController.glkView setNeedsDisplay];
}
@end