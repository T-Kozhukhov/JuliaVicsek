struct particle
    position
    orientation::Float64 # angle of particle
end

function MIC(pos, l)
    return map(x->(mod(x + l/2, l) - l/2), pos)
end

function PBC(pos, l)
    return map(x->(mod(x, l)), pos)
end

# declare argument variables
iterationCount = 1000
partCount = 500
partSpeed = 0.25
neighbourRadii = 1
domainSize = 50
println("Arguments:")
for i = 1:length(ARGS) 
    println("\tArgument $i: $(ARGS[i])")
end
# assign Arguments
try
    global iterationCount = parse(UInt64, ARGS[1])
    global partCount = parse(UInt64, ARGS[2])
    global partSpeed = parse(Float64, ARGS[3])
    global neighbourRadii = parse(Float64, ARGS[4])
    global domainSize = parse(Float64, ARGS[5])
catch
    println("Could not parse arguments. Use format of:")
    println("julia vicsek.jl [ITERATIONCOUNT] [PARTICLE COUNT] [PARTICLE SPEED] [NEIGHBOUR RADII] [DOMAINSIZE]")
    exit()
end

##TODO: initialise and place particles properly
particleList = Array{particle, partCount}
for i = 1:partCount
    ##TODO: get random position
    # randPos = rand(0:.001:domainSize, 2)
    particleList[i].position = rand(0:.001:domainSize, 2)
    # randOri = rand(0:.001:2\pi)
    particleList[i].orientation = rand(0:.001:2\pi)
    # particleList[i] = particle(randPos, randOri)
    # push!(particleList, particle(randPos, randOri))
end

# for t = 1:iterationCount
#     println("Iteration $t/$iterationCount")
#     # println(MIC(t, domainSize))
#     ##TODO: get particle neighbours (bin into cell list first)
#     ##TODO: get particle orientations
#     ##TODO: evolve particles

#     ##TODO: plot particles
# end

##TODO finish sim