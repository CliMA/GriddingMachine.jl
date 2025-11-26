# CLM5 settings
CLM5_PFT_LUT = [
            "not_vegetated"                     0       0       0       0       0;
            "needleleaf_evergreen_temperate"    2.35    0.07    0.05    0.35    0.10;
            "needleleaf_evergreen_boreal"       2.35    0.07    0.05    0.35    0.10;
            "needleleaf_deciduous_boreal"       2.35    0.07    0.05    0.35    0.10;
            "broadleaf_evergreen_tropical"      4.12    0.10    0.05    0.45    0.25;
            "broadleaf_evergreen_temperate"     4.12    0.10    0.05    0.45    0.25;
            "broadleaf_deciduous_tropical"      4.45    0.10    0.05    0.45    0.25;
            "broadleaf_deciduous_temperate"     4.45    0.10    0.05    0.45    0.25;
            "broadleaf_deciduous_boreal"        4.45    0.10    0.05    0.45    0.25;
            "evergreen_shrub"                   4.70    0.07    0.05    0.35    0.10;
            "deciduous_temperate_shrub"         4.70    0.10    0.05    0.45    0.25;
            "deciduous_boreal_shrub"            4.70    0.10    0.05    0.45    0.25;
            "c3_arctic_grass"                   2.22    0.11    0.05    0.35    0.34;
            "c3_non-arctic_grass"               5.25    0.11    0.05    0.35    0.34;
            "c4_grass"                          1.62    0.11    0.05    0.35    0.34;
            "c3_crop"                           5.79    0.11    0.05    0.35    0.34;
            "c3_irrigated"                      5.79    0.11    0.05    0.35    0.34];
CLM5_PFTS = CLM5_PFT_LUT[:, 1];
CLM5_PFTG = CLM5_PFT_LUT[:, 2] .* sqrt(1000);
CLM5_ρPAR = CLM5_PFT_LUT[:, 3];
CLM5_τPAR = CLM5_PFT_LUT[:, 4];
CLM5_ρNIR = CLM5_PFT_LUT[:, 5];
CLM5_τNIR = CLM5_PFT_LUT[:, 6];
