include("RaceEnvironment.jl")


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





function Sarsa(nits::Int64, α::Float64, γ::Float64)

    steparr = []

    r = RaceTrack(Track,noise = 0.1)
    Q = rand(r.nrow, r.ncol, r.max_velocity+1, r.max_velocity+1, 9)

    @progress for i in 1:nits
        isDone = false
        steps = 0
        S_t = [r.position[1],r.position[2],r.velocity[1]+1,r.velocity[2]+1]
        A_t =  eps_greedy(Q[S_t..., :])

        while !isDone
            steps +=1
            (R_t,isDone) = take_action(r,A_t)
            S_t1 = [r.position[1],r.position[2], r.velocity[1]+1, r.velocity[2]+1]

            A_t1 = eps_greedy(Q[S_t1..., :])

            #println("Q BEFORE $(Q[S_t...,A_t])")
            Q[S_t...,A_t] += α * (R_t + γ*Q[S_t1...,A_t1] - Q[S_t...,A_t])
            #println("Q AFTER $(Q[S_t...,A_t])")

            S_t = S_t1
            A_t = A_t1
        end
        push!(steparr, steps)
    end
    return (Q,steparr)
end



function QLearn(nits::Int64, α::Float64, γ::Float64)

    steparr = []
    r = RaceTrack(Track,noise = 0)
    Q = rand(r.nrow, r.ncol, r.max_velocity+1, r.max_velocity+1, 9)

    @progress for episode in 1:nits
        steps = 0
        isDone = false
        S_t = [r.position[1],r.position[2],r.velocity[1]+1,r.velocity[2]+1]

        while !isDone
            steps +=1
            A_t =  eps_greedy(Q[S_t..., :])
            (R_t,isDone) = take_action(r,A_t)
            S_t1 = [r.position[1],r.position[2], r.velocity[1]+1, r.velocity[2]+1]

            #println("Q BEFORE $(Q[S_t...,A_t])")
            Q[S_t...,A_t] += α * (R_t + γ* maximum(Q[S_t1...,:]) - Q[S_t...,A_t])
            #println("Q AFTER $(Q[S_t...,A_t])")

            S_t = S_t1
        end
        push!(steparr, steps)
    end
    return (Q,steparr)
end


Q, steps  = Sarsa(10^4, 0.1,1.0)
Q2, steps2 = QLearn(10^4, 0.1, 1.0)



using Gadfly


splot = layer(x = collect(1:length(steps)), y = steps, Geom.smooth(smoothing = 0.1),
                Theme(default_color = "red"))
qplot = layer(x = collect(1:length(steps2)), y = steps2, Geom.smooth(smoothing = 0.1))
plot(splot,qplot, Guide.manual_color_key("",["Sarsa","QLearn"],
                            [Gadfly.current_theme().default_color,"red"]))
