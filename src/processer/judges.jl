#=
#Y/N response
_jdg_1(x) = (x in ["N", "NO", "Y", "YES"]);

#Check if path to Artifacts.toml given
_jdg_2(x) = (
    length(x) >= 14 && x[end-13:end] == "Artifacts.toml" && isfile(x)
);

#Check if Strings separated by commas given
_jdg_3(x) = (
    try
        split(x, ",");
        return true;
    catch e
        return false;
    end;
);

#Check/create directory
_jdg_6(x) = (
    if isdir(x) return true end;
    try
        mkpath(x);
        return true
    catch e
        return false
    end;
);

#Check if JSON file name given
_jdg_7(x) = (length(x) >= 5 && x[end-4:end] == ".json");
=#
