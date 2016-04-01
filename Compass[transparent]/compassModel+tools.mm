#import "compassModel.h"
#ifdef __IPHONE__
typedef UIFont NSFont;
typedef UIColor NSColor;
#endif

CGSize makeGLFrameSize(NSAttributedString *attr_str){
    CGSize t_size = [attr_str size];
    
    NSRange whiteSpaceRange = [attr_str.string
                               rangeOfCharacterFromSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    
    if (whiteSpaceRange.location != NSNotFound){
        // assume the label has at most two lines, figure out which line longer
        NSMutableAttributedString *firstCopy = attr_str.mutableCopy;
        [[firstCopy mutableString] setString: [attr_str.string substringToIndex:whiteSpaceRange.location]];
        
        NSMutableAttributedString *secondCopy = attr_str.mutableCopy;
        [[secondCopy mutableString] setString: [attr_str.string substringFromIndex:whiteSpaceRange.location]];
        float boxWidth = max(firstCopy.size.width, secondCopy.size.width);
        
        t_size.width = boxWidth;
        t_size.height = firstCopy.size.height + secondCopy.size.height;
        
#ifdef __IPAD__
        // don't know why...
        t_size.width = t_size.width + 2;
        t_size.height = t_size.height + 2;
#endif
        
    }
    return t_size;
}

texture_info compassMdl::generateTextureInfo(NSString *label){
    texture_info my_texture_info;
    
    //--------------
    // Font generation
    //--------------
    // Set font size
	NSFont * font =[NSFont fontWithName:@"Helvetica-Bold"
                                   size:
                    [configurations[@"font_size"] floatValue]];
    NSString * string = [NSString stringWithFormat:@"%@", label];
    
	NSMutableDictionary *stringAttrib = [NSMutableDictionary dictionary];
	[stringAttrib setObject:font forKey:NSFontAttributeName];
    
    //--------------
    // Render labels, different rendering methods depending on the platform
    //--------------
    NSAttributedString *attr_str =
    [[NSAttributedString alloc] initWithString:string attributes:stringAttrib];
    CGSize str_size = makeGLFrameSize(attr_str);
    
    my_texture_info.size = str_size;
    my_texture_info.attr_str = attr_str;
    return my_texture_info;
}

//---------------------
// Initialize texture_info
//---------------------
void compassMdl::initTextureArray(){
    for (int i = 0; i < data_array.size(); ++i){
        texture_info my_texture_info =
        generateTextureInfo(
                            [NSString stringWithUTF8String: data_array[i].name.c_str()]);
        data_array[i].my_texture_info = my_texture_info;
    }
}

