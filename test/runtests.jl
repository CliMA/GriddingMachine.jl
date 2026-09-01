using GriddingMachine
using GriddingMachine.Collector
using GriddingMachine.Indexer
using GriddingMachine.Requestor
using GriddingMachine.Server

using HTTP
using JSON
using NetcdfIO: append_nc!, save_nc!
using OrderedCollections: OrderedDict
using SHA
using Sockets
using Test
using YAML

include("fixtures.jl")

@testset verbose = true "GriddingMachine" begin
    @testset verbose = true "Collector" begin
        include("collector.jl")
    end

    @testset "Indexer read_dataset" begin
        include("indexer-read.jl")
    end

    @testset "Model input dictionaries" begin
        include("model-inputs.jl")
    end

    @testset verbose = true "Land datasets and CO2" begin
        include("land-datasets.jl")
    end

    @testset verbose = true "Grid dictionaries from tags" begin
        include("grid-from-tags.jl")
    end

    @testset verbose = true "Server responses" begin
        include("server-responses.jl")
    end

    @testset verbose = true "Server endpoints" begin
        include("server-endpoints.jl")
    end

    @testset verbose = true "Server page" begin
        include("server-page.jl")
    end

    @testset verbose = true "Server and Requestor" begin
        include("server-requestor.jl")
    end
end
