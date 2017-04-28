LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE:= fxexec
LOCAL_SRC_FILES:= fxexec.cpp
LOCAL_LDLIBS := -ldl -llog
include $(BUILD_SHARED_LIBRARY)