
===== The following items is Vervata's releasing check list by Yut =====

1. Make sure product ID is correct. Product Id in test server and production server may be different.
2. Make sure the client points to the right server.  Test and production server URL is different.
3. When building a release candidate, make sure either major or minor number is changed, always discuss this with me or Dominique if I’m not available.
     We must never release any build which major.minor number are the same with the current production version.


===== Release Guideline =====

For Testing: 	Obfuscate = Disable, RuntimeLog = ON,  LogLevel = Verbose (optional)
For Production: Obfuscate = Enable,  RuntimeLog = OFF, LogLevel = Debug


===== Step-By-Step For Production Release =====

1. Turn OFF debugging logs:-
    - Each components should have their own Customization class, which contain the flag to enable/disable its debugging logs.
    - JNI source code
    - Disable showRuntimeLog in com.vvt.logger.Logger 
    
2. Check obfuscate options in each components and in application-main
    - Normally, each component will share the same ANT properties files here: "_build/common.properties".
    - For the APK project, enable obfuscate in "project.properties"
    	- by removing comment from this line "proguard.config=proguard.cfg".
    
3. Select editions you're going to build in: "_build/build.xml".


=== After building complete ===

- Commit code to SVN and Tag


===== TO CREATE MOCK PACKAGE NAME =====

- Define package name in build script "build.xml"
    
    