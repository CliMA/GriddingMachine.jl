using GriddingMachine
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

LCH_LUT = load_LUT(LeafChlorophyll{FT}());
mask_LUT!(LCH_LUT, FT[0,Inf]);
LCH_LUT = regrid_LUT(LCH_LUT, Int(size(LCH_LUT.data,2)/180));
anim = @animate for i ∈ 1:size(LCH_LUT.data,3)
    preview_data(LCH_LUT, i, (0,80));
end
gif(anim, fps=5)

LNC_LUT = load_LUT(LeafNitrogen{FT}());
mask_LUT!(LNC_LUT, FT[0,Inf]);
LNC_LUT = regrid_LUT(LNC_LUT, Int(size(LNC_LUT.data,2)/180));
preview_data(LNC_LUT, 1)

LPC_LUT = load_LUT(LeafPhosphorus{FT}());
mask_LUT!(LPC_LUT, FT[0,Inf]);
LPC_LUT = regrid_LUT(LPC_LUT, Int(size(LPC_LUT.data,2)/180));
preview_data(LPC_LUT, 1)

SLA_LUT = load_LUT(LeafSLA{FT}());
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
anim = @animate for year ∈ 2001:2019, i ∈ 1:46
    GPP_LUT = load_LUT(GPPMPIv006{FT}(), year, "1X", "8D");
    mask_LUT!(GPP_LUT, FT[-100,Inf]);
    preview_data(GPP_LUT, i, (0,10));
end
gif(anim, fps=20)

# GPP VPM
anim = @animate for year ∈ 2000:2019, i ∈ 1:46
    @show year;
    GPP_LUT = load_LUT(GPPVPMv20{FT}(), year, "1X", "8D");
    mask_LUT!(GPP_LUT, FT[-100,Inf]);
    preview_data(GPP_LUT, i, (0,10));
end
gif(anim, fps=20)

LAI_LUT = load_LUT(LAIMonthlyMean{FT}());
LAI_LUT = regrid_LUT(LAI_LUT, Int(size(LAI_LUT.data,2)/180));
anim = @animate for i ∈ 1:size(LAI_LUT.data,3)
    preview_data(LAI_LUT, i, (0,6));
end
gif(anim, fps=1)

NPP_LUT = load_LUT(NPPModis{FT}());
mask_LUT!(NPP_LUT, FT[-Inf,1e19]);
NPP_LUT = regrid_LUT(NPP_LUT, Int(size(NPP_LUT.data,2)/180));
NPP_LUT.data .*= 1e9;
preview_data(NPP_LUT, 1)

TDT_LUT = load_LUT(TreeDensity{FT}(), "12X", "1Y");
mask_LUT!(TDT_LUT, FT[0,Inf]);
TDT_LUT = regrid_LUT(TDT_LUT, Int(size(TDT_LUT.data,2)/180));
preview_data(TDT_LUT, 1, (0, 150000))

ELE_LUT = load_LUT(LandElevation{FT}());
mask_LUT!(ELE_LUT, FT[0,Inf]);
ELE_LUT = regrid_LUT(ELE_LUT, Int(size(ELE_LUT.data,2)/180));
preview_data(ELE_LUT, 1)

LMK_LUT = load_LUT(LandMaskERA5{FT}());
LMK_LUT = regrid_LUT(LMK_LUT, Int(size(LMK_LUT.data,2)/180));
preview_data(LMK_LUT, 1)

FLD_LUT = load_LUT(FloodPlainHeight{FT}());
mask_LUT!(FLD_LUT, FT[0,Inf]);
FLD_LUT = regrid_LUT(FLD_LUT, Int(size(FLD_LUT.data,2)/180));
preview_data(FLD_LUT, 1)

RVH_LUT = load_LUT(RiverHeight{FT}());
mask_LUT!(RVH_LUT, FT[0,Inf]);
RVH_LUT = regrid_LUT(RVH_LUT, Int(size(RVH_LUT.data,2)/180));
preview_data(RVH_LUT, 1)

RVW_LUT = load_LUT(RiverWidth{FT}());
mask_LUT!(RVW_LUT, FT[0,Inf]);
RVW_LUT = regrid_LUT(RVW_LUT, Int(size(RVW_LUT.data,2)/180));
preview_data(RVW_LUT, 1)

RVL_LUT = load_LUT(RiverLength{FT}());
mask_LUT!(RVL_LUT, FT[0,Inf]);
RVL_LUT = regrid_LUT(RVL_LUT, Int(size(RVL_LUT.data,2)/180));
preview_data(RVL_LUT, 1)

RVM_LUT = load_LUT(LandMaskERA5{FT}());
RVM_LUT = regrid_LUT(RVM_LUT, Int(size(RVM_LUT.data,2)/180));
preview_data(RVM_LUT, 1)

UCA_LUT = load_LUT(UnitCatchmentArea{FT}());
UCA_LUT = regrid_LUT(UCA_LUT, Int(size(UCA_LUT.data,2)/180));
preview_data(UCA_LUT, 1)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl
