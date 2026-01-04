# ======================================================================================
# Web Form Templates for GriddingMachine Server (Components Only)
# ======================================================================================
#
# This file contains component definitions for the web interface.
# The main HTML template is now in "unified-form.jl"
#

# Generate options for artifact tags dropdown
GM_TAGS = sort(YAML_TAGS);
GM_TAG_OPTIONS = [GRHTML.option("--Choose a TAG--"); [GRHTML.option(t) for t in GM_TAGS]];

# GM version options
GM_VERS = ["gm1", "gm2", "gm3", "gm4"];
GM_VER_OPTIONS = [GRHTML.option("--Choose a Version--"); [GRHTML.option(v) for v in GM_VERS]];

# Weather driver version options
WD_VERS = ["wd1"];
WD_VER_OPTIONS = [GRHTML.option("--Choose WD Version--"); [GRHTML.option(v) for v in WD_VERS]];

# Common form elements
HEADER = GRHTML.h2("Input your choices:");

# Common input fields
CYC_LABEL = GRHTML.label("Cycle");
CYC_INPUT = GRHTML.input(type = "number", name = "cyc", step="1", placeholder="0");

GMV_LABEL = GRHTML.label("GM Version");
GMV_SELECT = GRHTML.select(GM_VER_OPTIONS, filled = false, name="gmv");

LAT_LABEL = GRHTML.label("Latitude");
LAT_INPUT = GRHTML.input(type = "number", name = "lat", step="any", placeholder="35.5");

LON_LABEL = GRHTML.label("Longitude");
LON_INPUT = GRHTML.input(type = "number", name = "lon", step="any", placeholder="115.5");

STD_LABEL = GRHTML.label("Include STD");
STD_CHECK = GRHTML.input(type = "checkbox", name = "include_std", checked = true);

TAG_LABEL = GRHTML.label("GriddingMachine TAG");
TAG_SELECT = GRHTML.select(GM_TAG_OPTIONS, filled = false, name="tag");

YEAR_LABEL = GRHTML.label("Year");
YEAR_INPUT = GRHTML.input(type = "number", name = "year", step="1", placeholder="2019");

WDV_LABEL = GRHTML.label("Weather Driver Version");
WDV_SELECT = GRHTML.select(WD_VER_OPTIONS, filled = false, name="wdv");

SUBMIT = GRHTML.input(type = "submit", value="Get JSON");

# Notes sections
HEADER_NOTE = GRHTML.h2("Note");
NOTES_ART = GRHTML.li.([
    "Cycle: 0 to request all data in the 3rd dimension (e.g., time)",
    "Include STD: when checked, include standard deviation (error) in the output. If not available, will return 'Not available in dataset'",
    "Interpolate: currently not implemented, returns grid cell values regardless of this setting",
]);
NOTES_DICT = GRHTML.li.([
    "GM Version: our default is gm2, please visit <a href=https://silicormosia.github.io/blogs/emerald/emerald.html#griddingmachine-selections target=_blank>CliMA Land Benchmark Page</a> for more details",
    "Year: the time-dependent variable is leaf area index (LAI), but the datasets we use may only cover year 2001 to 2020.",
]);
NOTES_WEATHER = GRHTML.li.([
    "WD Version: Only 'wd1' (ERA5 single level data) is supported now.",
    "GM Version: our default is gm2",
    "Year: weather data covers year 2001 to 2020 (consistent with LAI datasets).",
    "Latitude/Longitude: Use decimal format (e.g., 35.5 for 35°30'N, 115.5 for 115°30'E)."
]);

# References section
HEADER_REFS = GRHTML.h2("Reference");
REFS_ART = GRHTML.li.([
    "<a href=https://doi.org/10.1038/s41597-022-01346-x target=_blank>Wang et al. (2022)</a> GriddingMachine, a database and software for Earth system modeling at global and regional scales. Scientific Data 9: 258",
    "Please refer to <a href=https://github.com/CliMA/GriddingMachine.jl/issues/62 target=_blank>GriddingMachine.jl</a> for the reference to the data you are using",
]);
REFS_DICT = GRHTML.li.([
    "<a href=https://doi.org/10.1038/s41597-022-01346-x target=_blank>Wang et al. (2022)</a> GriddingMachine, a database and software for Earth system modeling at global and regional scales. Scientific Data 9: 258",
    "<a href=http://dx.doi.org/10.1029/2021MS002964 target=_blank>Wang et al. (2023)</a> Modeling global vegetation gross primary productivity, transpiration and hyperspectral canopy radiative transfer simultaneously using a next generation land surface model—CliMA Land. Journal of Advances in Modeling Earth Systems 15(3): e2021MS002964",
    "Please refer to <a href=https://github.com/CliMA/GriddingMachine.jl/issues/62 target=_blank>GriddingMachine.jl</a> for the reference to the data you are using",
]);

# ======================================================================================
# Individual Form Templates
# ======================================================================================

# Artifact Data Form
ARTIFACT_FORM = GRHTML.form(
    action = "/gm_artifact_result",
    method = "POST",
    [
        GRHTML.h1("Request for Artifact Data from GriddingMachine.jl"),
        HEADER,
        TAG_LABEL, TAG_SELECT,
        LAT_LABEL, LAT_INPUT,
        LON_LABEL, LON_INPUT,
        CYC_LABEL, CYC_INPUT,
        STD_CHECK, STD_LABEL,
        SUBMIT,
        HEADER_NOTE,
        GRHTML.ul(NOTES_ART),
        HEADER_REFS,
        GRHTML.ul(REFS_ART)
    ]
);

# GM Dictionary Form
GMDICT_FORM = GRHTML.form(
    action = "/gm_dict_result",
    method = "POST",
    [
        GRHTML.h1("Request for GM Dictionary from GriddingMachine.jl"),
        HEADER,
        GMV_LABEL, GMV_SELECT,
        YEAR_LABEL, YEAR_INPUT,
        LAT_LABEL, LAT_INPUT,
        LON_LABEL, LON_INPUT,
        SUBMIT,
        HEADER_NOTE,
        GRHTML.ul(NOTES_DICT),
        HEADER_REFS,
        GRHTML.ul(REFS_DICT)
    ]
);

# Weather Data Form
WEATHER_FORM = GRHTML.form(
    action = "/gm_weather_result",
    method = "POST",
    [
        GRHTML.h1("Request for Weather Data from GriddingMachine.jl"),
        HEADER,
        WDV_LABEL, WDV_SELECT,
        YEAR_LABEL, YEAR_INPUT,
        LAT_LABEL, LAT_INPUT,
        LON_LABEL, LON_INPUT,
        SUBMIT,
        HEADER_NOTE,
        GRHTML.ul(NOTES_WEATHER),
        HEADER_REFS,
        GRHTML.ul(REFS_DICT)
    ]
);