//
//  model.cpp
//  Exploration
//
//  Created by Daniel Miau on 2/8/14.
//  Copyright (c) 2014 Daniel Miau. All rights reserved.
//

#include "compassModel.h"
#include "commonInclude.h"
#include <unistd.h>
#import <CoreLocation/CoreLocation.h>
#include "xmlParser.h"

// http://stackoverflow.com/questions/3277121/include-objective-c-header-in-c-file

using namespace std;
#pragma mark compassMdl class`
// http://www.galloway.me.uk/tutorials/singleton-classes/
// http://www.yolinux.com/TUTORIALS/C++Singleton.html


//--------------
// Compass model singleton initializations
//--------------
compassMdl* compassMdl::shareCompassMdl(){
    static compassMdl* instance = NULL;
    
    if (!instance){ // Only allow one instance of class to be generated
        instance = new compassMdl;
        instance->initMdl();
    }
    return instance;
};

//--------------
// Compass model initializations
//--------------
int compassMdl::initMdl(){
    
    //--------------
    // Parameter initialization
    //--------------
    tilt = 0;
    compassCenterXY.x = 0.0;
    compassCenterXY.y = 0.0;
    lockLandmarks = false;
    configurations = [[NSMutableDictionary alloc] init];

    //--------------
    // Initialize filesystem
    //--------------
#ifdef __IPHONE__
    docFilesystem = [[filesystem alloc] initIOSDOC];
    dbFilesystem = [[filesystem alloc] initDROPBOX];
#endif
    
    //--------------
    // Load configurations and locations
    //--------------
    configuration_filename = [[NSBundle mainBundle] pathForResource:@"configurations.json" ofType:@""];
    
    // Need to read the configuraiton file first (to get the default location file name, if default options are used.
    readConfigurations(this);
    
    location_filename =[[NSBundle mainBundle] pathForResource:configurations[@"default_location_filename"] ofType:@""];
    
    //------------
    // Load configuations from physical files into memory
    //------------
    reloadFiles();
    watchConfigurationFile();
    
    return 0;
}

//===================
// Load locations and configurations
// from physical files into memory
//===================
int compassMdl::reloadFiles(){
    // Read the configuration data
    readConfigurations(this);
    // Read the location data
    readLocationKml(this);
    updateMdl();
    return 0;
}

//===================
// Update Mdl (calculate distances and orientations, etc.)
//===================
int compassMdl::updateMdl(){
    // recalculate distnace and orientation, etc.
    
    // also need to sort locations by their distnaces
    vector<pair<double, int>> location_pair;
    
    // need to reset compass_params.indices_sorted_by_distance and distance_list
    // before entering the loop
    distance_list.clear();
    indices_sorted_by_distance.clear();

    
    for (int i = 0; i < data_array.size(); ++i){
        double distance = current_pos.computeDistanceFromLocation
        (data_array[i]);
        double orientation = current_pos.computeOrientationFromLocation
        (data_array[i]);
        data_array[i].distance = distance;
        data_array[i].orientation = orientation;
        
        // distance_list and indices_sorted_by_distance are used for normalization
        // and drawing purposes.
        distance_list.push_back(distance);
        location_pair.push_back(make_pair(distance, i));
    }
    
    sort(location_pair.begin(), location_pair.end(), compareAscending);
    for (int i = 0; i < location_pair.size(); ++i){
        indices_sorted_by_distance.push_back(location_pair[i].second);
    }
    
    // -----------------
    // Filter landmarks
    // -----------------
    
    // [todo] this part should be customizable
    // K_ORIENTATIONS
    
    if (lockLandmarks){
        // indices_for_rendering should be sorted by its associated distances
        vector<pair<double, int>> dist_id_pair_list;
        for (int i = 0; i< indices_for_rendering.size(); ++i)
        {
            int j = indices_for_rendering[i];
            dist_id_pair_list
            .push_back(make_pair(data_array[j].distance, j));
        }
        
        // **indices_for_rendering should be sorted by distance
        sort(dist_id_pair_list.begin(), dist_id_pair_list.end(), compareAscending);
        
        indices_for_rendering.clear();
        for (int i = 0; i < dist_id_pair_list.size(); ++i)
        {
            indices_for_rendering.push_back(dist_id_pair_list[i].second);
        }
    }else{
        indices_for_rendering.clear();
        indices_for_rendering =
        applyFilter(hashFilterStr(configurations[@"filter_type"]),
                    [configurations[@"landmark_n"] intValue]);
    }
    // -----------------
    // Calculate bounding box for displaying the map
    // -----------------
    
    // [todo better bound]
    // Calculate latitude delta and longitude delta
    // Find out the longest distance for normalization
    std::vector<double>::iterator result =
    std::max_element(distance_list.begin(),
                     distance_list.end());
    double max_dist = *result; //(meters)
    
    latitudedelta = 0.1 * max_dist / 1110000.0;
    longitudedelta = 0.1 * max_dist / 1110000.0;
    return 0;
}

int compassMdl::cleanMdl(){
    for (int i = 0; i < color_map.size(); ++i)
        delete [] color_map[i];
    // http://www.cplusplus.com/forum/beginner/51598/
    // http://stackoverflow.com/questions/936687/how-do-i-declare-a-2d-array-in-c-using-new
    return EXIT_SUCCESS;
}

//===================
// watch the configuraiton, reread the configuration file if the file has been touched
//===================
void compassMdl::watchConfigurationFile(){
    //http://stackoverflow.com/questions/11355144/file-monitoring-using-grand-central-dispatch/11372441#11372441
    
    int fdes = open([configuration_filename UTF8String], O_RDONLY);
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    void (^eventHandler)(void), (^cancelHandler)(void);
    unsigned long mask = DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_ATTRIB | DISPATCH_VNODE_LINK | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE;
    __block dispatch_source_t source;
    
    eventHandler = ^{
        unsigned long l = dispatch_source_get_data(source);
        if (l & DISPATCH_VNODE_DELETE) {
            printf("watched file deleted!  cancelling source\n");
            dispatch_source_cancel(source);
        }
        else{
            NSLog(@"%lu", l);
            // [todo] currently only works with aquamacs
            // handle the file has data case
            printf("Watched file has data\n");
            readConfigurations(this);
        }
    };
    cancelHandler = ^{
        int fdes = dispatch_source_get_handle(source);
        close(fdes);
        // Wait for new file to exist.
        while ((fdes = open([configuration_filename UTF8String], O_RDONLY)) == -1)
            sleep(1);
        printf("re-opened target file in cancel handler\n");
        source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fdes, mask, queue);
        dispatch_source_set_event_handler(source, eventHandler);
        dispatch_source_set_cancel_handler(source, cancelHandler);
        dispatch_resume(source);
    };
    
    source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,fdes, mask, queue);
    dispatch_source_set_event_handler(source, eventHandler);
    dispatch_source_set_cancel_handler(source, cancelHandler);
    dispatch_resume(source);
}


#pragma mark ----------location distance/orientation tools----------
//===================
// tools for distance and orientation calculation
//===================
double DegreesToRadians(double degrees) {return degrees * M_PI / 180.0;};
double RadiansToDegrees(double radians) {return radians * 180.0/M_PI;};
// calculate bearing
// http://stackoverflow.com/questions/3925942/cllocation-category-for-calculating-bearing-w-haversine-function
//

double data::computeDistanceFromLocation(data& another_data){

    // Take advantage of OSX's foundation class
    CLLocation *cur_location = [[CLLocation alloc]
                                initWithLatitude: this->latitude
                                longitude: this->longitude];
    
    
    CLLocation *target_location = [[CLLocation alloc]
                                   initWithLatitude:
                                   another_data.latitude
                                   longitude:
                                   another_data.longitude];
    CLLocationDistance distnace = [cur_location distanceFromLocation: target_location];
    return distnace;
}


double data::computeOrientationFromLocation(data &another_data){
    
    double lat1 = DegreesToRadians(this->latitude);
    double lon1 = DegreesToRadians(this->longitude);
    
    double lat2 = DegreesToRadians(another_data.latitude);
    double lon2 = DegreesToRadians(another_data.longitude);
    
    double dLon = lon2 - lon1;
    
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double radiansBearing = atan2(y, x);
    
    return RadiansToDegrees(radiansBearing);
}