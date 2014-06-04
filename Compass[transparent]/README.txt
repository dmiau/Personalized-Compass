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






