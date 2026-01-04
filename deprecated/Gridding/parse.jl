#=
###############################################################################
#
# Parse h and v index from MODIS file name
#
###############################################################################
"""
    parse_HV(modis_name::String)

Return the H and V index, given
- `modis_name` MODIS file name
"""
function parse_HV(modis_name::String)
    i = findfirst(".h", modis_name)[1];
    h = parse(Int, modis_name[i+2:i+3]) + 1;
    v = parse(Int, modis_name[i+5:i+6]) + 1;

    return h,v
end
=#
