//
//  iOSViewController.h
//  Compass[transparent]
//
//  Created by Daniel Miau on 6/3/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface iOSViewController : UIViewController{
    NSTimer* renderTimer;
}

@property (weak, nonatomic) IBOutlet GLKView *glkView;
@end
