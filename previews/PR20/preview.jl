# # Dataset Previews




# First, initialize by adding tools and declare floating type
using GriddingMachine
using Plots
using Plots.PlotMeasures
pyplot();

FT = Float32;
#------------------------------------------------------------------------------




# Then, define a function to plot the dataset
function preview_data(ds::GriddedDataset{FT}, ind::Int)
    ## regrid data if needed
    lat_size = size(ds.data,2);
    if (lat_size > 180) && (lat_size%180 == 0)
        _ds = regrid_LUT(ds, Int(lat_size/180));
    else
        _ds = ds;
    end

    ## preview data
    map = heatmap(view(_ds.data,:,:,ind)',
                  origin="lower",
                  aspect_ratio=1,
                  xticks=[],
                  yticks=[],
                  c=:viridis,
                  size=(700,300),
                  framestyle=:none,
                  right_margin=10px);

    return map
end

function preview_data(ds::GriddedDataset{FT}, ind::Int, clim::Tuple)
    ## regrid data if needed
    lat_size = size(ds.data,2);
    if (lat_size > 180) && (lat_size%180 == 0)
        _ds = regrid_LUT(ds, Int(lat_size/180));
    else
        _ds = ds;
    end

    ## preview data
    map = heatmap(view(_ds.data,:,:,ind)',
                  origin="lower",
                  aspect_ratio=1,
                  xticks=[],
                  yticks=[],
                  c=:viridis,
                  clim=clim,
                  size=(700,300),
                  framestyle=:none,
                  right_margin=10px);

    return map
end
#------------------------------------------------------------------------------




# ## Canopy height
CHT_LUT = load_LUT(CanopyHeightGLAS{FT}());
preview_data(CHT_LUT, 1)
#------------------------------------------------------------------------------




# ## Clumping index
CLI_LUT = load_LUT(ClumpingIndexPFT{FT}());
mask_LUT!(CLI_LUT, FT[0,1])
anim = @animate for i ∈ 1:size(CLI_LUT.data,3)
    preview_data(CLI_LUT, i, (0,1));
end
gif(anim, fps=1)
#------------------------------------------------------------------------------




# ## Leaf area index
LAI_LUT = load_LUT(LAIMonthlyMean{FT}());
anim = @animate for i ∈ 1:size(LAI_LUT.data,3)
    preview_data(LAI_LUT, i, (0,6));
end
gif(anim, fps=1)
#------------------------------------------------------------------------------




# ## Leaf nitrogen content
LNC_LUT = load_LUT(LeafNitrogen{FT}());
mask_LUT!(LNC_LUT, FT[0,Inf]);
preview_data(LNC_LUT, 1)
#------------------------------------------------------------------------------




# ## Leaf phosphorus content
LPC_LUT = load_LUT(LeafPhosphorus{FT}());
mask_LUT!(LPC_LUT, FT[0,Inf]);
preview_data(LPC_LUT, 1)
#------------------------------------------------------------------------------




# ## Net primary productivity
NPP_LUT = load_LUT(NPPModis{FT}());
mask_LUT!(NPP_LUT, FT[-Inf,1e19]);
NPP_LUT.data .*= 1e9;
preview_data(NPP_LUT, 1)
#------------------------------------------------------------------------------




# ## Specific leaf area
SLA_LUT = load_LUT(LeafSLA{FT}());
mask_LUT!(SLA_LUT, FT[0,Inf]);
preview_data(SLA_LUT, 1)
#------------------------------------------------------------------------------




# ## Vcmax
VCM_LUT = load_LUT(VcmaxOptimalCiCa{FT}());
mask_LUT!(VCM_LUT, FT[0,Inf]);
preview_data(VCM_LUT, 1)
#------------------------------------------------------------------------------
