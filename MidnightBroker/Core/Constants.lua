local _, MB = ...

MB.Constants = {
    ELEMENT_IDS = {
        TIME = "time",
        ZONE = "zone",
        COORDS = "coords",
        DURABILITY = "durability",
        MEMORY = "memory",
        GOLD = "gold",
        FPS = "fps",
        LATENCY = "latency",
    },
    ELEMENT_ORDER = {
        "time",
        "zone",
        "coords",
        "durability",
        "memory",
        "gold",
        "fps",
        "latency",
    },
    DURABILITY_SLOTS = {
        1, 3, 5, 6, 7, 8, 9, 10, 16, 17,
    },
    UPDATE_INTERVALS = {
        TIME = 1.0,
        COORDS = 0.35,
        MEMORY = 3.0,
        GOLD = 1.5,
        FPS = 0.5,
        LATENCY = 1.5,
        BROKER = 1.0,
    },
    COPPER_PER_SILVER = 100,
    COPPER_PER_GOLD = 10000,
    DEFAULT_FONT = "Fonts\\FRIZQT__.TTF",
    FONT_OPTIONS = {
        { id = "frizqt", label = "Friz Quadrata", path = "Fonts\\FRIZQT__.TTF" },
        { id = "arialn", label = "Arial Narrow", path = "Fonts\\ARIALN.TTF" },
        { id = "morpheus", label = "Morpheus", path = "Fonts\\MORPHEUS.TTF" },
        { id = "skurri", label = "Skurri", path = "Fonts\\SKURRI.TTF" },
    },
    TIME_FORMAT_OPTIONS = {
        { value = "%H:%M:%S", label = "24h (HH:MM:SS)" },
        { value = "%H:%M", label = "24h (HH:MM)" },
        { value = "%I:%M:%S %p", label = "12h (h:MM:SS AM/PM)" },
        { value = "%I:%M %p", label = "12h (h:MM AM/PM)" },
    },
    DATE_FORMAT_OPTIONS = {
        { value = "%Y-%m-%d", label = "YYYY-MM-DD" },
        { value = "%m/%d/%Y", label = "MM/DD/YYYY" },
        { value = "%d/%m/%Y", label = "DD/MM/YYYY" },
        { value = "%b %d, %Y", label = "Mon DD, YYYY" },
    },
    DATETIME_LAYOUT_OPTIONS = {
        { value = "date_then_time", label = "Date then time" },
        { value = "time_then_date", label = "Time then date" },
        { value = "two_line", label = "Two-line (date above time)" },
    },
    GOLD_FORMAT_OPTIONS = {
        { value = "gsc", label = "Gold / Silver / Copper" },
        { value = "g", label = "Gold only" },
    },
    TEXT_JUSTIFY_OPTIONS = {
        { value = "LEFT", label = "Left" },
        { value = "CENTER", label = "Center" },
        { value = "RIGHT", label = "Right" },
    },
    ZONE_LAYOUT_OPTIONS = {
        { value = "one_line", label = "One line (Zone - Subzone)" },
        { value = "two_line", label = "Two line (Zone / Subzone)" },
    },
    MEMORY_TOOLTIP_OPTIONS = {
        { value = "top10", label = "Top 10" },
        { value = "top25", label = "Top 25" },
        { value = "all", label = "All" },
    },
    MIN_FRAME_WIDTH = 140,
    MIN_FRAME_WIDTH_BY_ELEMENT = {
        durability = 110,
        fps = 100,
    },
    MAX_FRAME_WIDTH = 420,
}
