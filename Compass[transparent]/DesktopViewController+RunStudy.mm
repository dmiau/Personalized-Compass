//
//  DesktopViewController+RunStudy.m
//  Compass[transparent]
//
//  Created by Daniel on 2/17/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "DesktopViewController+RunStudy.h"

@implementation DesktopViewController (RunStudy)

- (IBAction)showNextTest:(id)sender {
    if (self.testManager->testManagerMode == OSXSTUDY){
        self.testManager->showNextTest();

        self.testManager->updateUITestMessage();
    }
}

- (IBAction)showPreviousTest:(id)sender {
    if (self.testManager->testManagerMode == OSXSTUDY){
        self.testManager->showPreviousTest();

        self.testManager->updateUITestMessage();        
    }
}

//------------------
// Display the truth,
// as well as the answer, if available
//------------------
- (IBAction)toggleAnswer:(id)sender {
    
    // Get the snapshot object
    int sid = self.testManager->test_counter;
    
    if (sid >= self.model->snapshot_array.size()){
        [self displayPopupMessage:@"snapshot_array's size is not right."];
        return;
    }else if (sid >= self.testManager->record_vector.size()){
        [self displayPopupMessage:@"record_vector's size is not right."];
        return;        
    }

    // Find the answer
    CGPoint cgTruth = self.testManager->record_vector[sid].cgPointTruth;
    
    //-------------
    // For task I, the coordinates are calculated relative to eiOS centroid, so we need
    // to convert them back to the OpenGL coordinates
    //-------------
    if ([self.testManager->record_vector[sid].code rangeOfString:
         toNSString(LOCATE)].location
        != NSNotFound)
    {
        cgTruth.x = cgTruth.x + self.renderer->emulatediOS.centroid_in_opengl.x;
        cgTruth.y = cgTruth.y + self.renderer->emulatediOS.centroid_in_opengl.y;
    }
    
    CustomPointAnnotation *annotation = [self createAnnotationFromGLPoint:cgTruth withType:answer];
    [self.mapView addAnnotation:annotation];
    [[self.mapView viewForAnnotation:annotation] setHidden:NO];
    

    self.studyIntAnswer = [NSNumber numberWithDouble:self.testManager->record_vector[sid].doubleTruth];
    
    // Show the user's answer
    if (self.testManager->record_vector[sid].isAnswered){
        CGPoint cgAnswer = self.testManager->record_vector[sid].cgPointAnswer;
        
        //-------------
        // For task I, the coordinates are calculated relative to eiOS centroid, so we need
        // to convert them back to the OpenGL coordinates
        //-------------
        if ([self.testManager->record_vector[sid].code rangeOfString:
             toNSString(LOCATE)].location
            != NSNotFound)
        {
            cgAnswer.x = cgAnswer.x + self.renderer->emulatediOS.centroid_in_opengl.x;
            cgAnswer.y = cgAnswer.y + self.renderer->emulatediOS.centroid_in_opengl.y;
        }
        
        CustomPointAnnotation *annotation = [self createAnnotationFromGLPoint:cgAnswer withType:dropped];
        
        [self.mapView addAnnotation:annotation];
    }
}

//---------------------
// Generates an CustomPointAnnotation from a given Open GL point
//---------------------
- (CustomPointAnnotation*) createAnnotationFromGLPoint: (CGPoint) glPoint withType:(location_enum) location_type
{
    CGPoint cpviewPoint;
    cpviewPoint.x = glPoint.x + self.renderer->view_width/2;
    cpviewPoint.y = glPoint.y + self.renderer->view_height/2;
    
    CLLocationCoordinate2D coord = [self.mapView convertPoint:cpviewPoint toCoordinateFromView:self.compassView];
    
    // Need to make a drop pin
    // Add drop-pin here
    CustomPointAnnotation *annotation = [[CustomPointAnnotation alloc] init];
    annotation.coordinate = coord;
    annotation.title      = @"Temp";
    annotation.address    = @"";
    annotation.subtitle   = @"";
    annotation.point_type = location_type;
    return annotation;
}

//---------------------
// Information view related stuff
//---------------------
- (IBAction)clickInformationViewOK:(id)sender {
    NSLog(@"Information OK was clicked!");
}


- (IBAction)toggleInformationView:(id)sender {
    if ([self.informationView isHidden]){
        [self.mapView setHidden:YES];
        [self.compassView setHidden:YES];
        [self.informationView setHidden:NO];
    }else{
        [self.mapView setHidden:NO];
        [self.compassView setHidden:NO];
        [self.informationView setHidden:YES];
    }
}

- (void) displayTestInstructionsByTask: (TaskType) taskType
{
    
    
    
    
    
    
}
@end
