//
//  compassRender+Components.mm
//  compass
//
//  Created by dmiau on 6/12/14.
//  Copyright (c) 2014 Daniel Miau. All rights reserved.
//
#include "commonInclude.h"
#include <math.h>
#include <algorithm>
#include "compassRender.h"

#ifdef __IPHONE__
typedef UIFont NSFont;
typedef UIColor NSColor;
#import "Texture2D.h"
#endif

#pragma mark ---------drawing the compass---------
//-------------
// drawCompass
//-------------
void compassRender::drawCompass(RenderParamStruct renderParamStruct){
    /*
     By the time this funciton is called,
     model->indices_for_rendering shold have been updated by the model
     */
    
    // ------------------
    // Find out the longest distance for normalization
    // ------------------
    vector <double> t_dist_list;
    for (int i = 0; i < model->indices_for_rendering.size(); ++i){
        int j = model->indices_for_rendering[i];
        t_dist_list.push_back(model->data_array[j].distance);
    }
    std::vector<double>::iterator result =
    std::max_element(t_dist_list.begin(),
                     t_dist_list.end());
    max_dist = *result;
    
    // ---------------
    // Draw the center circle
    // ---------------
    glColor4f([model->configurations[@"circle_color"][0] floatValue]/255,
              [model->configurations[@"circle_color"][1] floatValue]/255,
              [model->configurations[@"circle_color"][2] floatValue]/255,
              1);
    
    // draw the center circle
    glPushMatrix();
    glTranslatef(0, 0, 1);
    drawCircle(0, 0, central_disk_radius, 50);
    glPopMatrix();
    
    // ---------------
    // Render triangles and the background disks
    // based on the specified style
    // ---------------
    
    // indices_for_rendering is updated in compassMdl.updateMdl()
    applyStyle(renderParamStruct.style_type, model->indices_for_rendering);
    
    // ---------------
    // draw the labels
    // ---------------
    if (label_flag){
        glPushMatrix();
        glTranslatef(0, 0, 1);
        for (int i = 0; i < model->indices_for_rendering.size(); ++i){
            int j = model->indices_for_rendering[i];
            data data_ = model->data_array[j];
            
            double distance = data_.distance / max_dist * half_canvas_size * 0.9;
            drawLabel(data_.orientation, distance, data_.name);
        }
        glPopMatrix();
    }
    
}

#pragma mark ---------drawing shapes---------
//-------------
// coreTriangle
//-------------
void compassRender::drawTriangle(int central_disk_radius, float rotation, float height)
{
    glPushMatrix();
    glRotatef(rotation, 0, 0, -1);
    //    cout << "rotation: " << rotation << endl;
    Vertex3D    vertex1 = Vertex3DMake(0, height, 0);
    Vertex3D    vertex2 = Vertex3DMake(-central_disk_radius, 0, 0);
    Vertex3D    vertex3 = Vertex3DMake(central_disk_radius, 0, 0);
    Triangle3D  triangle = Triangle3DMake(vertex1, vertex2, vertex3);
    glVertexPointer(3, GL_FLOAT, 0, &triangle);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    glPopMatrix();
}

//-------------
// coreCircle
// http://slabode.exofire.net/circle_draw.shtml
//-------------
void compassRender::drawCircle(float cx, float cy, float r, int num_segments)
{
    float* p_vertex_array = new float[num_segments * 2];
    
    // draw a filled circle
    for(int ii = 0; ii < num_segments; ii++)
    {
        float theta = 2.0f * 3.1415926f * float(ii) / float(num_segments);//get the current angle
        
        float x = r * cosf(theta);//calculate the x component
        float y = r * sinf(theta);//calculate the y component
        
        p_vertex_array[ii*2] = x + cx;
        p_vertex_array[ii*2 + 1] = y + cy;
    }
    
    glVertexPointer(2, GL_FLOAT, 0, p_vertex_array);
    glDrawArrays(GL_TRIANGLE_FAN, 0, num_segments);
    delete[] p_vertex_array;
}
