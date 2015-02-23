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
    
    snapshot mySnapshot = self.model->snapshot_array[sid];

    // Find the answer
    for (int i = 0; i < mySnapshot.is_answer_list.size(); ++i){
        if (mySnapshot.is_answer_list[i]){
            int data_id = mySnapshot.selected_ids[i];
            data myData = self.model->data_array[data_id];
            [self.mapView addAnnotation: myData.annotation];
            [[self.mapView viewForAnnotation:myData.annotation] setHidden:NO];
        }
    }
    
    
    // Show the user's answer
    if (self.testManager->record_vector[sid].isAnswered){
        CGPoint cgAnswer = self.testManager->record_vector[sid].cgPointAnswer;
        CGPoint cpviewPoint;
        cpviewPoint.x = cgAnswer.x + self.renderer->view_width/2;
        cpviewPoint.y = cgAnswer.y + self.renderer->view_height/2;
        
        CLLocationCoordinate2D coord = [self.mapView convertPoint:cpviewPoint toCoordinateFromView:self.compassView];

        // Need to make a drop pin
        // Add drop-pin here
        CustomPointAnnotation *annotation = [[CustomPointAnnotation alloc] init];
        annotation.coordinate = coord;
        annotation.title      = @"Dropped Pin";
        annotation.subtitle   = @"";
        annotation.point_type = dropped;
        
        [self.mapView addAnnotation:annotation];
    }
}
@end
