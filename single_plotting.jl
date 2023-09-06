using WAV
using Statistics
using Plots

# module MainFunctions

# export detect_silence, plot_waveform

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

function plot_waveform(samples, sample_rate, silence_zones, silence_threshold, min_silence_duration, file_path)
    # Create a new plot
    p = plot(title="Threshold: $silence_threshold, Duration: $min_silence_duration", xlabel="File: $file_path", titlefont=font(12, "Courier", color=:red))

    # Plot the waveform
    plot!(p, 1:length(samples), samples, color=:blue, label="Waveform")

    # Highlight the silence zones
    for i in 1:length(silence_zones)
        (start, stop) = silence_zones[i]
        if i == 1
            plot!(p, start:stop, samples[start:stop], color=:red, label="Silence")
        else
            plot!(p, start:stop, samples[start:stop], color=:red, label="")
        end
    end

    # Display the plot
    # display(p)
    plot!(p, show=true)
end


# end # module

file_path = "test 2.wav"
silence_threshold = 0.001
min_silence_duration = 0.002

samples, sample_rate, silence_zones = detect_silence(file_path, silence_threshold, min_silence_duration)
plot_waveform(samples, sample_rate, silence_zones, silence_threshold, min_silence_duration, file_path)

# function check_late_init_hangup(silence_zones, sample_rate, min_duration)
#     late_init = false
#     late_hangup = false

#     # Check for Late Initialization
#     if !isempty(silence_zones)
#         (start, stop) = silence_zones[1]
#         if start == 1 && (stop - start + 1) / sample_rate >= min_duration
#             late_init = true
#         end
#     end

#     # Check for Late Hangup
#     if !isempty(silence_zones)
#         (start, stop) = silence_zones[end]
#         if stop == length(samples) && (stop - start + 1) / sample_rate >= min_duration
#             late_hangup = true
#         end
#     end

#     return late_init, late_hangup
# end

# # samples, sample_rate, silence_zones = detect_silence(file_path, silence_threshold, min_silence_duration)
# late_init, late_hangup = check_late_init_hangup(silence_zones, sample_rate, 5)

# println("Late Initialization: ", late_init)
# println("Late Hangup: ", late_hangup)

# using Makie
# # using CairoMakie
# using GeometryBasics: Point2f0

# function plot_circles(late_init::Bool, late_hangup::Bool)
#     # Set up a scene with two circles
#     scene = Scene()
#     c1 = Circle(Point2f0(0), 1)
#     c2 = Circle(Point2f0(2), 1)
#     Makie.scatter!(scene, c1, color=late_init ? :red : :green)
#     Makie.scatter!(scene, c2, color=late_hangup ? :red : :green)

#     # Display the scene
#     Makie.display(scene)
# end

# # plot_circles(late_init, late_hangup)
