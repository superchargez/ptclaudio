using Genie
using Genie.Renderer.Html
include("main.jl")

Genie.config.server_host = "0.0.0.0"
Genie.config.server_port = 8000

route("/") do
    file_path = "/home/jawad/Documents/projects/julia/ptclaudio/output.wav"
    silence_threshold = 0.01
    min_silence_duration = 0.5

    samples, sample_rate, silence_zones = MainFunctions.detect_silence(file_path, silence_threshold, min_silence_duration)
    MainFunctions.plot_waveform(samples, sample_rate, silence_zones)

    html("<h1>Waveform</h1>")
end

up(8001)
