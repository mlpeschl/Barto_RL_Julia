include("RaceEnvironment.jl")

function length_eval(policy,eps)
    local r1 = RaceTrack(Track,noise = 0.1)
    isDone = false
    locallen = 0

    while !isDone
        if rand() > eps
            action = policy[r.position[1],r.position[2],
                r.velocity[1]+1,r.velocity[2]+1]
        else
            action = rand(1:9)
        end
        (reward,isDone) = take_action(r,action)
        locallen += 1
    end
    return locallen
end


function generate_behavior(r::RaceTrack)
    b = Array{Any}(undef,r.nrow, r.ncol, r.max_velocity+1, r.max_velocity+1)
    for i in 1:r.nrow, j in 1:r.ncol, k in 1:r.max_velocity+1, l in 1:r.max_velocity+1
        z = rand(9)                               #Total of 9 Actions
        b[i,j,k,l] = (exp.(z))/(sum(exp.(z)))     #softmax
    end
    return b
end


#Off policy MC Control for estimating π ≈ π*
gamma = 1  #Discount Factor

r = RaceTrack(Track,noise = 0.1)
Q = rand(r.nrow, r.ncol, r.max_velocity+1, r.max_velocity+1, 9)
C = rand(r.nrow, r.ncol, r.max_velocity+1, r.max_velocity+1, 9)

policy = zeros(Int64,r.nrow, r.ncol, r.max_velocity+1, r.max_velocity+1)

for i in 1:r.nrow, j in 1:r.ncol, k in 1:r.max_velocity+1, l in 1:r.max_velocity+1
    policy[i,j,k,l] = argmax(Q[i,j,k,l,:])
end

#Learning see below
global b = generate_behavior(r)
global upcount = 0
global percentage = 0
nits = 10^4
global lengthsMC = []

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
    push!(lengthsMC, copy(length_eval(policy,0.1)))
end


"test = []
for i in 1:10^3
    push!(test, copy(length_eval(policy,1.0)))
end

test"
