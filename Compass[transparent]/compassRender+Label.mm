#include "commonInclude.h"
#include <cmath>
#include <algorithm>
#include "compassRender.h"


#ifdef __IPHONE__
typedef UIFont NSFont;
typedef UIColor NSColor;
#import "Texture2D.h"
#endif

#pragma mark ---------drawing labels---------
//-------------
// draw label
//-------------
void compassRender::drawLabel(float rotation, float height, string name)
{
    //--------------
    // Font generation
    //--------------
    // Set font size
	NSFont * font =[NSFont fontWithName:@"Helvetica-Bold"
                                   size:
                    [model->configurations[@"font_size"] floatValue]];
    NSString * string = [NSString stringWithFormat:@"%@",
                         [NSString stringWithUTF8String:name.c_str()]];
    
	NSMutableDictionary *stringAttrib = [NSMutableDictionary dictionary];
	[stringAttrib setObject:font forKey:NSFontAttributeName];
    
    //--------------
    // Render labels, different rendering methods depending on the platform
    //--------------
    NSAttributedString *attr_str =
    [[NSAttributedString alloc] initWithString:string attributes:stringAttrib];
    CGSize str_size = makeGLFrameSize(attr_str);
    

    //------------------
    
    glPushMatrix();
    //--------------------
    // Keep the text level (rotate->translate->rotate)
    //--------------------
    glRotatef(rotation, 0, 0, -1);
    glTranslatef(0, height, 0); //central_disk_radius
    glRotatef(-rotation, 0, 0, -1);
    
    if (!wedgeMode){
        // Fix text size
        float scale = 1/ (compass_scale); // glDrawingCorrectionRatio *
        glScalef(scale, scale, 1);
    }
    
    // This line seems to make the text darker for some reason
    glColor4f (1.0f, 1.0f, 1.0f, 1.0f);
    
    //--------------
    // Render labels, different rendering methods depending on the platform
    //--------------
    rotation = rotation + model->camera_pos.orientation;
    
    if (rotation < 0)
        rotation = rotation + 360;
    
    if (!wedgeMode){
        glRotatef(model->camera_pos.orientation, 0, 0, 1);
        if ((rotation > 180) && (rotation < 360))
            glTranslatef(-str_size.width, 0, 0);
    }
    //--------------------
    //text tilting still needs to be fixed
    glRotatef(-model->tilt, 1, 0, 0);
    //--------------------
    
#ifndef __IPHONE__
    //--------------
    // OSX
    //--------------

    glRotatef(180, 1, 0, 0);
    label_string = [[GLString alloc] initWithAttributedString:attr_str];
    [label_string drawAtPoint:NSMakePoint (0, 0)];
#else
    //--------------
    // iOS
    //--------------
    glScalef(0.25, 0.25, 0);
    drawiOSText(string, 4*[model->configurations[@"font_size"] floatValue],
                4*str_size.width,
                4*str_size.height);
#endif
    glPopMatrix();
}

CGSize compassRender::makeGLFrameSize(NSAttributedString *attr_str){
    CGSize t_size = [attr_str size];

    NSRange whiteSpaceRange = [attr_str.string
                               rangeOfCharacterFromSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    
    if (whiteSpaceRange.location != NSNotFound){
        t_size.width = t_size.width /2;
        t_size.height = t_size.height * 2;
    }
    t_size.width = 2*round(t_size.width/2) + 8;
    t_size.height = 2*round(t_size.height/2) + 4;
    
    return t_size;
}

//--------------
// iOS related tools
//--------------
#ifdef __IPHONE__
void compassRender::drawiOSText(NSString *string, int font_size,
                                CGFloat width, CGFloat height){
    // Use black
    if (mapView.mapType == MKMapTypeStandard){
        glColor4f(0, 0, 0, 1.0);
    }else{
        glColor4f(255.0/255.0, 54.0/255.0, 96.0/255.0, 1.0);
    }

    glEnable(GL_TEXTURE_2D);
    // Set up texture
    Texture2D* statusTexture = [[Texture2D alloc]
                                initWithString:string
                                dimensions:CGSizeMake(width, height)
                                alignment: UITextAlignmentLeft
                                fontName:@"Helvetica-Bold" fontSize:font_size];
    
    // Bind texture
    glBindTexture(GL_TEXTURE_2D, [statusTexture name]);
    
    // Enable modes needed for drawing
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    

    // Draw
    [statusTexture drawInRect:CGRectMake(0, 0, width, height)];
    
    // Disable modes so they don't interfere with other parts of the program
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisable(GL_TEXTURE_2D);
    glDisable(GL_BLEND);
    
}
#endif

//---------------------
// Initialize label_texture_array
//---------------------
void compassRender::initTextureArray(){
    
    for (int i = 0; i < label_texture_array.size(); ++i){
        glDeleteTextures(1, &(label_texture_array[i].texture_id));
    }
    
    label_texture_array.clear();
    for (int i = 0; i < model->data_array.size(); ++i){
        texture_info my_texture_info =
        generateTexture(
        [NSString stringWithUTF8String: model->data_array[i].name.c_str()]);
        label_texture_array.push_back(my_texture_info);
    }
}

texture_info compassRender::generateTexture(NSString *label){
    texture_info my_texture_info;
    
    //--------------
    // Font generation
    //--------------
    // Set font size
	NSFont * font =[NSFont fontWithName:@"Helvetica-Bold"
                                   size:
                    [model->configurations[@"font_size"] floatValue]];
    NSString * string = [NSString stringWithFormat:@"%@", label];
    
	NSMutableDictionary *stringAttrib = [NSMutableDictionary dictionary];
	[stringAttrib setObject:font forKey:NSFontAttributeName];
    
    //--------------
    // Render labels, different rendering methods depending on the platform
    //--------------
    NSAttributedString *attr_str =
    [[NSAttributedString alloc] initWithString:string attributes:stringAttrib];
    CGSize str_size = makeGLFrameSize(attr_str);
    
    // Use black
    if (mapView.mapType == MKMapTypeStandard){
        glColor4f(0, 0, 0, 1.0);
    }else{
        glColor4f(255.0/255.0, 54.0/255.0, 96.0/255.0, 1.0);
    }
    
    glEnable(GL_TEXTURE_2D);
    // Set up texture
    Texture2D* statusTexture = [[Texture2D alloc]
                                initWithString:label
                                dimensions:CGSizeMake(str_size.width*4,
                                                      str_size.height*4)
                                alignment: UITextAlignmentLeft
                                fontName:@"Helvetica-Bold"
                                fontSize:4*[model->configurations[@"font_size"] floatValue]];
    
    my_texture_info.size = str_size;
    my_texture_info.attr_str = attr_str;
    my_texture_info.texture_id = [statusTexture name];
    return my_texture_info;
}
















