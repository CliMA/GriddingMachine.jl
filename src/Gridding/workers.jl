###############################################################################
#
# Dynamically change number of workers
#
###############################################################################
"""
    dynamic_workers!(nthread::Int)

Change the number of workers according to CPU_THREADS, given
- `nthread` Number of thread required
"""
function dynamic_workers!(nthread::Int)
    MaxThreads = Sys.CPU_THREADS;

    # if        no worker yet, and nthread <= MaxThreads, hire nthread
    # elseif    no worker yet, but nthread > MaxThreads, hire MaxThreads
    # elseif    some workers already, and nthread <= MaxThreads, hire more
    # elseif    some workers already, and nthread > MaxThreads, hire more
    # else      workers is more than expected, remove the extra
    if (length(workers())==1) && (workers()[1]==1) && (nthread<=MaxThreads)
        addprocs(nthread, exeflags="--project");
    elseif (length(workers())==1) && (workers()[1]==1) && (nthread>MaxThreads)
        addprocs(MaxThreads, exeflags="--project");
    elseif length(workers())<nthread && (nthread<=MaxThreads)
        addprocs(nthread-length(workers()), exeflags="--project");
    elseif length(workers())<MaxThreads && (nthread>MaxThreads)
        addprocs(MaxThreads-length(workers()), exeflags="--project");
    else
        _to_remove = workers()[(nthread+1):end];
        rmprocs(_to_remove...);
    end

    # load the module into each worker
    @everywhere Base.MainInclude.eval(using GriddingMachineOld);

    return nothing
end
