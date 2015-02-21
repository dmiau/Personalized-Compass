-------------------------------------------------------------------
1.16.2014 
-------------------------------------------------------------------
attemp to continue my work of investigating the json parser 
- need to figure out how to link a static library
- this make command successful build the program
g++ -ljson_linux-gcc-4.2.1_libmt jsontest.cpp -o t_json -L ./jsoncpp/

=============
Element 0 in array: item1
Element 1 in array: item2
Not an array: asdf
Json Example pretty print: 
{
   "array" : [ "item1", "item2" ],
   "not an array" : "asdf"
}
=============

for some reason the executable look at the library in this dir:
buildscons/linux-gcc-4.2.1/src/lib_json/

I used this command to build jsoncpp
scons platform=linux-gcc

looks like someoen has the same problem:
http://stackoverflow.com/questions/17276853/linking-jsoncpp


This works:
g++ -ljson_linux-gcc-4.2.1_libmt jsontest.cpp -o t_json -L ./

only place the static library: 
libjson_linux-gcc-4.2.1_libmt.a
in the folder

-------------------------------------------------------------------
2.1.2014
-------------------------------------------------------------------
Separate json testing code to sandbox

-------------------------------------------------------------------
2.6.2014
-------------------------------------------------------------------
Design the program interface and decide what do I want to do?

-------------------------------------------------------------------
2.7.2014
-------------------------------------------------------------------
- Add jsonReader successfully to the compass project
- Figured out how to use the unit test framework (it was actually quite easy!

-------------------------------------------------------------------
2.8.2014
-------------------------------------------------------------------
The following features have been completed:
- configuraiton file
- location file
- draw arbitrary numbe of triangles

Next milestone:
- add test to the app
- handle resizing

TODO:
- check this antialiasing and multisample tutorial
http://lazyfoo.net/tutorials/OpenGL/28_antialiasing_and_multisampling/index.php
- update the labeling code
- generate an image to overlay on Google Map
- also check this text tutorial
http://en.wikibooks.org/wiki/OpenGL_Programming/Modern_OpenGL_Tutorial_Text_Rendering_01
- need to do extra checking on json read
- resize the window:
http://stackoverflow.com/questions/3267243/in-opengl-how-can-i-adjust-for-the-window-being-resized

-------------------------------------------------------------------
2.13.2014
-------------------------------------------------------------------
added the auto color code

-------------------------------------------------------------------
2.21.2014
-------------------------------------------------------------------
- figuing out that using Google Maps + csv file is the fastest way to contructute a database
- maybe I should use this to calculate the bearing
http://stackoverflow.com/questions/3809337/calculating-bearing-between-two-cllocationcoordinate2ds

plan of the day: 
- add latitude and longitude in locations.json
- add current location and bearing in configurations.json
- add distance and bearing calculation code
- add interest point selection code (probability)

Use this service:
http://www.latlong.net/convert-address-to-lat-long.html

[8:07pm]
Here is a very good c++ reference site:
http://www.learncpp.com/

- need to handle the overlaping issues and labeling issue
- can we take cvs file directly?

-------------------------------------------------------------------
2.25.2014
-------------------------------------------------------------------
- added the ordering code
- now need to port everything to cocoa so I can take advantage of the fonts in osx
- successfully converted a GLUT project to a Cocoa OpenGl project
- This may be a good tutorial (from the perspective of a Microsoft developer!)
[ref]
http://www.dbiesiada.com/blog/2013/04/simple-skeleton-framework-for-cocoa-osx-opengl-application/

http://dragonsandbytecode.wordpress.com/2012/06/07/game-dev-diary-5-about-textures-and-2d/#more-228


-------------------------------------------------------------------
2.26.2014
-------------------------------------------------------------------
- convert the codebase to Cocoa
- learn that there is this thing call glgeterror
http://msdn.microsoft.com/en-us/library/windows/desktop/dd373546(v=vs.85).aspx

successfully convert the app to cocoa


-------------------------------------------------------------------
2.27.2014
-------------------------------------------------------------------


-------------------------------------------------------------------
2.28.2014
-------------------------------------------------------------------
- Added more controls to the GUI (somehow the figure does not get updated)
- data needs to get reinitialized!
- maybe I should populate table view too (adding a table to include more debugging information)

-------------------------------------------------------------------
3.1.2014
-------------------------------------------------------------------
- Added table click control
- Load different locations, smartwatch size demonstration, 

-------------------------------------------------------------------
3.17.2014
-------------------------------------------------------------------
code refactoring

write two classes: model class and viewer classes

Get command line argument directly from the process
//Get command line argument from the process
    //http://stackoverflow.com/questions/5146849/accessing-command-line-arguments-in-objective-c

The decision is to stick as close to C++ as possible.


Next step: make the compass interactive -- rotating, scale, etc.


-------------------------------------------------------------------
3.18.2014
-------------------------------------------------------------------
- rotate and move the compass
- 3D tilt (half done)
- change to perspective projection (added)

- add the north indicator

added the entitlement

For some reason I cannot make the OpenGL view background transparent


-------------------------------------------------------------------
3.19.2014
-------------------------------------------------------------------
- Rebuilding a new project [done]
- Adding interaction

start to use the //[todo] tag

today's goal: taking advantage of the big data!

Let's get searchfield to work today! 

#import <Cocoa/Cocoa.h>

===========
@interface ATBasicTableViewWindowController : NSWindowController<NSTableViewDelegate, NSTableViewDataSource> {
@private
    // An array of dictionaries that contain the contents to display
    NSMutableArray *_tableContents;
    IBOutlet NSTableView *_tableView;
}

@end
===========

outgoing entitlement issues
http://stackoverflow.com/questions/22185980/why-using-mklocalsearch-returns-an-error-and-fails-to-load-the-expected-results


-------------------------------------------------------------------
3.21.2014
-------------------------------------------------------------------
integrating XML parser

took the following string out (trying out the NSBundle feature)
$(SRCROOT)/Compass[transparent]/

successfully integrated XML parser [12:15PM]

perhaps I should spend some time to figure out how to use eigen library

-------------------------------------------------------------------
3.22.2014
-------------------------------------------------------------------
Adding view controller
Reorganized the code: added DesktopViewController, cleaned up AppDelegate


-------------------------------------------------------------------
3.23.2014
-------------------------------------------------------------------

Todo:
- integrated with Google street view?

four test cases:
1. desktop 
2. smart watch
3. browser map
4. Google street view


-------------------------------------------------------------------
3.27.2014
-------------------------------------------------------------------
- added pin annotation

Goal:
- adding custom cell view
MKPointAnnotation
MKPinAnnocationView

text and color appearance

- locationIDSortedByDist
- add distance annimation


-------------------------------------------------------------------
3.28.2014
-------------------------------------------------------------------
NSSplitView is something I should look into.

Goals of the day:
- adding current location
- turn the render class into a singleton and adding two init methods:
* initRenderModel
* initRenderView

a solution to non-KVO compliant code
http://stackoverflow.com/questions/10796058/is-it-possible-to-continuously-track-the-mkmapview-region-while-scrolling-zoomin?lq=1

disable callout:
http://stackoverflow.com/questions/8442832/setting-canshowcallout-no-for-current-location-annotation-iphone


-------------------------------------------------------------------
3.29.2014
-------------------------------------------------------------------
transparent window:
https://developer.apple.com/library/mac/samplecode/RoundTransparentWindow/Introduction/Intro.html

TODO:
- labeling algorithm, 2D and 3D?
- algorithm to choose "best" landmarks when there are two many

- NSSplitView?
- foundation changes - take advantage of data binding and KVO?

- add control to table cells (checkbox, color indication, etc.)

- understnad the coordinate systems of OpenGLView and subview
- fix subview ordering issues
- fix subview layer problem 
- refresh table cache mutable array

work on valuable things 

view ordering:
http://stackoverflow.com/questions/2872840/how-do-i-make-an-nsview-move-to-the-front-of-all-nsviews


-------------------------------------------------------------------
4.1.2014
-------------------------------------------------------------------
- Updated input argument parsing
- data import. add the capability to import other KML data
- update distances on the table column
* idea: using a flag as the notification of KVO (in desktop
  controlller) The flag will only be modified when the central
  coordinates are changed


-------------------------------------------------------------------
4.2.2014
-------------------------------------------------------------------
- Need to fix (clean up) the update code
- Need to fix the drop pin code

- modify focal length to reduce perspective distortion when the scene
  is tilted
- OpenGL text (label) [check Cocoa OpenGL example]
* steal the GLString class
* check the drawAtPoint method


Check this method to resort subviews
http://stackoverflow.com/questions/2872840/how-do-i-make-an-nsview-move-to-the-front-of-all-nsviews

Added a new target!


-------------------------------------------------------------------
4.3.2014
-------------------------------------------------------------------
- add camera control to compass
- add a reset camera method


looks like OpenGl take the height as the dominant axis (and clip the width)

- need to add zoom funciton (while fix the text size)

read event responding guide

- need to think about how to add translation
- Check NSImageCell

-------------------------------------------------------------------
4.6.2014
-------------------------------------------------------------------
- OpenGl select
http://www.glprogramming.com/red/chapter13.html
http://www.lighthouse3d.com/opengl/picking/index.php3?openglway

- looks like it is possible to hack into Google Street View (by taking
advantage of the data in URL!)
https://www.google.com/maps/@40.794678,-73.969731,3a,75y,10.15h,86.85t/data=!3m4!1e1!3m2!1sun6Ti8kJyehMuMLFqzE7pw!2e0

-------------------------------------------------------------------
4.7.2014
-------------------------------------------------------------------
- combo box is working!
- added a new target: smartWatch (a work in progress)

snow man picking seems to be a good example!
http://www.lighthouse3d.com/opengl/picking/index.php3?openglway

What's next?

- fix table listing code?
2014-04-07 21:36:03.981 Compass[transparent][32893:303] *** -[__NSArrayM objectAtIndex:]: index 23 beyond bounds [0 .. 7]

- landmark selection

Use core animation to mask an image
http://stackoverflow.com/questions/16512761/calayer-with-transparent-hole-in-it

two good tutorials:
http://www.raywenderlich.com/forums/viewtopic.php?f=2&t=7155
http://www.raywenderlich.com/2502/calayers-tutorial-for-ios-introduction-to-calayers-tutorial

-------------------------------------------------------------------
4.10.2014
-------------------------------------------------------------------
- control the speed of animation
- better pin toggle code
- 

-------------------------------------------------------------------
4.16.2014
-------------------------------------------------------------------
Priorities?

-------------------------------------------------------------------
4.17.2014
-------------------------------------------------------------------
- implement filter and renderer
[done] model.filter_kNearestLocations
[done] model.filter_kOrientations
model.filter_forceEquilibrium

render.style_realRatio
render.style_perspective
render.style_thresholdSticks

- implement style poster (use viewports)
juxtapose

- brainstom integration with streetview and the personalized map
- characters, characters, characters (what will be fun and interesting
characters?)

- four applications
* osx desktop
* smartwatch
* mobile devices
* web browsers

** navigation?

Can I create an external control file? So I don't need to recompile program
again and again. [Take advantage of hash table?]

Should I build an XML configuration editor?

check if string is number
http://rosettacode.org/wiki/Determine_if_a_string_is_numeric#C.2B.2B

[
    {
        "property": "#prop1",
        "value": 1,
        "comment": "my comment"
    }, 
    {
        "latitude": 40.807536, 
        "name": "Columbia University", 
        "longitude": -73.962573
    }
]


-------------------------------------------------------------------
4.18.2014
-------------------------------------------------------------------
It made sense to use NSDictonary, so that I can easily debug!

Finished the backend for a text based interface.

Now I should work on the different style of renderer.

render.style_realRatio
render.style_perspective
render.style_thresholdSticks

- implement style poster (use viewports)
juxtapose

- brainstom integration with streetview and the personalized map
- characters, characters, characters (what will be fun and interesting
characters?)

- need to refactor the update code at some point

- perahps I should not show the map by default.


-------------------------------------------------------------------
4.20.2014
-------------------------------------------------------------------
- experiment Otsu threshold algorithm
- experiment mode detection algorithm

The modified Otsu algorithm should work!

render.style_realRatio
render.style_perspective
render.style_thresholdSticks

11:15PM working on bimodal rendering code

filtered_dist is not sorted!!

-------------------------------------------------------------------
4.22.2014
-------------------------------------------------------------------
- location filtering algorithm requires some work
- adding debug info

-------------------------------------------------------------------
4.23.2014
-------------------------------------------------------------------
- fixed a bunch of table related bugs

What should I be focusing today?

- better color selectiont to distinguish between two layers
- or should I have two separate disks?
- implement 4 applications

- start to work on smart watch application
(let's aim to leave at around 6pm)

For some reason the OpenGL view is always the top most. But I guess it is OK.
I will just need to work with it. 

It is possible to configure the view programmatically.

should look into NSView's InvalidateIntrinsicContentSize

check out the following debug function
NSLog(@"%f %f %f %f", NSMinX(rect), NSMinY(rect), NSWidth(rect), NSHeight(rect));


http://travisjeffery.com/b/2013/11/preventing-ib-auto-generated-at-build-time-for-view-with-fixed-frame/

maybe check this one too
http://stackoverflow.com/questions/19015215/trouble-with-autolayout-on-uitableviewcell


ordering views
http://stackoverflow.com/questions/2872840/how-do-i-make-an-nsview-move-to-the-front-of-all-nsviews

-------------------------------------------------------------------
4.24.2014
-------------------------------------------------------------------
Let's add the web target today!

- integrated a web browser target! [11:43PM]

Goals for tomorrow:
- 

-------------------------------------------------------------------
4.25.2014
-------------------------------------------------------------------
- investigate function pointer
http://www.learncpp.com/cpp-tutorial/78-function-pointers/

- todos:
* create a renderParamStruct
renderParamStruct.filterType (or indicesForRendering, a vector)
renderParamsStruct.renderStyle

* in the style selector, implment drawRect, which requires a custom version of 
 resizeGL

-------------------------------------------------------------------
4.28.2014
-------------------------------------------------------------------
- working on style selector
The consideration is that I would like to have a deafult mode, as well as a mode
that I can run with custom parameters.


-------------------------------------------------------------------
4.29.2014
-------------------------------------------------------------------
- filter needs to be modified
- completed the style selector back end work
- need to add debug and text configuration file

Maybe I should look into NSTask:
http://www.raywenderlich.com/36537/nstask-tutorial

hashit
http://stackoverflow.com/questions/650162/why-switch-statement-cannot-be-applied-on-strings

- win_width and win_height should be the properties of OpenGLView, not the camera
- each instance of OpenGLView has its own win_width and win_height


-------------------------------------------------------------------
5.2.2014
-------------------------------------------------------------------
Should I have two renderer? Yes.
- Made some progress on the styel selector

-------------------------------------------------------------------
5.10.2014
-------------------------------------------------------------------
Todo:
- One Tokyo and one European city example
- fix color matching issue
- two layer design
- different style profile

Use file system event to monitor file changes:
https://developer.apple.com/library/mac/documentation/Darwin/Conceptual/FSEvents_ProgGuide/UsingtheFSEventsFramework/UsingtheFSEventsFramework.html

another example:
http://www.davidhamrick.com/2011/10/13/Monitoring-Files-With-GCD-Being-Edited-With-A-Text-Editor.html

-------------------------------------------------------------------
5.11.2014
-------------------------------------------------------------------
- text-based configuration works with aquamacs but not command prompt emacs

- One Tokyo and one European city example
- paper driven demonstration
- two layer design
- different style profile

-------------------------------------------------------------------
5.12.2014
-------------------------------------------------------------------
- adding a secondary circle
- adding cutsom control of initial compass location

-------------------------------------------------------------------
5.14.2014
-------------------------------------------------------------------
- implement URL updata code, since in the browser mode, there is no map actions to trigger model updates
* hooked up compass with the browser, but there seems to be some heading issue

- figure out a way to control the visibility of the table?
- fix browser flash issues


- usability issue improvement

- interaction (in OpenGL?)

-------------------------------------------------------------------
5.20.2014
-------------------------------------------------------------------
- added color picking code
- need to color hash

Use this code to check if a key exists:

// http://stackoverflow.com/questions/1939953/how-to-find-if-a-given-key-exists-in-a-c-stdmap
if ( m.find("f") == m.end() ) {
  // not found
} else {
  // found
}


formular for the color key:
R*256^2 + G * 256 + B

some other selection mode:
http://www.opengl.org/archives/resources/faq/technical/selection.htm

Since the current one seems work well, I don't need to care about others.

Need to do something about the drawLabel method


-------------------------------------------------------------------
5.22.2014
-------------------------------------------------------------------
- check GLString frameSize method
// - (NSSize) frameSize; // returns either dynamc frame (text size + margins) or static frame size (switch with staticFrame)
I can take advantage of frameSize to fix the orientation and line break issues

- fixed text orientation issue

-------------------------------------------------------------------
5.23.2014
-------------------------------------------------------------------
todo:
- implement hysteresis, deal with flip flop
- interaction - min/max text
- articulate the problem, by thinking deeply, rigorously, and reading LOTS OF papers
- fixed the tilt issue in the browser mode

Something new that I learned today: If I want to see the message printed out 
from NSLog, I need to run the applicaiton as a child of the console.
http://stackoverflow.com/questions/364564/how-to-get-the-output-of-an-os-x-application-on-the-console-or-to-a-file

Look into how to get a Bitmap texture map
NSBitmapImageRep

I think it may be easier if I use icons (or letter abbreveation) as opposed to
full name for user study.

-------------------------------------------------------------------
5.26.2014
-------------------------------------------------------------------
- heading and tilt are extremely confusing
- need to decouple MKMapKit from the web browser
- next focus: hysteresis 

-------------------------------------------------------------------
6.3.2014
-------------------------------------------------------------------
- adding an iphone target
- hooking up all the components
- need to fix json parser
- I may need to use NSJSONSerialization
- produced an error free build

-------------------------------------------------------------------
6.4.2014
-------------------------------------------------------------------
- have more knowledge about how iOS is initialized
- completed a first verison of working iphone code!

-------------------------------------------------------------------
6.5.2014
-------------------------------------------------------------------
- Successfully installed my first iOS app!

-------------------------------------------------------------------
6.6.2014
-------------------------------------------------------------------
Goals of today:
- implemented the rotation hack
- need to add text indication (and feedback on map...)

I coudln't get text work on iOS
http://iphonedevelopment.blogspot.com/2009/05/opengl-es-from-ground-up-part-6_25.html
http://gamesfromwithin.com/remixing-opengl-and-uikit
http://liam.flookes.com/wp/2011/09/27/rendering-text-on-iphone-with-opengl/



http://www.wmdeveloper.com/2010/09/create-bitmap-graphics-context-on.html


-------------------------------------------------------------------
6.7.2014
-------------------------------------------------------------------
trying out this text solution
http://stackoverflow.com/questions/512258/is-there-a-decent-opengl-text-drawing-library-for-the-iphone-sdk/512722#512722

-------------------------------------------------------------------
6.8.2014
-------------------------------------------------------------------

Goals of today:
Optimization

Initialization
- proper zoom level
- exclude visible landmarks from the compass

Interactions
- hysteriesis
- flip-flop?

Text userability improvements:
- line break
- text size, style (bold)
- orientation

Map annotations
- mark the personal landmarks on the map

Control and Customization
- localize myself (where am I?)
- change to different presets
- create a new set
- move the compass
- adjust the size of the compass
- jump to different landmakrs

Distance indicator 
- adding distance to the compass 
[ maybe I need to think about multi threading]


-------------------------------------------------------------------
6.9.2014
-------------------------------------------------------------------
- have better idea about text rendering on iOS, but there are still more to do...

- compass color
- make the text horizontal (and invariant to rotation)


-------------------------------------------------------------------
6.11.2014
-------------------------------------------------------------------
- adding gluPerspective to OpenGL ES
http://maniacdev.com/2009/05/opengl-gluperspective-function-in-iphone-opengl-es

-------------------------------------------------------------------
6.12.2014
-------------------------------------------------------------------
Goals of today:
- add dataset customization
- file reorganization

check this:
http://stackoverflow.com/questions/2503436/how-to-check-if-nsstring-begins-with-a-certain-character

should look into this (scroll menu)
https://github.com/John-Lluch/SWRevealViewController


-------------------------------------------------------------------
6.13.2014
-------------------------------------------------------------------
- when interface and implementation are in the same file, the interface usually acts as a class extension
Note the parentheses.

@interface myClass ()

@end

http://stackoverflow.com/questions/10647913/declare-interface-inside-implementation-file-objective-c
- following the instructions here to implmenet iOS location services

3:53PM
- added search, need to do pin and display managmenet
- next step: look into iCloud syncing

8:54PM
Some potential improvements:
- Compass should only include invisible points
http://stackoverflow.com/questions/16239443/how-to-know-whether-mkmapview-visiblemaprect-contains-a-coordinate

-------------------------------------------------------------------
6.17.2014
-------------------------------------------------------------------

- it is possible to set line thickness in OpenGL
http://opengl.czweb.org/ch06/141-145.html

- need to fix the scaling code, for wedge, we need to draw them "true to scale"

slide out menu
http://www.raywenderlich.com/32054/how-to-create-a-slide-out-navigation-like-facebook-and-path

http://sugartin.info/2012/10/01/ios-notification-sliding-type-animation-for-slide-up-down/

-------------------------------------------------------------------
6.18.2014
-------------------------------------------------------------------

Todo:
--------
- "lock" certain landmarks
* need to labeling code, one for the personalized compass, one for Wedge
- filter algorithm improvement (esp. for overlap)
- box2d (need to include the scale information)
- 3D text tilt

- dropbox file support
- debug support (mark the problematic location), add the support to
start the map at a chosen location

Nice to have:
- Google street view
* 

Next:
--------
- annotate the landmarks, control the annotation of landmarks


Done:
--------
- incorporate wedge
* infrastructure work
* add a menu pane to support extra parameters
- draw wedge "true to scale"


-------------------------------------------------------------------
6.19.2014
-------------------------------------------------------------------
Look into how to recognize gesture in MKMapView
http://stackoverflow.com/questions/1121889/intercepting-hijacking-iphone-touch-events-for-mkmapview/4064570#4064570

-------------------------------------------------------------------
6.20.2014
-------------------------------------------------------------------
- adding annotations and table
- successfully added the table

maybe I should look into how to add a dropbox folder

pass data using segue:
http://www.appcoda.com/storyboards-ios-tutorial-pass-data-between-view-controller-with-segue/

- fixed the rotation bug in iOS


L198 indices_for_rendering needs to be sorted by distance

sort_id_by_distance function?

label collision tutorial
http://www.iforce2d.net/b2dtut/collision-anatomy

let's implement an overview map
check MKMapPointsPerMeterAtLatitude


-------------------------------------------------------------------
6.22.2014
-------------------------------------------------------------------
- checked and confirmed that smartWatch and browser targets sitll work
- one step at a time
- implemented the scaling rectangle, but the behavior is strange, 
I need to give it a bit more thought.
- need to fix the rotation issue of the scale indicator (the box)

-------------------------------------------------------------------
6.23.2014
-------------------------------------------------------------------
- debug ipad coordinate issues

-------------------------------------------------------------------
6.24.2014
-------------------------------------------------------------------
Need to learn how to use unwind segue
http://stackoverflow.com/questions/12561735/what-are-unwind-segues-for-and-how-do-you-use-them

- added the table view to iPad

-------------------------------------------------------------------
6.26.2014
-------------------------------------------------------------------
- adding dropbox support
- implement data source

- should I implement an unlink option?
https://www.dropbox.com/developers/sync/docs/ios

-------------------------------------------------------------------
6.27.2014
-------------------------------------------------------------------

Here is the trick to draw polylines on top of a map:
http://stackoverflow.com/questions/20350685/polyline-not-drawing-from-user-location-blue-dot

http://stackoverflow.com/questions/6167884/monotouch-draw-a-mkpolyline-on-map

    MKMapPoint *pointsArray = malloc(sizeof(CLLocationCoordinate2D));
    pointsArray[0]= MKMapPointForCoordinate(currentLocation);
    pointsArray[1]= MKMapPointForCoordinate(otherLocation);
    routeLine = [MKPolyline polylineWithPoints:pointsArray count:2];
    free(pointsArray);

    [self.mapView addOverlay:routeLine];

- bug fixes, add-ons
* fix wedge

-------------------------------------------------------------------
6.28.2014
-------------------------------------------------------------------
- implement a constrait for the wedge

-------------------------------------------------------------------
6.29.2014
-------------------------------------------------------------------
- adding a debug subview (done)
- need to populate debug subview
- added debug view
- next step, draw box on the map

check this method:
+ (instancetype)polylineWithPoints:(MKMapPoint *)points count:(NSUInteger)count

this is useful to find the visible rect
http://stackoverflow.com/questions/2081753/getting-the-bounds-of-an-mkmapview


-------------------------------------------------------------------
6.30.2014
-------------------------------------------------------------------
two goals toady:
- draw the box
- fix debug information pane

- need to fix this->model->configurations[@"wedge_correction_x"] issue
dropbox configuraiton

-------------------------------------------------------------------
7.1.2014
-------------------------------------------------------------------
- bookmark management

http://stackoverflow.com/questions/1469474/setting-an-image-for-a-uibutton-in-code

-------------------------------------------------------------------
7.2.2014
-------------------------------------------------------------------
- constructing the new viewPanel and modelPanel
- try to wirte an XML writer

-------------------------------------------------------------------
7.4.2014
-------------------------------------------------------------------
- fixed manual control
- add select/deselect all
- removed the lock when "find current location" is enabled

-------------------------------------------------------------------
7.5.2014
-------------------------------------------------------------------
- work on the expanded view of custom droppin
- figured out how navigation controller works!

-------------------------------------------------------------------
7.6.2014
-------------------------------------------------------------------
- working on the detail pane
- working on save and saveas
- working on the dropbox file write case

-------------------------------------------------------------------
7.7.2014
-------------------------------------------------------------------
- refactory the pinview code
- need to connect detail view from the table view
- hook up table view with detail view
- need to do something about compassCenterXY (model) and compass_centroid (render)
- should implement KVO to resolve configuration file update issues

Todo:
- need to add code to watch this variable: configurationFileReadFlag (model)

ipad modal back button:
http://stackoverflow.com/questions/10841653/create-a-modal-view-with-navigation-bar-and-back-button
http://stackoverflow.com/questions/9483100/iphone-navigation-back-button


-------------------------------------------------------------------
7.8.2014
-------------------------------------------------------------------
- implementing the back action of modal view controllers
[self dismissViewControllerAnimated:YES completion:nil];

- working on the ipad target to catch up the development progress

Here is a tutorial for deleting and inserting rows in a table
https://developer.apple.com/library/ios/documentation/userexperience/conceptual/tableview_iphone/ManageInsertDeleteRow/ManageInsertDeleteRow.html

- working on CLLocationManager related stuff

Evening at UCL office

add a custom MKPinAnnotationView:
http://stackoverflow.com/questions/15950698/custom-pin-on-mkmapview-in-ios

custom the image of MKAnnotationView
http://stackoverflow.com/questions/9814988/mkmapview-instead-of-annotation-pin-a-custom-view

- update ipad code

-------------------------------------------------------------------
7.9.2014
-------------------------------------------------------------------
- fix ipad navigation issue (from the setting pane to the map pane)

todo:
rotate an UIImage:
http://stackoverflow.com/questions/1315251/how-to-rotate-a-uiimage-90-degrees?rq=1

update annotation:
http://stackoverflow.com/questions/6375473/updating-mkannotation-image-without-flashing

- looks like the proper way to rotate the heading image is to rotate
the view UIView setTrnasform

Use the keyword: UIView rotate

http://stackoverflow.com/questions/11476296/mkannotationview-rotation
http://stackoverflow.com/questions/3169298/setting-a-rotation-transformation-to-a-uiview-or-its-layer-doesnt-seem-to-work

check this:
http://stackoverflow.com/questions/21370728/rotate-uiview-around-its-center-keeping-its-size

-------------------------------------------------------------------
7.10.2014
-------------------------------------------------------------------
This solution works to rotate a view around its center:
http://stackoverflow.com/questions/21370728/rotate-uiview-around-its-center-keeping-its-size

- fix the FindMe view
- 

-------------------------------------------------------------------
7.11.2014
-------------------------------------------------------------------
Goals of today:
- fix the tilt issue

The following is not needed:
------
float modelview[16];
glGetFloatv(GL_MODELVIEW_MATRIX, modelview);

//https://developer.apple.com/library/ios/documentation/GLkit/Reference/GLKMatrix4/Reference/reference.html#//apple_ref/c/func/GLKMatrix4Multiply

GLKMatrix4 rotateMat;
rotateMat =  GLKMatrix4RotateZ (GLKMatrix4Identity,
                                (rotation)/180 * M_PI);
GLKVector3 vec3 = GLKMatrix4MultiplyAndProjectVector3 (
                        rotateMat,GLKVector3Make(1, 0, 0));
------

Looks like it is possible to catch the zoom and rotate event. I will do that later.

This recipe checks whether a point is visible or not:
http://stackoverflow.com/questions/9126137/how-can-we-know-that-map-coordinates-are-in-current-region-or-not-in-current-reg?lq=1


-------------------------------------------------------------------
7.14.2014
-------------------------------------------------------------------
Goals of today:
- implement FindMe
If I can fix overlap issues, even better!

reserve some special index for the user location

it will be very nice if the find me button can distinguish betweeen single tap 
and double taps

single tap: turn on/off location service
double tap: go to current location

recognize single tap and double taps:
http://stackoverflow.com/questions/8876202/uitapgesturerecognizer-single-tap-and-double-tap

UIButton customization
http://stackoverflow.com/questions/5608654/double-tap-on-a-uibutton

findMe toggle code still needs to be fixed. 

-------------------------------------------------------------------
7.15.2014
-------------------------------------------------------------------
- fixed a small orientation bug

-------------------------------------------------------------------
7.16.2014
-------------------------------------------------------------------
- came back to NYC, let's do some refactoring work, if I can get
box2d to work, even better!
- figure out what the important features are
- reorganize menu items

-------------------------------------------------------------------
7.17.2014
-------------------------------------------------------------------
Goals of today:
- smart watch mode improvement
- font color and triangle colors in the satellite mode

Progress:
- enhance watch mode
- bring wedge to the watch mode
- max_aperture needs to be corrected
- how can I create a mask?

check this solution:
http://stackoverflow.com/questions/16512761/calayer-with-transparent-hole-in-it

- the solution works. need to refine further
- made some progress on the watch mode

introducing colors seems to be a low-hanging fruit

- added boundary indicator for smart watch

-------------------------------------------------------------------
7.18.2014
-------------------------------------------------------------------
- fix the color issue
- updated color profile, it was a good choice
- implement the debug view
How to capture a snapshot:
http://stackoverflow.com/questions/4189621/setting-the-zoom-level-for-a-mkmapview

How can I serialize data with plist?

- maybe I need to modify xmlParser? and use a common data format? 
that is, I will need to add the following items:
- span
- orientation

-------------------------------------------------------------------
7.19.2014
-------------------------------------------------------------------
- implement snapshot object and history object
check NSDate

http://stackoverflow.com/questions/5689179/get-time-and-date-by-nsdate

-------------------------------------------------------------------
7.20.2014
-------------------------------------------------------------------
- investigate drawing polyline
http://stackoverflow.com/questions/10911534/how-to-draw-a-mkpolyline-on-a-mapview
- implementd the snapshot and breadcrumb mode

Need to enable background location update:
http://stackoverflow.com/questions/3413258/give-some-screenshots-to-create-uibackgroundmodes-key-in-info-plist-for-ios4

check out this:
http://stackoverflow.com/questions/18946881/background-location-services-not-working-in-ios-7?lq=1
http://mobileoop.com/background-location-update-programming-for-ios-7
https://github.com/voyage11/Location/tree/master/Location

check if the app is in background mode:
http://stackoverflow.com/questions/5835806/check-if-ios-app-is-in-background

https://developer.apple.com/library/ios/documentation/uikit/reference/uiapplicationdelegate_protocol/Reference/Reference.html
search for "Monitoring App State Changes"

- need to fix the case when location service fails to update

n choose k in c++:
http://stackoverflow.com/questions/5095407/n-choose-k-implementation

-------------------------------------------------------------------
7.21.2014
-------------------------------------------------------------------
- propagated the new changes to iPad
- prototype hollow indicator
- implemented snapshot parser
- need to put the save history code into background thread
- implemented history parser (but not connected yet)


- augmented reality mode?

-------------------------------------------------------------------
7.22.2014
-------------------------------------------------------------------
Goals of today:
- implement scale indicator
- there may be a way I can optimize text rendering, can I somehow render all the
labels and cache them?

- moving some data analysis tool to compassMdl
- running does help me be more productive 
* finished seveal snapshot, scale indicator changes today
(need to figure out how to incorporate running into my routine)

-------------------------------------------------------------------
7.23.2014
-------------------------------------------------------------------
I had to switch the order (made MapView below OpenGL View) to make gesture recognition works on Map View. But now OpenGLView cannot accept touch events. 

Maybe we will need to add user location into indices_for_rendering for data clustering
- fixed the issue, filtered_id_list needs to be sorted

- orientation calculation may need to be fixed

-------------------------------------------------------------------
7.24.2014
-------------------------------------------------------------------
- do not fly to the 1st location if the location file is new.kml
- added code to list and load history files
- adding a detail pane for history files

-------------------------------------------------------------------
7.25.2014
-------------------------------------------------------------------
- it might be a good idea to think about the smart watch mode

- calculate distance from a point to a polyline
http://programmizm.sourceforge.net/blog/2012/distance-from-a-point-to-a-polyline

-------------------------------------------------------------------
7.26.2014
-------------------------------------------------------------------
- add notes filed to history files
Goals of today:
- add labels for wedges. done @ 10:41PM

text outline: http://stackoverflow.com/questions/10036671/how-could-i-outline-text-font

-------------------------------------------------------------------
7.27.2014
-------------------------------------------------------------------
- should focus on user study today
- rotating the view:
http://stackoverflow.com/questions/19095161/force-landscape-ios-7

working on device rotation
- implemented a rotating screen!


-------------------------------------------------------------------
7.28.2014
-------------------------------------------------------------------
http://stackoverflow.com/questions/18969248/how-to-draw-a-transparent-uitoolbar-or-uinavigationbar-in-ios7

lock rotation:
http://stackoverflow.com/questions/7081221/how-does-one-add-uibutton-to-uitoolbar-programmatically

fonts chage sizes after rotation, need to fix this.

-------------------------------------------------------------------
7.30.2014
-------------------------------------------------------------------
- call initRenderView before updateViewport

created a property called UIConfigurations

need to update the following two:
[self.model->configurations setObject:[NSNumber numberWithBool:false]
                               forKey:@"UIRotationLock"];
[self.model->configurations setObject:[NSNumber numberWithBool:false]
                               forKey:@"UIBreadcrumbDisplay"];
done!
- added the demo mode
- add pin creation control

renderAnnotations
zoom level, and the selected landmarks, etc.

- did a big merge job
Did a lot of work today. Merged to the master (that I detached on 6.30, a month ago!). 
Good job!

-------------------------------------------------------------------
7.31.2014
-------------------------------------------------------------------
- add UISwitch to the landmark table

Todos:
- snapshot should contain landmark IDs
- need to implement tester class


-------------------------------------------------------------------
8.1.2014
-------------------------------------------------------------------
- added the debug control
- added the saveas capability to snapshot

- added the capability to move the compass

-------------------------------------------------------------------
8.2.2014
-------------------------------------------------------------------
Here is the trick to modify mapview
http://stackoverflow.com/questions/18263359/setting-the-frame-of-an-uiview-does-not-work

How to detect pinch gesture simultaneously?
http://stackoverflow.com/questions/6747427/why-would-uipinchgesturerecognizer-not-be-called-while-scrollviewdidendzooming

Detect two points in gesture recognizer
http://stackoverflow.com/questions/17657553/get-uipinchgesturerecognizer-finger-positions

-adding Box2D to the code base
-looks like box2d is good to go!

-------------------------------------------------------------------
8.3.2014
-------------------------------------------------------------------
- upgrade orientation computation
- ready to modify wedge
- organize the wedge code
- squash some small bugs (hide all panels before launching a new one)

-------------------------------------------------------------------
8.4.2014
-------------------------------------------------------------------
- looks like I can customize the navigation bar
http://stackoverflow.com/questions/18177010/how-to-change-navigation-bar-color-in-ios-7-or-6
http://stackoverflow.com/questions/3680805/uinavigationbar-set-title-programatically-iphone-sdk-4

-------------------------------------------------------------------
8.5.2014
-------------------------------------------------------------------
- modified the ratio sum fomula

-------------------------------------------------------------------
8.6.2014
-------------------------------------------------------------------
- need to do something for wedge on the watch mode
used this recipe to rotte the screen:
http://stackoverflow.com/questions/20987249/how-do-i-programmatically-set-device-orientation-in-ios7

- successfully added rotation code
- did some work on the demo mode and rotation mode

-------------------------------------------------------------------
8.8.2014
-------------------------------------------------------------------
- remove rotation control
- modify readLocationKml

-------------------------------------------------------------------
8.9.2014
-------------------------------------------------------------------
tutorial to add directions to map:

Apple's doc:
https://developer.apple.com/library/ios/documentation/userexperience/Conceptual/LocationAwarenessPG/ProvidingDirections/ProvidingDirections.html

Stackoverflow-add interaction to polylines:
http://stackoverflow.com/questions/11713788/how-to-detect-taps-on-mkpolylines-overlays-like-maps-app

A tutorial:
http://www.techotopia.com/index.php/Using_MKDirections_to_get_iOS_7_Map_Directions_and_Routes

-------------------------------------------------------------------
8.10.2014
-------------------------------------------------------------------
- fixing the locking panel bug
- added a switch to lock the center


-------------------------------------------------------------------
8.13.2014
-------------------------------------------------------------------
- implemented yet another version of wedge
- prototype does help. the better you prototype, the better you understand the problem

-------------------------------------------------------------------
8.14.2014
-------------------------------------------------------------------
- modified wedge style
- need to fix label info
- there are bugs in interaction
need to check this "personalized_compass_status" too
- lock center mode gets disabled after the compass is moved
- consider change color scheme
- consider adding background for labels
- improve perspective projection
- improve overview map to make a fair comparison

- enabling wedge on iPad, text renderin is the performance bottleneck
- default positions (center, UR, BL) need to support rotation mode

dropbox: need to observe file changes
- (BOOL)addObserver:(id)observer forPath:(DBPath *)path block:(DBObserver)block

How can I make a fair comparison to overview map?
Can I implement an autozoom?

- add in place search

-------------------------------------------------------------------
8.15.2014
-------------------------------------------------------------------
- add smart scale for the overview map
modifying updateOverviewMap

maybe I can use this function:

MKCoordinateRegion MKCoordinateRegionMakeWithDistance(
   CLLocationCoordinate2D centerCoordinate,
   CLLocationDistance latitudinalMeters,
   CLLocationDistance longitudinalMeters
);

-------------------------------------------------------------------
8.17.2014
-------------------------------------------------------------------
- think about how to make a fair comparison to overview map

-------------------------------------------------------------------
8.19.2014
-------------------------------------------------------------------
- let's fix the dropbox syncing capability (dropbox syncing may not be that important at the point)

// Add viewcontroller to the responding chain
http://stackoverflow.com/questions/20061052/how-to-add-nsviewcontroller-to-a-responder-chain

- need to figure out how to configure annotation and how to do search
- check regionThatFits

-------------------------------------------------------------------
8.20.2014
-------------------------------------------------------------------
- add custom annotation to the desktop map
- experimenting adding a subview
- made some progress on the callout experiment!
- adding a settings view

-------------------------------------------------------------------
8.22.2014
-------------------------------------------------------------------
- enhance annotation control
- had a quite a day yesterday

goals of today:
- networking
* should look into SimpleWebSocketServer

-------------------------------------------------------------------
8.25.2014
-------------------------------------------------------------------
Goals of today:
- implement web socket communications
- implement test case generator (to prepare a table for discussion)
- do you want to put all the cases into a web table?
- how do you organize/integrate all the fragmented knowledge?

- adding server code the code base
- successfully hook up the server
let's figure out iOS communication

-------------------------------------------------------------------
8.26.2014
-------------------------------------------------------------------
Goals of today:
- implement iOS client code
- investigate how to programmatically generate test cases

-------------------------------------------------------------------
8.27.2014
-------------------------------------------------------------------
- implement iOS client code (I want to wrap up this today)
- I should switch to SocketRocket
- successfully added the server and client code
- now need to add test case generation
- should look into testCocoaGL for offline rendering example
- implemented an "add in place" button
look into components, label code

I need to tool to convert coordinates in OpenGL to MapView
- cache label texture

-------------------------------------------------------------------
8.28.2014
-------------------------------------------------------------------
- modifying label_info_array
- 5:05PM 

-------------------------------------------------------------------
8.29.2014
-------------------------------------------------------------------
- work on test case generator
- consider implementing a map selector (which allows me to use Google Maps)
- color improvement
- need to separate the dependency on a map, maybe I can create augmented reality type of app later

detect mouse hold event:
http://stackoverflow.com/questions/9967118/detect-mouse-being-held-down

-------------------------------------------------------------------
9.5.2014
-------------------------------------------------------------------
- add scale indicator
- multi-destination zoom
- test case generator
- write down the steps to perform each task
- improve color scheme

-------------------------------------------------------------------
10.6.2014
-------------------------------------------------------------------
- let's try to fix the iOS8 bug (localization) issue today

http://nevan.net/2014/09/core-location-manager-changes-in-ios-8/

fixed the location service bug (two keys need to be added in plist)

should look into how to use TestFlight
https://developer.apple.com/library/ios/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Chapters/BetaTestingTheApp.html#//apple_ref/doc/uid/TP40011225-CH35-SW2

https://developer.apple.com/app-store/testflight/

-------------------------------------------------------------------
12.20.2014
-------------------------------------------------------------------
- The desktop applicaiton does not work on the latest 10.10 SDK for unknown reasons

What is this?
2014-12-20 10:26:46.466 Compass[transparent][39797:4989346] Failed to connect (viewController) outlet from (AppDelegate) to (DesktopViewController): missing setter or instance variable

- reverting the framework back to 10.9 solves the problem.
- verified the server is still working!
http://localhost:50862/
- verified the code worked. 

-------------------------------------------------------------------
12.22.2014
-------------------------------------------------------------------
- Layout user study plan (before the real user studies, I will need to conduct pilots)

-------------------------------------------------------------------
12.23.2014
-------------------------------------------------------------------
- should figure out how to implement drop-pins
Looks like the mouseDown problem might be releated to the nextReponder chain.

http://prod.lists.apple.com/archives/cocoa-dev/2014/Sep/msg00397.html
http://stackoverflow.com/questions/20061052/how-to-add-nsviewcontroller-to-a-responder-chain
- Fixed issues for Yosemite 10.10 SDK!

Feels good. I am back to build software again!

Desktop application wishlist:
- gesture interaction (long press to drop pin, or right-click to drop-pin,
long-press to move the compass)
- hyperlink mode


Here are some of the tasks that I left-off:
- need to improve color scheme
- need to separate the dependency on a map, maybe I can create augmented reality type of app later

detect mouse hold event:
http://stackoverflow.com/questions/9967118/detect-mouse-being-held-down

- fix the framework issues for 10.10

- added the long-held to drop pin function
- now need to fix button clicking and item updates

In OSXPinAnnotationView, need to implement add and remove.

I may need pin management too, but what are the most needed features at this point?
Tomorrow's goals:
- server-client communication
- need to design a test manager
- need to contact Carmine and Mengu to ask how they build a test manager?
- the test manager needs to log lots of information
- OpenGL performance issues
- Location management pane
- [desktop] dropbox support
- [desktop] long-press to move the compass

Multiple annotations: the signs of mutliple annotations can be shown simultaneously.

-------------------------------------------------------------------
12.24.2014
-------------------------------------------------------------------
- Let's move the configuration dialog to a separate window

-------------------------------------------------------------------
12.26.2014
-------------------------------------------------------------------
- Fixed the centroid lock bug
- Found out the iPad crash issue: snapshot array is empty (dropbox was not enabled...)
- Performed websocket communication experiment
Document root:
/Users/daniel_miau/Dropbox/Projects/Compass[transparent]/build/Debug/Compass[transparent].app/Contents/Resources/Web

- I should experiment message passing
- The iOS client is in iOSViewController+Client.mm

-------------------------------------------------------------------
12.30.2014
-------------------------------------------------------------------
iOS:
- implement broadcasting current orientation and four corners

OSX:
- display a ractangle to match the iOS's orientation and view.

Maybe I should implement KVO. 
beefing up the communication code.

How to put c-type struct in NSArray
http://stackoverflow.com/questions/14328173/how-to-store-cllocationcoordinate2d

How to include a c array as an object property (very important!)
http://stackoverflow.com/questions/17548425/objective-c-property-for-c-array

-------------------------------------------------------------------
12.31.2014
-------------------------------------------------------------------
How to put struct in NSData
http://stackoverflow.com/questions/5373545/structs-to-nsdata-to-structs

I guess I will need to turn the notification off. 

- The connection pane (iOS) does not persist.

-------------------------------------------------------------------
1.1.2015
-------------------------------------------------------------------
- Display iOS display region

-------------------------------------------------------------------
1.2.2015
-------------------------------------------------------------------
Today's goals:
- sync desktop with the mobile devices
- adjust the desktop map size to include the iOS map
3:53PM. The communication code works!

Some bugs:
iOS: 
- the app crashes when the connection is dropped. To reproduce, 
I can cut the connection from the OSX side. [fixed@10:06PM]
- cannot turn off the connection. the segment control status 
is not updated [fixed@11:34PM]

OSX:
- the server cannot be really turned off [fixed@10:23PM]
- updateMapDisplayRegion code needs to be refiend (so as the one iniOS)
- when the table and the compass is on, the app is easy to crash...
(so when working on the box drawing code, this part needs to be taken into account)

self.model->camera_pos.orientation = heading_deg;
self.model->tilt = tilt_deg;

    heading: -self.mapView.camera.heading
                           tilt: -self.mapView.camera.pitch];


    NSDictionary *myDict = @{@"ulurbrbl" :
                        [NSData dataWithBytes:&(temp)
                                       length:sizeof(temp)],
                             @"map_region":[NSData dataWithBytes:
                                            &(temp_region)
                                        length:sizeof(temp_region)],
                             @"mdl_orientation":[NSNumber numberWithFloat:
                                                 self.model->camera_pos.orientation],
                             @"mdl_tilt":[NSNumber numberWithFloat:
                                                 self.model->tilt]};

-------------------------------------------------------------------
1.3.2015
-------------------------------------------------------------------
check compassRender::renderStyleWedge
drawBoxInView is an good example

drawing is in compassRender::render

box4Corners is calculated within updateOverviewMap

CGPoint iOSFourCornersInNSView[4];
Refactor drawBoxInView

- need to clean up settings code

remove?
- SettingsViewController.mm, SettingsViewController.h

What's next?
- implement Wedge-like testing environment
- 

-------------------------------------------------------------------
1.5.2015
-------------------------------------------------------------------
- Try to build the code on a new system. 
- I want to implement wedge testing mode. 
How can I modify the screen size?

potential sources of confusion:

compassRender:
-view_height
-viewport_height

OpenGL:
-viewHeight

* up and down motions need to be fixed. 

The screen size may be modified in compassRenderer+wedge.m
TODO
TOFIX

Need to add a mask

mapMask = [CALayer layer];
mapMask.backgroundColor = [[UIColor whiteColor] CGColor];
mapMask.frame = CGRectMake(0, 0,
                           self.mapView.frame.size.width,
                           self.mapView.frame.size.height);
mapMask.opacity = 1;
[self.mapView.layer addSublayer:mapMask];

//
UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.mapView.bounds.size.width, self.mapView.bounds.size.height) cornerRadius:0];

UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:
                            CGRectMake(fwidth/2-radius, fheight/2-radius,2*radius, 2*radius) cornerRadius:radius];
[path appendPath:circlePath];
[path setUsesEvenOddFillRule:YES];

CAShapeLayer *fillLayer = [CAShapeLayer layer];
fillLayer.path = path.CGPath;
fillLayer.fillRule = kCAFillRuleEvenOdd;
fillLayer.fillColor = [UIColor blackColor].CGColor;
fillLayer.opacity = 1;
[self.glkView.layer addSublayer:fillLayer];
self.view.backgroundColor = [UIColor blackColor];

Attach NSBezierPath to a CAShapeLayer
http://stackoverflow.com/questions/17788870/how-to-attach-an-nsbezierpath-to-a-cashapelayer

-------------------------------------------------------------------
1.9.2015
-------------------------------------------------------------------
What needs to be done?
- [done] Stand-alone iOS wedge mode (for testing)
* [done] vislibility test will need to be updated
- wedge parameters (fomula parameter modifications?)
- move the location table to the configuration pane 
- (desktop) touch-hold to move the compass
- color - green check , red x
- compass color (red is reserved for N, in most cases)
- update method consolidation/clean-up
- watch test mode

* test manager
- test generation
- test result logging
- show the difference between the answer and the groundtruth
- setting sychronization (between the memory and the file); setting serilization

iPad
- cover the entire screen with the GL layer

wedge_correction_X

Nice to have:
- transition between a wedge and a compass

-------------------------------------------------------------------
1.11.2015
-------------------------------------------------------------------
What should I tackle today? (I should try to work from home, at least in the afternoon.)

-------------------------------------------------------------------
1.12.2015
-------------------------------------------------------------------
The lighting in my room is throwing me off. It feels like there is soemething wrong with my eyes...(I hope not)



Done:
- Stand-alone iOS wedge mode (for testing)
* vislibility test will need to be updated
- toggleCompass is to toggle the conventional compass

- relocate table to the configurations panel

-------------------------------------------------------------------
1.13.2015
-------------------------------------------------------------------
Brought my MacMini to the office. 

Done:
- moving the combo box to the configuration panel
- move the location table to the configuration pane 
- initialize configurations window

Working:
- location selection
- delete

tableCellCache

-------------------------------------------------------------------
1.14.2015
-------------------------------------------------------------------
- need to check the iOSViewController viewWillAppear method 

-------------------------------------------------------------------
1.15.2015
-------------------------------------------------------------------
Done:
- implmented landmarkLock

-------------------------------------------------------------------
1.16.2015
-------------------------------------------------------------------
What needs to be done?
- wedge parameters (fomula parameter modifications?)
- (desktop) touch-hold to move the compass
- color - green check , red x
- compass color (red is reserved for N, in most cases)
- update method consolidation/clean-up
- watch test mode
- the issue of chaning compass sizes
- Why there is a sudden shift when calling updateMapDisplayRegion
- need to display label touch checking code when the compass is off

iPad
- cover the entire screen with the GL layer

wedge_correction_X

Nice to have:
- transition between a wedge and a compass

Working:
* test manager
- test generation
- test result logging
- show the difference between the answer and the groundtruth
- setting sychronization (between the memory and the file); setting serilization

4:49PM. I realized the current design/implementation is not ideal. The design and implementation need to be redone.

-------------------------------------------------------------------
1.18.2015
-------------------------------------------------------------------
Planning.

I will use arc4random() to draw one elment from the array at a time
http://stackoverflow.com/questions/7047085/reading-random-values-from-an-array

methods to write:
- (vector<data>) generateLocationsForCloseDist: (int) close_distc Number: (int) close_n
FarDist: (int) far Number: (int) far_n

-------------------------------------------------------------------
1.19.2015
-------------------------------------------------------------------
I think I have some ideas. The way how my test harness currently works is a bit strage. 

The core of the test harness is implemented in DemoManager (a C++ class). 
The DemoManager has a property called test_vector, which is supposed to store a collection of tests. At the moment, however, it stores one test per device type. 

-------------------------------------------------------------------
1.20.2015
-------------------------------------------------------------------
Today's goals:
- iOS interface modification
- test generation

Done:
- implementing a tab bar controller
- Convert TestManager to DemoManager

Working:

displaySnapshot is the method to load and display a snapshot

-------------------------------------------------------------------
1.21.2015
-------------------------------------------------------------------
Today's goal:
- Make progress on TestManager
Maybe I can take advantage of the information stored in iOSFourCornersInNSView

Done:
- Cleaned up DemoManager and TestManager
- Have a conceptual model on what to implement

Working:
- Implementing generateLocateTests

self.rootViewController.renderer->iOSFourCornersInNSView

I do need a test file to specify the following parameters:
- 

-------------------------------------------------------------------
1.22.2015
-------------------------------------------------------------------
Today's goals:
- Locate tests generation (did not do much on this day...)

-------------------------------------------------------------------
1.23.2015
-------------------------------------------------------------------

I sketched out some ideas on how to implement the test harness. 
4:32PM. Work on the test harness again. 

For test case generation, I should try to use double as much as possible. 

-------------------------------------------------------------------
1.25.2015
-------------------------------------------------------------------
I can tokenize strings
http://stackoverflow.com/questions/259956/nsstring-tokenize-in-objective-c

Working on test case generation design.
p: phone
w:watch
c:compass
w:wedge

-------------------------------------------------------------------
1.26.2015
-------------------------------------------------------------------
- expecting snow storm, working from home today. 

Does this make sense?

Have a nested loop to iterate all the possible test_spec, in each iteration, test_vector will be called. Each test_vector is associated with one person. 

test_vector = generateTestVector(test_spec);
10:32PM. There is something wrong in my permute function.

-------------------------------------------------------------------
1.27.2015
-------------------------------------------------------------------
- Need to update the "next" function so it returns vector<string>
- Have a draft to generate test vectors
12:21PM. Now on to generate locations. 

- I would like to complete location vector generation today. I think it is possible. 
What kind of location vector do you want to generate?
2:03PM. Should I take a nap or not?

10:15PM. I felt hard to concentrate. I know there are issues in generateRandomLocateLocations. distr needs to be cached.

-------------------------------------------------------------------
1.28.2015
-------------------------------------------------------------------
11:11AM. Work in the office. 
Let's make some progress on location generation today. 
2:10PM. Came back to work on the triangulate test generation

Let's at least complete the locate test harness first. 

5:06PM. Ran into LLDB issue with std::map

5:29PM. Standard, predefined marcors:
http://stackoverflow.com/questions/2760411/objective-c-x-code-equivalent-of-file-and-line-from-c-c

5:36PM. Let's fix the desktop loading/saving path issue before dinner. Look for the string NSBundle.
configuration_filename
location_filename

-------------------------------------------------------------------
1.29.2015
-------------------------------------------------------------------
Goal of today:
- Have a working locate test!

Done:
- Fill out placeholders for generateTriangulateLocations and generateOrientLocations
- Generate .tests

Todo:
- Generate .kml and .snapshot
- Testharness UI

-------------------------------------------------------------------
1.30.2015
-------------------------------------------------------------------

*Todo
- [Desktop] implement snapshot
- [Desktop] use mouse to move the compass location
- [Desktop] test authoring tool? (my task might be overly complicated)
- Testharness UI
- Compass scaling when the window is scaled?
- Need some desktop <-> iOS conversion tools:


*Done
- Read the file from the dropbox source
look for *_filename [10:51AM]
- heading is problematic. The rotating map has this snap-back feature, which is annoying. Fixed. [4:34PM]

*Working
- Generate .kml and .snapshot
* I would need some kind of test configuation files 

check displaySnapshot in iOSViewController+SnapShot.mm

snapshot has a field called coordinateRegion.

MKCoordinateSpan span

- I want to see how MKMapRect change and how MKCoordinateSpace changes?
what happen to the rotate function?

In compassRender
    float em_ios_width;
    float em_ios_height;
    float em_watch_radius;

check calculateiOSScreenSize

-------------------------------------------------------------------
1.31.2015
-------------------------------------------------------------------
Need to address the following two questions:
1. How do I know the mapRect in OSX?
2. How do I know the mapRect in iOS?

A couple of things can be useful:
- MKMapPoint
- MKMapSize (not sure how to get this)
- MKMapRect
- MKZoomScale (not useful)

need to initialize 
em_ios_height and em_ios_width

-------------------------------------------------------------------
2.1.2015
-------------------------------------------------------------------

Todo:

==================
iOS emulation
==================
.kml and .snapshot generation
(assuming no rotation in tests)
- converts the coordinates in the test files (in iOS screen coordinates) to the coordinates in the OSX screen coordinates
- calculate map coordinates on OSX
- store all map coordinates to .kml and .snapshot
- store the latitude and longitude spans in .snapshots

display
iOS:
- display snapshot has been implemented
- OSX's load snapshot method need to convert latitude delta and longitude delta to the ones on the desktop.

Done:


Working:
.kml and .snapshot generation
(assuming no rotation in tests)

8:52PM. I want to port the snapshot capability to the desktop. 

-------------------------------------------------------------------
2.2.2015
-------------------------------------------------------------------
*Done:
- implement the snapshot feature on the desktop
- turned out I need to implement a NSViewController [4:39PM]
- experimenting code sharing

*Todo:
- [Desktop] use mouse to move the compass location
- [Desktop] test authoring tool? (my task might be overly complicated)
- Testharness UI
- Compass scaling when the window is scaled?
- Need some desktop <-> iOS conversion tools:
- Use NSTabViewDelegate to update the configuration pane
http://stackoverflow.com/questions/13443446/take-an-action-when-user-switches-tabs-on-an-nstabview
- sync from desktop to iOS

*Working:
-.kml and .snapshot generation
(assuming no rotation in tests)

I found there are two kml generation functions. One is called genKMLString, the other is called genSnapSthotString. This is confusing. 

-------------------------------------------------------------------
2.3.2015
-------------------------------------------------------------------
What do I want to achieve today?  

*Done:
- folder organization
-.kml and .snapshot generation
(assuming no rotation in tests)
- Pin display control 
* Display no pins for the tests
- TabView initialization

*Todo:
- The behavior of manual selection is a bit strange...

*Working:

-------------------------------------------------------------------
2.4.2015
-------------------------------------------------------------------
What do you want to do today?

*Done
- Fixing the manual selection bug [9:57AM]
- Think about the architecture of TestManager [11:32AM, half done]
- Did a lot of parameter tuning [1:24PM]
- Reload the configuration file
* loadParametersFromModelConfiguration
    self.renderer->loadParametersFromModelConfiguration();

    mdl_instance->configurationFileReadFlag = [NSNumber numberWithInt:1];
- Desktop compass should be moved to the lower left
- Keep the controls in the locations pane updated [4:53PM]
- Keep the controls in the configurations pane updated [5:25PM]

- Change the "Test Cases" pane to the "Study Log" pane [5:27PM]
- configure visualization type in snapshot generation (need to log the necessary information) [9:11PM]

*Todo
- Implement "Run Test"
- Snapshot loading is too slow on iOS
- Test authoring tool (manually add locations)
- Implement a StudyLog structure
- Implement iOS's TestManager (right now it only has a DemoManager)
- Design and implement package exchange (right now a dictionary is sent)
- Design what information needs to be passed around
* iOSViewController+Client
* MyWebSocket
* DesktopViewController+Server
- Mouse-click-to-move the compass
- compass_disk_radius is kept getting changed
- map zoom in/out, pan around
- desktop compass box in emiOS mode

*Working
- Display visualization and configure display type correctly

-------------------------------------------------------------------
2.4.2015
-------------------------------------------------------------------
*Done
- need to modify readLocationKml [3:01PM]
- There is a strange bug. I have to use load snapshot. (kmlComboBox bug?)
- Need to fix annotation control (when the mpa region is changed)
http://stackoverflow.com/questions/2100483/hide-show-annotation-on-mkmapview
- (void)changeAnnotationDisplayMode: (NSString*) mode
self.UIConfigurations[@"ShowPins"] [4:42PM]

*ToDO
- Snapshot loading is too slow on iOS
- Test authoring tool (manually add locations)
- Implement a StudyLog structure

- Design and implement package exchange (right now a dictionary is sent)

- Mouse-click-to-move the compass
- compass_disk_radius is kept getting changed
- map zoom in/out, pan around
- desktop compass box in emiOS mode

- Automatically calculate MapRect for the study
- Add annotation editing capability to the desktop map
- kml and snapshot dir needs to be refreshed after tab switch

*Working
- Display visualization and configure display type correctly
- Implement "Run Test"
- Implement iOS's TestManager (right now it only has a DemoManager)
- Fix the changing eiOS screen
- Communication module (Design what information needs to be passed around)
* iOSViewController+Client
* MyWebSocket
* DesktopViewController+Server

It is complicated to send messages from the server. 

Apply singleton and dependency injection in MyWebSocket.mm

Use the sendData method

- (void)sendData:(NSData *)msgData

-------------------------------------------------------------------
2.6.2015
-------------------------------------------------------------------
*Done
- where is compass_scale used? (removed all compass_scale)
- Removed glDrawingCorrectionRatio
- compass_radius (in pixel)
- need to clean up compassRender.mm, the code is ridiculous
- It is complicated to send messages from the server. 
Apply singleton and dependency injection in MyWebSocket.mm
Use the sendData method
- (void)sendData:(NSData *)msgData
- compass_centroid_radius (in pixel)
- compass_disk_radius is kept getting changed [5:08PM]
- Center iOS boundary after window is resized (when iOS sync is off) [8:22PM]

*ToDo
- Snapshot loading is too slow on iOS
- Test authoring tool (manually add locations)
- Implement a StudyLog structure
- Design and implement package exchange (right now a dictionary is sent)
- map zoom in/out, pan around
- desktop compass box in emiOS mode

- Automatically calculate MapRect for the study
- Add annotation editing capability to the desktop map
- kml and snapshot dir needs to be refreshed after tab switch
- The box indicator calculation is incorrect
- Mouse-click-to-move the compass

*Working
- Display visualization and configure display type correctly
- Implement "Run Test"
- Implement iOS's TestManager (right now it only has a DemoManager)
- Fix the changing eiOS screen

- Communication module (Design what information needs to be passed around)
* iOSViewController+Client
* MyWebSocket
* DesktopViewController+Server

- Sometimes a needle could become too thin
- iWath emulation

- watchMode, modify drawOneSide to cut off the legs

-------------------------------------------------------------------
2.7.2015
-------------------------------------------------------------------
*Done
- Mouse-click-to-move the compass [3:50PM]

*ToDo
- Snapshot loading is too slow on iOS
- Test authoring tool (manually add locations)
- Implement a StudyLog structure
- Design and implement package exchange (right now a dictionary is sent)
- map zoom in/out, pan around
- desktop compass box in emiOS mode

- Automatically calculate MapRect for the study
- Add annotation editing capability to the desktop map
- kml and snapshot dir needs to be refreshed after tab switch
- The box indicator calculation is incorrect


*Working
- Display visualization and configure display type correctly
- Implement "Run Test"
- Implement iOS's TestManager (right now it only has a DemoManager)
- Fix the changing eiOS screen

- Communication module (Design what information needs to be passed around)
* iOSViewController+Client
* MyWebSocket
* DesktopViewController+Server

- Sometimes a needle could become too thin
- iWath emulation
- watchMode, modify drawOneSide to cut off the legs
- display whitebackground (this should be easy)

- building an emulatediOS class

-------------------------------------------------------------------
2.8.2015
-------------------------------------------------------------------
*Done
- building an emulatediOS class

Perhaps I don't need iOSFourCornersInNSView at all
Clean up this:
    //-------------------
    // Displaying iOS box in OSX
    //-------------------
    bool isiOSBoxEnabled;
    // The four corners of the iOS display
    // (is NSView coordinates)
    CGPoint iOSFourCornersInNSView[4];
    
    bool isiOSMaskEnabled;

need to remove calculateiOSScreenSize
        self.rootViewController.renderer->emulatediOS.changeSizeByScale(scale);

iOSFourCornersInNSView [7:27PM]
- mouse-click-to-move emiOS [11:05PM]

*ToDo
- Snapshot loading is too slow on iOS
- Test authoring tool (manually add locations)
- Implement a StudyLog structure
- Design and implement package exchange (right now a dictionary is sent)
- map zoom in/out, pan around
- desktop compass box in emiOS mode

- Automatically calculate MapRect for the study
- Add annotation editing capability to the desktop map
- kml and snapshot dir needs to be refreshed after tab switch
- The box indicator calculation is incorrect


*Working
- Display visualization and configure display type correctly
- Implement "Run Test"
- Implement iOS's TestManager (right now it only has a DemoManager)
- Fix the changing eiOS screen

- Communication module (Design what information needs to be passed around)
* iOSViewController+Client
* MyWebSocket
* DesktopViewController+Server

- Sometimes a needle could become too thin
- iWath emulation
- watchMode, modify drawOneSide to cut off the legs
- display whitebackground (this should be easy)

-------------------------------------------------------------------
2.9.2015
-------------------------------------------------------------------
*Done
- label control 
- kml loading [9:35AM]
- Fix the changing eiOS screen

- Fixed a bug in user dropped pin
* CalloutViewController annotation editing control
* configureUserDroppedPinView seems have some issues [2:21PM]
- kml and snapshot dir needs to be refreshed after tab switch
- Add annotation editing capability to the desktop map[2:24PM]
- drawBoxInCompass needs to be modified 
- The box indicator calculation is incorrect [8:53PM]
- desktop compass box in emiOS mode
- Test authoring tool (manually add locations)

*ToDo
- Snapshot loading is too slow on iOS
- Implement a StudyLog structure
- Design and implement package exchange (right now a dictionary is sent)
- map zoom in/out, pan around

- Automatically calculate MapRect for the study

- Communication module (Design what information needs to be passed around)
* iOSViewController+Client
* MyWebSocket
* DesktopViewController+Server

- Lation square generation
- Compass needs to be updated in real time when it is moved 

*Working
- Display visualization and configure display type correctly
- Implement "Run Test"
- Implement iOS's TestManager (right now it only has a DemoManager)

- Sometimes a needle could become too thin
- iWath emulation
- watchMode, modify drawOneSide to cut off the legs
- display whitebackground (this should be easy)

-------------------------------------------------------------------
2.10.2015
-------------------------------------------------------------------
***** Done
- display whitebackground (this should be easy) [10:32PM]
- Load snapshots in study mode [11:07AM]
- Display visualization and configure display type correctly [12:20PM]
- cleaned: loadCentroidFromModelConfiguration, recVec [3:30PM]

***** ToDo
- Snapshot loading is too slow on iOS
- Implement a StudyLog structure
- Design and implement package exchange (right now a dictionary is sent)
- map zoom in/out, pan around

- Communication module (Design what information needs to be passed around)
* iOSViewController+Client
* MyWebSocket
* DesktopViewController+Server

- Lation square generation
- Compass needs to be updated in real time when it is moved 
- Naming conventions: .locations, .snapshot, .tests, etc. 
- Think about tests which involve multiple locations (I can sketch out some ideas)
- Outline the paper

- Automatically calculate MapRect for the study

***** Working
- Sometimes a needle could become too thin
- iWath emulation, watchMode, modify drawOneSide to cut off the legs

- Implement "Run Test"
- Implement iOS's TestManager (right now it only has a DemoManager)

-------------------------------------------------------------------
2.11.2015
-------------------------------------------------------------------
***** Done
- Implement iOS's TestManager (right now it only has a DemoManager) [11:23AM]
- Communication module (Design what information needs to be passed around)
* iOSViewController+Client 
* MyWebSocket [3:41PM]
* DesktopViewController+Server [4:32PM]
- Design and implement package exchange (right now a dictionary is sent)
- Implement "Run Test"

***** ToDo
- Snapshot loading is too slow on iOS
- Implement a StudyLog structure
- map zoom in/out, pan around

- Lation square generation
- Compass needs to be updated in real time when it is moved 

- Think about tests which involve multiple locations (I can sketch out some ideas)
- Outline the paper
- Automatically calculate MapRect for the study

***** Working
- Sometimes a needle could become too thin
- iWath emulation, watchMode, modify drawOneSide to cut off the legs
- Naming conventions: .locations, .snapshot, .tests, etc. 

- test authoring tool

Test authoring tool strategies:
- Use TestManager
- Grow location_dict
- Grow test_vector
- Generate snapshot, and store the snapshot into the snapshot vector

- need to improve the snapshot class [11:06PM]

maintain a type counter dictionary

-------------------------------------------------------------------
2.12.2015
-------------------------------------------------------------------
***** Done
- need to improve the snapshot class [9:56AM]
- building a home button [2:28PM]

***** ToDo
- Snapshot loading is too slow on iOS
- Implement a StudyLog structure
- map zoom in/out, pan around

- Lation square generation
- Compass needs to be updated in real time when it is moved 

- Think about tests which involve multiple locations (I can sketch out some ideas)
- Outline the paper
- Automatically calculate MapRect for the study

***** Working
- Sometimes a needle could become too thin
- iWath emulation, watchMode, modify drawOneSide to cut off the legs
- Naming conventions: .locations, .snapshot, .tests, etc. 

- Test Creator

Test authoring tool strategies (now on iOS):
- Use TestManager
- Grow location_dict
- Grow test_vector
- Generate snapshot, and store the snapshot into the snapshot vector

maintain a type counter dictionary
toggleWatchMask can be enhanced.
- fake it until you make it. [5:20PM]

-------------------------------------------------------------------
2.13.2015
-------------------------------------------------------------------
***** Done
- snapshot message should not accept touch-edit [8:42AM]
- integrate data selector with the location table [9:46AM]
- centralize .kml and .snapshot saving [10:47]
- when the study mode is off, landmark lock should be disabled [11:04AM]
- study snapshot detail -> crash [11:18AM]
- clea up self.model->lockLandmarks (use manual selection instead) [11:28AM]
- add home red box [11:58AM]
- retired updateMapDisplayRegion
use
[self.mapView setRegion:<#(MKCoordinateRegion)#> animated:<#(BOOL)#>]; instead. 
- somehow the compass thinks its center is located at the center of the screen
- compass needs an update after it is moved (inprecise) [2:52PM]
- Test authoring tool strategies (now on iOS):
- Use TestManager
- Grow location_dict
- Grow test_vector
- Generate snapshot, and store the snapshot into the snapshot vector
- Test Creator
- study counter is incorrect when jump to a study [5:33PM]
- Fixed the threading issue [9:30PM]. The call to handleMessage needs to be on the main thread

dispatch_async(dispatch_get_main_queue(),
               ^{

               });

***** ToDo
- Snapshot loading is too slow on iOS
- Implement a StudyLog structure
- map zoom in/out, pan around

- Lation square generation
- Compass needs to be updated in real time when it is moved 

- Think about tests which involve multiple locations (I can sketch out some ideas)
- Outline the paper
- Automatically calculate MapRect for the study

***** Working
- Sometimes a needle could become too thin
- iWath emulation, watchMode, modify drawOneSide to cut off the legs
- Naming conventions: .locations, .tests, .history, etc. 

maintain a type counter dictionary
toggleWatchMask can be enhanced.

- author drop-pin should be enabled
- ortho+wedge do not work
- loading studies is too slow

- implement task type counter
- work on the study experience
* need to set up the watch mode correctly
- renderAnnottions has issues
looks like I have some threading issues. 
dispatch_queue_t mainQueue = dispatch_get_main_queue();
dispatch_async(mainQueue,
               ^{
                   // Redraw the compass
                   // Update GUI components
                   [self updateOverviewMap];
                   [self.glkView setNeedsDisplay];
                   [self updateFindMeView];
               });
        
- iOS cannot receive NSData

-------------------------------------------------------------------
2.14.2015
-------------------------------------------------------------------
***** Done
- study mode on, location switch->crash bug [12:58PM] UIAlertView returns immediately
- work on the study experience (figured out a plane)

***** ToDo
- Snapshot loading is too slow on iOS (annotation and big list of locatinos are main reasons)
- Implement a StudyLog structure
- map zoom in/out, pan around

- Lation square generation
- Compass needs to be updated in real time when it is moved 

- Think about tests which involve multiple locations (I can sketch out some ideas)
- Outline the paper
- Automatically calculate MapRect for the study

***** Working
- Sometimes a needle could become too thin
- iWath emulation, watchMode, modify drawOneSide to cut off the legs
- Naming conventions: .locations, .tests, .history, etc. 

maintain a type counter dictionary
toggleWatchMask can be enhanced.

- author drop-pin should be enabled
- ortho+wedge do not work
- loading studies is too slow

- implement task type counter

* need to set up the watch mode correctly
- renderAnnottions has issues

- iOS cannot receive NSData


What needs to be done? Plane for tomorrow
- message passing:

types of message:
NONE, OK, BAD, NEXT

handlePackage (for the COLLECTOR, desktop)
START triggers the timer, drop-pin ends the timer, and then click the next

handleMessage (for the CONTROLLER, iOS)


initTestEnv
- whitebackground, etc. 
- allocate a vector of studyLog
- id, startTime, endTime, duration, truth, answer, error

showTestNumber
(bool)displaySnapshot: (int) snapshot_id withStudySettings: (testManagerMode) mode
mode: OFF, DEVICESTUDY, OSXSTUDY


annotation control, programmatically control the pins/labels, and destroy them. smarter annotation management. 


study presentation (especially on the OSXSTUDY machine)
calculate everything in mappoint, then convert the measurements to (lat, lon), and calculate latitudeDelta and longitudeDelta.


answers differ based on the types of tasks: LOCATE, LOCALIZE, LCOATE+, ORIENT
answer_id: when displaying annotatoions, if location_id == answer_id, don't show


answer reviewing:
TestManager: OFF, DEVICESTUDY, OSXSTUDY, REVIEW

-------------------------------------------------------------------
2.15.2015
-------------------------------------------------------------------
***** Done
TestManager: OFF, DEVICESTUDY, OSXSTUDY, REVIEW [11:25AM]
- iOS cannot receive NSData (implement handleMessage) [11:25AM]
types of message:
NONE, OK, BAD, NEXT
promote toggleBlankBackground to be a system methode [1:59PM]
initTestEnv
- whitebackground, etc. 
- allocate a vector of studyLog
- id, startTime, endTime, duration, truth, answer, error [9:07PM]
- handlePackage (for the COLLECTOR, desktop) [9:19PM]
- Think about tests which involve multiple locations (I can sketch out some ideas)

***** ToDo
- Snapshot loading is too slow on iOS (annotation and big list of locatinos are main reasons)
- Implement a StudyLog structure
- map zoom in/out, pan around

- Lation square generation
- Compass needs to be updated in real time when it is moved 

- Outline the paper
- Automatically calculate MapRect for the study

- Naming conventions: .locations, .tests, .history, etc. 

***** Working
- Sometimes a needle could become too thin
- iWath emulation, watchMode, modify drawOneSide to cut off the legs

maintain a type counter dictionary
toggleWatchMask can be enhanced.

- loading studies is too slow

- ortho+wedge do not work

- implement task type counter
* need to set up the watch mode correctly
- renderAnnottions has issues

- message passing:
START triggers the timer, drop-pin ends the timer, and then click the next

showTestNumber
(bool)displaySnapshot: (int) snapshot_id withStudySettings: (testManagerMode) mode
mode: OFF, DEVICESTUDY, OSXSTUDY

annotation control, programmatically control the pins/labels, and destroy them. smarter annotation management. think about the case that multiple annotations need to be displayed simultaneously.

answers differ based on the types of tasks: LOCATE, LOCALIZE, LCOATE+, ORIENT
answer_id: when displaying annotatoions, if location_id == answer_id, don't show

answer reviewing:

-------------------------------------------------------------------
2.16.2015
-------------------------------------------------------------------
***** Done
desktop need to shut this off
self.socket_status = [NSNumber numberWithBool:YES]; [10:24AM]

drop-pin
- testManagerMode == DEVICESTUDY and __IPHONE__, drop pin disabled
- testManagerMode = AUTHORING, all drop-pins should be enabled
- testManagerMode = OSXSTUDY, log the time, the answer, and send the NEXT message
- receving the START message triggers the timer
@"UIAcceptsPinCreation" [12:13PM]
- Snapshot loading is too slow on iOS (annotation and big list of locatinos are main reasons)
- loading studies is too slow [4:23PM] (need to use isEqualToString)
- Implement a StudyLog structure [4:23PM]

***** ToDo
- map zoom in/out, pan around

- Lation square generation
- Compass needs to be updated in real time when it is moved 

- Outline the paper
- Automatically calculate MapRect for the study

- Naming conventions: .locations, .tests, .history, etc. 

***** Working
- Sometimes a needle could become too thin
- iWath emulation, watchMode, modify drawOneSide to cut off the legs

maintain a type counter dictionary
toggleWatchMask can be enhanced.

- ortho+wedge do not work

- implement task type counter
* need to set up the watch mode correctly
- renderAnnottions has issues

- message passing:
START triggers the timer, drop-pin ends the timer, and then click the next

showTestNumber
(bool)displaySnapshot: (int) snapshot_id withStudySettings: (testManagerMode) mode
mode: OFF, DEVICESTUDY, OSXSTUDY

annotation control, programmatically control the pins/labels, and destroy them. smarter annotation management. think about the case that multiple annotations need to be displayed simultaneously.

answers differ based on the types of tasks: LOCATE, LOCALIZE, LCOATE+, ORIENT
answer_id: when displaying annotatoions, if location_id == answer_id, don't show

review the study


test presentation
showTestNumber
(bool)displaySnapshot: (int) snapshot_id withStudySettings: (testManagerMode) mode
mode: OFF, DEVICESTUDY, OSXSTUDY, REVIEW

refactor to display watch, and others

- showTestNumber
* showLocateTest(TestManagerMode mode)
* showLocalizeTest(TestManagerMode mode)
* showLocatePlusTest(TestManagerMode mode)
* showOrientTest(TestManagerMode mode)


test authoring
- calculateMultipleLocationsDisplayRegion (on the desktop)
study presentation (especially on the OSXSTUDY machine)
calculate everything in mappoint, then convert the measurements to (lat, lon), and calculate latitudeDelta and longitudeDelta.
- implement task type counter, integrate the test code with the counter

test generation
- latin sq. generation
- generate LOCALIZE and LOCATE+ tests

annotation control
- renderAnnotationsIDs (vector<int> id_list, bool labelFlag)


-------------------------------------------------------------------
2.17.2015
-------------------------------------------------------------------
***** Done
- moved enableMapInteraction to the class level [10:27AM]
- showTestNumber
- (bool)displaySnapshot: (int) snapshot_id withStudySettings: (testManagerMode) mode
mode: OFF, DEVICESTUDY, OSXSTUDY [10:30AM]
- toggleWatchMask can be enhanced.
- calculateMultipleLocationsDisplayRegion (on the desktop)
study presentation (especially on the OSXSTUDY machine)
calculate everything in mappoint, then convert the measurements to (lat, lon), and calculate latitudeDelta and longitudeDelta. [9:49PM]
* showLocateTest(TestManagerMode mode)
* showLocalizeTest(TestManagerMode mode) [9:49PM]

***** ToDo
- map zoom in/out, pan around

- Lation square generation
- Compass needs to be updated in real time when it is moved 

- Outline the paper
- Automatically calculate MapRect for the study

- Naming conventions: .locations, .tests, .history, etc. 

- annotation control
- renderAnnotationsIDs (vector<int> id_list, bool labelFlag)

***** Working
- Sometimes a needle could become too thin
- iWath emulation, watchMode, modify drawOneSide to cut off the legs

maintain a type counter dictionary

* need to set up the watch mode correctly
- renderAnnottions has issues

- message passing:
START triggers the timer, drop-pin ends the timer, and then click the next

annotation control, programmatically control the pins/labels, and destroy them. smarter annotation management. think about the case that multiple annotations need to be displayed simultaneously.

answers differ based on the types of tasks: LOCATE, LOCALIZE, LCOATE+, ORIENT
answer_id: when displaying annotatoions, if location_id == answer_id, don't show

review the study

refactor to display watch, and others

- showTestNumber
* showLocatePlusTest(TestManagerMode mode)
* showOrientTest(TestManagerMode mode)

test authoring
- implement task type counter, integrate the test code with the counter

test generation
- latin sq. generation
- generate LOCALIZE and LOCATE+ tests

- ortho+watch do not work

circle overlay
http://stackoverflow.com/questions/9056451/draw-a-circle-of-1000m-radius-around-users-location-in-mkmapview

- lock rotation in the author mode?


-------------------------------------------------------------------
2.18.2015
-------------------------------------------------------------------
***** Done
- add system level displayPopupMessage [11:45AM]
- Top priority:
START triggers the timer, drop-pin ends the timer, and then click the next
Generate a test record [2:27PM]
- minimal needle size constraints [3:12PM]
- data clustering control [4:00PM] fixed the REAL_RATIO mode
- add a pin mode called @"Study" [4:46PM]
- render the locate tests at the right scale [5:28PM]

***** ToDo
- map zoom in/out, pan around

- Lation square generation
- Compass needs to be updated in real time when it is moved 

- Outline the paper
- Automatically calculate MapRect for the study

- Naming conventions: .locations, .tests, .history, etc. 

- annotation control
- renderAnnotationsIDs (vector<int> id_list, bool labelFlag)

Medium effort:
- iWath emulation, watchMode, modify drawOneSide to cut off the legs
* need to set up the watch mode correctly
- renderAnnottions has issues
- ortho+watch do not work

High effort:
test generation
- latin sq. generation
- generate LOCALIZE and LOCATE+ tests

answers differ based on the types of tasks: LOCATE, LOCALIZE, LCOATE+, ORIENT
answer_id: when displaying annotatoions, if location_id == answer_id, don't show

Long term:
- showTestNumber
* showLocatePlusTest(TestManagerMode mode)
* showOrientTest(TestManagerMode mode)

***** Working

Quick fixes:

- implement and maintain a type counter dictionary, added to the authoring pane, integrate the test code with the counter
- review the study
- lock rotation in the author mode?
- circle overlay
http://stackoverflow.com/questions/9056451/draw-a-circle-of-1000m-radius-around-users-location-in-mkmapview

- annotation control, programmatically control the pins/labels, and destroy them. smarter annotation management. think about the case that multiple annotations need to be displayed simultaneously.

-------------------------------------------------------------------
2.19.2015
-------------------------------------------------------------------
***** Done
wedge is bigger than the box? 
* because there is a min_base length in Wedge+Ortho.mm
* self.model->configurations[@"wedge_correction_x"] needs to be adjusted based on device
compass scale box is wrong
* because the update function did not update compass's (lab, lon) [11:48AM]
- Generate locate tests for the watch [12:19PM]
- iWath emulation, watchMode,
- Compass needs to be updated in real time when it is moved [12:30PM]
- Automatically calculate MapRect for the study [12:30AM]

***** ToDo
- map zoom in/out, pan around

- Outline the paper
- Naming conventions: .locations, .tests, .history, etc. 

- annotation control
- renderAnnotationsIDs (vector<int> id_list, bool labelFlag)

- circle overlay
http://stackoverflow.com/questions/9056451/draw-a-circle-of-1000m-radius-around-users-location-in-mkmapview

Medium effort:
- modify drawOneSide to cut off the legs
* need to set up the watch mode correctly
- renderAnnottions has issues
- ortho+watch do not work

answers differ based on the types of tasks: LOCATE, LOCALIZE, LCOATE+, ORIENT
answer_id: when displaying annotatoions, if location_id == answer_id, don't show
TestManager: need an answer conversion (from mouseLoc to the true answer)

Long term:
- showTestNumber
* showLocatePlusTest(TestManagerMode mode)
* showOrientTest(TestManagerMode mode)

***** Working
Quick fixes:
- implement and maintain a type counter dictionary, added to the authoring pane, integrate the test code with the counter
- review the study
- lock rotation in the author mode?

- annotation control, programmatically control the pins/labels, and destroy them. smarter annotation management. think about the case that multiple annotations need to be displayed simultaneously.

High effort:
Test Generation (making new levels for the game):
- latin square generation 
- alternatively, I can implement shuffle
- generate LOCALIZE and LOCATE+ tests

working on generateRandomTriangulateLocations 

- estimate the distance (in terms of integer multiple)
- get the ios beta testing work

- issues that need to be fixed:
* scaleCoordinateSpanForDevice, the base needs to use the information stored in snapShot

* calculateLatLonFromiOSX: should be test dependent
* check location generation
- iOS dropbox folder support?
- bugs here:
    self.rootViewController.testManager->
            calculateMultipleLocationsDisplayRegion();

-------------------------------------------------------------------
2.20.2015
-------------------------------------------------------------------
***** Done
- working on generateRandomTriangulateLocations [10:55AM]
* scaleCoordinateSpanForDevice, the base needs to use the information stored in snapShot
* need to perform double divison [10:55AM]
- different task should have different location list [4:56PM]
- generate LOCALIZE [5:03PM]
- orientation task generation [9:37PM]

***** ToDo
- map zoom in/out, pan around

- Outline the paper
- Naming conventions: .locations, .tests, .history, etc. 

- annotation control
- renderAnnotationsIDs (vector<int> id_list, bool labelFlag)

- circle overlay
http://stackoverflow.com/questions/9056451/draw-a-circle-of-1000m-radius-around-users-location-in-mkmapview

Medium effort:
- modify drawOneSide to cut off the legs
* need to set up the watch mode correctly
- renderAnnottions has issues
- ortho+watch do not work

answers differ based on the types of tasks: LOCATE, LOCALIZE, LCOATE+, ORIENT
answer_id: when displaying annotatoions, if location_id == answer_id, don't show
TestManager: need an answer conversion (from mouseLoc to the true answer)

Long term:
- showTestNumber
* showLocatePlusTest(TestManagerMode mode)
* showOrientTest(TestManagerMode mode)

- iOS dropbox folder support?

Quick fixes:
- implement and maintain a type counter dictionary, added to the authoring pane, integrate the test code with the counter
- review the study
- lock rotation in the author mode?

- annotation control, programmatically control the pins/labels, and destroy them. smarter annotation management. think about the case that multiple annotations need to be displayed simultaneously.

High effort:
Test Generation (making new levels for the game):
- latin square generation 
- alternatively, I can implement shuffle
- LOCATE+ tests


- estimate the distance (in terms of integer multiple)
- get the ios beta testing work

- issues that need to be fixed:
* calculateLatLonFromiOSX: should be test dependent
* enhance location generation

- bugs here:
    self.rootViewController.testManager->
            calculateMultipleLocationsDisplayRegion();

***** Working
- answer logging
- answer review mode

-------------------------------------------------------------------
2.21.2015
-------------------------------------------------------------------
***** Done
- added compass rotation in study toolbar
- answer logging [12:15PM]

***** ToDo
- map zoom in/out, pan around

- Outline the paper
- Naming conventions: .locations, .tests, .history, etc. 

- annotation control
- renderAnnotationsIDs (vector<int> id_list, bool labelFlag)

- circle overlay
http://stackoverflow.com/questions/9056451/draw-a-circle-of-1000m-radius-around-users-location-in-mkmapview

Medium effort:
- modify drawOneSide to cut off the legs
* need to set up the watch mode correctly
- renderAnnottions has issues
- ortho+watch do not work

answers differ based on the types of tasks: LOCATE, LOCALIZE, LCOATE+, ORIENT
answer_id: when displaying annotatoions, if location_id == answer_id, don't show
TestManager: need an answer conversion (from mouseLoc to the true answer)

Long term:
- showTestNumber
* showLocatePlusTest(TestManagerMode mode)
* showOrientTest(TestManagerMode mode)

- iOS dropbox folder support?

Quick fixes:
- implement and maintain a type counter dictionary, added to the authoring pane, integrate the test code with the counter
- review the study
- lock rotation in the author mode?

- annotation control, programmatically control the pins/labels, and destroy them. smarter annotation management. think about the case that multiple annotations need to be displayed simultaneously.

High effort:
Test Generation (making new levels for the game):
- latin square generation 
- alternatively, I can implement shuffle
- LOCATE+ tests


- estimate the distance (in terms of integer multiple)
- get the ios beta testing work

- issues that need to be fixed:
* calculateLatLonFromiOSX: should be test dependent
* enhance location generation

- bugs here:
    self.rootViewController.testManager->
            calculateMultipleLocationsDisplayRegion();

***** Working
- answer review mode








