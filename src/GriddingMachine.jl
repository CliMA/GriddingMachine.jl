module GriddingMachine

using Revise


# # make sure the GriddingMachine directory exists
GRIDDINGMACHINE_HOME = joinpath(homedir(), "GriddingMachine");
mkpath(GRIDDINGMACHINE_HOME);
mkpath(joinpath(GRIDDINGMACHINE_HOME, "cache"));
mkpath(joinpath(GRIDDINGMACHINE_HOME, "public"));


# include the modules
include("Collector/Collector.jl");
include("Indexer/Indexer.jl");
include("Requestor/Requestor.jl");
include("Server/Server.jl");


end # module
