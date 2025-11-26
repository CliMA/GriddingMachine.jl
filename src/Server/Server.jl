module Server

import Genie.Renderer.Json as GRJSON

using Genie: down, params, route, up

using ..Collector: YAML_TAGS, download_dataset!, update_database!
using ..Indexer: read_dataset


include("json-site-data.jl");
include("route-setup.jl");
include("route-up-down.jl");


# import Genie.Renderer.Html as GRHTML
#
# using Dates: format, now, seconds
# using Genie.Requests: postpayload
# using Pkg: dependencies





# download the Artifacts.yaml file to local GriddingMachine folder
# GM.update_database!();


# determine the GriddingMachine version
# DEPS = dependencies();
# VERS = nothing;
# for (_uuid, _dep) in DEPS
#     global VERS;
#     if _dep.name == "GriddingMachine"
#         VERS = _dep.version;
#         break;
#     end;
# end;


# the features meant for different servers
# include("json/artifact_url.jl");
# include("json/sitedata_json.jl");
# include("json/gmdict_json.jl");
# include("json/weather_json.jl");

# setup the the servers
# include("server/url_routes.jl");
# include("server/form_templates.jl");
# include("server/form_routes.jl");
# include("server/up_down.jl");

# tunnel routes to protect private IP to avoid public exposure
# include("server/tunnel_routes.jl");


end; # module
