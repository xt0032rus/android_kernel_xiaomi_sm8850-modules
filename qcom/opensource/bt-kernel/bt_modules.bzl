PWR_PATH = "pwr"
SLIMBUS_PATH = "slimbus"
FMRTC_PATH = "rtc6226"

# This dictionary holds all the BT modules included in the bt-kernel
bt_modules = {}

def register_bt_modules(name, path = None, config_opt = None, srcs = [], config_srcs = {}, deps = [], config_deps = {}):
    """
    Register modules
    Args:
        name: Name of the module (which will be used to generate the name of the .ko file)
        path: Path in which the source files can be found
        config_opt: Config name used in Kconfig (not needed currently)
        srcs: source files and local headers
        config_srcs: source files and local headers that depend on a config define being enabled.
        deps: a list of dependent targets
        config_deps: a list of dependent targets that depend on a config define being enabled.
    """
    processed_config_srcs = {}
    processed_config_deps = {}

    for config_src_name in config_srcs:
        config_src = config_srcs[config_src_name]

        if type(config_src) == "list":
            processed_config_srcs[config_src_name] = {True: config_src}
        else:
            processed_config_srcs[config_src_name] = config_src

    for config_deps_name in config_deps:
        config_dep = config_deps[config_deps_name]

        if type(config_dep) == "list":
            processed_config_deps[config_deps_name] = {True: config_dep}
        else:
            processed_config_deps[config_deps_name] = config_dep

    module = struct(
        name = name,
        path = path,
        srcs = srcs,
        config_srcs = processed_config_srcs,
        config_opt = config_opt,
        deps = deps,
        config_deps = processed_config_deps,
    )
    bt_modules[name] = module

# --- BT Modules ---

register_bt_modules(
    name = "btpower",
    path = PWR_PATH,
    config_opt = "CONFIG_MSM_BT_POWER",
    srcs = ["btpower.c"],
)

register_bt_modules(
    name = "btpower_new",
    path = PWR_PATH,
    config_opt = "CONFIG_SECOND_BT_POWER",
    srcs = ["btpower.c"],
    deps = ["%b_btpower"],
)
