using GriddingMachine
using Plots
using Plots.PlotMeasures

FT = Float32;

function preview_data(ds::GriddedDataset{FT}, ind::Int)
    # preview data
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
    # preview data
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

CHT_LUT = load_LUT(CanopyHeightGLAS{FT}());
CHT_LUT = regrid_LUT(CHT_LUT, Int(size(CHT_LUT.data,2)/180));
preview_data(CHT_LUT, 1)

CLI_LUT = load_LUT(ClumpingIndexPFT{FT}());
CLI_LUT = regrid_LUT(CLI_LUT, Int(size(CLI_LUT.data,2)/180));
mask_LUT!(CLI_LUT, FT[0,1])
anim = @animate for i ∈ 1:size(CLI_LUT.data,3)
    preview_data(CLI_LUT, i, (0,1));
end
gif(anim, fps=1)

LAI_LUT = load_LUT(LAIMonthlyMean{FT}());
LAI_LUT = regrid_LUT(LAI_LUT, Int(size(LAI_LUT.data,2)/180));
anim = @animate for i ∈ 1:size(LAI_LUT.data,3)
    preview_data(LAI_LUT, i, (0,6));
end
gif(anim, fps=1)

LCH_LUT = load_LUT(LeafChlorophyll{FT}());
LCH_LUT = regrid_LUT(LCH_LUT, Int(size(LCH_LUT.data,2)/180));
mask_LUT!(CLI_LUT, FT[0,Inf])
anim = @animate for i ∈ 1:size(LCH_LUT.data,3)
    preview_data(LCH_LUT, i, (0,80));
end
gif(anim, fps=5)

LNC_LUT = load_LUT(LeafNitrogen{FT}());
LNC_LUT = regrid_LUT(LNC_LUT, Int(size(LNC_LUT.data,2)/180));
mask_LUT!(LNC_LUT, FT[0,Inf]);
preview_data(LNC_LUT, 1)

LPC_LUT = load_LUT(LeafPhosphorus{FT}());
LPC_LUT = regrid_LUT(LPC_LUT, Int(size(LPC_LUT.data,2)/180));
mask_LUT!(LPC_LUT, FT[0,Inf]);
preview_data(LPC_LUT, 1)

NPP_LUT = load_LUT(NPPModis{FT}());
NPP_LUT = regrid_LUT(NPP_LUT, Int(size(NPP_LUT.data,2)/180));
mask_LUT!(NPP_LUT, FT[-Inf,1e19]);
NPP_LUT.data .*= 1e9;
preview_data(NPP_LUT, 1)

SLA_LUT = load_LUT(LeafSLA{FT}());
SLA_LUT = regrid_LUT(SLA_LUT, Int(size(SLA_LUT.data,2)/180));
mask_LUT!(SLA_LUT, FT[0,Inf]);
preview_data(SLA_LUT, 1)

VCM_LUT = load_LUT(VcmaxOptimalCiCa{FT}());
VCM_LUT = regrid_LUT(VCM_LUT, Int(size(VCM_LUT.data,2)/180));
mask_LUT!(VCM_LUT, FT[0,Inf]);
preview_data(VCM_LUT, 1)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

