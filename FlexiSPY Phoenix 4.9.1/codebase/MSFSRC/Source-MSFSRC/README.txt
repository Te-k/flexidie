1. Requirements
- Mac OS X 10.9 or higher
- Xcode 6 or higher
- Xcode command line tools installed
- A jailbroken iOS device, iOS 7+, installed OpenSSH Server
- dpkg (install from macports)

2. How to build
- run build.sh to build deb file

3. Source code Information:
- Tweak.xm: this is main file, enabled voip calls and phone calls
- PCMMixer: mix recorded pcm files

#define SKYPE_RECORDING 1 // Enable VoIP call recording on Skype
#define VIBER_RECORDING 1 // Enable VoIP call recording on Viber
#define WHATSAPP_RECORDING 1 // Enable VoIP call recording on WhatsApp
#define PHONE_CALL_RECORDING 1 // Enable voice phone call recording

4. Output
- All recorded sound files will be in folder /var/tmp/Tracer/ on iOS device