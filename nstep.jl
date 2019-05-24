
function eps_greedy(arr,eps = 0.1)
    if rand() < 1-eps
        return sargmax(arr)
    else
        return rand(1:9)
    end
end



function n_Sarsa(nits::Int64, α::Float64, γ::Float64, n::Int64)

    steparr = []


    r = RaceTrack(Track,noise = 0.1)
    Q = rand(r.nrow, r.ncol, r.max_velocity+1, r.max_velocity+1, 9)

    @progress for i in 1:nits
        St_arr = []
        Rt_arr = []
        Act_arr = []
        isDone = false
        T = Inf
        t = 0
        S_0 = [r.position[1],r.position[2],r.velocity[1]+1,r.velocity[2]+1]
        A_0 = eps_greedy(Q[S_0..., :])
        push!(St_arr,copy(S_0))
        push!(Act_arr,copy(A_0))

        while true
            if t < T
                S_t = [r.position[1],r.position[2],r.velocity[1]+1,r.velocity[2]+1]
                A_t =  eps_greedy(Q[S_t..., :])
                (R_t1,isDone) = take_action(r,A_t)
                S_t1 = [r.position[1],r.position[2], r.velocity[1]+1, r.velocity[2]+1]
                push!(St_arr, copy(S_t1))
                push!(Rt_arr, copy(R_t1))
                if isDone
                    T = t+1
                else
                    A_t1 = eps_greedy(Q[S_t1...,:])
                    push!(Act_arr,copy(A_t1))
                end
            end



            τ = Int64(t-n+1)
            if τ >= 0
                G = 0
                for i in 1:min(τ+n,T)
                    G += γ^(i-τ-1) * Rt_arr[Int64(i)]
                end
                if τ+n < T
                    G += γ^n * Q[St_arr[τ+n+1]...,Act_arr[τ+n+1]]
                end
                Q[St_arr[τ+1]...,Act_arr[τ+1]] += α*(G-Q[St_arr[τ+1]...,Act_arr[τ+1]])
            end

            t+=1
            #println("tau: $(τ)")
            #println("T: $(T)")
            if τ == T-1
                println("BROKEN")
                break
            end
        end
        push!(steparr, T)
    end
    return (Q,steparr)
end


(Qsars, steparr) = n_Sarsa(5*10^3, 0.5, 1.0, 2)
