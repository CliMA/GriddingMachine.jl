module Processor

include("borrowed/GriddingMachineData.jl")

function process_file()
    @info "Please follow the instructions to create a JSON file for your dataset(s) and reprocess your dataset(s)"

    _jdg_1(x) = (x in ["N", "NO", "Y", "YES"]);


    while true
        _msg = "Do you want to reprocess a dataset. Type Y/y or N/n to continue > ";
        if (verified_input(_msg, uppercase, _jdg_1) in ["N", "NO"])
            break;
        end;
        
        _msg = "Please input the folder path of the JSON file you want to create";
        folder = verified_input(_msg, xxx, xxx); #check if a directory is given and if the folder exists
        _msg = "Please input the file name of the JSON file you want to create";
        file = verified_input(_msg, xxx, xxx); #check if a string is given
        
        json = "$(folder)*/*$(file)";

        if isfile(json)
            @info "File $(json) exists already";
            _msg = "Do you still want to create the JSON file? Type Y/y or N/n to continue > ";
            if (verified_input(_msg, uppercase, _jdg_1) in ["N", "NO"])
                @info "Skipping...";
                continue;
            end;
        else
            @info "File $(json) does not exist, creating...";
        end;

        griddingmachine_json!(json);

        @info "JSON file successfully saved"


    end



end

end #module