using GriddingMachine.Partitioner
using JSON: parsefile

#clean_files("/net/fluo/data1/group/emilyg/gridded_test", "TROPO_SIF_gridded", 36, 2020);

#println(Partitioner.get_data(parsefile("/home/exgu/GriddingMachine.jl/json/Partition/grid_TROPOMI.json"), 
#                    [(0, 0), (7, 0), (7, 7), (0, 7)], 2020, "sif"))

#Partitioner.partition(parsefile("/home/exgu/GriddingMachine.jl/json/Partition/grid_TROPOMI.json"));

Partitioner.partition(parsefile("/home/exgu/GriddingMachine.jl/json/Partition/grid_TROPOMI_R005.json"));