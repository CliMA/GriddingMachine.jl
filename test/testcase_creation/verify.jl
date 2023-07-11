using JSON
using NCDatasets: Dataset, defVar

include("$(@__DIR__)/../../../GriddingMachine.jl/src/borrowed/GriddingMachineData.jl");
using GriddingMachine.Processer
using GriddingMachine.Indexer: read_LUT
using GriddingMachine.Collector: query_collection
using GriddingMachine.Blender: regrid

println("start");

dir = "$(@__DIR__)/../../../GriddingMachine.jl/json/";

files = ["ind_lat_lon", "ind_lon_lat", "lat_lon_ind", "lat_ind_lon", "lon_ind_lat", "lonf_lat_ind", "lon_latf_ind", "lin_scale", "exp_scale", "edge"];

rep_locf = "/home/exgu/GriddingMachine.jl/test/nc_files/reprocessed";

correct = reprocess_data!(rep_locf, JSON.parsefile("$(dir)lon_lat_ind.json"););

for f in files
    _json = "$(dir)$(f).json";

    json_dict = JSON.parse(open(_json));
    name_function = eval(Meta.parse(json_dict["INPUT_MAP_SETS"]["FILE_NAME_FUNCTION"]));
    data_scaling_functions = [_dict["SCALING_FUNCTION"] == "" ? nothing :  eval(Meta.parse(_dict["SCALING_FUNCTION"])) for _dict in json_dict["INPUT_VAR_SETS"]];
    std_scaling_functions = if "INPUT_STD_SETS" in keys(json_dict)
        [_dict["SCALING_FUNCTION"] == "" ? nothing : eval(Meta.parse(_dict["SCALING_FUNCTION"])) for _dict in json_dict["INPUT_STD_SETS"]];
    else
        [nothing for _dict in json_dict["INPUT_VAR_SETS"]];
    end;

    result = reprocess_data!(rep_locf, json_dict; file_name_function = name_function, data_scaling_functions = data_scaling_functions, std_scaling_functions = std_scaling_functions);
    if result != []
        println("$(f) pass = $(isapprox(result, correct; atol = 1e-7))");
    end

end

glob = reprocess_data!(rep_locf, JSON.parsefile("$(dir)glob.json"););
partial = reprocess_data!(rep_locf, JSON.parsefile("$(dir)partial.json"););
if partial != []
    println("partial pass = $(isequal(partial, glob))");
end

#=same_file = reprocess_data!(rep_locf, JSON.parsefile("$(dir)same_file.json"););
combined_file = Processer.combine_files("/home/exgu/GriddingMachine.jl/test/nc_files", ["file_1.nc", "file_2.nc"], "same_file", Dict("description" => "Random data, combined"), ["lon", "lat", "ind"], "combined_file.nc");

Processer.reprocess_files("/home/exgu/GriddingMachine.jl/json", rep_locf);=#

println("ok")
