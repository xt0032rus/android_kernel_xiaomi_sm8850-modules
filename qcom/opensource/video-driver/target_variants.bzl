targets = [
    # keep sorted
    "autogvm",
]

la_variants = [
    # keep sorted
    "consolidate",
    "perf",
    "gki",
]

def get_all_la_variants():
    return [(t, v) for t in targets for v in la_variants]

def get_all_variants():
    return get_all_la_variants()
