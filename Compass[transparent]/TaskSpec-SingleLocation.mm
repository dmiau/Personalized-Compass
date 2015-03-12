//
//  TaskSpec-Generation.mm
//  Compass[transparent]
//
//  Created by Daniel on 3/4/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#include "TaskSpec.h"
using namespace std;

//------------------
// Desktop only implementation
//------------------
#ifndef __IPHONE__
#import "DesktopViewController.h"

//--------------------
// TestGeneration Dispatcher
//--------------------
void TaskSpec::generateLocationAndSnapshots(vector<data> &t_data_array)
{
    switch (taskType) {
        case LOCATE:
            generateLocateTests(t_data_array);
            break;
        case TRIANGULATE:
            generateTriangulateTests(t_data_array);
            break;
        case ORIENT:
            generateOrientTests(t_data_array);
            break;
        case LOCATEPLUS:
            generateLocatePlusTests(t_data_array);
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
    
    if (taskType == LOCATE){
        trials = @"locate_trials";
        practices = @"locate_practices";
    }else{
        trials = @"distance_trials";
        practices = @"distance_practices";
    }
    
    //-------------------
    // Generate locations, data, and snapshot
    //-------------------
    vector<int> trial_dist = NSArrayIntToVector
    (testSpecDictionary[trials]);
    
    for (int i = 0; i < trial_dist.size(); ++i){
        
        int x = trial_dist[i];
        if (isMutant){
            x = -x;
        }
        
        addOneDataAndSnapshot
        (to_string(i), IntPointMake(x, 0), t_data_array);
    }

    //-------------------
    // Generate practice trials
    //-------------------
    vector<int> practice_dist = NSArrayIntToVector
    (testSpecDictionary[practices]);
    for (int i = 0; i < practice_dist.size(); ++i)
    {
        int x = practice_dist[i];
        if (isMutant){
            x = -x;
        }
        
        string trialString = to_string(i) + "t";
        addOneDataAndSnapshot
        (trialString, IntPointMake(x, 0), t_data_array);
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
    //-------------------------
    // Generate point (x, y) here
    //-------------------------
    for (int i = 0; i < xy_vector.size(); ++i)
    {
        int x = xy_vector[i][0];
        int y = xy_vector[i][1];
        
        if (isMutant)
        {
            x = -x; y = -y;
        }
        
        addOneDataAndSnapshot
        (to_string(i), IntPointMake(x, y), t_data_array);
    }
    
    //-------------------
    // Generate practice trials
    //-------------------
    xy_vector = NSArrayStringToVector
    (testSpecDictionary[@"orient_practices_xy"]);
    for (int i = 0; i < xy_vector.size(); ++i)
    {
        int x = xy_vector[i][0];
        int y = xy_vector[i][1];
        
        if (isMutant)
        {
            x = -x; y = -y;
        }
        
        string trialString = to_string(i) + "t";

        addOneDataAndSnapshot
        (trialString, IntPointMake(x, y), t_data_array);
        
    }    
}

void TaskSpec::addOneDataAndSnapshot(string trialString,
                                     IntPoint openGLPoint,
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
    t_snapshot.notes = [NSString stringWithFormat:
                        @"(x, y): (%d, %d)", openGLPoint.x,openGLPoint.y];
    
    if (trialString.find("t") == string::npos)
        snapshot_array.push_back(t_snapshot);
    else
        practice_snapshot_array.push_back(t_snapshot);
    
    
    //-----------------
    // Log debug information
    //-----------------
    code_location_vector.push_back(
                                   make_pair(identifier + ":" + trialString,
                                vector<int>{openGLPoint.x,openGLPoint.y}));
}
#endif