//
//  TaskSpec-Generation.mm
//  Compass[transparent]
//
//  Created by Daniel on 3/4/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#include "TaskSpec.h"
#include "compassRender.h"
using namespace std;

//------------------
// Desktop only implementation
//------------------
#ifndef __IPHONE__
#import "DesktopViewController.h"

//--------------------
// TestGeneration Dispatcher
//--------------------
void TaskSpec::generateLocationAndSnapshots(vector<data> &t_data_array,
                                            std::mt19937 &generator)
{
    switch (taskType) {
        case LOCATE:
            generateLocateTests(t_data_array);
            break;
        case TRIANGULATE:
            generateTriangulateTests(t_data_array, generator);
            break;
        case ORIENT:
            generateOrientTests(t_data_array);
            break;
        case LOCATEPLUS:
            generateLocatePlusTests(t_data_array, generator);
            break;
        case DISTANCE:
            generateLocateTests(t_data_array);
            break;
        default:
            break;
    }
};


//-----------------------
// Locate tests
//-----------------------
void TaskSpec::generateLocateTests(vector<data> &t_data_array)
{
    snapshot_array.clear();
    code_location_vector.clear();
 
    NSString* trials;
    NSString* practices;
    double scale_factor = 1;
    
    
    vector<int> trial_dist;
    vector<int> practice_dist;
    if (taskType == LOCATE){
        trial_dist = NSArrayIntToVector
        (testSpecDictionary[@"locate_trials"]);
        practice_dist = NSArrayIntToVector
        (testSpecDictionary[@"locate_practices"]);
    }else{
        trial_dist = NSArrayIntToVector
        (testSpecDictionary[@"distance_trials"]);
        practice_dist = NSArrayIntToVector
        (testSpecDictionary[@"distance_practices"]);

        vector<int> distractor = NSArrayIntToVector
        (testSpecDictionary[@"distance_trials_distractor"]);
        
        int distractor_count = distractor.size();
        
        if (isMutant){
            for (int i = 0; i < distractor_count/2; ++i){
                trial_dist.push_back(distractor[i]);
            }
        }else{
            for (int i = distractor_count/2; i < distractor_count; ++i){
                trial_dist.push_back(distractor[i]);
            }
        }
        
        scale_factor =
        (double)rootViewController.renderer->emulatediOS.width / (double)rootViewController.renderer->emulatediOS.true_ios_width;
    }
    
    //-------------------
    // Generate locations, data, and snapshot
    //-------------------
    for (int i = 0; i < trial_dist.size(); ++i){
        int x = trial_dist[i];
        if (isMutant){
            x = -x;
        }
        
        // Need to scale x for the distance tests
        addOneDataAndSnapshot
        (to_string(i), CGPointMake(x*scale_factor, 0), t_data_array);
    }

    //-------------------
    // Generate practice trials
    //-------------------
    for (int i = 0; i < practice_dist.size(); ++i)
    {
        int x = practice_dist[i];
        if (isMutant){
            x = -x;
        }
        
        string trialString = to_string(i) + "t";
        // Need to scale x for the distance tests
        addOneDataAndSnapshot
        (trialString, CGPointMake(x*scale_factor, 0), t_data_array);
    }
}

//-----------------------
// Orient tests
//-----------------------
void TaskSpec::generateOrientTests(vector<data> &t_data_array)
{
    snapshot_array.clear();
    code_location_vector.clear();
    
    //-------------------
    // Parameters
    //-------------------
    vector<vector<int>> xy_vector = NSArrayStringToVector
    (testSpecDictionary[@"orient_trials_xy"]);
    
    double scale_factor =
    (double)rootViewController.renderer->emulatediOS.width / (double)rootViewController.renderer->emulatediOS.true_ios_width;
    
    //-------------------------
    // Generate point (x, y) here
    //-------------------------
    for (int i = 0; i < xy_vector.size(); ++i)
    {
        double x = xy_vector[i][0] * scale_factor;
        double y = xy_vector[i][1] * scale_factor;
        
        if (isMutant)
        {
            x = -x; y = -y;
        }
        
        addOneDataAndSnapshot
        (to_string(i), CGPointMake(x, y), t_data_array);
    }
    
    //-------------------
    // Generate practice trials
    //-------------------
    xy_vector = NSArrayStringToVector
    (testSpecDictionary[@"orient_practices_xy"]);
    for (int i = 0; i < xy_vector.size(); ++i)
    {
        double x = xy_vector[i][0] * scale_factor;
        double y = xy_vector[i][1] * scale_factor;
        
        if (isMutant)
        {
            x = -x; y = -y;
        }
        
        string trialString = to_string(i) + "t";

        addOneDataAndSnapshot
        (trialString, CGPointMake(x, y), t_data_array);
        
    }    
}

void TaskSpec::addOneDataAndSnapshot(string trialString,
                                     CGPoint openGLPoint,
                       vector<data> &t_data_array)
{
    //--------------
    // Generate a new test location
    //--------------
    CGPoint mapViewPoint =
    CGPointMake(openGLPoint.x + rootViewController.renderer->view_width/2,
                rootViewController.renderer->view_height/2 - openGLPoint.y);
    
    data t_data;
    CLLocationCoordinate2D coord =
    [rootViewController.mapView convertPoint: mapViewPoint
                        toCoordinateFromView:rootViewController.mapView];
    t_data.latitude = coord.latitude;
    t_data.longitude = coord.longitude;
    t_data.name = identifier + ":" + trialString;
    t_data_array.push_back(t_data);
    
    //--------------
    // Generate a new snapshot
    //--------------
    
    // Calculate coordinate region
    MKCoordinateRegion coordinateRegion;
    coordinateRegion.center = rootViewController.mapView.centerCoordinate;
    
    if (deviceType == PHONE){
        //----------------
        // Phone
        //----------------
        coordinateRegion.span =
        [rootViewController calculateCoordinateSpanForDevice:PHONE];
    }else{
        //----------------
        // Watch
        //----------------
        coordinateRegion.span =
        [rootViewController calculateCoordinateSpanForDevice:WATCH];
    }
    
    //------------------
    // Collect all the selected ids
    //------------------
    vector<int> selected_ids = {(int)t_data_array.size() - 1};
    vector<int> is_answer_list = {1};
    
    //------------------
    // Assemble a snapshot
    //------------------
    snapshot t_snapshot;
    t_snapshot.name = [NSString stringWithUTF8String:
                       (identifier + ":" + trialString).c_str()];
    t_snapshot.coordinateRegion = coordinateRegion;
    t_snapshot.selected_ids = selected_ids;
    t_snapshot.is_answer_list = is_answer_list;
    t_snapshot.orientation = 0;
    t_snapshot.deviceType = deviceType;
    t_snapshot.notes = [NSString stringWithFormat:
                        @"(x, y): (%f, %f)", openGLPoint.x,openGLPoint.y];
    
    if (trialString.find("t") == string::npos)
        snapshot_array.push_back(t_snapshot);
    else
        practice_snapshot_array.push_back(t_snapshot);
    
    
    //-----------------
    // Log debug information
    //-----------------
    code_location_vector.push_back(
                                   make_pair(identifier + ":" + trialString,
                                vector<int>{(int)openGLPoint.x,(int)openGLPoint.y}));
}
#endif