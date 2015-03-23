//
//  TestManager.cpp
//  Compass[transparent]
//
//  Created by Daniel on 1/20/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#include "TestManager.h"

#ifndef __IPHONE__
#import "DesktopViewController.h"
#else
#import "iOSViewController.h"
#endif

#import "CHCSVParser.h"
#import "compassRender.h"

using namespace std;

//--------------
// Test Manager singleton initializations
//--------------
TestManager* TestManager::shareTestManager(){
    static TestManager* instance = NULL;
    
    if (!instance){ // Only allow one instance of class to be generated
        instance = new TestManager;
        instance->initTestManager();
    }
    return instance;
};

//--------------
// Test Manager initializations
//--------------
int TestManager::initTestManager(){
    
    model = compassMdl::shareCompassMdl();
    
    test_counter = 0;
    testManagerMode = OFF;
    iOSAnswer = 10000;
    isRecordAutoSaved = NO;
    iOSdeviceType = PHONE;
    
    //----------------
    // Parameters for each type of test
    //----------------
    // File names
    // Initialize default output filenames
    test_foldername     = @"study0";
    test_kml_filename   = @"studyLocations.kml";
    test_location_filename  = @"temp.locations";
    alltest_vector_filename = @"allTestVectors.tests";
    test_snapshot_prefix = @"snapshot-participant";
    practice_filename = @"practice.snapshot";
    record_filename = @"participant0.dat";
    test_specs_filename = @"testSpec.plist";
    
#ifndef __IPHONE__
    loadTestSpecPlist();
#endif
    
    // Initialize random number generation
    seed = 12345;
    std::mt19937 temp(seed);
    generator = temp;
    return 0;
}


//--------------
// Reset the test manager
//--------------
void TestManager::resetTestManager(){
    test_counter = 0;
}

//--------------
// Load test spec plist
//--------------
void TestManager::loadTestSpecPlist(){
    NSPropertyListFormat format;
    NSString *errorDesc = nil;
    NSString *plistPath;
    plistPath = [model->desktopDropboxDataRoot
                 stringByAppendingPathComponent: test_specs_filename];
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    testSpecDictionary = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:&format
                                          errorDescription:&errorDesc];
}

//--------------
// Prepare the output environment
//--------------
void TestManager::setupOutputFolder(){
    NSString *out_folder_path = [model->desktopDropboxDataRoot
                                 stringByAppendingString:test_foldername];
    if (![[NSFileManager defaultManager] fileExistsAtPath:out_folder_path])
    {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:out_folder_path withIntermediateDirectories:NO attributes:nil error:&error];
        NSLog(@"%@ created", out_folder_path);
    }
}

//--------------
// Test Generation
//--------------
int TestManager::generateTests(){
#ifndef __IPHONE__
 
    //=====================
    // Test Parameters
    //=====================
    device_list = {PHONE, WATCH};
    visualization_list = {VIZWEDGE, VIZPCOMPASS};
    task_list = {LOCATE, TRIANGULATE, ORIENT, LOCATEPLUS, DISTANCE}; //DISTANCE
    data_set_list = {NORMAL, MUTANT};
    
    phone_task_list = {LOCATE, ORIENT, DISTANCE};
    watch_task_list = {TRIANGULATE, LOCATEPLUS};

    //=====================
    // Initialize taskSpec_dict
    //=====================
    taskSpec_dict.clear();
    t_data_array.clear();
    code_xy_vector.clear();
    practice_snapshot_vector.clear();

    // Reset the practice snapshots
    practice_snapshot_dict.clear();
    practice_snapshot_dict[NORMAL] = vector<snapshot>();
    practice_snapshot_dict[NORMAL].clear();
    practice_snapshot_dict[MUTANT] = vector<snapshot>();
    practice_snapshot_dict[MUTANT].clear();
    
    //=====================
    // The following generates two classes of TestSpecs, one normal and one mutant
    //=====================
    for (auto dsit = data_set_list.begin(); dsit != data_set_list.end(); ++dsit)
    {
        for (auto dit = device_list.begin(); dit != device_list.end(); ++dit)
        {
            for (auto tit = task_list.begin(); tit != task_list.end(); ++tit)
            {
                string code = toString(*dit) + ":" +
                toString(*tit) + ":" + toString(*dsit);
                
                TaskSpec myTaskSpec(*tit,
                                    testSpecDictionary,
                                    rootViewController);
                if (myTaskSpec.deviceType != *dit)
                    continue;
                
                if (*dsit == MUTANT)
                    myTaskSpec.isMutant = YES;
                
                //--------------
                // Here we restrict tasks to only be generated on specific platform
                //--------------
                if (myTaskSpec.deviceType == *dit){
                    myTaskSpec.identifier = code;
                    myTaskSpec.deviceType = *dit; 
                    myTaskSpec.generateLocationAndSnapshots(t_data_array, generator);
                    taskSpec_dict[code] = myTaskSpec;
                    
                    // For debug purpose
                    code_xy_vector.insert(code_xy_vector.end(),
                                          myTaskSpec.code_location_vector.begin(),
                                          myTaskSpec.code_location_vector.end());
                    
                    //---------------------
                    // Deposit practice snapshots
                    //---------------------
                    practice_snapshot_vector.insert(practice_snapshot_vector.end(),
                                                    myTaskSpec.practice_snapshot_array.begin(),myTaskSpec.practice_snapshot_array.end()
                                                    );
                    
                    // Shuffle then insert
                    shuffle(myTaskSpec.practice_snapshot_array.begin(),
                                   myTaskSpec.practice_snapshot_array.end(), generator);
                    practice_snapshot_dict[*dsit].insert(practice_snapshot_dict[*dsit].end(),
                                    myTaskSpec.practice_snapshot_array.begin(),
                                    myTaskSpec.practice_snapshot_array.end());
                }
            }
        }
    }

    //=====================
    // Generate location vector
    // based on the device, visualization and task specified in the list
    //=====================
    saveLocationVector();
    
    //=====================
    // Generate Test Vectors
    //=====================
    generateAllTestVectors(device_list, visualization_list, task_list);

    //=====================
    // Save the files
    //=====================
    saveSnapShotsToKML();
#endif
    return 0;
}

void TestManager::saveLocationVector(){
    
    // Make sure the output folder exists
    setupOutputFolder();
    //---------------------
    // Save code_xy to CSV
    //---------------------
    NSString *folder_path = [model->desktopDropboxDataRoot
                             stringByAppendingString:test_foldername];
    NSString *out_file = [folder_path
                          stringByAppendingPathComponent:@"temp.locations.old"];
    CHCSVWriter *w = [[CHCSVWriter alloc] initForWritingToCSVFile:out_file];
    
    // http://stackoverflow.com/questions/1443793/iterate-keys-in-a-c-map
    
    // map<string, vector<int>> location_dict;
    for (int i = 0; i <code_xy_vector.size(); ++i){
        string code = code_xy_vector[i].first;
        vector<int> xy = code_xy_vector[i].second;
        [w writeLineOfFields:@[[NSString stringWithUTF8String:code.c_str()],
                               [NSNumber numberWithInteger:xy[0]],
                               [NSNumber numberWithInteger:xy[1]]]];
    }
    
    out_file = [folder_path
                          stringByAppendingPathComponent:test_location_filename];
    w = [[CHCSVWriter alloc] initForWritingToCSVFile:out_file];
    
    //---------------------
    // Pull the information from snapshots in TaskSpec direction
    //---------------------
    for (auto iter = taskSpec_dict.begin(); iter != taskSpec_dict.end(); ++iter)
    {
        vector<snapshot> t_snapshot = iter->second.snapshot_array;
        
        for (int i = 0; i < t_snapshot.size(); ++i)
        {
            [w writeLineOfFields:@[t_snapshot[i].name,
                                   t_snapshot[i].notes]];
        }
    }

    //---------------------
    // Pull the information from snapshots in TaskSpec direction
    //---------------------
    for (auto iter = taskSpec_dict.begin(); iter != taskSpec_dict.end(); ++iter)
    {
        vector<snapshot> t_snapshot = iter->second.practice_snapshot_array;
        
        for (int i = 0; i < t_snapshot.size(); ++i)
        {
            [w writeLineOfFields:@[t_snapshot[i].name,
                                   t_snapshot[i].notes]];
        }
    }
    
    //---------------------
    // Save t_data_array to KML
    //---------------------
    NSString *content = genKMLString(t_data_array);
    
    NSError* error;
    NSString *doc_path = [folder_path
                          stringByAppendingPathComponent:test_kml_filename];
    
    if (![content writeToFile:doc_path
                   atomically:YES encoding: NSUTF8StringEncoding
                        error:&error])
    {
        throw(runtime_error("Failed to write test kml file"));
    }
}