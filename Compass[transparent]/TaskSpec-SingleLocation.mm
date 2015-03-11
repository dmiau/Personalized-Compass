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
            generateDistanceTests(t_data_array);
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
    float device_width;
    float monitor_width = 1920;
    //-------------------
    // Parameters
    //-------------------
    if (deviceType == PHONE){
        device_width = rootViewController.renderer->emulatediOS.width;
    }else{
        device_width = rootViewController.renderer->emulatediOS.radius;
    }

    snapshot_array.clear();
    code_location_vector.clear();
    
    //-------------------
    // Generate locations, data, and snapshot
    //-------------------
    vector<int> trial_dist = NSArrayIntToVector
    (testSpecDictionary[@"locate_trials"]);
    
    for (int i = 0; i < trial_dist.size(); ++i){
        addOneDataAndSnapshot
        (to_string(i), CGPointMake(trial_dist[i], 0), t_data_array);
        code_location_vector.push_back(make_pair(identifier + ":" + to_string(i),
                                                 vector<int>{trial_dist[i], 0}));
    }

    //-------------------
    // Generate practice trials
    //-------------------
    vector<int> practice_dist = NSArrayIntToVector
    (testSpecDictionary[@"locate_practices"]);
    for (int i = 0; i < practice_dist.size(); ++i)
    {
        string trialString = to_string(i) + "t";
        addOneDataAndSnapshot
        (trialString, CGPointMake(practice_dist[i], 0), t_data_array);
        code_location_vector.push_back(make_pair(identifier + ":" + trialString,
                                                 vector<int>{practice_dist[i], 0}));
    }
}

//-----------------------
// Distance tests
//-----------------------
void TaskSpec::generateDistanceTests(vector<data> &t_data_array)
{
    float device_width;
    float monitor_width = 1920;

    //-------------------
    // Parameters
    //-------------------
    if (deviceType == PHONE){
        device_width = rootViewController.renderer->emulatediOS.width;
    }else{
        device_width = rootViewController.renderer->emulatediOS.radius;
    }
    
    snapshot_array.clear();
    code_location_vector.clear();
    //-------------------
    // Generate locations, data, and snapshot
    //-------------------
    vector<int> trial_dist = NSArrayIntToVector
    (testSpecDictionary[@"distance_trials"]);
    
    for (int i = 0; i < trial_dist.size(); ++i){
        code_location_vector.push_back(make_pair(identifier + ":" + to_string(i),
                                                 vector<int>{trial_dist[i], 0}));
        addOneDataAndSnapshot
        (to_string(i), CGPointMake(trial_dist[i], 0), t_data_array);
    }
    
    //-------------------
    // Generate practice trials
    //-------------------
    vector<int> practice_dist = NSArrayIntToVector
    (testSpecDictionary[@"distance_practices"]);
    for (int i = 0; i < practice_dist.size(); ++i)
    {
        string trialString = to_string(i) + "t";
        addOneDataAndSnapshot
        (trialString, CGPointMake(practice_dist[i], 0), t_data_array);
        code_location_vector.push_back(make_pair(identifier + ":" + trialString,
                                                 vector<int>{practice_dist[i], 0}));
    }
}

//-----------------------
// Orient tests
//-----------------------
void TaskSpec::generateOrientTests(vector<data> &t_data_array)
{
    //-------------------
    // Parameters
    //-------------------
    vector<vector<int>> xy_vector = NSArrayStringToVector
    (testSpecDictionary[@"orient_trials_xy"]);
    
    snapshot_array.clear();
    code_location_vector.clear();
    //-------------------------
    // Generate point (x, y) here
    //-------------------------
    for (int i = 0; i < xy_vector.size(); ++i){
        code_location_vector.push_back(
                                       make_pair(identifier + ":" + to_string(i),
                                                 vector<int>{xy_vector[i][0],
                                                     xy_vector[i][1]}));
        addOneDataAndSnapshot
        (to_string(i), CGPointMake(xy_vector[i][0], xy_vector[i][1]), t_data_array);
        
    }
    
    //-------------------
    // Generate practice trials
    //-------------------
    xy_vector = NSArrayStringToVector
    (testSpecDictionary[@"orient_practices_xy"]);
    for (int i = 0; i < xy_vector.size(); ++i){
        string trialString = to_string(i) + "t";
        code_location_vector.push_back(
                                       make_pair(identifier + ":" + trialString,
                                                 vector<int>{xy_vector[i][0],
                                                     xy_vector[i][1]}));
        addOneDataAndSnapshot
        (trialString, CGPointMake(xy_vector[i][0], xy_vector[i][1]), t_data_array);
        
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
    
    if (trialString.find("t") == string::npos)
        snapshot_array.push_back(t_snapshot);
    else
        practice_snapshot_array.push_back(t_snapshot);
}
#endif