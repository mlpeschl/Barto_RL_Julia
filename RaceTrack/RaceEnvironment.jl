include("Tracks.jl")

using StatsBase

mutable struct RaceTrack
    #Z = Wall
    #s = Start
    #o = Track
    #f = Finish
    Shape::Array{Char,2}
    max_velocity::Int64
    position::Array{Int64, 1}
    velocity::Array{Int64,1}
    nrow::Int64
    ncol::Int64
    noise::Float64

    function RaceTrack(Shape; max_velocity =5, noise = 0.1)
        shapematrix = convtomatrix(Shape)
        pos = random_start(shapematrix)
        nrow = size(shapematrix)[1]
        ncol = size(shapematrix)[2]
        new(shapematrix, max_velocity, pos,[0,0],nrow,ncol,noise)
    end

end


function velocity_change(r::RaceTrack, change::Array{Int64,1})
    if rand() > r.noise      #Probability noise of not changing Velocity
        r.velocity = r.velocity + change
        r.velocity = min.(r.velocity, r.max_velocity)
        r.velocity = max.(r.velocity,0)
    end
end

function random_start(Shape::Array{Char,2})
    start_indices = findall(x -> x=='s', Shape)
    nstarts = length(start_indices)
    randomstart = start_indices[rand(1:nstarts)]
    pos = [0,0]
    pos[1] = randomstart[1]
    pos[2] = randomstart[2]
    return pos
end

function pos_change(r::RaceTrack)
    current_pos = r.position
    #new_pos = r.position + r.velocity
    nsteps = sum(r.velocity)
    steps_up = 0
    steps_r = 0
    #Randomly move one up or right until maximum steps are reached
    while (steps_up < r.velocity[1]) | (steps_r < r.velocity[2])
        rorup = rand(1:2)    #Select random move
        if (rorup == 1) & (steps_up == r.velocity[1])
            rorup = 2
        elseif (rorup ==2) & (steps_r == r.velocity[2])
            rorup = 1
        end

        #println("HELP")
        if rorup == 1
            current_pos[1] -= 1    #move up one
            steps_up +=1
            #rintln("up")
           #println(current_pos)
            if wallcheck(r.Shape,current_pos)
                r.position = random_start(r.Shape)   #Ran into wall -> Back to start
                r.velocity = [0,0]                   #Reset velocity
                return 0
            elseif fincheck(r.Shape,current_pos)     #Finished -> Done
                return 1
            end

        else
            current_pos[2] += 1    #move right one
            steps_r +=1
            #rintln("right")
            #rintln(current_pos)
            if wallcheck(r.Shape,current_pos)
                r.position = random_start(r.Shape)   #Ran into wall -> Back to start
                r.velocity = [0,0]                   #Reset velocity
                return 0
            elseif fincheck(r.Shape,current_pos)     #Finished -> Done
                return 1
            end

        end

     end

    r.position = current_pos      #Update position after not running into Wall/Finish

end

function wallcheck(shape::Array{Char,2}, pos::Array{Int64,1})
    return (shape[pos[1],pos[2]] == 'Z')
end

function fincheck(shape::Array{Char,2}, pos::Array{Int64,1})
    return (shape[pos[1],pos[2]] == 'f')
end

function take_action(r::RaceTrack, action::Int64)
    #Take action, return reward
    #Convert Action-Number to actual Values
    if action == 1
        change = [0,0]
    elseif action == 2
        change = [1,0]
    elseif action == 3
        change = [0,1]
    elseif action == 4
        change = [1,1]
    elseif action == 5
        change = [-1,1]
    elseif action == 6
        change = [1,-1]
    elseif action == 7
        change = [-1,-1]
    elseif action == 8
        change = [0,-1]
    else change = [-1,0]

    end


    current_pos = r.Shape[r.position[1],r.position[2]]

    #A_t
    velocity_change(r, change)

    #R_t and Environment Control
    if current_pos == 'f'
        r.position = random_start(r.Shape)       #Reset Environment
        r.velocity = [0,0]
        return (0,true)                          #Return Tuple (a = reward, b = done)

    else
        #S_t+1
        pos_change(r)
        return (-1,false)
    end

end


function generate_episode(b::Any,r::RaceTrack,deterministic = false)
    isDone = false
    S = []
    A = []
    R = []
    while !isDone
        #println(r.position)
        push!(S, [r.position[1],r.position[2],r.velocity[1]+1,r.velocity[2]+1])
        if deterministic
            action = Int(b[r.position[1],r.position[2],
                    r.velocity[1]+1,r.velocity[2]+1])

        else

            action = sample(Weights(b[r.position[1],r.position[2],
                    r.velocity[1]+1,r.velocity[2]+1]))
        end
        push!(A, action)

        (reward,isDone) = take_action(r,action)

        push!(R,reward)
    end
    return (S,A,R)
end


function convtomatrix(ar::Array{String,1})
    breadth = length(ar[1])
    depth = length(ar)
    m = Array{Char}(undef, depth, breadth)
    for i in 1:depth
       for j in 1:breadth
            m[i,j] = ar[i][j]
        end
    end
    return m
end
