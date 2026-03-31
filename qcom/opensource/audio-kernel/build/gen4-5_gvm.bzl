load(":audio_modules.bzl", "audio_modules")
load(":module_mgr.bzl", "define_target_modules")
load(":target_variants.bzl", "get_all_le_variants")

def define_gen4_5_gvm(t, v):
    define_target_modules(
        target = t,
        variant = v,
        registry = audio_modules,
        modules = [
            "spf_machine_dlkm",
            "stub_dlkm",
        ],
        config_options = [
           "CONFIG_SND_SOC_GVM_AUTO_SPF",
	       "CONFIG_SND_SOC_MSM_STUB",
        ],
    )

def define_gen4_5_target():
     for (t, v) in get_all_le_variants():
        print(t)
        print(v)
        if t == "autogvm":
            define_gen4_5_gvm(t, v)