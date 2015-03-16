//
//  DesktopViewController+RunStudy.m
//  Compass[transparent]
//
//  Created by Daniel on 2/17/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "DesktopViewController+RunStudy.h"
#import "testCodeInterpreter.h"

@implementation DesktopViewController (RunStudy)

- (IBAction)showNextTest:(id)sender {
    if (self.testManager->testManagerMode == OSXSTUDY){
        self.studyIntAnswer = [NSNumber numberWithInt:0];
        
        
        // In the test mode,
        // next button should be disabled after it is clicked
        if ([self.isPracticingMode boolValue])
        {
            [self.nextTestButton setEnabled:YES];
        }else{
            [self.nextTestButton setEnabled:NO];
        }
        
        //-------------------
        // Safe guard for practice session
        //-------------------
        int test_counter = self.testManager->test_counter;
        
        if ([self.model->snapshot_array[test_counter].name hasSuffix:@"t"]
                 && ![self.model->snapshot_array[test_counter+1].name hasSuffix:@"t"])
        {
            [self displayPopupMessage:
             @"You have reached the end of the practice session.\nPlease notify the test coordinator to proceed."];
            return;
        }else if (![self.model->snapshot_array[test_counter].name hasSuffix:@"t"]
                  && [self.model->snapshot_array[test_counter+1].name hasSuffix:@"t"])
        {
            [self displayPopupMessage:
             @"You have reached the end of a test session.\nPlease notify the test coordinator to proceed."];
            return;
        }else if ( test_counter+1 >= self.model->snapshot_array.size()){
            [self displayInformationText];
            [self displayPopupMessage:
             @"You have reached the end of the study session.\nThansk for your participation!\nPlease notify the test coordinator to proceed."];
            return;
        }
        
        self.testManager->showNextTest();
        
        // In the test mode,
        // next button should be disabled after it is clicked
        if ([self.isPracticingMode boolValue])
        {
            [self.nextTestButton setEnabled:YES];
        }else{
            [self.nextTestButton setEnabled:NO];
        }
        
    }
}

- (IBAction)showPreviousTest:(id)sender {
    if (self.testManager->testManagerMode == OSXSTUDY){
        self.studyIntAnswer = [NSNumber numberWithInt:0];
        if (self.testManager->test_counter == 0){
            [self displayInformationText];
        }else{
            self.testManager->showPreviousTest();
        }
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
    annotation.title      = @"Answer";
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
    
    //--------------------
    // Hide the text field if it is visible
    //--------------------
    if (![self.informationTextField isHidden])
    {

        [self.informationTextField setHidden:YES];
        [self.informationImageView setHidden:NO];
        [self displayStudyTitle];
        
        if ((self.testManager->test_counter ==
            self.model->snapshot_array.size()-1) ||
            self.testManager->testManagerMode == OFF)
        {
            //----------------------
            // Dismiss the dialog
            // if it is at the end of the session
            //----------------------
            [self setInformationViewVisibility:NO];
        }
        return;
    }
    
    //--------------------
    // If the image dialog is visible
    //--------------------
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
        [self setInformationViewVisibility:YES];
    }else{
        //------------------
        // Hide the information view
        //------------------
        [self setInformationViewVisibility:NO];
    }
}

- (void)setInformationViewVisibility: (BOOL)state{
    if (state){
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
    self.isInformationViewVisible = [NSNumber numberWithBool:state];
}

- (void) displayTestInstructionsByTask: (TaskType) taskType
{
    self.isInformationViewVisible = [NSNumber numberWithBool:YES];
    
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
    [self displayStudyTitle];
    [self.nextTestButton setEnabled:NO];
    [self.confirmButton setEnabled:NO];
}

//----------------------------
// Display test information
//----------------------------
- (void) displayInformationText
{
    self.isInformationViewVisible = [NSNumber numberWithBool:YES];
    [self.informationTextField setHidden:NO];
    [self displayStudyTitle];
    //------------------
    // Show the information view
    //------------------
    [self.mapView setHidden:YES];
    [self.compassView setHidden:YES];
    [self.informationView setHidden:NO];
    [self.informationImageView setHidden:YES];
}

- (void) displayStudyTitle{
    
    if (![self.informationTextField isHidden]){
        if (self.testManager->test_counter ==0)
        {
            self.studyTitle = @"Welcome";
        }else if (self.testManager->test_counter ==
                  self.model->snapshot_array.size() -1)
        {
            self.studyTitle = @"The End";
        }
    }else{
        // Display chapter info
        
        int counter = self.testManager->test_counter;
        
        string studyTitle;
        if ([self.model->snapshot_array[counter].name hasSuffix:@"t"]){
            studyTitle = "Practice: ";
        }else{
            // Get chapter info
            int chapter_n = self.testManager->chapterInfo
            [extractCode(self.model->snapshot_array[counter].name)];
            studyTitle = "Chapter " + to_string(chapter_n) + ": ";
        }
        
        TestCodeInterpreter codeInterpreter(self.model->snapshot_array[counter].name);
        studyTitle = studyTitle + codeInterpreter.genTitle();
        
        self.studyTitle = [NSString stringWithUTF8String:studyTitle.c_str()];
    }
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
        || [self.isPracticingMode boolValue])
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
