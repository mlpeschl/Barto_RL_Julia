include("RaceEnvironment.jl")


function sargmax(array)
    tmp = maximum(array)
    inds = findall(x -> x == tmp, array)
    return rand(inds)
end

function eps_greedy(arr,eps = 0.01)
    #println(arr)
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
    r = RaceTrack(Track,noise = 0.1)
    Q = rand(r.nrow, r.ncol, r.max_velocity+1, r.max_velocity+1, 9)

    if α == 0.0
        counter = 1
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
                #println(1/counter)
                Q[S_t...,A_t] += (1/(counter)) * (R_t + γ* maximum(Q[S_t1...,:]) - Q[S_t...,A_t])
                #println("Q AFTER $(Q[S_t...,A_t])")
                counter +=1
                S_t = S_t1

            end
            push!(steparr, steps)
        end
    else
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
    end
    return (Q,steparr)
end


Q1, steps1  = QLearn(10^3, 0.0 ,0.99)
Q2, steps2 = QLearn(10^3, 0.5, 1.0)

l1 = layer(x = collect(1:length(steps1)), y = steps1, Geom.smooth(smoothing = 0.2),Theme(default_color = "blue"))
l2 = layer(x = collect(1:length(steps2)), y = steps2, Geom.smooth(smoothing = 0.2), Theme(default_color = "red"))

plot(l1,l2, Guide.manual_color_key("",["α = 1/(n^(3/2))","α = 0.5"],["blue","red"])) |> PDF("currentplot.PDF")
