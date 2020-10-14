var documenterSearchIndex = {"docs":
[{"location":"generated/preview/","page":"Data Preview","title":"Data Preview","text":"EditURL = \"https://github.com/CliMA/GriddingMachine.jl/blob/master/docs/src/preview.jl\"","category":"page"},{"location":"generated/preview/#Dataset-Previews","page":"Data Preview","title":"Dataset Previews","text":"","category":"section"},{"location":"generated/preview/","page":"Data Preview","title":"Data Preview","text":"First, initialize by adding tools and declare floating type","category":"page"},{"location":"generated/preview/","page":"Data Preview","title":"Data Preview","text":"using GriddingMachine\nusing Plots\nusing Plots.PlotMeasures\npyplot();\n\nFT = Float32;\nnothing #hide","category":"page"},{"location":"generated/preview/","page":"Data Preview","title":"Data Preview","text":"Then, define a function to plot the dataset","category":"page"},{"location":"generated/preview/","page":"Data Preview","title":"Data Preview","text":"function preview_data(ds::GriddedDataset{FT}, ind::Int)\n    # regrid data if needed\n    lat_size = size(ds.data,2);\n    if (lat_size > 180) && (lat_size%180 == 0)\n        _ds = regrid_LUT(ds, Int(lat_size/180));\n    else\n        _ds = ds;\n    end\n\n    # preview data\n    map = heatmap(view(_ds.data,:,:,ind)',\n                  origin=\"lower\",\n                  aspect_ratio=1,\n                  xticks=[],\n                  yticks=[],\n                  c=:viridis,\n                  size=(700,300),\n                  framestyle=:none,\n                  right_margin=10px);\n\n    return map\nend\n\nfunction preview_data(ds::GriddedDataset{FT}, ind::Int, clim::Tuple)\n    # regrid data if needed\n    lat_size = size(ds.data,2);\n    if (lat_size > 180) && (lat_size%180 == 0)\n        _ds = regrid_LUT(ds, Int(lat_size/180));\n    else\n        _ds = ds;\n    end\n\n    # preview data\n    map = heatmap(view(_ds.data,:,:,ind)',\n                  origin=\"lower\",\n                  aspect_ratio=1,\n                  xticks=[],\n                  yticks=[],\n                  c=:viridis,\n                  clim=clim,\n                  size=(700,300),\n                  framestyle=:none,\n                  right_margin=10px);\n\n    return map\nend","category":"page"},{"location":"generated/preview/#Canopy-height","page":"Data Preview","title":"Canopy height","text":"","category":"section"},{"location":"generated/preview/","page":"Data Preview","title":"Data Preview","text":"CHT_LUT = load_LUT(CanopyHeightGLAS{FT}());\npreview_data(CHT_LUT, 1)","category":"page"},{"location":"generated/preview/#Clumping-index","page":"Data Preview","title":"Clumping index","text":"","category":"section"},{"location":"generated/preview/","page":"Data Preview","title":"Data Preview","text":"CLI_LUT = load_LUT(ClumpingIndexPFT{FT}());\nmask_LUT!(CLI_LUT, FT[0,1])\nanim = @animate for i ∈ 1:size(CLI_LUT.data,3)\n    preview_data(CLI_LUT, i, (0,1));\nend\ngif(anim, fps=1)","category":"page"},{"location":"generated/preview/#Leaf-area-index","page":"Data Preview","title":"Leaf area index","text":"","category":"section"},{"location":"generated/preview/","page":"Data Preview","title":"Data Preview","text":"LAI_LUT = load_LUT(LAIMonthlyMean{FT}());\nanim = @animate for i ∈ 1:size(LAI_LUT.data,3)\n    preview_data(LAI_LUT, i, (0,6));\nend\ngif(anim, fps=1)","category":"page"},{"location":"generated/preview/#Leaf-nitrogen-content","page":"Data Preview","title":"Leaf nitrogen content","text":"","category":"section"},{"location":"generated/preview/","page":"Data Preview","title":"Data Preview","text":"LNC_LUT = load_LUT(LeafNitrogen{FT}());\nmask_LUT!(LNC_LUT, FT[0,Inf]);\npreview_data(LNC_LUT, 1)","category":"page"},{"location":"generated/preview/#Leaf-phosphorus-content","page":"Data Preview","title":"Leaf phosphorus content","text":"","category":"section"},{"location":"generated/preview/","page":"Data Preview","title":"Data Preview","text":"LPC_LUT = load_LUT(LeafPhosphorus{FT}());\nmask_LUT!(LPC_LUT, FT[0,Inf]);\npreview_data(LPC_LUT, 1)","category":"page"},{"location":"generated/preview/#Net-primary-productivity","page":"Data Preview","title":"Net primary productivity","text":"","category":"section"},{"location":"generated/preview/","page":"Data Preview","title":"Data Preview","text":"NPP_LUT = load_LUT(NPPModis{FT}());\nmask_LUT!(NPP_LUT, FT[-Inf,1e19]);\nNPP_LUT.data .*= 1e9;\npreview_data(NPP_LUT, 1)","category":"page"},{"location":"generated/preview/#Specific-leaf-area","page":"Data Preview","title":"Specific leaf area","text":"","category":"section"},{"location":"generated/preview/","page":"Data Preview","title":"Data Preview","text":"SLA_LUT = load_LUT(LeafSLA{FT}());\nmask_LUT!(SLA_LUT, FT[0,Inf]);\npreview_data(SLA_LUT, 1)","category":"page"},{"location":"generated/preview/#Vcmax","page":"Data Preview","title":"Vcmax","text":"","category":"section"},{"location":"generated/preview/","page":"Data Preview","title":"Data Preview","text":"VCM_LUT = load_LUT(VcmaxOptimalCiCa{FT}());\nmask_LUT!(VCM_LUT, FT[0,Inf]);\npreview_data(VCM_LUT, 1)","category":"page"},{"location":"generated/preview/","page":"Data Preview","title":"Data Preview","text":"","category":"page"},{"location":"generated/preview/","page":"Data Preview","title":"Data Preview","text":"This page was generated using Literate.jl.","category":"page"},{"location":"#GriddingMachine","page":"Home","title":"GriddingMachine","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Global datasets to feed CliMA Land model","category":"page"},{"location":"#Usage","page":"Home","title":"Usage","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"# not registered for now\nusing Pkg;\nPkg.add(PackageSpec(url=\"https://github.com/CliMA/GriddingMachine.jl.git\", rev=\"main\"));\n\nusing GriddingMachine\n\nFT = Float32;\nLAI_LUT = load_LUT(LAIMonthlyMean{FT}());\n# read the lai at lat=30, lon=-100, month=Augest\nlai_val = read_LUT(LAI_LUT, FT(30), FT(-100), 8);\n@show lai_val;","category":"page"},{"location":"#Collected-Datasets","page":"Home","title":"Collected Datasets","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Structure Name Artifact Description\nCanopyHeightGLAS canopy_height_0_05_deg 1/2 degree resolution, year 2005\nClumpingIndexMODIS clumping_index_500_m 1/240 degree resolution, year 2006\nClumpingIndexPFT clumping_index_0_5_deg_PFT 1/2 degree resolution per PFT, year 2006\nGPPMPIv006 MPI_GPP_v006_0_5_deg_8D 1/2 degree resolution per 8 days, year 2001-2019\n MPI_GPP_v006_0_5_deg_1M 1/2 degree resolution per month, year 2001-2019\nGPPVPMv20 VPM_GPP_v20_0_2_deg_8D 1/5 degree resolution per 8 days, year 2000-2019\n VPM_GPP_v20_0_083_deg_8D 1/12 degree resolution per 8 days, year 2000-2019\nLAIMonthlyMean lai_monthly_mean 1/4 degree resolution per month, mean of year 1981-2015\nLeafNitrogen leaf_sla_n_p_0_5_deg 1/2 degree resolution, mean from report literature\nLeafPhosphorus  \nLeafSLA  \nNPPModis npp_1_deg 1 degree resolution, year 2000\nVcmaxOptimalCiCa vcmax_0_5_deg 1/2 degree resolution, derived from optimal Ci/Ca","category":"page"},{"location":"API/#API","page":"API","title":"API","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"CurrentModule = GriddingMachine","category":"page"},{"location":"API/#Datasets-for-Clima-Look-Up-Table","page":"API","title":"Datasets for Clima Look-Up-Table","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"All data are stored in a general structure, but they are catergorized to     different data types. The general data structure is","category":"page"},{"location":"API/","page":"API","title":"API","text":"GriddedDataset","category":"page"},{"location":"API/#GriddingMachine.GriddedDataset","page":"API","title":"GriddingMachine.GriddedDataset","text":"struct GriddedDataset{FT<:AbstractFloat}\n\nA general struct to store data\n\nFields\n\ndata\nMonthly mean LAI\nres_lat\nLatitude resolution [°]\nres_lon\nLongitude resolution [°]\nres_time\nTime resolution: D-M-Y-C: day-month-year-century\ndt\nType label\n\n\n\n\n\n","category":"type"},{"location":"API/","page":"API","title":"API","text":"Note it here that the dt field in GriddedDataset is the data     identity of the stored data. Please refer the lists below","category":"page"},{"location":"API/#Dataset-types","page":"API","title":"Dataset types","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"Current supported dataset formats are","category":"page"},{"location":"API/","page":"API","title":"API","text":"AbstractFormat\nFormatNC\nFormatTIFF","category":"page"},{"location":"API/#GriddingMachine.AbstractFormat","page":"API","title":"GriddingMachine.AbstractFormat","text":"abstract type AbstractFormat\n\nHierachy of AbstractFormat\n\nFormatTIFF\nFormatNC\n\n\n\n\n\n","category":"type"},{"location":"API/#GriddingMachine.FormatNC","page":"API","title":"GriddingMachine.FormatNC","text":"struct FormatNC\n\n\n\n\n\n","category":"type"},{"location":"API/#GriddingMachine.FormatTIFF","page":"API","title":"GriddingMachine.FormatTIFF","text":"struct FormatTIFF\n\n\n\n\n\n","category":"type"},{"location":"API/#General-type","page":"API","title":"General type","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"AbstractDataset","category":"page"},{"location":"API/#GriddingMachine.AbstractDataset","page":"API","title":"GriddingMachine.AbstractDataset","text":"abstract type AbstractDataset{FT}\n\nHierachy of AbstractDataset\n\nAbstractCanopyHeight\nAbstractClumpingIndex\nAbstractGPP\nAbstractLAI\nAbstractLeafMN\nAbstractNPP\nAbstractVcmax\n\n\n\n\n\n","category":"type"},{"location":"API/#Canopy-height","page":"API","title":"Canopy height","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"AbstractCanopyHeight\nCanopyHeightGLAS","category":"page"},{"location":"API/#GriddingMachine.AbstractCanopyHeight","page":"API","title":"GriddingMachine.AbstractCanopyHeight","text":"abstract type AbstractCanopyHeight{FT}\n\nHierachy of AbstractCanopyHeight\n\nCanopyHeightGLAS\n\n\n\n\n\n","category":"type"},{"location":"API/#GriddingMachine.CanopyHeightGLAS","page":"API","title":"GriddingMachine.CanopyHeightGLAS","text":"struct GPPMPIv006{FT}\n\nStruct for canopy height from GLAS ICESat\n\n\n\n\n\n","category":"type"},{"location":"API/#Clumping-index","page":"API","title":"Clumping index","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"AbstractClumpingIndex\nClumpingIndexMODIS\nClumpingIndexPFT","category":"page"},{"location":"API/#GriddingMachine.AbstractClumpingIndex","page":"API","title":"GriddingMachine.AbstractClumpingIndex","text":"abstract type AbstractCanopyHeight{FT}\n\nHierachy of AbstractCanopyHeight\n\nClumpingIndexMODIS\nClumpingIndexPFT\n\n\n\n\n\n","category":"type"},{"location":"API/#GriddingMachine.ClumpingIndexMODIS","page":"API","title":"GriddingMachine.ClumpingIndexMODIS","text":"struct GPPMPIv006{FT}\n\nStruct for canopy height from GLAS ICESat\n\n\n\n\n\n","category":"type"},{"location":"API/#GriddingMachine.ClumpingIndexPFT","page":"API","title":"GriddingMachine.ClumpingIndexPFT","text":"struct GPPMPIv006{FT}\n\nStruct for canopy height from GLAS ICESat, for different plant functional     types. The indices are Broadleaf, Needleleaf, C3 grasses, C4 grasses,     and shrubland\n\n\n\n\n\n","category":"type"},{"location":"API/#Gross-primary-productivity","page":"API","title":"Gross primary productivity","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"AbstractGPP\nGPPMPIv006\nGPPVPMv20","category":"page"},{"location":"API/#GriddingMachine.AbstractGPP","page":"API","title":"GriddingMachine.AbstractGPP","text":"abstract type AbstractGPP{FT}\n\nHierachy of AbstractGPP\n\nGPPMPIv006\nGPPVPMv20\n\n\n\n\n\n","category":"type"},{"location":"API/#GriddingMachine.GPPMPIv006","page":"API","title":"GriddingMachine.GPPMPIv006","text":"struct GPPMPIv006{FT}\n\nStruct for MPI GPP v006\n\n\n\n\n\n","category":"type"},{"location":"API/#GriddingMachine.GPPVPMv20","page":"API","title":"GriddingMachine.GPPVPMv20","text":"struct GPPVPMv20{FT}\n\nStruct for VPM GPP v20\n\n\n\n\n\n","category":"type"},{"location":"API/#Leaf-area-index","page":"API","title":"Leaf area index","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"AbstractLAI\nLAIMonthlyMean","category":"page"},{"location":"API/#GriddingMachine.AbstractLAI","page":"API","title":"GriddingMachine.AbstractLAI","text":"abstract type AbstractLAI{FT}\n\nHierachy of AbstractLAI\n\nLAIMonthlyMean\n\n\n\n\n\n","category":"type"},{"location":"API/#GriddingMachine.LAIMonthlyMean","page":"API","title":"GriddingMachine.LAIMonthlyMean","text":"struct LAIMonthlyMean{FT}\n\nStruct for monthly mean MODIS LAI\n\n\n\n\n\n","category":"type"},{"location":"API/#Leaf-mass-and-nutrients","page":"API","title":"Leaf mass and nutrients","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"AbstractLeafMN\nLeafSLA\nLeafNitrogen\nLeafPhosphorus","category":"page"},{"location":"API/#GriddingMachine.AbstractLeafMN","page":"API","title":"GriddingMachine.AbstractLeafMN","text":"abstract type AbstractLeafMN{FT}\n\nHierachy of AbstractLAI\n\nLeafNitrogen\nLeafPhosphorus\nLeafSLA\n\n\n\n\n\n","category":"type"},{"location":"API/#GriddingMachine.LeafSLA","page":"API","title":"GriddingMachine.LeafSLA","text":"struct LeafSLA{FT}\n\nStruct for leaf specific leaf area (inverse of leaf mass per area)\n\n\n\n\n\n","category":"type"},{"location":"API/#GriddingMachine.LeafNitrogen","page":"API","title":"GriddingMachine.LeafNitrogen","text":"struct LeafNitrogen{FT}\n\nStruct for leaf nitrogen content\n\n\n\n\n\n","category":"type"},{"location":"API/#GriddingMachine.LeafPhosphorus","page":"API","title":"GriddingMachine.LeafPhosphorus","text":"struct LeafPhosphorus{FT}\n\nStruct for leaf specific leaf area (inverse of leaf mass per area)\n\n\n\n\n\n","category":"type"},{"location":"API/#Net-primary-productivity","page":"API","title":"Net primary productivity","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"AbstractNPP\nNPPModis","category":"page"},{"location":"API/#GriddingMachine.AbstractNPP","page":"API","title":"GriddingMachine.AbstractNPP","text":"abstract type AbstractNPP{FT}\n\nHierachy of AbstractLAI\n\nNPPModis\n\n\n\n\n\n","category":"type"},{"location":"API/#GriddingMachine.NPPModis","page":"API","title":"GriddingMachine.NPPModis","text":"struct NPPModis{FT}\n\nStruct for Modis NPP\n\n\n\n\n\n","category":"type"},{"location":"API/#Vcmax","page":"API","title":"Vcmax","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"AbstractVcmax\nVcmaxOptimalCiCa","category":"page"},{"location":"API/#GriddingMachine.AbstractVcmax","page":"API","title":"GriddingMachine.AbstractVcmax","text":"abstract type AbstractLAI{FT}\n\nHierachy of AbstractVcmax\n\nVcmaxOptimalCiCa\n\n\n\n\n\n","category":"type"},{"location":"API/#GriddingMachine.VcmaxOptimalCiCa","page":"API","title":"GriddingMachine.VcmaxOptimalCiCa","text":"struct VcmaxOptimalCiCa{FT}\n\nStruct for Vcmax estimated from optimal Ci:Ca ratio\n\n\n\n\n\n","category":"type"},{"location":"API/#LOAD-and-READ-Look-Up-Table","page":"API","title":"LOAD and READ Look-Up-Table","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"Griddingmachine package allows for reading data from both the artifact and     local files. To read the artifacts, function query_LUT is     provided:","category":"page"},{"location":"API/","page":"API","title":"API","text":"query_LUT","category":"page"},{"location":"API/#GriddingMachine.query_LUT","page":"API","title":"GriddingMachine.query_LUT","text":"query_LUT(dt::AbstractDataset)\nquery_LUT(dt::AbstractDataset, year::Int, res_g::Number, res_t::String)\n\nQuery the file location from artifacts,\n\ndt Dataset type, subtype of AbstractDataset\nyear Which year\nres_g Resolution in degree\nres_t Resolution in time\n\n\n\n\n\n","category":"function"},{"location":"API/","page":"API","title":"API","text":"A general function is provided to load the look-up tables. Before you load the     table, you need to know what data you want to read (see     AbstractDataset), data from which year (required for some     datasets), geophysical resolution (required for some datasets), and time     resolution (resuired for some datasets). Also, if you want to load local     files, you need to know the file name, dataset format, and the dataset     label (e.g., variable name in *.nc files, or band number in *.tif files).     Be aware that some datasets may be very big, be patient when downloading     the data files. Also, you need to use computers or servers with enough     memory, otherwise the program may crash when loading the data.","category":"page"},{"location":"API/","page":"API","title":"API","text":"load_LUT","category":"page"},{"location":"API/#GriddingMachine.load_LUT","page":"API","title":"GriddingMachine.load_LUT","text":"load_LUT(dt::AbstractDataset{FT}) where {FT<:AbstractFloat}\nload_LUT(dt::AbstractDataset{FT},\n         year::Int,\n         res_g::Number,\n         res_t::String) where {FT<:AbstractFloat}\nload_LUT(dt::AbstractDataset{FT},\n         file::String,\n         format::AbstractFormat,\n         label::String,\n         res_t::String,\n         rev_lat::Bool) where {FT<:AbstractFloat}\n\nLoad look up table and return the struct, given\n\ndt Dataset type, subtype of AbstractDataset\nyear Which year\nres_g Resolution in degree\nres_t Resolution in time\nfile File name to read, useful to read local files\nformat Dataset format from AbstractFormat\nlabel Variable label in dataset, e.g., var name in .nc files, band numer in   .tif files\nrev_lat Whether latitude is stored reversely in the dataset, e.g., 90 to   -90. If true, mirror the dataset on latitudinal direction\n\nNote that the artifact for GPP is about\n\n500 MB for 0.2 degree resolution (5^2 * 36018046)\n2600 MB for 0.083 degree resolution (12^2 * 36018046)\n\n\n\n\n\n","category":"function"},{"location":"API/","page":"API","title":"API","text":"The loaded data may contain null values filled with different default values.     To remove these unexpected data, a general function is provided to mask out     these values.","category":"page"},{"location":"API/","page":"API","title":"API","text":"mask_LUT!","category":"page"},{"location":"API/#GriddingMachine.mask_LUT!","page":"API","title":"GriddingMachine.mask_LUT!","text":"mask_LUT!(ds::GriddedDataset, default::Number)\nmask_LUT!(ds::GriddedDataset, lims::Array)\n\nFilter out the unrealistic values from the dataset, given\n\nds GriddedDataset type struct\ndefault Optional. Default value to replace NaNs\nlims Lower and upper limits for the dataset\n\n\n\n\n\n","category":"function"},{"location":"API/","page":"API","title":"API","text":"A general function is provided to read the look-up tables. Note that you need     to use realistic latitude, longitude, and index (required for some     datasets) to read the data properly. For example, latitude must be within     the range of [-90,90], longitude must be within the range of [-180,180]     or [0,360], and index must be in [1,12] if you use it as month or     [0,46] if you read the 8-day products. The functions lat_ind     and lon_ind help convert latitude and longitude into index,     respectively.","category":"page"},{"location":"API/","page":"API","title":"API","text":"read_LUT\nlat_ind\nlon_ind","category":"page"},{"location":"API/#GriddingMachine.read_LUT","page":"API","title":"GriddingMachine.read_LUT","text":"read_LUT(ds::GriddedDataset{FT},\n         lat::FT,\n         lon::FT) where {FT<:AbstractFloat}\nread_LUT(ds::GriddedDataset{FT},\n         lat::FT,\n         lon::FT,\n         ind::Int) where {FT<:AbstractFloat}\nread_LUT(ds::GriddedDataset{FT},\n         dt::AbstractDataset{FT},\n         lat::FT,\n         lon::FT) where {FT<:AbstractFloat}\nread_LUT(ds::GriddedDataset{FT},\n         dt::AbstractDataset{FT},\n         lat::FT,\n         lon::FT,\n         ind::Int) where {FT<:AbstractFloat}\n\nRead the LAI from given\n\nds GriddedDataset type struct\ndt Dataset type, subtype of AbstractDataset\nlat Latitude\nlon Longitude\nind Index of cycle in the year, e.g., 1-46, or Month number from 1 to 12   for LAIMonthlyMean DataType\n\n\n\n\n\n","category":"function"},{"location":"API/#GriddingMachine.lat_ind","page":"API","title":"GriddingMachine.lat_ind","text":"lat_ind(lat::FT; res::FT) where {FT<:AbstractFloat}\n\nRound the latitude and return the index in a matrix, Given\n\nlat Latitude\nres Resolution in latitude\n\n\n\n\n\n","category":"function"},{"location":"API/#GriddingMachine.lon_ind","page":"API","title":"GriddingMachine.lon_ind","text":"lon_ind(lon::FT; res::FT=1) where {FT<:AbstractFloat}\n\nRound the longitude and return the index in a matrix, Given\n\nlon Longitude\nres Resolution in longitude\n\n\n\n\n\n","category":"function"},{"location":"API/#Regrid-the-Look-Up-Table","page":"API","title":"Regrid the Look-Up-Table","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"For better matching the gridded data, we also provide a function to regrid the     dataset.","category":"page"},{"location":"API/","page":"API","title":"API","text":"regrid_LUT","category":"page"},{"location":"API/#GriddingMachine.regrid_LUT","page":"API","title":"GriddingMachine.regrid_LUT","text":"regrid_LUT(ds::AbstractDataset{FT},\n           zoom::Int;\n           nan_weight::Bool=false\n) where {FT<:AbstractFloat}\n\nRegrid the data from high to low resolution and return the struct, given\n\nds GriddedDataset type struct\nzoom Integer geophysical zoom factor (>=2)\nnan_weight Optional. If true, assuming nan = 0; if false, neglecting it.\n\n\n\n\n\n","category":"function"}]
}
