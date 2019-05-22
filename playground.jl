include("RaceEnvironment.jl")

using Gadfly

function sargmax(array)
    tmp = maximum(array)
    inds = findall(x -> x == tmp, array)
    return rand(inds)
end

function eps_greedy(arr,eps = 0.01)
    if rand() < 1-eps
        return sargmax(arr)
    else
        return rand(1:9)
    end
end

γ = 0.95 #Discount Factor
α = 10^(-2) #Learning Rate

r = RaceTrack(Track,noise = 0.1)
Q = rand(r.nrow, r.ncol, r.max_velocity+1, r.max_velocity+1, 9)


nits = 10^4

@progress for i in 1:nits
    isDone = false
    S_t = [r.position[1],r.position[2],r.velocity[1]+1,r.velocity[2]+1]
    A_t =  eps_greedy(Q[S_t..., :])

    while !isDone
        (R_t,isDone) = take_action(r,A_t)
        S_t1 = [r.position[1],r.position[2], r.velocity[1]+1, r.velocity[2]+1]

        A_t1 = eps_greedy(Q[S_t1..., :])

        #println("Q BEFORE $(Q[S_t...,A_t])")
        Q[S_t...,A_t] += α * (R_t + γ*Q[S_t1...,A_t1] - Q[S_t...,A_t])
        #println("Q AFTER $(Q[S_t...,A_t])")

        S_t = S_t1
        A_t = A_t1
    end
end



#Testbench
r = RaceTrack(Track,noise = 0)
lengths = []
global len = 0
trials = 10
for i in 1:trials
    isDone = false
    while !isDone
        S_t = [r.position[1],r.position[2],r.velocity[1]+1,r.velocity[2]+1]
        A_t =  eps_greedy(Q[S_t..., :])
        #A_t = rand(1:9)
        (R_t, isDone) = take_action(r,A_t)
        global len +=1
    end
end

println(len/trials)
