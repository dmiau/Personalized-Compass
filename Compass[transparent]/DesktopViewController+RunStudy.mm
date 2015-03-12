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
        self.studyIntAnswer = [NSNumber numberWithInt:0];
        self.testManager->showNextTest();
        self.testManager->updateUITestMessage();
    }
}

- (IBAction)showPreviousTest:(id)sender {
    if (self.testManager->testManagerMode == OSXSTUDY){
        self.studyIntAnswer = [NSNumber numberWithInt:0];
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
    
    if (self.testManager->isLocked){
        [self displayPopupMessage:@"TestManager is locked."];
        return;
    }
    
    if (![self.informationTextField isHidden]){
        [self.informationTextField setHidden:YES];
        [self.informationImageView setHidden:NO];
        return;
    }
    
    // Dismiss the dialog
    [self toggleInformationView:nil];
    
    if (self.testManager->testManagerMode != OFF){
        // Start the test
        self.testManager->startTest();
        
        // Enable the buttons
        [self.nextTestButton setEnabled:NO];
        [self.confirmButton setEnabled:YES];
    }
}

- (IBAction)toggleInformationView:(id)sender {
    if ([self.informationView isHidden]){
        //------------------
        // Show the information view
        //------------------
        [self.mapView setHidden:YES];
        [self.compassView setHidden:YES];
        [self.informationView setHidden:NO];
    }else{
        //------------------
        // Hide the information view
        //------------------
        [self.mapView setHidden:NO];
        [self.compassView setHidden:NO];
        [self.informationView setHidden:YES];
    }
}

- (void) displayTestInstructionsByTask: (TaskType) taskType
{
    static NSImage *locate_image = [[NSImage alloc] initWithContentsOfFile:
            [[NSBundle mainBundle] pathForResource:@"locate.jpg" ofType:@""]];
    static NSImage *distance_image = [[NSImage alloc] initWithContentsOfFile:
            [[NSBundle mainBundle] pathForResource:@"distance.jpg" ofType:@""]];
    static NSImage *triangulate_image = [[NSImage alloc] initWithContentsOfFile:
            [[NSBundle mainBundle] pathForResource:@"triangulate.jpg" ofType:@""]];
    static NSImage *orient_image = [[NSImage alloc] initWithContentsOfFile:
            [[NSBundle mainBundle] pathForResource:@"orient.jpg" ofType:@""]];
    static NSImage *locateplus_image = [[NSImage alloc] initWithContentsOfFile:
            [[NSBundle mainBundle] pathForResource:@"lplus.jpg" ofType:@""]];

    //------------------
    // Show the information view
    //------------------
    [self.mapView setHidden:YES];
    [self.compassView setHidden:YES];
    [self.informationView setHidden:NO];
    [self.informationImageView setHidden:NO];
    [self.informationTextField setHidden:YES];
    
    switch (taskType) {
        case LOCATE:
            [self.informationImageView setImage:locate_image];
            break;
        case DISTANCE:
            [self.informationImageView setImage:distance_image];
            break;
        case TRIANGULATE:
            [self.informationImageView setImage:triangulate_image];
            break;
        case ORIENT:
            [self.informationImageView setImage:orient_image];
            break;
        case LOCATEPLUS:
            [self.informationImageView setImage:locateplus_image];
            break;
        default:
            break;
    }
    [self.nextTestButton setEnabled:NO];
    [self.confirmButton setEnabled:NO];
}

//----------------------------
// Display test information
//----------------------------
- (void) displayInformationText
{
    [self.informationTextField setHidden:NO];
    
    string testSpecMsg;
    for (auto iter = self.testManager->snapshotDistributionInfo.begin();
         iter != self.testManager->snapshotDistributionInfo.end(); ++iter)
    {
        testSpecMsg = testSpecMsg + "\n" + iter->first + ": " + to_string(iter->second);
    }
    

    int ans_counter = 0;
    for (int i = 0; i < self.testManager->record_vector.size(); ++i){
        if (self.testManager->record_vector[i].isAnswered){
            ++ans_counter;
        }
    }
    string answerMsg = to_string(ans_counter) + " out of " +
    to_string((int)self.testManager->record_vector.size()) + " answered.";
    
    string fileMsg;
    fileMsg = "DBRoot: \n" + string([self.model->desktopDropboxDataRoot UTF8String]) + "\n" +
    "Location file: " + string([self.model->location_filename UTF8String]) + "\n" +
    "Snapshot file: " + string([self.model->snapshot_filename UTF8String]) + "\n" +
    "Record file: " + string([self.testManager->record_filename UTF8String]) + "\n\n";
    
    string message;
    message = testSpecMsg + "\n\n" + answerMsg + "\n\n" + fileMsg;
    
    self.informationTextField.stringValue = [NSString stringWithUTF8String:message.c_str()];
    
    //------------------
    // Show the information view
    //------------------
    [self.mapView setHidden:YES];
    [self.compassView setHidden:YES];
    [self.informationView setHidden:NO];
    [self.informationImageView setHidden:YES];

}

//-------------------
// Confirm the answer
// Do some basic checking and decide whether to enable the next button or not
//-------------------
- (IBAction)confirmAnswer:(id)sender {
    
    // Before jumping into a new test, end the previous (unanswered) test
    // The timer of the answered test is stopped in the endTest method
    
    int test_counter = self.testManager->test_counter;
    if ([self.model->snapshot_array[test_counter].name
         rangeOfString:toNSString(DISTANCE)].location!= NSNotFound)
        
    {
        //--------------------
        // Do a special check for the distance estimation task
        //--------------------
        if (NumberIsFraction(self.studyIntAnswer)){
            [self displayPopupMessage:@"Distance estimation must be an integer."];
            return;
        }
        
        // Collect the distance estimation answer if the task is t1
        self.testManager->endTest(CGPointMake(0,0),
                                  [self.studyIntAnswer doubleValue]);
    }
    
    // Stop the timer if the test has not been answered
    if (!self.testManager->record_vector[test_counter].isAnswered)
    {
        self.testManager->record_vector[test_counter].end();
    }
    
    // Enable the next button if the answer is verified,
    // or when the system is put in dev/practice mode
    if (self.testManager->verifyAnswerQuality()
        || [self.isShowAnswerAvailable boolValue])
    {
        [self.nextTestButton setEnabled:YES];
    }
}


BOOL NumberIsFraction(NSNumber *number) {
    double dValue = [number doubleValue];
    if (dValue < 0.0)
        return (dValue != ceil(dValue));
    else
        return (dValue != floor(dValue));
}
@end
