# # Dataset Previews




# First, initialize by adding tools and declare floating type
using GriddingMachine
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




# ## Canopy height
CHT_LUT = load_LUT(CanopyHeightGLAS{FT}());
CHT_LUT = regrid_LUT(CHT_LUT, Int(size(CHT_LUT.data,2)/180));
preview_data(CHT_LUT, 1)
#------------------------------------------------------------------------------




# ## Clumping index
## global clumping index
CLI_LUT = load_LUT(ClumpingIndexMODIS{FT}(), "12X", "1Y");
CLI_LUT = regrid_LUT(CLI_LUT, Int(size(CLI_LUT.data,2)/180));
mask_LUT!(CLI_LUT, FT[0,1]);
preview_data(CLI_LUT, 1, (0.4,1));
#------------------------------------------------------------------------------




## global clumping index per PFT
CLI_LUT = load_LUT(ClumpingIndexPFT{FT}());
CLI_LUT = regrid_LUT(CLI_LUT, Int(size(CLI_LUT.data,2)/180));
mask_LUT!(CLI_LUT, FT[0,1]);
anim = @animate for i ∈ 1:size(CLI_LUT.data,3)
    preview_data(CLI_LUT, i, (0.4,1));
end
gif(anim, fps=1)
#------------------------------------------------------------------------------




# ## Gross primary productivity
## MPI GPP
anim = @animate for year ∈ 2001:2019, i ∈ 1:46
    GPP_LUT = load_LUT(GPPMPIv006{FT}(), year, "1X", "8D");
    preview_data(GPP_LUT, i, (0,10));
end
gif(anim, fps=20)
#------------------------------------------------------------------------------




## VPM GPP
anim = @animate for year ∈ 2000:2019, i ∈ 1:46
    @show year;
    GPP_LUT = load_LUT(GPPVPMv20{FT}(), year, "1X", "8D");
    preview_data(GPP_LUT, i, (0,10));
end
gif(anim, fps=20)
#------------------------------------------------------------------------------




# ## Leaf area index
LAI_LUT = load_LUT(LAIMonthlyMean{FT}());
LAI_LUT = regrid_LUT(LAI_LUT, Int(size(LAI_LUT.data,2)/180));
anim = @animate for i ∈ 1:size(LAI_LUT.data,3)
    preview_data(LAI_LUT, i, (0,6));
end
gif(anim, fps=1)
#------------------------------------------------------------------------------




# ## Leaf chlorophyll content
LCH_LUT = load_LUT(LeafChlorophyll{FT}());
LCH_LUT = regrid_LUT(LCH_LUT, Int(size(LCH_LUT.data,2)/180));
mask_LUT!(CLI_LUT, FT[0,Inf]);
anim = @animate for i ∈ 1:size(LCH_LUT.data,3)
    preview_data(LCH_LUT, i, (0,80));
end
gif(anim, fps=5)
#------------------------------------------------------------------------------




# ## Leaf nitrogen content
LNC_LUT = load_LUT(LeafNitrogen{FT}());
LNC_LUT = regrid_LUT(LNC_LUT, Int(size(LNC_LUT.data,2)/180));
mask_LUT!(LNC_LUT, FT[0,Inf]);
preview_data(LNC_LUT, 1)
#------------------------------------------------------------------------------




# ## Leaf phosphorus content
LPC_LUT = load_LUT(LeafPhosphorus{FT}());
LPC_LUT = regrid_LUT(LPC_LUT, Int(size(LPC_LUT.data,2)/180));
mask_LUT!(LPC_LUT, FT[0,Inf]);
preview_data(LPC_LUT, 1)
#------------------------------------------------------------------------------




# ## Net primary productivity
NPP_LUT = load_LUT(NPPModis{FT}());
NPP_LUT = regrid_LUT(NPP_LUT, Int(size(NPP_LUT.data,2)/180));
mask_LUT!(NPP_LUT, FT[-Inf,1e19]);
NPP_LUT.data .*= 1e9;
preview_data(NPP_LUT, 1)
#------------------------------------------------------------------------------




# ## Specific leaf area
SLA_LUT = load_LUT(LeafSLA{FT}());
SLA_LUT = regrid_LUT(SLA_LUT, Int(size(SLA_LUT.data,2)/180));
mask_LUT!(SLA_LUT, FT[0,Inf]);
preview_data(SLA_LUT, 1)
#------------------------------------------------------------------------------




# ## Vcmax
VCM_LUT = load_LUT(VcmaxOptimalCiCa{FT}());
VCM_LUT = regrid_LUT(VCM_LUT, Int(size(VCM_LUT.data,2)/180));
mask_LUT!(VCM_LUT, FT[0,Inf]);
preview_data(VCM_LUT, 1)
#------------------------------------------------------------------------------
