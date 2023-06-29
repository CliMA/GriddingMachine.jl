module Processer

include("borrowed/GriddingMachineData.jl")

"""
    combine_files(folder::String)
"""
function combine_files end

combine_files(folder::String) = (
    files = String[_file for _file in readdir(folder)];
)


"""
    reprocess_files()

Reprocess user's dataset(s) and create corresponding JSON file(s). All information is entered manually by the user.

#
    reprocess_files(JSON_locf::String, rep_locf::String)

Reprocess user's dataset(s) and create corresponding JSON file(s) with folder paths given.

- `JSON_locf` Path of folder where the created JSON file will be stored
- `rep_locf` Path of folder where the reprocessed dataset will be stored

"""
function reprocess_files end

reprocess_files() = (
    @info "Please follow the instructions to create a JSON file for your dataset(s) and reprocess your dataset(s)";

    _jdg_1(x) = (x in ["N", "NO", "Y", "YES"]);
    _jdg_6(x) = (
        if isdir(x) return true end;
        try 
            mkpath(x);
            return true
        catch e
            return false
        end;
    );
    _jdg_7(x) = (length(x) >= 5 && x[end-4:end] == ".json");
    
    while true
        #Get user input for directories
        _msg = "Please input the folder path of the JSON file you want to create > ";
        JSON_locf = verified_input(_msg, _jdg_6); #check if folder exists; if not, one is created
        _msg = "Please input the file name of the JSON file you want to create (file_name.json) > ";
        JSON_name = verified_input(_msg, _jdg_7); #check if a JSON file name is given
        _msg = "Please input the folder path of the reprocessed file you want to create > ";
        rep_locf = verified_input(_msg, _jdg_6); #check if folder exists; if not, one is created

        #Process the file and store JSON and reprocessed files in given directories
        _json = "$(JSON_locf)/$(JSON_name)";
        reprocess_file(_json, rep_locf);

        #

        #Ask user if they want to reprocess another dataset
        _msg = "Do you want to reprocess another dataset? Type Y/y or N/n to continue > ";
        if (verified_input(_msg, uppercase, _jdg_1) in ["N", "NO"])
            return nothing;
        end;
    end;
    
    return nothing;
    
);


reprocess_files(JSON_locf::String, rep_locf::String) = (
    @info "Please follow the instructions to create a JSON file for your dataset(s) and reprocess your dataset(s)";

    _jdg_1(x) = (x in ["N", "NO", "Y", "YES"]);
    _jdg_7(x) = (length(x) >= 5 && x[end-4:end] == ".json");

    while true
        #Get user input for directories
        _msg = "Please input the file name of the JSON file you want to create (file_name.json) > ";
        JSON_name = verified_input(_msg, _jdg_7); #check if a JSON file name is given

        #Process the file and store JSON and reprocessed files in given directories
        _json = "$(JSON_locf)/$(JSON_name)";
        reprocess_file(_json, rep_locf);

        #Ask user if they want to reprocess another dataset
        _msg = "Do you want to reprocess another dataset? Type Y/y or N/n to continue > ";
        if (verified_input(_msg, uppercase, _jdg_1) in ["N", "NO"])
            return nothing;
        end;
    end;

    return nothing;

);


"""
    reprocess_file(_json::String, rep_locf::String)

This is a helper method that creates a single JSON file based on user input and reprocesses the data represented by the JSON file 

- `_json` Path of JSON file to be created
- `rep_locf` Path of folder where the reprocessed dataset will be stored

"""
function reprocess_file end;

reprocess_file(_json::String, rep_locf::String) = (

    _jdg_1(x) = (x in ["N", "NO", "Y", "YES"]);
    _jdg_2(x) = (
        length(x) >= 14 && x[end-13:end] == "Artifacts.toml" && isdir(x)
    );
    _jdg_3(x) = (
        try
            split(x, ",");
            return true;
        catch e
            return false;
        end;
    );
    _jdg_6(x) = (
        if isdir(x) return true end;
        try 
            mkpath(x);
            return true
        catch e
            return false
        end;
    );
    
    #Check if JSON file exists already
    if isfile(_json)
        @info "File $(_json) exists already";
        _msg = "Do you still want to create the JSON file? Type Y/y or N/n to continue > ";
        if (verified_input(_msg, uppercase, _jdg_1) in ["N", "NO"])
            _msg = "Do you still want to reprocess the dataset based on the JSON file? Type Y/y or N/n to continue > ";
            if (verified_input(_msg, uppercase, _jdg_1) in ["N", "NO"])
                @info "Terminating...";
                return nothing;
            else
                @info "Skipping...";
            end;
        else
            #Create JSON file
            griddingmachine_json!(_json);
            @info "JSON file successfully saved";
        end;
    else
        @info "File $(_json) does not exist, creating...";
        #Create JSON file
        griddingmachine_json!(_json);
        @info "JSON file successfully saved";
    end;

    #Reprocess data
    @info "Reprocessing data...";
    reprocess_from_json(_json, rep_locf);

    #Ask user if they want to deploy artifact
    _msg = "Do you want to deploy the reprocessed data as an artifact? Type Y/y or N/n to continue > ";
    if (verified_input(_msg, uppercase, _jdg_1) in ["N", "NO"])
        return nothing;
    end;

    #Deploy artifact
    _msg = "Please input the directory of the Artifacts.toml file > ";
    art_toml = verified_input(_msg, _jdg_2);
    _msg = "Please input the folder of the compressed data to be stored > ";
    art_tarf = verified_input(_msg, _jdg_6);
    _msg = "Please inpt the URLs where the compressed files are to be uploaded, separated by , > ";
    art_urls = verified_input(_msg, _jdg_3);

    @info "Deploying reprocessed dataset as artifact...";
    deploy_from_json(_json, art_toml, rep_locf, art_tarf, art_urls);

    return true;
);


"""
    reprocess_from_json(_json::String, rep_locf::String)

This method reprocesses the data represented by a given JSON file 

- `_json` Path of JSON file to be parsed
- `rep_locf` Path of folder where the reprocessed dataset will be stored

"""
function reprocess_from_json end;

reprocess_from_json(_json::String, rep_locf::String) = (
    #Parse JSON file created
    json_dict = JSON.parse(open(_json));

    #Get all the functions
    name_function = (f = eval(Meta.parse(json_dict["INPUT_MAP_SETS"]["FILE_NAME_FUNCTION"])); x -> Base.invokelatest(f, x));
    data_scaling_f = [_dict["SCALING_FUNCTION"] == "" ? nothing : (f = eval(Meta.parse(_dict["SCALING_FUNCTION"])); x -> Base.invokelatest(f, x)) for _dict in json_dict["INPUT_VAR_SETS"]];
    std_scaling_f = if "INPUT_STD_SETS" in keys(json_dict)
        [_dict["SCALING_FUNCTION"] == "" ? nothing : (f = eval(Meta.parse(_dict["SCALING_FUNCTION"])); x -> Base.invokelatest(f, x)) for _dict in json_dict["INPUT_STD_SETS"]];
    else
        [nothing for _dict in json_dict["INPUT_VAR_SETS"]];
    end;
    data_masking_f = [_dict["MASKING_FUNCTION"] == "" ? nothing : (f = eval(Meta.parse(_dict["MASKING_FUNCTION"])); x -> Base.invokelatest(f, x)) for _dict in json_dict["INPUT_VAR_SETS"]];
    std_masking_f = if "INPUT_STD_SETS" in keys(json_dict)
        [_dict["MASKING_FUNCTION"] == "" ? nothing : (f = eval(Meta.parse(_dict["MASKING_FUNCTION"])); x -> Base.invokelatest(f, x)) for _dict in json_dict["INPUT_STD_SETS"]];
    else
        [nothing for _dict in json_dict["INPUT_VAR_SETS"]];
    end;

    #Reprocess the data
    reprocess_data!(rep_locf, json_dict;
                    file_name_function = name_function, 
                    data_scaling_functions = data_scaling_f, 
                    std_scaling_functions = std_scaling_f,
                    data_masking_functions = data_masking_f,
                    std_masking_functions = std_masking_f);
    @info "Process complete";
);


"""
    deploy_from_json(_json::String, rep_locf::String)

This method deploys the data represented by a given JSON file that is stored in a local folder

- `_json` Path of JSON file to be parsed
- `art_toml` Directory of Artifacts.toml file
- `rep_locf` Path of folder where the reprocessed dataset is stored
- `art_tarf` Path of folder where the compressed data would be stored
- `art_urls` Vector of public urls, where the compressed files are to be uploaded (user need to upload the file manually)

"""
function deploy_from_json end;

deploy_from_json(_json::String, art_toml::String, rep_locf::String, art_tarf::String, art_urls::Vector{String}) = (
    #Parse JSON file
    json_dict = JSON.parse(open(_json));

    #Deploy artifact
    if art_urls == []
        deploy_griddingmachine_artifacts!(json_dict, art_toml, rep_locf, art_tarf);
    else
        deploy_griddingmachine_artifacts!(json_dict, art_toml, rep_locf, art_tarf; art_urls = art_urls);
    end;
    @info "Artifact deployed";
);

#"/home/exgu/GriddingMachine.jl/Artifacts.toml"
#"/home/exgu/GriddingMachine.jl/artifacts"

end; #module