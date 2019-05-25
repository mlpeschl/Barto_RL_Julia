include("Environment.jl")

function eps_greedy(Q::Array{Float64,2}, epsilon::Float64, S::Int64)
    randnr = rand()
    if randnr > epsilon
        A = sargmax(Q[S,:])
    else
        A = rand(1:size(Q)[2])
    end

    return A
end


function sargmax(array)
    tmp = maximum(array)
    inds = findall(x -> x == tmp, array)
    return rand(inds)
end

function DynaQ(nits::Int64, n::Int64, γ = 0.95, ϵ = 0.1, α = 0.1)
    Q = rand(60,4)
    Model = fill((-1,-1),(60,4))
    observed = Set()
    g = GridWorld()
    cumsum = 0
    bench = []
    for t in 1:nits

        if t == 1001
            g.blocks = collect(32:40)

        end

        S = g.position
        A = eps_greedy(Q,ϵ,S)
        (R,isDone) = action(g,A)
        if isDone
            cumsum +=1
        end

        S´ = g.position

        Q[S,A] += α * (R + γ * maximum(Q[S´,:]) - Q[S,A])
        Model[S,A] = (R,S´)
        union!(observed,[(S,A)])
        for i in 1:n
            (S,A) = rand(observed)
            (R,S´) = Model[S,A]
            Q[S,A] += α * (R + γ * maximum(Q[S´,:]) - Q[S,A])
        end
        append!(bench,copy(cumsum))
    end
    return (Q,bench)
end



function DynaQplus(nits::Int64, n::Int64, γ = 0.95, ϵ = 0.1, α = 0.1, κ = 0.0005)
    Q = rand(60,4)
    Model = fill((-1,-1),(60,4))
    τ = zeros(Int64,(60,4))
    observed = Set()
    g = GridWorld()
    cumsum = 0
    bench = []
    for t in 1:nits
        if t == 1001
            g.blocks = collect(32:40)

        end
        S = g.position
        A = eps_greedy(Q,ϵ,S)
        (R,isDone) = action(g,A)
        τ .+= 1
        τ[S,A] = 0
        if isDone
            cumsum +=1
        end
        S´ = g.position

        Q[S,A] += α * (R + γ * maximum(Q[S´,:]) - Q[S,A])
        Model[S,A] = (R,S´)
        union!(observed,[(S,A)])
        for i in 1:n
            (S,A) = rand(observed)
            (R,S´) = Model[S,A]
            Q[S,A] += α * ((R+ κ*sqrt(τ[S,A])) + γ * maximum(Q[S´,:]) - Q[S,A])
        end
        append!(bench,copy(cumsum))
    end
    return (Q,bench)
end



function DynaQ2(nits::Int64, n::Int64, γ = 0.95, ϵ = 0.1, α = 0.1, κ = 0.0005)
    Q = rand(60,4)
    Model = fill((-1,-1),(60,4))
    τ = zeros(Int64,(60,4))
    observed = Set()
    g = GridWorld()
    cumsum = 0
    bench = []
    for t in 1:nits
        if t == 1001
            g.blocks = collect(32:40)

        end
        S = g.position
        A = eps_greedy(Q + κ*τ, ϵ, S)
        (R,isDone) = action(g,A)
        τ .+= 1
        τ[S,A] = 0
        if isDone
            cumsum +=1
        end
        S´ = g.position

        Q[S,A] += α * (R + γ * maximum(Q[S´,:]) - Q[S,A])
        Model[S,A] = (R,S´)
        union!(observed,[(S,A)])
        for i in 1:n
            (S,A) = rand(observed)
            (R,S´) = Model[S,A]
            Q[S,A] += α * (R + γ * maximum(Q[S´,:]) - Q[S,A])
        end
        append!(bench,copy(cumsum))
    end
    return (Q,bench)
end





function eval(nits::Int64)
    benchDyna = zeros(4000)
    benchDynaplus = zeros(4000)
    benchDyna2 = zeros(4000)
    @progress for i in 1:nits

        (QDyna, tmp) = DynaQ(4000,50)
        (QDynaplus, tmp1) = DynaQplus(4000,50)
        (QDyna2, tmp2) = DynaQ2(4000,50)
        benchDyna += tmp
        benchDynaplus += tmp1
        benchDyna2 += tmp2
    end

    benchDyna = benchDyna/nits
    benchDynaplus = benchDynaplus/nits
    benchDyna2 = benchDyna2/nits
    return (benchDyna,benchDynaplus, benchDyna2)
end


(benchDyna, benchDynaplus, benchDyna2) = eval(200)
