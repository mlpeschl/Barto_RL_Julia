include("RaceEnvironment.jl")


function generate_behavior(r::RaceTrack)
    b = Array{Any}(undef,r.nrow, r.ncol, r.max_velocity+1, r.max_velocity+1)
    for i in 1:r.nrow, j in 1:r.ncol, k in 1:r.max_velocity+1, l in 1:r.max_velocity+1
        z = rand(9)                               #Total of 9 Actions
        b[i,j,k,l] = (exp.(z))/(sum(exp.(z)))     #softmax
    end
    return b
end


#Off policy MC Control for estimating π ≈ π*
gamma = 0.8  #Discount Factor

r = RaceTrack(Track,noise = 0.1)
Q = rand(r.nrow, r.ncol, r.max_velocity+1, r.max_velocity+1, 9)
C = zeros(r.nrow, r.ncol, r.max_velocity+1, r.max_velocity+1, 9)

policy = zeros(Int64,r.nrow, r.ncol, r.max_velocity+1, r.max_velocity+1)

for i in 1:r.nrow, j in 1:r.ncol, k in 1:r.max_velocity+1, l in 1:r.max_velocity+1
    policy[i,j,k,l] = argmax(Q[i,j,k,l,:])
end

#Learning see below
policy2 = copy(policy);
global b = generate_behavior(r)



global upcount = 0
global percentage = 0
nits = 10^2


@progress for episode in 1:nits

     if episode % (nits/100) == 0
        global percentage +=1
        print("\r")
        print("\r $(percentage)% trained, Policy updated $(upcount) times. ")
    end
    if episode % (nits/100) == 0
        global b = generate_behavior(r)
    end

    (S,A,R) = generate_episode(b,r)


    G = 0
    W = 1
    for t in length(S): -1 : 1
        G = gamma*G + R[t]
        #println(G)
        C[S[t][1], S[t][2], S[t][3], S[t][4], A[t]] += W

        Q[S[t][1], S[t][2], S[t][3], S[t][4], A[t]] +=
        (W/C[S[t][1], S[t][2], S[t][3], S[t][4], A[t]])
        *(G - Q[S[t][1], S[t][2], S[t][3], S[t][4], A[t]] )

        if(policy[S[t][1],S[t][2],S[t][3],S[t][4]]!== argmax(Q[S[t][1], S[t][2], S[t][3], S[t][4],:]))
            global upcount +=1
        end

        policy[S[t][1],S[t][2],S[t][3],S[t][4]]= argmax(Q[S[t][1], S[t][2], S[t][3], S[t][4],:])

        if A[t] !== Int(policy[S[t][1],S[t][2],S[t][3],S[t][4]])
            break
        end
        W = W * (1/b[S[t][1],S[t][2],S[t][3],S[t][4]][A[t]])
        #println(W)
        #W = W*2
    end
end

r = RaceTrack(Track,noise = 0)
println("\nLÄNGE $(length(generate_episode(policy,r,true)))")
