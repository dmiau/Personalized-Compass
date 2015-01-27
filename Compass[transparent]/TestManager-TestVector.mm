//
//  TestManager-TestVector.cpp
//  Compass[transparent]
//
//  Created by dmiau on 1/26/15.
//  Copyright (c) 2015 dmiau. All rights reserved.
//

#import "TestManager.h"
using namespace std;

vector<vector<vector<string>>> permute(vector<vector<string>> input, int leaf_n){
    vector<vector<vector<string>>> output; output.clear();
    
    for (int i = 0; i < input.size(); ++i){
        if (leaf_n > 1){
            vector<vector<string>> temp = input;
            temp.erase(temp.begin() + i);
            
            vector<vector<vector<string>>> t_output = permute(temp, leaf_n-1);
            
            for (int j = 0; j < t_output.size(); ++j){
                t_output[j].insert(t_output[j].begin(), input[i]);
                output.push_back(t_output[j]);
            }
        }else{
            output.push_back({input[i]});
        }
    }
    return output;
}

//---------------
// Pool object
//---------------
pool::pool(vector<string> conditions, int leaf_n){
    counter = 0;
    content.clear();
    // Do one permutation and another special permute
    // example input {1, 2}
    vector<vector<string>> temp; temp.clear();
    do {
        temp.push_back(conditions);
    } while (next_permutation(conditions.begin(),conditions.end()));
    // At this point {{1, 2}, {2, 1}}
    
    // Need to use recursion
    content = permute(temp, leaf_n);
    // At this point
    // {{{1, 2}, {2, 1}},
    // {{2, 1}, {1, 2}}}
}

// Next should return the following in sequence
// {1, 2}, {2, 1},   {2, 1}, {1, 2}
// Note that next should be able to go through the boundary of cells.
// so vector<string>

// The items are organized as
// {{{1, 2}, {2, 1}},
// {{2, 1}, {1, 2}}}
// So I will use row_i and col_i to access an item
vector<string> pool::next(){
    vector<string> output;
    
    int i = counter % (content.size()*content[0].size());
    
    int row_i = (int) i / content[0].size();
    int col_i = counter % content[0].size();
    output = content[row_i][col_i];
    counter = counter + 1;
    return output;
}

//--------------
// Testvector Generation
//--------------
vector<string> TestManager::generateTestVector(
                                               vector<string> device_list,
                                               vector<string> visualization_list,
                                               vector<string> task_list,
                                               vector<string> distance_list,
                                               vector<int> location_list
                                               )
{
    vector<string> test_vector; test_vector.clear();
    
    //Goal:
    //generate test vector, examples:
    //phone:pcompass:t1:c1, c2,...c5
    //phone:pcompass:t2:b1:c1, c2, c3 //bundle
    //phone:pcompass:t3:c1, c2,...c5
    
    string dprefix = "", dvprefix = "", dvtprefix = "", prefix = "";
    // Generate test vectors
    for (int di = 0; di<device_list.size(); ++di){
        // Device loop
        dprefix = device_list[di];
        for (int vi = 0; vi < visualization_list.size(); ++vi){
            // Visualization loop
            dvprefix = dprefix + ":" + visualization_list[vi];
            
            for(int ti = 0; ti < task_list.size(); ++ti){
                // Task loop
                dvtprefix = dvprefix + ":" + task_list[ti];
                
                for (int si = 0; si < distance_list.size(); ++si){
                    // Distance loop
                    
                    for (int li = 0; li < location_list.size(); ++li){
                        if (task_list[ti] != "t2"){
                            prefix = dvtprefix + ":" + distance_list[si]
                            + to_string(li);
                        }else{
                            
                        }
                        
                        // Store the ID into test_vector
                        test_vector.push_back(prefix);
                    }
                }
            }
        }
    }
    
    return test_vector;
}