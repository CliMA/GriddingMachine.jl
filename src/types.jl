#######################################################################################################################################################################################################
#
# Changes to the struct
# General
#     2022-Jan-27: add struct to indicate TROPOMI SIF L2
#
#######################################################################################################################################################################################################
"""
"""
struct TropomiL2SIF
    "Identifier"
    ID::String
    "Path to the database"
    PATH::String
    "Name pattern"
    PATTERN::String
    "If the data is stored per year"
    PER_YEAR::Bool
    "If the data is stored per month"
    PER_MONTH::Bool
    "Target folder"
    TARGET::String
end


#######################################################################################################################################################################################################
#
# Changes to the construtor
# General
#     2022-Jan-27: add construtor to construt structs for TROPOMI Caltech and ESA
#
#######################################################################################################################################################################################################
"""
"""
TropomiL2SIF(id::String) = (
    @assert id in ["CaltechNIR", "ESANIR"] "id must be CaltechNIR or ESANIR";

    _dir     = (id=="CaltechNIR" ? "/net/fluo/data3/projects/TROPOMI/nc_ungridded" : "/net/fluo/data2/data/TROPOMI_SIF_ESA/original/v2.1/l2b");
    _pattern = (id=="CaltechNIR" ? "TROPO_SIF_yyyy-mm-dd_ungridded.nc" : "TROPOSIF_L2B_yyyy-mm-dd.nc");
    _year    = (id=="CaltechNIR" ? false : true);
    _month   = (id=="CaltechNIR" ? false : true);

    return TropomiL2SIF(id, _dir, _pattern, _year, _month, "/home/wyujie/GriddingMachine/partitions/$(id)")
);
