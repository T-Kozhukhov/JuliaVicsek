import LinearAlgebra: norm

mutable struct particle
    position
    orientation::Float64 # angle of particle in radians
end

function MIC(diff, l)
    # convert absolute diff to PBC diff
    return map(x->(mod(x + l/2, l) - l/2), diff)
end

function PBC(pos, l)
    # apply PBC to positions
    return map(x->(mod(x, l)), pos)
end

function AverageAngle(neighbourList)
    # compute average angle, by using vector, from all particles in neighbour list
    vecSum = [0, 0]
    for i = 1:length(neighbourList)
        vecSum += neighbourList[i].position
    end
    return atan(vecSum[2], vecSum[1])
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
    global noise = parse(Float64, ARGS[6])
catch
    println("Could not parse arguments. Use format of:")
    println("julia vicsek.jl [ITERATIONCOUNT] [PARTICLE COUNT] [PARTICLE SPEED] [NEIGHBOUR RADII] [DOMAINSIZE] [NOISE]")
    exit()
end

# initialise and place particles
particleList = particle[]
for i = 1:partCount
    randPos = rand(0:.001:domainSize, 2)
    randOri = rand(0:.001:2\pi)
    push!(particleList, particle(randPos, randOri))
end

for t = 1:iterationCount
    println("Iteration $t/$iterationCount")

    newAngles = Float64[] # list of new angles for each particle

    ##TODO: get particle neighbours and get new orientations and apply noise
    for p in particleList
        # construct neighbour list
        nList = particle[]
        for pj in particleList
            if norm(MIC(p.position - pj.position, domainSize)) < neighbourRadii
                push!(nList, pj)
            end
        end

        # add new computed angle newAngle list
        push!(newAngles, AverageAngle(nList) + rand(-noise:noise))
    end

    # apply new orientations
    for i = 1:partCount
        particleList[i].orientation = newAngles[i]
    end

    # evolve particles
    for p in particleList
        p.position = PBC(p.position + partSpeed*[cos(p.orientation), sin(p.orientation)], domainSize)
    end

    ##TODO: plot particles
end

##TODO finish sim