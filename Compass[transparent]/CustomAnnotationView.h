//
//  CustomAnnotationView.h
//  Compass[transparent]
//
//  Created by dmiau on 7/4/14.
//  Copyright (c) 2014 dmiau. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CustomAnnotationView : MKPinAnnotationView
<UITextFieldDelegate, UIGestureRecognizerDelegate>
@property UIView *customView;
@property UITextField *textField;
@property UIButton *button;
@property bool ignoreFlag;
@end
