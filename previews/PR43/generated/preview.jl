using GriddingMachine
using PkgUtility
using Plots
using Plots.PlotMeasures

ENV["GKSwstype"]="100";
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

LNC_LUT = load_LUT(LeafNitrogenButler{FT}());
mask_LUT!(LNC_LUT, FT[0,Inf]);
LNC_LUT = regrid_LUT(LNC_LUT, Int(size(LNC_LUT.data,2)/180));
preview_data(LNC_LUT, 1)

LNC_LUT = load_LUT(LeafNitrogenBoonman{FT}());
mask_LUT!(LNC_LUT, FT[0,Inf]);
LNC_LUT = regrid_LUT(LNC_LUT, Int(size(LNC_LUT.data,2)/180));
preview_data(LNC_LUT, 1)

LPC_LUT = load_LUT(LeafPhosphorus{FT}());
mask_LUT!(LPC_LUT, FT[0,Inf]);
LPC_LUT = regrid_LUT(LPC_LUT, Int(size(LPC_LUT.data,2)/180));
preview_data(LPC_LUT, 1)

SLA_LUT = load_LUT(LeafSLAButler{FT}());
mask_LUT!(SLA_LUT, FT[0,Inf]);
SLA_LUT = regrid_LUT(SLA_LUT, Int(size(SLA_LUT.data,2)/180));
preview_data(SLA_LUT, 1)

SLA_LUT = load_LUT(LeafSLABoonman{FT}());
mask_LUT!(SLA_LUT, FT[0,Inf]);
SLA_LUT = regrid_LUT(SLA_LUT, Int(size(SLA_LUT.data,2)/180));
preview_data(SLA_LUT, 1)

VCM_LUT = load_LUT(VcmaxOptimalCiCa{FT}());
mask_LUT!(VCM_LUT, FT[0,Inf]);
VCM_LUT = regrid_LUT(VCM_LUT, Int(size(VCM_LUT.data,2)/180));
preview_data(VCM_LUT, 1)

CHT_LUT = load_LUT(CanopyHeightGLAS{FT}());
mask_LUT!(CHT_LUT, FT[0,Inf]);
CHT_LUT = regrid_LUT(CHT_LUT, Int(size(CHT_LUT.data,2)/180));
preview_data(CHT_LUT, 1)

CHT_LUT = load_LUT(CanopyHeightBoonman{FT}());
mask_LUT!(CHT_LUT, FT[0,Inf]);
CHT_LUT = regrid_LUT(CHT_LUT, Int(size(CHT_LUT.data,2)/180));
preview_data(CHT_LUT, 1)

# global clumping index
CLI_LUT = load_LUT(ClumpingIndexMODIS{FT}(), "12X", "1Y");
mask_LUT!(CLI_LUT, FT[0,1]);
CLI_LUT = regrid_LUT(CLI_LUT, Int(size(CLI_LUT.data,2)/180));
preview_data(CLI_LUT, 1, (0.4,1))

# global clumping index per PFT
CLI_LUT = load_LUT(ClumpingIndexPFT{FT}());
mask_LUT!(CLI_LUT, FT[0,1]);
CLI_LUT = regrid_LUT(CLI_LUT, Int(size(CLI_LUT.data,2)/180));
anim = @animate for i ∈ 1:size(CLI_LUT.data,3)
    preview_data(CLI_LUT, i, (0.4,1));
end
gif(anim, fps=1)

# GPP MPI
GPP_LUT = load_LUT(GPPMPIv006{FT}(), 2005, "2X", "8D");
GPP_LUT = regrid_LUT(GPP_LUT, Int(size(GPP_LUT.data,2)/180));
mask_LUT!(GPP_LUT, FT[-100,Inf]);
anim = @animate for i ∈ 1:46
    preview_data(GPP_LUT, i, (0,10));
end
gif(anim, fps=5)

# GPP VPM
GPP_LUT = load_LUT(GPPVPMv20{FT}(), 2005, "5X", "8D");
GPP_LUT = regrid_LUT(GPP_LUT, Int(size(GPP_LUT.data,2)/180));
mask_LUT!(GPP_LUT, FT[-100,Inf]);
anim = @animate for i ∈ 1:46
    preview_data(GPP_LUT, i, (0,10));
end
gif(anim, fps=5)

# Annual data
LAI_LUT = load_LUT(LAIMODISv006{FT}(), 2005, "2X", "8D");
LAI_LUT = regrid_LUT(LAI_LUT, Int(size(LAI_LUT.data,2)/180));
mask_LUT!(LAI_LUT, FT[0,Inf]);
anim = @animate for i ∈ 1:46
    preview_data(LAI_LUT, i, (0,6));
end
gif(anim, fps=5)

# monthly mean of multiple years
LAI_LUT = load_LUT(LAIMonthlyMean{FT}());
LAI_LUT = regrid_LUT(LAI_LUT, Int(size(LAI_LUT.data,2)/180));
anim = @animate for i ∈ 1:size(LAI_LUT.data,3)
    preview_data(LAI_LUT, i, (0,6));
end
gif(anim, fps=1)

NDV_LUT = load_LUT(NDVIAvhrr{FT}(), 2018, "20X", "1M");
NDV_LUT = regrid_LUT(NDV_LUT, Int(size(NDV_LUT.data,2)/180));
anim = @animate for i ∈ 1:size(NDV_LUT.data,3)
    preview_data(NDV_LUT, i, (0,1));
end
gif(anim, fps=1)

NIV_LUT = load_LUT(NIRvAvhrr{FT}(), 2018, "20X", "1M");
NIV_LUT = regrid_LUT(NIV_LUT, Int(size(NIV_LUT.data,2)/180));
anim = @animate for i ∈ 1:size(NIV_LUT.data,3)
    preview_data(NIV_LUT, i, (0,1));
end
gif(anim, fps=1)

NIO_LUT = load_LUT(NIRoAvhrr{FT}(), 2018, "20X", "1M");
NIO_LUT = regrid_LUT(NIO_LUT, Int(size(NIO_LUT.data,2)/180));
anim = @animate for i ∈ 1:size(NIO_LUT.data,3)
    preview_data(NIO_LUT, i, (0,1));
end
gif(anim, fps=1)

NPP_LUT = load_LUT(NPPModis{FT}());
mask_LUT!(NPP_LUT, FT[-Inf,1e19]);
NPP_LUT = regrid_LUT(NPP_LUT, Int(size(NPP_LUT.data,2)/180));
NPP_LUT.data .*= 1e9;
preview_data(NPP_LUT, 1)

VGA_LUT = load_LUT(VGMAlphaJules{FT}(), "12X", "1Y");
mask_LUT!(VGA_LUT, FT[0,Inf]);
VGA_LUT = regrid_LUT(VGA_LUT, Int(size(VGA_LUT.data,2)/180));
anim = @animate for i ∈ 1:4
    preview_data(VGA_LUT, i);
end
gif(anim, fps=1)

VGN_LUT = load_LUT(VGMLogNJules{FT}(), "12X", "1Y");
mask_LUT!(VGN_LUT, FT[0,Inf]);
VGN_LUT = regrid_LUT(VGN_LUT, Int(size(VGN_LUT.data,2)/180));
anim = @animate for i ∈ 1:4
    preview_data(VGN_LUT, i);
end
gif(anim, fps=1)

VGT_LUT = load_LUT(VGMThetaRJules{FT}(), "12X", "1Y");
mask_LUT!(VGT_LUT, FT[0,Inf]);
VGT_LUT = regrid_LUT(VGT_LUT, Int(size(VGT_LUT.data,2)/180));
anim = @animate for i ∈ 1:4
    preview_data(VGT_LUT, i);
end
gif(anim, fps=1)

VGT_LUT = load_LUT(VGMThetaSJules{FT}(), "12X", "1Y");
mask_LUT!(VGT_LUT, FT[0,Inf]);
VGT_LUT = regrid_LUT(VGT_LUT, Int(size(VGT_LUT.data,2)/180));
anim = @animate for i ∈ 1:4
    preview_data(VGT_LUT, i);
end
gif(anim, fps=1)

SIF_LUT = load_LUT(SIFTropomi740{FT}(), 2018, "1X", "1M");
mask_LUT!(SIF_LUT, FT[-100,100]);
anim = @animate for i ∈ 1:12
    preview_data(SIF_LUT, i, (0,3.5));
end
gif(anim, fps=3)

TDT_LUT = load_LUT(TreeDensity{FT}(), "12X", "1Y");
mask_LUT!(TDT_LUT, FT[0,Inf]);
TDT_LUT = regrid_LUT(TDT_LUT, Int(size(TDT_LUT.data,2)/180));
preview_data(TDT_LUT, 1, (0, 150000))

TDT_LUT = load_LUT(WoodDensity{FT}());
mask_LUT!(TDT_LUT, FT[0,Inf]);
TDT_LUT = regrid_LUT(TDT_LUT, Int(size(TDT_LUT.data,2)/180));
preview_data(TDT_LUT, 1)

LMK_LUT = load_LUT(LandMaskERA5{FT}());
LMK_LUT = regrid_LUT(LMK_LUT, Int(size(LMK_LUT.data,2)/180));
preview_data(LMK_LUT, 1)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

