LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE    := fxril
LOCAL_SRC_FILES := fxril.c
LOCAL_LDLIBS    := -llog
include $(BUILD_SHARED_LIBRARY)
