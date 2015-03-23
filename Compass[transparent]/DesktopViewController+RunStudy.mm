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
        
        // Skip the following if it is in the Dve mode
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:[NSNumber numberWithBool:NO] forKey:@"isAnswerConfirmed"];
        // In the test mode,
        // next button should be disabled after it is clicked
        if ([prefs boolForKey:@"isDevMode"])
        {
            [self.nextTestButton setEnabled:YES];
            [self.showAnswerButton setEnabled:YES];
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
            [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"isWaitingAdminCheck"];
            return;
        }else if ( test_counter+1 >= self.model->snapshot_array.size()){
            self.studyTitle = @"Thank You!";
            [self displayInformationText];
            [self displayPopupMessage:
             @"You have reached the end of the study session.\nThank you for your participation!\nPlease notify the test coordinator to proceed."];
            [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"isWaitingAdminCheck"];
            
            // Do a forced save here
            if (self.testManager->isRecordAutoSaved)
            {
                self.testManager->saveRecord(
                        [self.model->desktopDropboxDataRoot
                         stringByAppendingPathComponent:
                         self.testManager->record_filename], true);
                self.testManager->isRecordAutoSaved = false;
            }
            
            return;
        }else if (![self.model->snapshot_array[test_counter].name hasSuffix:@"t"]
                  && [self.model->snapshot_array[test_counter+1].name hasSuffix:@"t"])
        {
            self.studyTitle = @"---Intermission---";
            [self displayInformationText];
            [self displayPopupMessage:
             @"You have completed the first half the study session.\nPlease notify the test coordinator to proceed."];
            [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"isWaitingAdminCheck"];
            
            // Note the test proceed
            return;
        }
        
        self.testManager->showNextTest();
        
        // In the test mode,
        // next button should be disabled after it is clicked
        if ([prefs boolForKey:@"isDevMode"])
        {
            [self.nextTestButton setEnabled:YES];
        }else{
            [prefs setObject:[NSNumber numberWithBool:NO] forKey:@"isAnswerConfirmed"];
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
//    self.testManager->collectGroundTruth();
    
    // Get the snapshot object
    int sid = self.testManager->test_counter;
    
    if (sid >= self.model->snapshot_array.size()){
        [self displayPopupMessage:@"snapshot_array's size is not right."];
        return;
    }else if (sid >= self.testManager->record_vector.size()){
        [self displayPopupMessage:@"record_vector's size is not right."];
        return;        
    }

    //-------------
    // For the orient task, show the answer on iPhone
    //-------------
    if (([self.testManager->record_vector[sid].code rangeOfString:
         toNSString(ORIENT)].location
        != NSNotFound) ||
        ([self.testManager->record_vector[sid].code rangeOfString:
          toNSString(DISTANCE)].location
         != NSNotFound))
    {
        [self sendMessage:@"ShowAnswers"];
        // Skip the rest
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
        
        
        // For wedge, we will show triangle only
        if ([self.model->configurations[@"wedge_status"] isEqualToString: @"on"])
        {
            self.renderer->emulatediOS.is_mask_enabled = NO;
        }else{
            // For compass, we will show drop pin
            CustomPointAnnotation *annotation = [self createAnnotationFromGLPoint:cgTruth withType:answer];
            [self.mapView addAnnotation:annotation];
            [[self.mapView viewForAnnotation:annotation] setHidden:NO];
        }
    }else{
        CustomPointAnnotation *annotation = [self createAnnotationFromGLPoint:cgTruth withType:answer];
        [self.mapView addAnnotation:annotation];
        [[self.mapView viewForAnnotation:annotation] setHidden:NO];
    }
    
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
    
    if (self.testManager->testManagerMode == OFF){
        [self toggleInformationView:nil];
        return;
    }
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    if ([prefs boolForKey:@"isWaitingAdminCheck"]){
        [self displayPopupMessage:@"TestManager is locked."];
        return;
    }

    //--------------------
    // check if iOS has the right device type
    //--------------------
    
    if (self.model->snapshot_array[self.testManager->test_counter].deviceType
        != self.testManager->iOSdeviceType)
    {
        [self displayPopupMessage:@"Please configure iOS to the correct device type."];
        return;
    }

    //--------------------
    // Hide the text field if it is visible
    //--------------------
    if (![self.informationTextField isHidden])
    {

        [self.informationTextField setHidden:YES];
//        [self.informationImageView setHidden:NO];
        [self.AVPlayerView setHidden:NO];
        [self.AVPlayerView.player play];
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

        [prefs setObject:[NSNumber numberWithBool:NO] forKey:@"isAnswerConfirmed"];
    }
}

//----------------------
// Menu bar control
//----------------------
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

//----------------------
// Toggle information view
//----------------------
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

//----------------------
// Display test instructions
//----------------------
- (void) displayTestInstructionsByCode: (NSString*) code
{
    // Skip the following if it is in the Dve mode
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if ([prefs boolForKey:@"isDevMode"])
        return;
    
    self.isInformationViewVisible = [NSNumber numberWithBool:YES];
    
    //------------------
    // Generate video name
    //------------------
    TestCodeInterpreter codeInterpreter(code);
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:codeInterpreter.genVideoName() ofType:@"mp4"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath: path];
    
    //------------------
    // Configure the video
    //------------------
    [self.AVPlayerView.player pause];
    self.AVPlayerView.player =
    [AVPlayer playerWithURL:url];
    self.AVPlayerView.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [self.AVPlayerView.player pause];
    
    //------------------
    // Show the information view
    //------------------
    [self.mapView setHidden:YES];
    [self.compassView setHidden:YES];
    [self.informationView setHidden:NO];
    
    // If the text field is not hidden, let the text field dispaly on top
    if (![self.informationTextField isHidden]){
        [self.informationTextField setHidden:NO];
        [self.AVPlayerView setHidden:YES];
    }else{
        [self.AVPlayerView setHidden:NO];
        [self.AVPlayerView.player play];
    }
    
    [self displayStudyTitle];
    
    [prefs setObject:[NSNumber numberWithBool:NO] forKey:@"isAnswerConfirmed"];
}



//----------------------------
// Display test information
//----------------------------
- (void) displayInformationText
{

    // Skip the following if it is in the Dve mode
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if ([prefs boolForKey:@"isDevMode"])
        return;
    
    self.isInformationViewVisible = [NSNumber numberWithBool:YES];
    [self.informationTextField setHidden:NO];
    [self displayStudyTitle];
    //------------------
    // Show the information view
    //------------------
    [self.mapView setHidden:YES];
    [self.compassView setHidden:YES];
    [self.informationView setHidden:NO];
    [self.AVPlayerView setHidden:YES];
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
    // Collect ground truth
    self.testManager->collectGroundTruth();
    
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
    
    
    // Skip the following if it is in the Dve mode
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (![prefs boolForKey:@"isDevMode"]){
        // Enable the next button if the answer is verified,
        // or when the system is put in dev/practice mode
        if (self.testManager->verifyAnswerQuality())
        {
            [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"isAnswerConfirmed"];
            
        }
    }else{
        [prefs setObject:[NSNumber numberWithBool:YES] forKey:@"isAnswerConfirmed"];
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
