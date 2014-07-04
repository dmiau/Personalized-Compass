#import "compassModel.h"
#include <string>
#include <sstream>

using namespace std;
bool xmlWirter(NSString* out_filepath, vector<data> my_data_array){
    
    string temp_str, coord_str;
    std::ostringstream stringStream;
    
    //-------------
    // Header
    //-------------
    temp_str = "<?xml version='1.0' encoding='UTF-8'?>\n";
    temp_str = temp_str + "<?xml version='1.0' encoding='UTF-8'?>\n";
    temp_str = temp_str + "<kml xmlns='http://www.opengis.net/kml/2.2'>\n";
    temp_str = temp_str + "<Document>\n";
    
    //-------------
    // Body
    //-------------
    
    // Example KML snippet
    /*
    <Placemark>
    <styleUrl>#icon-503-FF8277</styleUrl>
    <name>Central Park</name>
    <description><![CDATA[Montréal, QC H2Z 1R1, Canada]]></description>
    <Point>
    <coordinates>-73.973093,40.772352,0.0</coordinates>
    </Point>
    </Placemark>
    */
    
    for (int i = 0; i < my_data_array.size(); ++i) {
        temp_str = temp_str + "<Placemark>\n";
        
        
        temp_str = temp_str + "<name>";
        temp_str = temp_str + my_data_array[i].name;
        temp_str = temp_str + "</name>";
        
        
        temp_str = temp_str + "<Point>\n";
    
        temp_str = temp_str + "<coordinates>";
        
        // Need to use this trick to output coordinates
        stringStream.clear();
        stringStream << my_data_array[i].latitude << ","
        << my_data_array[i].longitude << ",0.0";
        
        coord_str = stringStream.str();
        temp_str = temp_str + coord_str;
        
        temp_str = temp_str + "</coordinates>";
        
        
        temp_str = temp_str + "</Point>\n";
        
        
        temp_str = temp_str + "</Placemark>\n";
        
    }
    

    //-------------
    // Ending
    //-------------
    temp_str = temp_str + "</Document>\n";
    temp_str = temp_str + "</kml>\n";
    
    NSString *out_str = [NSString stringWithUTF8String:temp_str.c_str()];
    NSError* error;
    if (![out_str writeToFile:out_filepath
              atomically:YES encoding: NSASCIIStringEncoding
                   error:&error])
    {
        // Do something if write fails.
    }
    
    // Use this method
    //writeToFile:atomically:encoding:error:
    return true;
}