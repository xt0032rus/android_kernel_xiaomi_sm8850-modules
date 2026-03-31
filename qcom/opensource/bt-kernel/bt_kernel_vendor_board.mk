# Build audio kernel driver
ifneq ($(TARGET_BOARD_AUTO),true)
ifeq ($(TARGET_USES_QMAA),true)
  ifeq ($(TARGET_USES_QMAA_OVERRIDE_BLUETOOTH), true)
     ifneq (,$(call is-board-platform-in-list2,$(TARGET_BOARD_PLATFORM)))
         BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_MODULES_OUT)/btpower.ko
          BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_MODULES_OUT)/btpower_new.ko
     endif
  endif
else
  ifneq (,$(call is-board-platform-in-list2,$(TARGET_BOARD_PLATFORM)))
     BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_MODULES_OUT)/btpower.ko
     BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_MODULES_OUT)/btpower_new.ko

  endif
endif
else
  ifneq (,$(call is-board-platform-in-list2, msmnile sm6150 gen4 gen5))
    BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_MODULES_OUT)/btpower.ko
    BOARD_VENDOR_KERNEL_MODULES += $(KERNEL_MODULES_OUT)/btpower_new.ko
  endif
endif
