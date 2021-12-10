## This is only an example
### Can we code on github web?
module Demo

export manual_mean

function manual_mean(values::Vector{<:Number})
    sum = 0
    for value in values
        sum += value
    end
    sum / length(vaules)
end

end # module
