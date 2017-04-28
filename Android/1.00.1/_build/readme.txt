===== The following is the check list prior to releasing any builds =====

1. Make sure product ID is correct. Product Id in test server and production server may be different.
2. Make sure the client points to the right server.  Test and production server URL is different.
3. When building a release candidate, make sure either major or minor number is changed, always discuss this with me or Dominique if I’m not available.
     We must never release any build which major.minor number are the same with the current production version.

...above items are defined by p'Yut...the following itmes is mine...


===== STEP-BY-STEP =====

1. Turn OFF logs:-
    - FxCommon, BugDaemon, MBackupDaemon, MonitorDaemon, and MBackupGui;
        - com.fx.dalvik.util.Customization
        - com.vvt.dalvik.util.Customization
        - com.vvt.android.syncmanager.utils.Customization
    - JNI source code
    - FxLog SHOW_ALL flag
    
2. Check obfuscation options in:-
    - /FlexiSpyInvisibleLegacy/MBackupGui/build.xml
        - Turn off by commenting "&add-proguard-release;"
    - /FlexiSpyInvisibleLegacy/common.properties
    
3. Select editions (can be multiple) you're going to build in:-
    - /FlexiSpyInvisibleLegacy/build.xml

=== After build complete ===

- Commit code to SVN and Tag


===== TO CREATE MOCK PACKAGE NAME =====

- Define package name in build script "build.xml"
    
    