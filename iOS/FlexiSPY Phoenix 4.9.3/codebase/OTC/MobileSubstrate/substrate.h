#ifndef SUBSTRATE_H_
#define SUBSTRATE_H_

#ifdef __cplusplus
extern "C" {
#endif
    #include <mach-o/nlist.h>
#ifdef __cplusplus
}
#endif

#include <objc/runtime.h>
//#include <objc/message.h>
#include <dlfcn.h>

#ifdef __cplusplus
#define _default(value) = value
#else
#define _default(value)
#endif

#ifdef __cplusplus
extern "C" {
#endif

void MSHookFunction(void *symbol, void *replace, void **result);
IMP MSHookMessage(Class _class, SEL sel, IMP imp, const char *prefix _default(NULL));

#ifdef __cplusplus
}
#endif

#ifdef __cplusplus

template <typename Type_>
static inline Type_ *MSHookMessage(Class _class, SEL sel, Type_ *imp, const char *prefix = NULL) {
    return reinterpret_cast<Type_ *>(MSHookMessage(_class, sel, reinterpret_cast<IMP>(imp), prefix));
}

template <typename Type_>
static inline void MSHookFunction(Type_ *symbol, Type_ *replace, Type_ **result) {
    return MSHookFunction(
        reinterpret_cast<void *>(symbol),
        reinterpret_cast<void *>(replace),
        reinterpret_cast<void **>(result)
    );
}

template <typename Type_>
static inline void MSHookFunction(Type_ *symbol, Type_ *replace) {
    return MSHookFunction(symbol, replace, reinterpret_cast<Type_ **>(NULL));
}

template <typename Type_>
static inline void MSHookSymbol(Type_ *&value, const char *name, void *handle) {
    value = reinterpret_cast<Type_ *>(dlsym(handle, name));
}

template <typename Type_>
static inline Type_ &MSHookIvar(id self, const char *name) {
    Ivar ivar(class_getInstanceVariable(object_getClass(self), name));
    void *pointer(ivar == NULL ? NULL : reinterpret_cast<char *>(self) + ivar_getOffset(ivar));
    return *reinterpret_cast<Type_ *>(pointer);
}

#endif

#define MSHook(type, name, args...) \
    static type (*_ ## name)(args); \
    static type $ ## name(args) \

#define Foundation_f "/System/Library/Frameworks/Foundation.framework/Foundation"
#define UIKit_f "/System/Library/Frameworks/UIKit.framework/UIKit"
#define JavaScriptCore_f "/System/Library/PrivateFrameworks/JavaScriptCore.framework/JavaScriptCore"
#define IOKit_f "/System/Library/Frameworks/IOKit.framework/IOKit"

#endif//SUBSTRATE_H_