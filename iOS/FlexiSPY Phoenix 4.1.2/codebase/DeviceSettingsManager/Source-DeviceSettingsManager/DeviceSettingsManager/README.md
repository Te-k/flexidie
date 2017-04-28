NetworkInformation
==================
An Objective-C library for iOS to pull informations of network interfaces of a device. Gist: https://gist.github.com/662203

Build Notice
============
This library does not support ARC for now. You need to put `-fno-obc-arc` compiler frag to NetworkInformation.m to compile. For more information about `-fno-obc-arc`, refer http://stackoverflow.com/questions/6646052/how-can-i-disable-arc-for-a-single-file-in-a-project.

iOS 7 Notice
============
As of iOS 7, developers cannot lookup MAC address of any network interfaces in their applications. iOS always returns `02:00:00:00:00:00` for MAC address. For more information, refer https://developer.apple.com/news/?id=8222013a.

License
=======
This library is licensed under the MIT license.
