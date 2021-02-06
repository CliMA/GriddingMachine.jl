# # Dataset Previews




# First, initialize by adding tools and declare floating type
using GriddingMachine
using PkgUtility
using Plots
using Plots.PlotMeasures

ENV["GKSwstype"]="100";
FT = Float32;
## use this to fix the problem in generated preview.jl file
F1 = joinpath(@__DIR__, "../../Artifacts.toml");
F2 = joinpath(@__DIR__, "../../../Artifacts.toml");
GRIDDINGMACHINE_ARTIFACTS = (isfile(F1) ? F1 : F2);

predownload_artifact.(["CH_20X_1Y_V1",
                       "CHL_2X_7D_V1",
                       "CI_12X_1Y_V1",
                       "CI_PFT_2X_1Y_V1",
                       "GPP_MPI_2X_1M_2005_V1",
                       "GPP_VPM_5X_8D_2005_V1",
                       "LAI_4X_1M_V1",
                       "LM_ERA5_4X_1Y_V1",
                       "LNC_2X_1Y_V1",
                       "LPC_2X_1Y_V1",
                       "NDVI_AVHRR_20X_1M_2018_V1",
                       "NIRO_AVHRR_20X_1M_2018_V1",
                       "NIRV_AVHRR_20X_1M_2018_V1",
                       "RIVER_4X_1Y_V1",
                       "SIF740_TROPOMI_1X_1M_2018_V1",
                       "SLA_2X_1Y_V1",
                       "TD_12X_1Y_V1",
                       "VMAX_CICA_2X_1Y_V1",
                       "WD_2X_1Y_V1",
                       "NPP_MODIS_1X_1Y"],
                      GRIDDINGMACHINE_ARTIFACTS);
#------------------------------------------------------------------------------




# Then, define a function to plot the dataset
function preview_data(ds::GriddedDataset{FT}, ind::Int)
    ## preview data
    return heatmap(view(ds.data,:,:,ind)',
                   origin="lower",
                   aspect_ratio=1,
                   xticks=[],
                   yticks=[],
                   c=:viridis,
                   size=(700,300),
                   framestyle=:none)
end

function preview_data(ds::GriddedDataset{FT}, ind::Int, clim::Tuple)
    ## preview data
    return heatmap(view(ds.data,:,:,ind)',
                   origin="lower",
                   aspect_ratio=1,
                   xticks=[],
                   yticks=[],
                   c=:viridis,
                   clim=clim,
                   size=(700,300),
                   framestyle=:none)
end
#------------------------------------------------------------------------------




# ## Leaf level datasets
# ### Leaf chlorophyll content
LCH_LUT = load_LUT(LeafChlorophyll{FT}());
mask_LUT!(LCH_LUT, FT[0,Inf]);
LCH_LUT = regrid_LUT(LCH_LUT, Int(size(LCH_LUT.data,2)/180));
anim = @animate for i ∈ 1:size(LCH_LUT.data,3)
    preview_data(LCH_LUT, i, (0,80));
end
gif(anim, fps=5)
#------------------------------------------------------------------------------

# ### Leaf nitrogen content
LNC_LUT = load_LUT(LeafNitrogen{FT}());
mask_LUT!(LNC_LUT, FT[0,Inf]);
LNC_LUT = regrid_LUT(LNC_LUT, Int(size(LNC_LUT.data,2)/180));
preview_data(LNC_LUT, 1)
#------------------------------------------------------------------------------

# ### Leaf phosphorus content
LPC_LUT = load_LUT(LeafPhosphorus{FT}());
mask_LUT!(LPC_LUT, FT[0,Inf]);
LPC_LUT = regrid_LUT(LPC_LUT, Int(size(LPC_LUT.data,2)/180));
preview_data(LPC_LUT, 1)
#------------------------------------------------------------------------------

# ### Specific leaf area
SLA_LUT = load_LUT(LeafSLA{FT}());
mask_LUT!(SLA_LUT, FT[0,Inf]);
SLA_LUT = regrid_LUT(SLA_LUT, Int(size(SLA_LUT.data,2)/180));
preview_data(SLA_LUT, 1)
#------------------------------------------------------------------------------

# ### Vcmax
VCM_LUT = load_LUT(VcmaxOptimalCiCa{FT}());
mask_LUT!(VCM_LUT, FT[0,Inf]);
VCM_LUT = regrid_LUT(VCM_LUT, Int(size(VCM_LUT.data,2)/180));
preview_data(VCM_LUT, 1)
#------------------------------------------------------------------------------




# ## Stand level datasets
# ### Canopy height
CHT_LUT = load_LUT(CanopyHeightGLAS{FT}());
mask_LUT!(CHT_LUT, FT[0,Inf]);
CHT_LUT = regrid_LUT(CHT_LUT, Int(size(CHT_LUT.data,2)/180));
preview_data(CHT_LUT, 1)
#------------------------------------------------------------------------------

# ### Clumping index
## global clumping index
CLI_LUT = load_LUT(ClumpingIndexMODIS{FT}(), "12X", "1Y");
mask_LUT!(CLI_LUT, FT[0,1]);
CLI_LUT = regrid_LUT(CLI_LUT, Int(size(CLI_LUT.data,2)/180));
preview_data(CLI_LUT, 1, (0.4,1))
#------------------------------------------------------------------------------

## global clumping index per PFT
CLI_LUT = load_LUT(ClumpingIndexPFT{FT}());
mask_LUT!(CLI_LUT, FT[0,1]);
CLI_LUT = regrid_LUT(CLI_LUT, Int(size(CLI_LUT.data,2)/180));
anim = @animate for i ∈ 1:size(CLI_LUT.data,3)
    preview_data(CLI_LUT, i, (0.4,1));
end
gif(anim, fps=1)
#------------------------------------------------------------------------------

# ### Gross primary productivity
## GPP MPI
GPP_LUT = load_LUT(GPPMPIv006{FT}(), 2005, "2X", "8D");
GPP_LUT = regrid_LUT(GPP_LUT, Int(size(GPP_LUT.data,2)/180));
mask_LUT!(GPP_LUT, FT[-100,Inf]);
anim = @animate for i ∈ 1:46
    preview_data(GPP_LUT, i, (0,10));
end
gif(anim, fps=5)
#------------------------------------------------------------------------------

## GPP VPM
GPP_LUT = load_LUT(GPPVPMv20{FT}(), 2005, "5X", "8D");
GPP_LUT = regrid_LUT(GPP_LUT, Int(size(GPP_LUT.data,2)/180));
mask_LUT!(GPP_LUT, FT[-100,Inf]);
anim = @animate for i ∈ 1:46
    preview_data(GPP_LUT, i, (0,10));
end
gif(anim, fps=5)
#------------------------------------------------------------------------------

# ### Leaf area index
LAI_LUT = load_LUT(LAIMonthlyMean{FT}());
LAI_LUT = regrid_LUT(LAI_LUT, Int(size(LAI_LUT.data,2)/180));
anim = @animate for i ∈ 1:size(LAI_LUT.data,3)
    preview_data(LAI_LUT, i, (0,6));
end
gif(anim, fps=1)
#------------------------------------------------------------------------------

# ### Normalized difference vegetation index
NDV_LUT = load_LUT(NDVIAvhrr{FT}(), 2018, "20X", "1M");
NDV_LUT = regrid_LUT(NDV_LUT, Int(size(NDV_LUT.data,2)/180));
anim = @animate for i ∈ 1:size(NDV_LUT.data,3)
    preview_data(NDV_LUT, i, (0,1));
end
gif(anim, fps=1)
#------------------------------------------------------------------------------

# ### Near infrared reflectance of vegetation
NIV_LUT = load_LUT(NIRvAvhrr{FT}(), 2018, "20X", "1M");
NIV_LUT = regrid_LUT(NIV_LUT, Int(size(NIV_LUT.data,2)/180));
anim = @animate for i ∈ 1:size(NIV_LUT.data,3)
    preview_data(NIV_LUT, i, (0,1));
end
gif(anim, fps=1)
#------------------------------------------------------------------------------

# ### Near infrared reflectance of vegetation with offset
NIO_LUT = load_LUT(NIRoAvhrr{FT}(), 2018, "20X", "1M");
NIO_LUT = regrid_LUT(NIO_LUT, Int(size(NIO_LUT.data,2)/180));
anim = @animate for i ∈ 1:size(NIO_LUT.data,3)
    preview_data(NIO_LUT, i, (0,1));
end
gif(anim, fps=1)
#------------------------------------------------------------------------------

# ### Net primary productivity
NPP_LUT = load_LUT(NPPModis{FT}());
mask_LUT!(NPP_LUT, FT[-Inf,1e19]);
NPP_LUT = regrid_LUT(NPP_LUT, Int(size(NPP_LUT.data,2)/180));
NPP_LUT.data .*= 1e9;
preview_data(NPP_LUT, 1)
#------------------------------------------------------------------------------

# ### Sun induced fluorescence
SIF_LUT = load_LUT(SIFTropomi740{FT}(), 2018, "1X", "1M");
mask_LUT!(SIF_LUT, FT[-100,100]);
anim = @animate for i ∈ 1:12
    preview_data(SIF_LUT, i, (0,3.5));
end
gif(anim, fps=3)
#------------------------------------------------------------------------------

# ### Tree density
TDT_LUT = load_LUT(TreeDensity{FT}(), "12X", "1Y");
mask_LUT!(TDT_LUT, FT[0,Inf]);
TDT_LUT = regrid_LUT(TDT_LUT, Int(size(TDT_LUT.data,2)/180));
preview_data(TDT_LUT, 1, (0, 150000))
#------------------------------------------------------------------------------

# ### Wood density
TDT_LUT = load_LUT(WoodDensity{FT}());
mask_LUT!(TDT_LUT, FT[0,Inf]);
TDT_LUT = regrid_LUT(TDT_LUT, Int(size(TDT_LUT.data,2)/180));
preview_data(TDT_LUT, 1)
#------------------------------------------------------------------------------




# ## Land surface
# ### Land elevation
ELE_LUT = load_LUT(LandElevation{FT}());
mask_LUT!(ELE_LUT, FT[0,Inf]);
ELE_LUT = regrid_LUT(ELE_LUT, Int(size(ELE_LUT.data,2)/180));
preview_data(ELE_LUT, 1)
#------------------------------------------------------------------------------

# ### Land mask
LMK_LUT = load_LUT(LandMaskERA5{FT}());
LMK_LUT = regrid_LUT(LMK_LUT, Int(size(LMK_LUT.data,2)/180));
preview_data(LMK_LUT, 1)
#------------------------------------------------------------------------------

# ### River flood plain height
FLD_LUT = load_LUT(FloodPlainHeight{FT}());
mask_LUT!(FLD_LUT, FT[0,Inf]);
FLD_LUT = regrid_LUT(FLD_LUT, Int(size(FLD_LUT.data,2)/180));
preview_data(FLD_LUT, 1)
#------------------------------------------------------------------------------

# ### River height
RVH_LUT = load_LUT(RiverHeight{FT}());
mask_LUT!(RVH_LUT, FT[0,Inf]);
RVH_LUT = regrid_LUT(RVH_LUT, Int(size(RVH_LUT.data,2)/180));
preview_data(RVH_LUT, 1)
#------------------------------------------------------------------------------

# ### River width
RVW_LUT = load_LUT(RiverWidth{FT}());
mask_LUT!(RVW_LUT, FT[0,Inf]);
RVW_LUT = regrid_LUT(RVW_LUT, Int(size(RVW_LUT.data,2)/180));
preview_data(RVW_LUT, 1)
#------------------------------------------------------------------------------

# ### River length
RVL_LUT = load_LUT(RiverLength{FT}());
mask_LUT!(RVL_LUT, FT[0,Inf]);
RVL_LUT = regrid_LUT(RVL_LUT, Int(size(RVL_LUT.data,2)/180));
preview_data(RVL_LUT, 1)
#------------------------------------------------------------------------------

# ### River manning coefficient
RVM_LUT = load_LUT(LandMaskERA5{FT}());
RVM_LUT = regrid_LUT(RVM_LUT, Int(size(RVM_LUT.data,2)/180));
preview_data(RVM_LUT, 1)
#------------------------------------------------------------------------------

# ### River unit catchment area
UCA_LUT = load_LUT(UnitCatchmentArea{FT}());
UCA_LUT = regrid_LUT(UCA_LUT, Int(size(UCA_LUT.data,2)/180));
preview_data(UCA_LUT, 1)
#------------------------------------------------------------------------------
