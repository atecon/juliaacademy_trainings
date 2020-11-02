using Pkg
try
    using Printf
    using HTTP
catch e
    println("Required packages need to be installed.")
    Pkg.add(["Printf", "HTTP"])
end


URL_MANIFEST = "https://raw.githubusercontent.com/JuliaAcademy/DataFrames/master/Manifest.toml";
URL_PROJECT = "https://raw.githubusercontent.com/JuliaAcademy/DataFrames/master/Project.toml";

function get_files(urls::StridedArray)
    for url in urls
        try
            HTTP.download(url, pwd())
            @info(@sprintf("Succesfully downloaded file '%s'", url))
        catch e
            @warn(@sprintf("Failed to download file '%s'", url))
        end
    end
end;

get_files([URL_MANIFEST, URL_PROJECT])

@info("Finished job")
exit()
