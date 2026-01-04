# ======================================================================================
# Unified Form Selector with Dynamic Interface
# ======================================================================================

UNIFIED_FORM = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GriddingMachine.jl Server</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        h2 {
            color: #34495e;
            margin-top: 25px;
        }
        .form-selector {
            display: flex;
            gap: 15px;
            margin-bottom: 30px;
            flex-wrap: wrap;
        }
        .form-selector button {
            flex: 1;
            min-width: 150px;
            padding: 15px 25px;
            font-size: 16px;
            font-weight: bold;
            border: 2px solid #3498db;
            background-color: white;
            color: #3498db;
            border-radius: 5px;
            cursor: pointer;
            transition: all 0.3s;
        }
        .form-selector button:hover {
            background-color: #3498db;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(52,152,219,0.3);
        }
        .form-selector button.active {
            background-color: #3498db;
            color: white;
        }
        .form-content {
            display: none;
        }
        .form-content.active {
            display: block;
        }
        label {
            display: block;
            margin-top: 15px;
            font-weight: bold;
            color: #2c3e50;
        }
        input[type="text"],
        input[type="number"],
        select {
            width: 100%;
            padding: 10px;
            margin-top: 5px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 14px;
        }
        input[type="checkbox"] {
            margin-right: 8px;
            width: 18px;
            height: 18px;
            vertical-align: middle;
        }
        input[type="submit"] {
            margin-top: 25px;
            padding: 12px 30px;
            background-color: #27ae60;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s;
        }
        input[type="submit"]:hover {
            background-color: #229954;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(39,174,96,0.3);
        }
        ul {
            line-height: 1.8;
            color: #555;
        }
        a {
            color: #3498db;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        .checkbox-group {
            margin-top: 15px;
            display: flex;
            align-items: center;
        }
        .checkbox-group label {
            margin-top: 0;
            margin-left: 5px;
        }
    </style>
    <script>
        function showForm(formId) {
            // Hide all forms
            document.querySelectorAll('.form-content').forEach(form => {
                form.classList.remove('active');
            });
            // Remove active class from all buttons
            document.querySelectorAll('.form-selector button').forEach(btn => {
                btn.classList.remove('active');
            });
            // Show selected form
            document.getElementById(formId).classList.add('active');
            // Add active class to clicked button
            event.target.classList.add('active');
        }
    </script>
</head>
<body>
    <div class="container">
        <h1>GriddingMachine.jl Server</h1>
        <p>Welcome to the GriddingMachine.jl data server. Please select a data type below:</p>

        <div class="form-selector">
            <button onclick="showForm('artifact-form')" class="active">Artifact Data</button>
            <button onclick="showForm('gmdict-form')">GM Dictionary</button>
            <button onclick="showForm('weather-form')">Weather Data</button>
        </div>

        <!-- Artifact Form -->
        <div id="artifact-form" class="form-content active">
            <form action="/gm_artifact_result" method="POST">
                <h2>Request Artifact Data</h2>

                <label for="tag">GriddingMachine TAG</label>
                <select name="tag" id="tag">
                    <option>--Choose a TAG--</option>
                    <!-- Tags will be populated by Julia -->
                </select>

                <label for="lat">Latitude</label>
                <input type="number" name="lat" id="lat" step="any" placeholder="35.5" value="35.5" required>

                <label for="lon">Longitude</label>
                <input type="number" name="lon" id="lon" step="any" placeholder="115.5" value="115.5" required>

                <label for="cyc">Cycle</label>
                <input type="number" name="cyc" id="cyc" step="1" placeholder="0" value="0">

                <div class="checkbox-group">
                    <input type="checkbox" name="include_std" id="include_std" checked>
                    <label for="include_std">Include Standard Deviation</label>
                </div>

                <input type="submit" value="Get JSON">

                <h2>Note</h2>
                <ul>
                    <li>Cycle: 0 to request all data in the 3rd dimension (e.g., time)</li>
                    <li>Include STD: when checked, include standard deviation (error) in the output. If not available, will return 'Not available in dataset'</li>
                    <li>Interpolate: currently not implemented, returns grid cell values regardless of this setting</li>
                </ul>

                <h2>Reference</h2>
                <ul>
                    <li><a href="https://doi.org/10.1038/s41597-022-01346-x" target="_blank">Wang et al. (2022)</a> GriddingMachine, a database and software for Earth system modeling at global and regional scales. Scientific Data 9: 258</li>
                    <li>Please refer to <a href="https://github.com/CliMA/GriddingMachine.jl/issues/62" target="_blank">GriddingMachine.jl</a> for the reference to the data you are using</li>
                </ul>
            </form>
        </div>

        <!-- GM Dictionary Form -->
        <div id="gmdict-form" class="form-content">
            <form action="/gm_dict_result" method="POST">
                <h2>Request GM Dictionary</h2>

                <label for="gmv_dict">GM Version</label>
                <select name="gmv" id="gmv_dict">
                    <option>--Choose a Version--</option>
                    <option>gm1</option>
                    <option selected>gm2</option>
                    <option>gm3</option>
                    <option>gm4</option>
                </select>

                <label for="year_dict">Year</label>
                <input type="number" name="year" id="year_dict" step="1" placeholder="2019" value="2019" required>

                <label for="lat_dict">Latitude</label>
                <input type="number" name="lat" id="lat_dict" step="any" placeholder="35.5" value="35.5" required>

                <label for="lon_dict">Longitude</label>
                <input type="number" name="lon" id="lon_dict" step="any" placeholder="115.5" value="115.5" required>

                <input type="submit" value="Get JSON">

                <h2>Note</h2>
                <ul>
                    <li>GM Version: our default is gm2, please visit <a href="https://silicormosia.github.io/blogs/emerald/emerald.html#griddingmachine-selections" target="_blank">CliMA Land Benchmark Page</a> for more details</li>
                    <li>Year: the time-dependent variable is leaf area index (LAI), but the datasets we use may only cover year 2001 to 2020.</li>
                </ul>

                <h2>Reference</h2>
                <ul>
                    <li><a href="https://doi.org/10.1038/s41597-022-01346-x" target="_blank">Wang et al. (2022)</a> GriddingMachine, a database and software for Earth system modeling at global and regional scales. Scientific Data 9: 258</li>
                    <li><a href="http://dx.doi.org/10.1029/2021MS002964" target="_blank">Wang et al. (2023)</a> Modeling global vegetation gross primary productivity, transpiration and hyperspectral canopy radiative transfer simultaneously using a next generation land surface model—CliMA Land. Journal of Advances in Modeling Earth Systems 15(3): e2021MS002964</li>
                </ul>
            </form>
        </div>

        <!-- Weather Form -->
        <div id="weather-form" class="form-content">
            <form action="/gm_weather_result" method="POST">
                <h2>Request Weather Data</h2>

                <label for="wdv">Weather Driver Version</label>
                <select name="wdv" id="wdv">
                    <option>--Choose WD Version--</option>
                    <option selected>wd1</option>
                </select>

                <label for="year_weather">Year</label>
                <input type="number" name="year" id="year_weather" step="1" placeholder="2019" value="2019" required>

                <label for="lat_weather">Latitude</label>
                <input type="number" name="lat" id="lat_weather" step="any" placeholder="35.5" value="35.5" required>

                <label for="lon_weather">Longitude</label>
                <input type="number" name="lon" id="lon_weather" step="any" placeholder="115.5" value="115.5" required>

                <input type="submit" value="Get JSON">

                <h2>Note</h2>
                <ul>
                    <li>WD Version: Only 'wd1' (ERA5 single level data) is supported now.</li>
                    <li>GM Version: our default is gm2</li>
                    <li>Year: weather data covers year 2001 to 2020 (consistent with LAI datasets).</li>
                    <li>Latitude/Longitude: Use decimal format (e.g., 35.5 for 35°30'N, 115.5 for 115°30'E).</li>
                </ul>

                <h2>Reference</h2>
                <ul>
                    <li><a href="https://doi.org/10.1038/s41597-022-01346-x" target="_blank">Wang et al. (2022)</a> GriddingMachine, a database and software for Earth system modeling at global and regional scales. Scientific Data 9: 258</li>
                    <li><a href="http://dx.doi.org/10.1029/2021MS002964" target="_blank">Wang et al. (2023)</a> Modeling global vegetation gross primary productivity, transpiration and hyperspectral canopy radiative transfer simultaneously using a next generation land surface model—CliMA Land. Journal of Advances in Modeling Earth Systems 15(3): e2021MS002964</li>
                </ul>
            </form>
        </div>
    </div>
</body>
</html>
""";
