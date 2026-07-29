""" Download the dataset file for a given artifact tag """
function download_dataset!(arttag::String)
    # If dataset not found in the database, update the database. If still not found, return an error
    if !dataset_found(arttag)
        update_database!();
        if !dataset_found(arttag)
            return error("Dataset $arttag does not exist in the database, please check the website for the available datasets!")
        end;
    end;

    # if the dataset file already exists, return the path directly
    dataset_file = dataset_path(arttag);
    if isfile(dataset_file)
        return dataset_file
    end;

    # download the dataset directly from the URL of the associated dataset
    @info "Downloading dataset for $arttag from $(dataset_url(arttag))...";
    cache_file = dataset_cache(arttag);
    urls = dataset_url(arttag);
    pings = Float64[];
    for url in urls
        server_add = replace(match(r"://([^/]+)/", url).captures[1], r":.*" => "");
        push!(pings, ip_address_ping(server_add));
    end;

    # sort the urls based on the ping results
    sorted_indices = sortperm(pings);
    sorted_urls = urls[sorted_indices];
    sorted_pings = pings[sorted_indices];

    # download from the fastest server available
    for i in eachindex(sorted_pings)
        if sorted_pings[i] == Inf
            error("All download servers are unreachable. Please check your internet connection.");
        end;
        try
            Downloads.download(sorted_urls[i], cache_file);
            break;
        catch e
            @warn "Failed to download from $(sorted_urls[i])";
            continue;
        end;
    end;
    mkpath(dataset_dir(arttag));
    mv(cache_file, dataset_file);

    return dataset_file
end;


function ip_address_ping(ipadd::String)
    try
        pinginfo = read(`ping -c 2 -W 2 $(ipadd)`, String);
        # the case in Mac
        if occursin("round-trip min/avg/max/stddev", pinginfo)
            iclip = findfirst("round-trip min/avg/max/stddev = ", pinginfo);
            suminfo = replace(pinginfo[iclip[end]+1:end], "ms\n" => "");
            pings = split(suminfo, "/");
            return parse(Float64, pings[2])
        # the case in Linux
        elseif occursin("time=", pinginfo)
            return parse(Float64, match(r"time=(\d+\.?\d*) ms", pinginfo)[1])
        # unsupported strings
        else
            @error "Unexpected ping output format, cannot parse ping time. Output: $pinginfo";
            return Inf
        end;
    catch
        return Inf
    end;
end;
