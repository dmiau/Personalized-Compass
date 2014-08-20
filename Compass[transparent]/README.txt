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













