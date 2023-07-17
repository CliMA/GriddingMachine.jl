const FTP_URLS = ["ftp://fluo.gps.caltech.edu/XYZT_GRIDDING_MACHINE/artifacts"];

using JSON
using ArchGDAL: read, getband

include("process_json/deploy.jl")
include("process_json/data_read.jl")
include("process_json/data_reprocess.jl")
include("process_json/json_attribute.jl")
include("process_json/json_data.jl")
include("process_json/json_griddingmachine.jl")
include("process_json/json_map.jl")
include("process_json/json_save.jl")

include("geotiff/read.jl")
