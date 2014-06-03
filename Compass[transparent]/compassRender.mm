//
//  drawing.cpp
//  compass
//
//  Created by dmiau on 11/6/13.
//  Copyright (c) 2013 Daniel Miau. All rights reserved.
//
#include "commonInclude.h"
#include <math.h>
#include <algorithm>
#include "compassRender.h"

#ifdef __IPHONE__
typedef UIFont NSFont;
typedef UIColor NSColor;
#import <GLKit/GLKit.h>
#endif

recVec glOrigin = {0.0, 0.0, 0.0};

#pragma mark ---------Renderer Initialization---------
// http://www.galloway.me.uk/tutorials/singleton-classes/
// http://www.yolinux.com/TUTORIALS/C++Singleton.html
compassRender* compassRender::shareCompassRender(){
    static compassRender* instance = NULL;
    
    if (!instance){ // Only allow one instance of class to be generated
        instance = new compassRender;
        instance->initRenderMdl();
    }
    return instance;
};


compassRender::compassRender(){
    initRenderMdl();
}

// sets the camera data to initial conditions
void compassRender::resetCamera()
{
    camera.fov = 30;
    
    camera.viewPos.x = 0.0;
    camera.viewPos.y = 0.0;
    camera.viewPos.z = 900; // This is the effective focal length
    
    camera.viewUp.x = 0;
    camera.viewUp.y = 1;
    camera.viewUp.z = 0;
}

int compassRender::initRenderMdl(){
    
    //--------------------
    // Initialize camera and shapes
    //--------------------
    resetCamera();     // Initialize the camera
    
    compass_scale = 1.0;
    label_flag = true;
    glDrawingCorrectionRatio = 1;
    half_canvas_size = camera.viewPos.z * tan(camera.fov/360*3.14);
    central_disk_radius = half_canvas_size/10;
    
    compass_centroid = glOrigin;
    
    //--------------------
    // Initialize string parameters
    //--------------------
    
    // init fonts for use with strings
	NSFont * font =[NSFont fontWithName:@"Helvetica" size:18.0];
    
	stringAttrib = [NSMutableDictionary dictionary];
	[stringAttrib setObject:font forKey:NSFontAttributeName];
    //	[stringAttrib setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	[stringAttrib setObject:
     [NSColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]
                     forKey:NSForegroundColorAttributeName];
    
#ifndef __IPHONE__
    label_string = [[GLString alloc] initWithString:@"" withAttributes:stringAttrib
                                      withTextColor:[NSColor colorWithDeviceRed:1.0f green:0.0f blue:0.0f alpha:1.0f]
                                       withBoxColor:[NSColor colorWithDeviceRed:0.5f green:0.5f blue:0.5f alpha:0.0f]
                                    withBorderColor:[NSColor colorWithDeviceRed:0.0f green:0.0f blue:0.0f alpha:0.0f]];
#endif
    
    // near and far are calculated from the point of view of an observer
    return EXIT_SUCCESS;
}


int compassRender::initRenderView(float win_width, float win_height){
    orig_wigth = win_width; orig_height = win_height;
    model = compassMdl::shareCompassMdl();
    
    // Transformations for the projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    
#ifdef __IPHONE__
    // left, right, bottom, top, z_near, z_far
    glOrthof(-half_canvas_size, half_canvas_size, -half_canvas_size, half_canvas_size,
             -150, 150);
#else
    //fovy, asepect, zNear, zFar
    gluPerspective(camera.fov, 1, 1, 3 * camera.viewPos.z );
#endif
    
    glMatrixMode(GL_MODELVIEW);
    
#ifndef __IPHONE__
    glLoadIdentity();
    gluLookAt(camera.viewPos.x, camera.viewPos.y, camera.viewPos.z,
              0, 0, 0,
              camera.viewUp.x, camera.viewUp.y, camera.viewUp.z);
#endif
    
    return EXIT_SUCCESS;
}

#pragma mark ------------- Handle window resize/update -------------


void compassRender::updateViewport
            (GLint x, GLint y, GLsizei width, GLsizei height)
{
    glDrawingCorrectionRatio = orig_height / height;
    glViewport (x, y, width, height);
    updateProjection((float)width/(float)height);  // update projection matrix
}

void compassRender::updateProjection(GLfloat aspect_ratio){
    
#ifndef __IPHONE__
	// set projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    //fovy, asepect, zNear, zFar
    gluPerspective(camera.fov, aspect_ratio, 1, 3 * camera.viewPos.z);
#endif
}

#pragma mark ---------core rendering routine---------
//--------------
// Tools
//--------------
RenderParamStruct makeRenderParams(
            filter_enum filter_type, style_enum style_type){
    
    RenderParamStruct renderParamStruct;
    renderParamStruct.filter_fun_param = 7;
    renderParamStruct.filter_type = filter_type;
    renderParamStruct.style_type = style_type;
    
    return renderParamStruct;
}

//--------------
// Display
//--------------

void compassRender::render(){
    
    filter_enum filter_type =
    model->hashFilterStr(model->configurations[@"filter_type"]);
    
    style_enum style_type =
    hashStyleStr(model->configurations[@"style_type"]);
        
    RenderParamStruct renderParamStruct =
    makeRenderParams(filter_type, style_type);
//    makeRenderParams(NONE, BIMODAL);
    render(renderParamStruct);
}

void compassRender::render(RenderParamStruct renderParamStruct) {
    glEnableClientState(GL_VERTEX_ARRAY);
    //    glEnable(GL_BLEND);
    //    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //
    //    glHint( GL_LINE_SMOOTH_HINT, GL_NICEST );
    //    glHint( GL_POLYGON_SMOOTH_HINT, GL_NICEST);
    //    glEnable(GL_MULTISAMPLE);
    glMatrixMode(GL_MODELVIEW);
    
    glPushMatrix();
    
    // Figureing out translation
    glTranslatef(compass_centroid.x, compass_centroid.y, compass_centroid.z);
    

    // [todo] Careful! Potential bug here...
    // tilt
    glRotatef(model->tilt, 1, 0, 0);
    
    glRotatef(model->current_pos.orientation, 0, 0, -1);

    float scale = glDrawingCorrectionRatio * compass_scale;
    glScalef(scale, scale, 1);
    
    //--------------
    // Draw compass
    //--------------
    drawCompass(renderParamStruct);
    
    glPopMatrix();
    glDisableClientState(GL_VERTEX_ARRAY);
//    glFlush();
//    glutSwapBuffers();
}

//-------------
// drawCompass
//-------------
void compassRender::drawCompass(RenderParamStruct renderParamStruct){
    
    // ------------------
    // Preprocesing:
    // ------------------
    vector<int> indices_for_rendering =
            model->applyFilter(renderParamStruct.filter_type,
                               renderParamStruct.filter_fun_param);
    
    // ------------------
    // Find out the longest distance for normalization
    // ------------------
    vector <double> t_dist_list;
    for (int i = 0; i < indices_for_rendering.size(); ++i){
        int j = indices_for_rendering[i];
        t_dist_list.push_back(model->data_array[j].distance);
    }
    std::vector<double>::iterator result =
    std::max_element(t_dist_list.begin(),
                     t_dist_list.end());
    max_dist = *result;
    
    // Need to draw from front to back
    // (this is interesting, is it because I am looking from the +z to 0?)

    
    // ---------------
    // Draw the center circle
    // ---------------
    glColor4f([model->configurations[@"circle_color"][0] floatValue]/255,
              [model->configurations[@"circle_color"][1] floatValue]/255,
              [model->configurations[@"circle_color"][2] floatValue]/255,
              1);
    
    // draw the center circle
    drawCircle(0, 0, central_disk_radius, 50);

    
    // ---------------
    // Render triangles and the background disks
    // based on the specified style
    // ---------------
    
    // [todo] more rendering style should be supported
    applyStyle(renderParamStruct.style_type, indices_for_rendering);
//    renderStyleBimodal(indices_for_rendering);
    
    // ---------------
    // draw the labels
    // ---------------
    if (label_flag){
        for (int i = 0; i < indices_for_rendering.size(); ++i){
            int j = indices_for_rendering[i];
            data data_ = model->data_array[j];
            
            double distance = data_.distance / max_dist * half_canvas_size * 0.9;
            drawLabel(data_.orientation, distance, data_.name);
        }
    }

}

#pragma mark ---------drawing helper functions---------
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
// draw label
//-------------
void compassRender::drawLabel(float rotation, float height, string name)
{
#ifndef __IPHONE__
	NSString * string = [NSString stringWithFormat:@"%@\n",
                         [NSString stringWithUTF8String:name.c_str()]];
    
    // Modify font size
	NSFont * font =[NSFont fontWithName:@"Helvetica"
                                   size:
                    [model->configurations[@"font_size"] floatValue]];
	stringAttrib = [NSMutableDictionary dictionary];
	[stringAttrib setObject:font forKey:NSFontAttributeName];
    
    [label_string setString:string withAttributes:stringAttrib];
    
    glPushMatrix();
    glRotatef(rotation, 0, 0, -1);
    
    glTranslatef(0, half_canvas_size * 0.9, 0); //central_disk_radius
    glRotatef(-90, 0, 0, -1);
    // Fix text size
    
//    font_size
//    float delta = [model->configurations[@"font_size"] floatValue]/ 100;
//    float scale = (0.04 + delta) * 1/ (glDrawingCorrectionRatio * compass_scale);
    float scale = 1/ ( compass_scale); // glDrawingCorrectionRatio *
    glScalef(scale, scale, scale);
    
    glColor4f (1.0f, 1.0f, 1.0f, 1.0f);
    
    glPushMatrix();
    glRotatef(180, 0, 1, 0);

    // Handle the orientaion of the string
    if ((rotation >= 0) && (rotation <= 180)) {
        glRotatef(180, 0, 0, 1);
        glTranslatef(-[label_string frameSize].width, 0, 0);
    }
    [label_string drawAtPoint:NSMakePoint (0, 0)];
    
    glPopMatrix();
    
    glPopMatrix();
#endif
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

