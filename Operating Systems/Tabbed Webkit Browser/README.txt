/* CSci4061 S2010 Assignment 2
* section: 5
* login: marsh413
* date: 03/12/10
* name: Philip Babcock, Harlan Iverson, Ben Marshall
* id:   3334517         3476594         3567208 
*/


Building:

In the src directory, run 'make'. to run, type 'multi-pro-web-browser'.

Build west tested on the ITLabs machines 'computer', 'blender', 'clock', and
'lamp'. Please ensure that the 'soft/webkit' module is installed. 

% uname -a
Linux computer 2.6.28-18-generic #59-Ubuntu SMP Thu Jan 28 01:40:19 UTC 2010 x86_64 GNU/Linux

% module list
Currently Loaded Modulefiles:
 1) soft/gcc/4.2             11) openwin                  
 2) java/jdk-1.6.0_14        12) modules                  
 3) perl/5.8.7               13) Frame/5.5                
 4) gnu                      14) math/mathematica/6.0     
 5) local                    15) scheme/mit               
 6) compilers/compilers      16) user                     
 7) system                   17) dot                      
 8) x11/R6.3                 18) mozilla/firefox/2.0.0.11 
 9) java/eclipse/3.3         19) soft/openoffice/3.0.1    
10) soft/webkit/1.1.15.4     20) soft/gimp/v.2.0.4        

Purpose:
The purpose of this program is to run a multi-process web-browser like Google Chrome.

How it works:
From browser.c, the router_process function in router.c is called.  This
function calls allocate_comm_channel (comm_channel.c), which creates two pipes
from the router to the router's next child (which will be the controller) for
bi-directional communication.  In comm_channel.c, we made a (static) array of
comm_channels in order to keep track of how many bi-directional pipes have been
opened (max of 10).  This first comm_channel gets the ccid (array index) of 0.

Next, router_process creates a tab index (0) for the controller, and calls
fork() to finally create the controller.  controller_process (controller.c) is
then called, which displays the controller window.  From then on, the router
handles communications in a loop.  Since we made our own commmunication channel
structure, the poll() function is not used for this (more explanation in code
comments).  Instead, the router iterates through our comm_channel array,
checking for pipes containing messages.  When one is found, the message in the
pipe is read and is handled based on its type.

If the message says that the user has created a new tab, then a new comm_channel
and tab index are allocated for that tab.  fork() is called again, and the newly
created child process calls urlrenderer_process (urlrenderer.c), which creates
the new tab (using no callbacks).  The parent process sets up a new
browser_window struct to prepare for when new actions are taken with the new
tab.

If the message (from the controller) says that the user has entered a URL with a
valid tab index (and hit enter in the URL field of the browser), the message
gets forwarded to url_renderer_process, which is now handling communications for
this specific tab in a loop.  url_renderer_process then renders the web page at
this URL in this browser.

If the message is that a tab window has been closed, the message is sent to
url_renderer_process (which is still handling messages for that tab), which
processes any remaining gtk events, and then terminates.  The comm_channel and
tab index for the closed tab are then freed from memory.

Once router_process completes one run-through of the comm_channel array, it
checks if it has any dead child processes, and reaps them if found.  It then
iterates through the comm_channels again, continuing the loop.

controller_process is terminated once the user closes all browser windows
including the main window (tab 0).  router_process will notice this when it
discovers that it has no more children processes while in the function
router_reap_children().  The router will then terminate, which terminates the
entire program since it is the only remaining process.

The outline of program structure:

main
  router_process
    router_create_controller
      ++ fork controller_process
        create_browser
        show_browser
    router_handle_comm
      router_handle_message
        msg.type = CREATE_TAB
          ++ fork urlrenderer_process
            create_browser
            urlrenderer_handle_comm
              msg.type = NEW_URI_ENTERED
                call given render function
              msg.type = TAB_KILLED
                handle remaining GTK events
                end process
        msg.type = NEW_URI_ENTERED
          check valid tab
          repeat message to URL-RENDERER
        msg.type = TAB_KILLED
          repeat message to CONTROLLER/URL-RENDERER
    router_reap_children
      errno = ECHILD
        all children are dead - exit

NOTE: each _process has en event loop, so all sub-tasks are done repeatedly 
except for router_create_controller.

Error handling:
We check for errors by evaluating the return result of most functions (having the
value -1 if an error occured) and print an appropriate message based on the resulting
error by use of our info() function.  info() also prints the pid of the process
that generated the error.

Assumptions:
We assume that the user knows the basics of using a web browser.
We assume that our browser doesn't have to cover errors that the sample browser
didn't.  For example, the sample browser errors out if more than 10 tabs
(including the main browser window) are opened.
We assumed the wrapper code worked.
