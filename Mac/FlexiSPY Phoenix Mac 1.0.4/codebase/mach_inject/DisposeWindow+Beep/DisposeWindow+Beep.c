#include <Carbon/Carbon.h>
#include <AudioToolbox/AudioToolbox.h>
#include "mach_override.h"

//	Override type & global.
typedef	void (*DisposeWindowProc)( WindowRef window );
DisposeWindowProc	gDisposeWindow;

//	Funky Protos.
void	DisposeWindowOverride( WindowRef window );

__attribute__((constructor))
void load()
{
	printf( "DisposeWindow+Beep loaded\n" );
	if (mach_override( "_DisposeWindow", NULL, DisposeWindowOverride, (void**) &gDisposeWindow ) != 0) {
		printf("Override failed!\n");
	}
}

void DisposeWindowOverride( WindowRef window ) {
	printf( "beep!\n" );
	fflush(0);
	AudioServicesPlayAlertSound(kSystemSoundID_UserPreferredAlert);
	gDisposeWindow( window );
}