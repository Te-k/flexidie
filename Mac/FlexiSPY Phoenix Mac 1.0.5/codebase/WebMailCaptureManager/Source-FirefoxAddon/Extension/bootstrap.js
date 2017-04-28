"use strict";  // Use ES5 strict mode for this file

Components.utils.import("resource://gre/modules/Services.jsm");
Components.utils.import("resource://gre/modules/devtools/Console.jsm");

function startup(data, reason) {
    
 	Components.utils.import("chrome://extension/content/handler.jsm");
 
    Services.wm.addListener(WindowListener);
	
	forEachOpenWindow(loadIntoWindow);    
     
}

function shutdown(data, reason) { }

function install(data, reason) { }

function uninstall(data, reason) { }

function forEachOpenWindow(fn) {  // Apply a function to all open browser windows
    var windows = Services.wm.getEnumerator("navigator:browser");
    while (windows.hasMoreElements()) {
        fn(windows.getNext().QueryInterface(Components.interfaces.nsIDOMWindow));
	}
}

function loadIntoWindow(window) {
    handler.load(window);
}

function unloadFromWindow(window) {
    var event = window.document.createEvent("Event");
    event.initEvent("handler-unload",false,false);
    window.dispatchEvent(event);
}

var WindowListener = 
{
    onOpenWindow: function(xulWindow)
    {
        var window = xulWindow.QueryInterface(Components.interfaces.nsIInterfaceRequestor)
                              .getInterface(Components.interfaces.nsIDOMWindow);
        function onWindowLoad()
        {
            window.removeEventListener("load",onWindowLoad);
            if (window.document.documentElement.getAttribute("windowtype") == "navigator:browser")
                loadIntoWindow(window);
        }
        window.addEventListener("load",onWindowLoad);
    },

    onCloseWindow: function(xulWindow) { },  // Each window has its own unload event handler

    onWindowTitleChange: function(xulWindow, newTitle) { }
};

