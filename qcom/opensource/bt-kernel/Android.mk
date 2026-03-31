# Android makefile for BT kernel modules

LOCAL_PATH := $(call my-dir)

# Build/Package only in case of supported target
ifeq ($(call is-board-platform-in-list,taro kalama pineapple msmnile sm6150 gen4 gen5), true)

BT_SELECT := CONFIG_MSM_BT_POWER=m
LOCAL_PATH := $(call my-dir)
LOCAL_MODULE_DDK_BUILD := true
LOCAL_MODULE_DDK_ALLOW_UNSAFE_HEADERS := true
LOCAL_MODULE_KO_DIRS := btpower.ko
#LOCAL_MODULE_KO_DIRS += slimbus/bt_fm_slim.ko
#LOCAL_MODULE_KO_DIRS += rtc6226/radio-i2c-rtc6226-qca.ko


# This makefile is only for DLKM
ifneq ($(findstring vendor,$(LOCAL_PATH)),)

ifneq ($(findstring opensource,$(LOCAL_PATH)),)
	BT_BLD_DIR := $(abspath .)/vendor/qcom/opensource/bt-kernel
endif # opensource

DLKM_DIR := $(TOP)/device/qcom/common/dlkm


###########################################################
# This is set once per LOCAL_PATH, not per (kernel) module
KBUILD_OPTIONS := BT_KERNEL_ROOT=$(BT_BLD_DIR)
KBUILD_OPTIONS += $(foreach bt_select, \
       $(BT_SELECT), \
       $(bt_select))
BT_SRC_FILES := $(LOCAL_PATH)/pwr/btpower.c

# Below are for Android build system to recognize each module name, so
# they can be installed properly. Since Kbuild is used to compile these
# modules, invoking any of them will cause other modules to be compiled
# as well if corresponding flags are added in KBUILD_OPTIONS from upper
# level Makefiles.

################################ btpower ################################
include $(CLEAR_VARS)
LOCAL_SRC_FILES           := $(BT_SRC_FILES)
LOCAL_MODULE              := btpower.ko
LOCAL_MODULE_KBUILD_NAME  := btpower.ko
LOCAL_MODULE_TAGS         := optional
LOCAL_MODULE_DEBUG_ENABLE := true
LOCAL_MODULE_PATH         := $(KERNEL_MODULES_OUT)

TARGET_KERNEL_DLKM_OVERRIDE += $(LOCAL_MODULE)
KBUILD_OPTIONS += BT_KERNEL_ROOT=$(BT_BLD_DIR)
KBUILD_OPTIONS += $(BT_SELECT)
KBUILD_OPTIONS += ENABLE_DDK_BUILD=true

include $(DLKM_DIR)/Build_external_kernelmodule.mk
################################ btpower_new ################################
include $(CLEAR_VARS)
LOCAL_SRC_FILES           := $(BT_SRC_FILES)
LOCAL_MODULE              := btpower_new.ko
LOCAL_MODULE_KBUILD_NAME  := btpower_new.ko
LOCAL_MODULE_TAGS         := optional
LOCAL_MODULE_DEBUG_ENABLE := true
LOCAL_MODULE_PATH         := $(KERNEL_MODULES_OUT)
TARGET_KERNEL_DLKM_OVERRIDE += $(LOCAL_MODULE)
KBUILD_OPTIONS += BT_KERNEL_ROOT=$(BT_BLD_DIR)
KBUILD_OPTIONS += $(BT_SELECT)
KBUILD_OPTIONS += ENABLE_DDK_BUILD=true
include $(DLKM_DIR)/Build_external_kernelmodule.mk

endif # DLKM check
endif # supported target check
