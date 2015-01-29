//
//  TestManager.cpp
//  Compass[transparent]
//
//  Created by Daniel on 1/20/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#include "TestManager.h"
#import "compassModel.h"

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
    
    visualization_vector.clear();
    device_vector.clear();
    visualization_counter = 0;
    test_counter = -1; //-1 means initialization
    
    vector<VisualizationType> visualization_enums
    = {VIZNONE, VIZPCOMPASS, VIZWEDGE, VIZOVERVIEW};
    NSArray* visualization_strings =
    @[@"None", @"PComp", @"Wedge", @"OverV"];
    
    for (int i = 0; i < visualization_enums.size(); ++i){
        param myParam;
        myParam.type = visualization_enums[i];
        myParam.isEnabled = true;
        myParam.name = visualization_strings[i];
        visualization_vector.push_back(myParam);
    }
    
    vector<DeviceType> device_enums = {PHONE, WATCH};
    
    NSArray* device_strings = @[@"Phone", @"Watch"];
    for (int i = 0; i < device_enums.size(); ++i){
        param myParam;
        myParam.type = device_enums[i];
        myParam.isEnabled = true;
        myParam.name = device_strings[i];
        device_vector.push_back(myParam);
    }
    
    // Generate a set of inti tests
//    generateTests();
    
    // Initialize random number generation
    seed = 12345;
    std::mt19937 temp(seed);
    generator = temp;
    return 0;
}


//--------------
// Test Generation
//--------------
int TestManager::generateTests(){
    compassMdl* model = compassMdl::shareCompassMdl();
    enabled_visualization_vector.clear();
    for (int i = 0; i < visualization_vector.size(); ++i){
        if (visualization_vector[i].isEnabled){
            enabled_visualization_vector.push_back
            (visualization_vector[i]);
        }
    }
    
    enabled_device_vector.clear();
    for (int i = 0; i < device_vector.size(); ++i){
        if (device_vector[i].isEnabled){
            enabled_device_vector.push_back
            (device_vector[i]);
        }
    }

    //=====================
    // Generate location vector
    //=====================
    
    for (int i = 0; i < enabled_device_vector.size(); ++i){
        DeviceType deviceType = (DeviceType) enabled_device_vector[i].type;
        
        map<string, vector<int>> t_location_dict = generateLocationVector();
        
//        vector<data> locate_tests = generateLocateTests(deviceType);
//        
//        // I will need to package the tests into snapshots
//        
//        vector<data> triangulate_ests = generateTriangulateTests(deviceType);
//        vector<data> orient_tests = generateOrientTests(deviceType);
    }
    
    //=====================
    // Generate tests
    //=====================
    
    //--------------------------
    // Test parameters
    vector<string> device_list = {"phone", "watch"};
    vector<string> visualization_list = {"pcompass", "wedge"};
    vector<string> task_list = {"t1", "t2", "t3"};
    vector<string> distance_list = {"c", "f"};
    
    pool device_pool = pool(device_list, 1); //phone, watch
    pool visualization_pool = pool(visualization_list, 2); //personalized compass, wedge
    pool task_pool = pool(task_list, 2);

    // Initialize several pools
    vector<string> location_list; location_list.clear();

    int location_n = 10; // number of locations per distance class
    // Initial location list
    for (int i = 0; i < location_n; ++i){
        location_list.push_back(to_string(i));
    }

    //--------------------------
//    vector<string> test_vector =
//    generateTestVector(device_list, visualization_list, task_list,
//                       distance_list, location_list);
    //--------------------------
    
    string dprefix = "", dvprefix = "", dvtprefix = "", prefix = "";
    vector<string> user_test_vector;
    vector<vector<string>> all_test_vectors; all_test_vectors.clear();
    for (int ui = 0; ui < participant_n; ++ui){
        
        user_test_vector.clear();
        vector<string> t_device_list = device_pool.next();
        for (int di = 0; di < device_list.size(); ++di){
            // Device prefix
            dprefix = t_device_list[di];
            
            vector<string> t_visualization_list = visualization_pool.next();
            for (int vi = 0; vi < visualization_list.size(); ++vi){
                // Visualization prefix
                dvprefix = dprefix + ":" + t_visualization_list[vi];
                
                vector<string> t_task_list = task_pool.next();
                for (int ti = 0; ti < task_list.size(); ++ti){
                    // Task prefix
                    dvtprefix = dvprefix + ":" + t_task_list[ti];
                    
                    // TODO: need some more works
                    for (int li = 0; li < location_list.size(); ++li){
                        // Location prefix is handled slightly differently
                        prefix = dvtprefix +  ":" + location_list[li];
                        user_test_vector.push_back(prefix);
                    }
                    
                }
            }
        }
        all_test_vectors.push_back(user_test_vector);
    }
    
    //--------------------------
    
    
    // Reset the test counter
    test_counter = -1;
    return 0;
}
