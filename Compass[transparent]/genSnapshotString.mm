#import "compassModel.h"
#include <string>
#include <sstream>

using namespace std;
NSString* genSnapshotString(vector<snapshot> my_snapshot_array)
{
    
    string temp_str, coord_str;
    std::ostringstream stringStream;
    
    //-------------
    // Header
    //-------------
    temp_str = "<?xml version='1.0' encoding='UTF-8'?>\n";
    temp_str = temp_str + "<kml xmlns='http://www.opengis.net/kml/2.2'>\n";
    temp_str = temp_str + "<Document>\n";
    
    //-------------
    // Body
    //-------------
    
    // Example KML snippet
    /*
     <Placemark>
     <name>Central Park</name>
     <Point>
     <coordinates>-73.973093,40.772352,0.0</coordinates>
     </Point>
     <orientation>30</orientation>
     <kmlFilename>london.kml</kmlFilename>
     </Placemark>
     */
    
    for (int i = 0; i < my_snapshot_array.size(); ++i) {
        temp_str = temp_str + "<Placemark>\n";
        
        
        temp_str = temp_str + "<name>";
        temp_str = temp_str + string([my_snapshot_array[i].name UTF8String]);
        temp_str = temp_str + "</name>\n";
        
        //-----------------
        // Coordinates
        //-----------------
        temp_str = temp_str + "<Point>\n";
        temp_str = temp_str + "<coordinates>";
        
        // Need to use this trick to output coordinates
        // longitude first, latitude second
        stringStream.clear();
        stringStream.str("");
        stringStream << my_snapshot_array[i].coordinateRegion.center.longitude << ","
        << my_snapshot_array[i].coordinateRegion.center.latitude << ",0.0";
        
        coord_str = stringStream.str();
        temp_str = temp_str + coord_str;
        
        temp_str = temp_str + "</coordinates>\n";
        temp_str = temp_str + "</Point>\n";
        
        //-----------------
        // Orientation
        //-----------------
        temp_str = temp_str + "<orientation>\n";
        stringStream.clear();
        stringStream.str("");
        stringStream << my_snapshot_array[i].orientation;
        temp_str = temp_str + stringStream.str();
        
        temp_str = temp_str + "</orientation>\n";

        //-----------------
        // kmlFinename
        //-----------------
        temp_str = temp_str + "<kmlFilename>\n";
        stringStream.clear();
        stringStream.str("");
        stringStream << [[my_snapshot_array[i].kmlFilename lastPathComponent] UTF8String];
        temp_str = temp_str + stringStream.str();
        
        temp_str = temp_str + "</kmlFilename>\n";
        
        temp_str = temp_str + "</Placemark>\n\n";
    }
    
    //-------------
    // Ending
    //-------------
    temp_str = temp_str + "</Document>\n";
    temp_str = temp_str + "</kml>\n";
    
    NSString *out_str = [NSString stringWithUTF8String:temp_str.c_str()];
    return out_str;
}