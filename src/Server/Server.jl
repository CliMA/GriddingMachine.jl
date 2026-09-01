module Server

import Genie.Renderer.Json as GRJSON

using Genie: down, params, route, up
using OrderedCollections: OrderedDict

using ..Collector: YAML_TAGS, dataset_found, download_dataset!, update_database!
using ..Indexer: LandDatasetLabels, WeatherDriverLabels, grid_dict, grid_weather, read_dataset


include("responses.jl");
include("json-site-data.jl");
include("json-grid-dict.jl");
include("route-setup.jl");
include("route-up-down.jl");


end; # module
