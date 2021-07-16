# # Dataset Previews




# First, initialize by adding tools and declare floating type
using GriddingMachine
using PkgUtility
using Plots
using Plots.PlotMeasures

ENV["GKSwstype"]="100";
FT = Float32;
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
# ### Leaf nitrogen content
LNC_LUT = load_LUT(LeafNitrogenButler{FT}(), 1);
preview_data(LNC_LUT, 1)
#------------------------------------------------------------------------------

LNC_LUT = load_LUT(LeafNitrogenBoonman{FT}(), 1);
preview_data(LNC_LUT, 1)
#------------------------------------------------------------------------------

# ### Leaf phosphorus content
LPC_LUT = load_LUT(LeafPhosphorus{FT}(), 1);
preview_data(LPC_LUT, 1)
#------------------------------------------------------------------------------

# ### Specific leaf area
SLA_LUT = load_LUT(LeafSLAButler{FT}(), 1);
preview_data(SLA_LUT, 1)
#------------------------------------------------------------------------------

SLA_LUT = load_LUT(LeafSLABoonman{FT}(), 1);
preview_data(SLA_LUT, 1)
#------------------------------------------------------------------------------

# ### Vcmax
VCM_LUT = load_LUT(VcmaxOptimalCiCa{FT}(), 1);
preview_data(VCM_LUT, 1)
#------------------------------------------------------------------------------




# ## Stand level datasets
# ### Canopy height
CHT_LUT = load_LUT(CanopyHeightGLAS{FT}(), 1);
preview_data(CHT_LUT, 1)
#------------------------------------------------------------------------------

CHT_LUT = load_LUT(CanopyHeightBoonman{FT}(), 1);
preview_data(CHT_LUT, 1)
#------------------------------------------------------------------------------

# ### Clumping index
## global clumping index
CLI_LUT = load_LUT(ClumpingIndexMODIS{FT}(), "12X", "1Y", 1);
preview_data(CLI_LUT, 1, (0.4,1))
#------------------------------------------------------------------------------

## global clumping index per PFT
CLI_LUT = load_LUT(ClumpingIndexPFT{FT}(), 1);
anim = @animate for i ∈ 1:size(CLI_LUT.data,3)
    preview_data(CLI_LUT, i, (0.4,1));
end
gif(anim, fps=1)
#------------------------------------------------------------------------------

# ### Gross primary productivity
## GPP MPI
GPP_LUT = load_LUT(GPPMPIv006{FT}(), 2005, "2X", "8D", 1);
anim = @animate for i ∈ 1:46
    preview_data(GPP_LUT, i, (0,10));
end
gif(anim, fps=5)
#------------------------------------------------------------------------------

## GPP VPM
GPP_LUT = load_LUT(GPPVPMv20{FT}(), 2005, "5X", "8D", 1);
anim = @animate for i ∈ 1:46
    preview_data(GPP_LUT, i, (0,10));
end
gif(anim, fps=5)
#------------------------------------------------------------------------------

# ### Leaf area index
## Annual data
LAI_LUT = load_LUT(LAIMODISv006{FT}(), 2005, "2X", "8D", 1);
anim = @animate for i ∈ 1:46
    preview_data(LAI_LUT, i, (0,6));
end
gif(anim, fps=5)
#------------------------------------------------------------------------------

## monthly mean of multiple years
LAI_LUT = load_LUT(LAIMonthlyMean{FT}(), 1);
anim = @animate for i ∈ 1:size(LAI_LUT.data,3)
    preview_data(LAI_LUT, i, (0,6));
end
gif(anim, fps=1)
#------------------------------------------------------------------------------

# ### Normalized difference vegetation index
NDV_LUT = load_LUT(NDVIAvhrr{FT}(), 2018, "20X", "1M", 1);
anim = @animate for i ∈ 1:size(NDV_LUT.data,3)
    preview_data(NDV_LUT, i, (0,1));
end
gif(anim, fps=1)
#------------------------------------------------------------------------------

# ### Near infrared reflectance of vegetation
NIV_LUT = load_LUT(NIRvAvhrr{FT}(), 2018, "20X", "1M", 1);
anim = @animate for i ∈ 1:size(NIV_LUT.data,3)
    preview_data(NIV_LUT, i, (0,1));
end
gif(anim, fps=1)
#------------------------------------------------------------------------------

# ### Near infrared reflectance of vegetation with offset
NIO_LUT = load_LUT(NIRoAvhrr{FT}(), 2018, "20X", "1M", 1);
anim = @animate for i ∈ 1:size(NIO_LUT.data,3)
    preview_data(NIO_LUT, i, (0,1));
end
gif(anim, fps=1)
#------------------------------------------------------------------------------

# ### Net primary productivity
NPP_LUT = load_LUT(NPPModis{FT}(), 1);
NPP_LUT.data .*= 1e9;
preview_data(NPP_LUT, 1)
#------------------------------------------------------------------------------

# ### Soil color class
SCC_LUT = load_LUT(SoilColor{FT}(), 1);
preview_data(SCC_LUT, 1)
#------------------------------------------------------------------------------

# ### Soil van Genuchten alpha
VGA_LUT = load_LUT(VGMAlphaJules{FT}(), "12X", "1Y", 1);
anim = @animate for i ∈ 1:4
    preview_data(VGA_LUT, i);
end
gif(anim, fps=1)
#------------------------------------------------------------------------------

# ### Soil van Genuchten log(n)
VGN_LUT = load_LUT(VGMLogNJules{FT}(), "12X", "1Y", 1);
anim = @animate for i ∈ 1:4
    preview_data(VGN_LUT, i);
end
gif(anim, fps=1)
#------------------------------------------------------------------------------

# ### Soil van Genuchten residual SWC
VGT_LUT = load_LUT(VGMThetaRJules{FT}(), "12X", "1Y", 1);
anim = @animate for i ∈ 1:4
    preview_data(VGT_LUT, i);
end
gif(anim, fps=1)
#------------------------------------------------------------------------------

# ### Soil van Genuchten saturated SWC
VGT_LUT = load_LUT(VGMThetaSJules{FT}(), "12X", "1Y", 1);
anim = @animate for i ∈ 1:4
    preview_data(VGT_LUT, i);
end
gif(anim, fps=1)
#------------------------------------------------------------------------------

# ### Sun induced fluorescence
SIF_LUT = load_LUT(SIFTropomi740{FT}(), 2018, "1X", "1M", 1);
anim = @animate for i ∈ 1:12
    preview_data(SIF_LUT, i, (0,3.5));
end
gif(anim, fps=3)
#------------------------------------------------------------------------------

# ### Tree density
TDT_LUT = load_LUT(TreeDensity{FT}(), "12X", "1Y", 1);
preview_data(TDT_LUT, 1, (0, 150000))
#------------------------------------------------------------------------------

# ### Wood density
TDT_LUT = load_LUT(WoodDensity{FT}(), 1);
preview_data(TDT_LUT, 1)
#------------------------------------------------------------------------------




# ## Land surface
# ### Land mask
LMK_LUT = load_LUT(LandMaskERA5{FT}(), 1);
preview_data(LMK_LUT, 1)
#------------------------------------------------------------------------------
