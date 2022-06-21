import LinearAlgebra: norm
using Plots

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

function unitVec(theta)
    # return unit vector in direction of theta
    return [cos(theta), sin(theta)]
end

function AverageAngle(neighbourList)
    # compute average angle, by using vector, from all particles in neighbour list
    vecSum = [0, 0]
    for n in neighbourList
        vecSum += unitVec(n.orientation)
    end
    return atan(vecSum[2], vecSum[1])
end

# declare argument variables
iterationCount = 1000
partCount = 500
partSpeed = 0.25
neighbourRadii = 2
domainSize = 50
noise = 0.5
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

    # get particle neighbours and get new orientations and apply noise
    for p in particleList
        # construct neighbour list
        nList = particle[]
        for pj in particleList
            if norm(MIC(p.position - pj.position, domainSize)) < neighbourRadii
                push!(nList, pj)
            end
        end

        # add new computed angle + noise to newAngle list
        push!(newAngles, AverageAngle(nList) + rand(-noise:noise))
    end

    # apply new orientations
    for i = 1:partCount
        particleList[i].orientation = newAngles[i]
    end

    # evolve particles
    for p in particleList
        p.position = PBC(p.position + partSpeed * unitVec(p.orientation), domainSize)
    end

    #=
        TODO: Need to improve plotting, this is super fucking slow.
        Some ideas:
        - Only dump ever D frames, taken as an input parameter
        - Maybe check which of the below lines is the slow one and find a nicer way
        - Have an accompanying python script that does the actual plotting?
            - Maybe use multithreading and have this run in the background after each frame?
        - Or, yeah, just multithread this step in general?
    =#
    q = (cos.(getfield.(particleList, :orientation)), sin.(getfield.(particleList, :orientation)))
    x = [p.position[1] for p in particleList]
    y = [p.position[2] for p in particleList]
    quiver(x, y, quiver=q)
    savefig("sim_t=$t.png")
end

#=
    TODO/ WIP ideas:
    - Finish off sim and close it off
    - Multithread? both cpu and or GPU (if that's easy in Julia?)

=#