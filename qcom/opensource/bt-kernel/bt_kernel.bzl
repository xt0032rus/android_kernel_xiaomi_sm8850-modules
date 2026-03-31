load(":target_variants.bzl", "get_all_variants")
load("//build/kernel/kleaf:kernel.bzl", "ddk_module")
load("//build/bazel_common_rules/dist:dist.bzl", "copy_to_dist_dir")
load(":bt_modules.bzl", "bt_modules")

def _get_config_choices(config_srcs, options):
    choices = []

    for option in config_srcs:
        choices.extend(config_srcs[option].get(option in options, []))

    return choices

def _get_module_srcs(module, options):
    """
    Gets all the module sources, formats them with the path for that module
    and then groups them together
    It also includes all the headers within the `include` directory
    `native.glob()` returns a new list with every file need for the current package
    """
    srcs = module.srcs + _get_config_choices(module.config_srcs, options)
    return native.glob(
        ["{}/{}".format(module.path, src) for src in srcs] + ["include/*.h"]
    )

def _get_module_deps(module, options, formatter):
    """
    Formats the dependent targets with the necessary prefix
    Args:
        module: kernel module
        options: dependencies that rely on a config option
        formatter: function that will replace the format string within `deps`
    Example:
        kernel build = "pineapple_gki"
        dep = "%b_btpower"
        The formatted string will look as follow
        formatted_dep = formatter(dep) = "pineapple_gki_btpower"
    """
    deps = module.deps + _get_config_choices(module.config_deps, options)
    return [formatter(dep) for dep in deps]

def _get_build_options(modules, config_options):
    all_options = {option: True for option in config_options}
    all_options = all_options | {module.config_opt: True for module in modules if module.config_opt}

    return all_options

def _get_module_build_options(module, config_options):
    all_options = {option: True for option in config_options}
    all_options = all_options | {module.config_opt: True}
    return all_options

def define_target_variant_modules(target, variant, modules, config_options = []):
    """
    Generates the ddk_module for each of our kernel modules
    Args:
        target: either `pineapple` or `kalama`
        variant: either `gki` or `consolidate`
        modules: bt_modules dictionary defined in `bt_modules.bzl`
        config_options: decides which kernel modules to build
    """
    print("target= ", target)
    print("variant= ", variant)
    print("modules= ", modules)
    print("config_options= ", config_options)

    tv = "{}_{}".format(target, variant)

    kernel_build = "//soc-repo:{}_base_kernel".format(tv)
    module_build = "//vendor/qcom/opensource/bt-kernel:{}".format(tv)
    print("kernel_build=", kernel_build)
    modules = [bt_modules.get(module_name) for module_name in modules]
    options = _get_build_options(modules, config_options)
    formatter = lambda s : s.replace("%b", kernel_build)
    formatter2 = lambda s : s.replace("%b", module_build)

    all_modules = []
    for module in modules:
        print("module = ", module)
        #_define_platform_config_rule(module.name, target, variant)
        #defconfig = ":{}/{}_defconfig_generate_{}".format(module.name, kernel_build, variant)
        #print("defconfig = ", defconfig)
        rule_name = "{}_{}".format(tv, module.name)
        print("rule_name = ", rule_name)
        module_srcs = _get_module_srcs(module, options)
        module_opt = _get_module_build_options(module, config_options)
        print("module_srcs = ", module_srcs)
        print("module_opt = ", module_opt)
        ddk_module(
            name = rule_name,
            kernel_build = kernel_build,
            #defconfig = defconfig,
            srcs = module_srcs,
            out = "{}.ko".format(module.name),
            deps = ["//common:all_headers",
                    "//soc-repo:all_headers",
                    "//soc-repo:{}/drivers/pinctrl/qcom/pinctrl-msm".format(tv),
                   ] + _get_module_deps(module, module_opt, formatter2),
            includes = ["include"],
            local_defines = module_opt.keys(),
            visibility = ["//visibility:public"],
        )

        all_modules.append(rule_name)

    copy_to_dist_dir(
        name = "{}_bt-kernel_dist".format(tv),
        data = all_modules,
        dist_dir = "out/target/product/{}/dlkm/lib/modules".format(target),
        flat = True,
        wipe_dist_dir = False,
        allow_duplicate_filenames = False,
        mode_overrides = {"**/*": "644"},
        log = "info",
    )

def _define_platform_config_rule(module, target, variant):
    tv = "{}_{}".format(target, variant)
    print("_define_platform_config_rule: module=", module);
    print("_define_platform_config_rule: target=", target);
    print("_define_platform_config_rule: variant=", variant);

    native.genrule(
        name = "{}/{}_defconfig_generate_perf".format(module, tv),
        outs = ["{}/{}_defconfig.generated_perf".format(module, tv)],
        srcs = [
            "{}/{}_gki_defconfig".format(module, target),
        ],
        cmd = "cat $(SRCS) > $@",
    )
    native.genrule(
        name = "{}/{}_defconfig_generate_perf-defconfig".format(module, tv),
        outs = ["{}/{}_defconfig.generated_perf-defconfig".format(module, tv)],
        srcs = [
            "{}/{}_gki_defconfig".format(module, target),
        ],
        cmd = "cat $(SRCS) > $@",
    )
    native.genrule(
        name = "{}/{}_defconfig_generate_consolidate".format(module, tv),
        outs = ["{}/{}_defconfig.generated_consolidate".format(module, tv)],
        srcs = [
            "{}/{}_consolidate_defconfig".format("pwr", target),
        ],
        cmd = "cat $(SRCS) > $@",
    )


def define_bt_modules(target, modules, config_options = []):
    print("target=", target)
    for (t, v) in get_all_variants():
        if t == target:
            define_target_variant_modules(t, v, modules, config_options)
