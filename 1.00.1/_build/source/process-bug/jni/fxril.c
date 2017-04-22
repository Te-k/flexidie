#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <errno.h>
#include <jni.h>
#include <android/log.h>

#define LOG(...) ((void)__android_log_print(ANDROID_LOG_INFO, "Ril", __VA_ARGS__))

int main() {}

jint Java_com_vvt_callmanager_Ril_setupServer(JNIEnv* env, jobject thiz)
{
	// LOG("setupServer # ENTER ...");
	char* socket_name = "/dev/socket/rild";
	struct sockaddr_un name;
	
	/* Create the socket. */
	int socket_fd = socket (AF_LOCAL, SOCK_STREAM, 0);
	// LOG("setupServer # socket '%s', fd: %d", socket_name, socket_fd);
	
	/* Indicate that this is a server. */
	name.sun_family = AF_LOCAL;
	strcpy (name.sun_path, socket_name);
	
	/* Bind socket */
	int result = bind (socket_fd, (struct sockaddr *) &name, sizeof(struct sockaddr_un));
	if (result != 0)
	{
		// LOG("setupServer # Binding failed!! - %s", strerror(errno));
		return;
	}
	
	// LOG("setupServer # EXIT ...");
	return socket_fd;
}
