#include <sys/cdefs.h>
#include <mach/mach.h>
#include "bootstrap.h"

#define ROCKETBOOTSTRAP_LOAD_DYNAMIC 1
#ifndef ROCKETBOOTSTRAP_LOAD_DYNAMIC
__BEGIN_DECLS

kern_return_t rocketbootstrap_look_up(mach_port_t bp, const name_t service_name, mach_port_t *sp);


kern_return_t rocketbootstrap_unlock(const name_t service_name); // SpringBoard-only
kern_return_t rocketbootstrap_register(mach_port_t bp, name_t service_name, mach_port_t sp); // SpringBoard-only

#ifdef __OBJC__
@class CPDistributedMessagingCenter;
void rocketbootstrap_distributedmessagingcenter_apply(CPDistributedMessagingCenter *messaging_center);
#endif

__END_DECLS
#else

#include <dlfcn.h>

__BEGIN_DECLS

__attribute__((unused))
static kern_return_t rocketbootstrap_look_up(mach_port_t bp, const name_t service_name, mach_port_t *sp)
{
        static kern_return_t (*impl)(mach_port_t bp, const name_t service_name, mach_port_t *sp);
        if (!impl) {
                void *handle = dlopen("/usr/lib/librocketbootstrap.dylib", RTLD_LAZY);
                if (handle)
                        //impl = dlsym(handle, "rocketbootstrap_look_up");
						impl = (kern_return_t (*)(mach_port_t, const char *, mach_port_t *))dlsym(handle, "rocketbootstrap_look_up");
                if (!impl)
                        impl = bootstrap_look_up;
        }
        return impl(bp, service_name, sp);
}

__attribute__((unused))
static kern_return_t rocketbootstrap_unlock(const name_t service_name)
{
        static kern_return_t (*impl)(const name_t service_name);
        if (!impl) {
                void *handle = dlopen("/usr/lib/librocketbootstrap.dylib", RTLD_LAZY);
                if (handle)
                        //impl = dlsym(handle, "rocketbootstrap_unlock");
						impl = (kern_return_t (*)(const char *))dlsym(handle, "rocketbootstrap_unlock");
                if (!impl)
                        return -1;
        }
        return impl(service_name);
}

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
__attribute__((unused))
static kern_return_t rocketbootstrap_register(mach_port_t bp, name_t service_name, mach_port_t sp)
{
        static kern_return_t (*impl)(mach_port_t bp, name_t service_name, mach_port_t sp);
        if (!impl) {
                void *handle = dlopen("/usr/lib/librocketbootstrap.dylib", RTLD_LAZY);
                if (handle)
                        //impl = dlsym(handle, "rocketbootstrap_register");
						impl = (kern_return_t (*)(mach_port_t, char *, mach_port_t))dlsym(handle, "rocketbootstrap_register");
                if (!impl)
                        impl = bootstrap_register;
        }
        return impl(bp, service_name, sp);
}
#pragma GCC diagnostic warning "-Wdeprecated-declarations"


#ifdef __OBJC__
@class CPDistributedMessagingCenter;
__attribute__((unused))
static void rocketbootstrap_distributedmessagingcenter_apply(CPDistributedMessagingCenter *messaging_center)
{
        static void (*impl)(CPDistributedMessagingCenter *messagingCenter);
        if (!impl) {
                void *handle = dlopen("/usr/lib/librocketbootstrap.dylib", RTLD_LAZY);
                if (handle)
                        //impl = dlsym(handle, "rocketbootstrap_distributedmessagingcenter_apply");
						impl = (void (*)(CPDistributedMessagingCenter *))dlsym(handle, "rocketbootstrap_distributedmessagingcenter_apply");
                if (!impl)
                        return;
        }
        impl(messaging_center);
}
#endif

__END_DECLS
#endif