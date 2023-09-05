using WAV
using Statistics
using Plots

module MainFunctions

export detect_silence, plot_waveform

function detect_silence(file_path::String, silence_threshold::Float64, min_silence_duration::Float64)
    # Read the WAV file
    samples, sample_rate = wavread(file_path)

    # Convert the samples to a 1D array
    samples = vec(mean(samples, dims=2))

    # Compute the window size and step size
    window_size = round(Int, min_silence_duration * sample_rate)
    step_size = round(Int, window_size / 2)

    # Initialize the silence zones array
    silence_zones = Vector{Tuple{Int, Int}}()

    # Iterate over the samples with a sliding window
    i = 1
    while i + window_size - 1 <= length(samples)
        # Compute the mean absolute amplitude in the current window
        mean_amplitude = mean(abs.(samples[i:i+window_size-1]))

        # Check if the mean amplitude is below the silence threshold
        if mean_amplitude < silence_threshold
            # Find the end of the silence zone
            j = i + window_size - 1
            while j + step_size <= length(samples)
                mean_amplitude = mean(abs.(samples[j+1:j+step_size]))
                if mean_amplitude >= silence_threshold
                    break
                end
                j += step_size
            end

            # Add the silence zone to the array
            push!(silence_zones, (i, j))

            # Move the window to the end of the silence zone
            i = j + 1
        else
            # Move the window one step forward
            i += step_size
        end
    end

    return samples, sample_rate, silence_zones
end

function plot_waveform(samples, sample_rate, silence_zones)
    # Create a new plot
    p = plot()

    # Plot the waveform
    plot!(p, 1:length(samples), samples, color=:blue, label="Waveform")

    # Highlight the silence zones
    for (start, stop) in silence_zones
        plot!(p, start:stop, samples[start:stop], color=:red, label="Silence")
    end

    # Display the plot
    # display(p)
    plot!(p, show=true)
end

end # module

file_path = "/home/jawad/Documents/projects/julia/ptclaudio/output.wav"
silence_threshold = 0.01
min_silence_duration = 0.5

samples, sample_rate, silence_zones = detect_silence(file_path, silence_threshold, min_silence_duration)
plot_waveform(samples, sample_rate, silence_zones)