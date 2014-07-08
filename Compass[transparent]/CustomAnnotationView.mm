//
//  CustomAnnotationView.m
//  Compass[transparent]
//
//  Created by dmiau on 7/4/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import "CustomAnnotationView.h"

@implementation CustomAnnotationView

//// determine the MKAnnotationView based on the annotation info and reuseIdentifier
////
//- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
//    if (self != nil)
//    {
//        NSArray *view_array =
//        [[NSBundle mainBundle] loadNibNamed:@"myPinAnnotationViewIOS"
//                                      owner:self options:nil];
//        UIView *aView = [view_array objectAtIndex:0];
//        aView.frame = CGRectMake(0, -50, aView.frame.size.width, aView.frame.size.height);
//        
//        [self addSubview:aView];
////        self.backgroundColor = [UIColor redColor];
//    }
//
//    return self;
//}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        NSArray *view_array =
        [[NSBundle mainBundle] loadNibNamed:@"myPinAnnotationViewIOS"
                                      owner:self options:nil];
        
        UIView *myView = [view_array objectAtIndex:0];
        [myView setBackgroundColor:[UIColor blackColor]];
        CGRect myRect = myView.frame;
        myRect.size.width = myRect.size.width/2;
        UITextField *textfield = [[UITextField alloc]
                                  initWithFrame: myRect];
        textfield.borderStyle = UITextBorderStyleRoundedRect;
        textfield.textColor = [UIColor blackColor];
        self.textField = textfield;
        self.textField.delegate = self;

        myRect.origin.x = myRect.size.width;
        self.button = [[UIButton alloc] initWithFrame:myRect];
        [self.button setBackgroundColor:[UIColor redColor]];
//        [myView addSubview:self.button];
//        [myView addSubview:textfield];


        self.customView = myView;
        self.ignoreFlag = false;
        

        
    }
    return self;
}

- (void)drawRect:(CGRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

//http://stackoverflow.com/questions/1565828/how-to-customize-the-callout-bubble-for-mkannotationview
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if(selected)
    {
        //Add your custom view to self...
        UIView *myView = self.customView;
        myView.frame = CGRectMake(-myView.frame.size.width/2,
                                  -myView.frame.size.height,
                                  myView.frame.size.width,
                                  myView.frame.size.height);

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(handlePinButtonTap:)];
        tap.numberOfTapsRequired = 1;
        tap.delegate = self;        
        [myView addGestureRecognizer:tap];

        [myView becomeFirstResponder];
        myView.userInteractionEnabled = YES;
        myView.exclusiveTouch = YES;
        [self addSubview:myView];
    }
    else
    {
        //Remove your custom view...
        
        // Instructions to remove a subview
        //http://stackoverflow.com/questions/1516294/uiview-what-is-the-correct-way-to-remove-a-subview-from-a-view-hierarchy-and-nu
//        if (!self.ignoreFlag)
//            [self.customView removeFromSuperview];
//        self.ignoreFlag = false;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    NSUInteger numTaps = [touch tapCount];
    if ([touches count] > 1)
    	NSLog(@"mult-touches %lu", (unsigned long)[touches count]);
    
    if (numTaps < 2) {
            	NSLog(@"touch once");
    } else {
    	NSLog(@"double tap");
    }

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

- (void) handlePinButtonTap:(UITapGestureRecognizer *)gestureRecognizer
{
    UIButton *btn = (UIButton *) gestureRecognizer.view;
    MKAnnotationView *av = (MKAnnotationView *)[btn superview];
    id<MKAnnotation> ann = av.annotation;
    NSLog(@"handlePinButtonTap: ann.title=%@", ann.title);
}
@end
