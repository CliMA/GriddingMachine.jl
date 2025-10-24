function request_weather(
    gmversion::String,
    wdversion::String,
    year::Int,
    lat::Number,
    lon::Number;
    port::Int = 5055,
    server::String = "http://tropo.gps.caltech.edu",
    user::String="Anonymous")
    # send a request to our webserver at tropo.gps.caltech.edu:44301 and translate it back to Dictionary
    web_url = "$(server):$(port)/weather.json?user=$(user)&gmversion=$(gmversion)&wdversion=$(wdversion)&year=$(year)&lat=$(lat)&lon=$(lon)";
    web_response = get(web_url; require_ssl_verification = false);
    json_str = String(web_response.body);
    json_dict = parse(json_str);

    # if there is no result item in the Dictionary
    if !haskey(json_dict, "Weather Data")
        @show json_dict;
        return error("There is something wrong with the request, please check the details about it!");
    end;   

    # 从JSON字典中提取天气数据
    weather_data = json_dict["Weather Data"]

    # 初始化一个空DataFrame
    df = DataFrame()
    # 遍历weather_data的每个键值对，将其作为一列添加到DataFrame中
    for (col_name, data_vec) in weather_data
        # 向DataFrame中添加一列：列名为col_name，数据为data_vec
        df[!, col_name] = data_vec
    end
    
    return df

end;