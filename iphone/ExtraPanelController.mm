//
//  ExtraPanelController.m
//  Compass[transparent]
//
//  Created by Daniel Miau on 8/5/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "ExtraPanelController.h"

@interface ExtraPanelController ()

@end

@implementation ExtraPanelController

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        NSLog(@"extra panel controller initialized");
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"extra panel controller viewWillAppear called");
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

@end
