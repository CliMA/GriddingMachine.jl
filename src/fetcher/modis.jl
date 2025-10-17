MOD09A1v061() = GeneralWgetData("hdf", "MOD09A1", joinpath(homedir(), "DATASERVER/satellite/MODIS/MOD09A1.061/original/"), "https://e4ftl01.cr.usgs.gov/MOLT/MOD09A1.061/", 8, (2000,2,18));
MYD09A1v061() = GeneralWgetData("hdf", "MYD09A1", joinpath(homedir(), "DATASERVER/satellite/MODIS/MYD09A1.061/original/"), "https://e4ftl01.cr.usgs.gov/MOLA/MYD09A1.061/", 8, (2002,7,4));

MOD09GAv061() = GeneralWgetData("hdf", "MOD09GA", joinpath(homedir(), "DATASERVER/satellite/MODIS/MOD09GA.061/original/"), "https://e4ftl01.cr.usgs.gov/MOLT/MOD09GA.061/", 1, (2000,2,24));
MYD09GAv061() = GeneralWgetData("hdf", "MYD09GA", joinpath(homedir(), "DATASERVER/satellite/MODIS/MYD09GA.061/original/"), "https://e4ftl01.cr.usgs.gov/MOLA/MYD09GA.061/", 1, (2002,7,4));

MOD15A2Hv061() = GeneralWgetData("hdf", "MOD15A2H", joinpath(homedir(), "DATASERVER/satellite/MODIS/MOD15A2H.061/original/"), "https://e4ftl01.cr.usgs.gov/MOLT/MOD15A2H.061/", 8, (2000,2,18));

MCD43C3v061() = GeneralWgetData("hdf", "MCD43C3", joinpath(homedir(), "DATASERVER/satellite/MODIS/MCD43C3.061/original/"), "https://e4ftl01.cr.usgs.gov/MOTA/MCD43C3.061/", 1, (2000,2,24));
