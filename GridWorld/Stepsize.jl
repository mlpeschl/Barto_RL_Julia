include("Environment.jl")

function sargmax(array::Vector{Float64})
    tmp = maximum(array)
    inds = findall(x -> x == tmp, array)
    return rand(inds)
end

function eps_greedy(Q::Array{Float64,2}, epsilon::Float64, S::Int64)
    if rand() > epsilon
        #println(Q[S,:])
        A = sargmax(Q[S,:])
    else
        A = rand(1:size(Q)[2])
    end
    return A
end

function Q_Learn(nits; α = 0.5, γ = 0.99, ϵ = 0.1)
    #Q-learning (Off-policy TD control) for estimating π ≈ π*
    g = GridWorld()
    #For comparing learning performance:
    episodelength = zeros(nits)
    ###################################
    Q = zeros(60,4)

    if α == 0
        counter = 1
        for episode in 1:nits
            isDone = false
            S = g.start
            while !isDone
                episodelength[episode] += 1
                A = eps_greedy(Q,ϵ,S)
                #println(A)
                (R,isDone) = action(g,A)
                S´ = g.position
                Q[S,A] += (1/counter)*(R + γ* maximum(Q[S´,:]) - Q[S,A])
                S = S´
                counter +=1
            end
        end
    else
        for episode in 1:nits
            isDone = false
            S = g.start
            while !isDone
                episodelength[episode] += 1
                A = eps_greedy(Q,ϵ,S)
                (R,isDone) = action(g,A)
                S´ = g.position
                Q[S,A] += α*(R + γ* maximum(Q[S´,:]) - Q[S,A])
                S = S´
            end
        end
    end
    return (Q,episodelength)
end


nits = 50


global eplen1 = zeros(nits)
for k in 1:5000
    Q,eplens = Q_Learn(nits, α = 1.1)
    global eplen1 = eplen1 + eplens
end
eplen1 = eplen1/5000

global eplen2 = zeros(nits)
for k in 1:5000
    Q,eplens = Q_Learn(nits, α = 0)
    global eplen2 = eplen2 + eplens
end
eplen2 = eplen2/5000

global eplen3 = zeros(nits)
for k in 1:5000
    Q,eplens = Q_Learn(nits, α = 1)
    global eplen3 = eplen3 + eplens
end
eplen3 = eplen3/5000


using Gadfly,Cairo,Fontconfig

l1 = layer(x = collect(1:length(eplen1)) ,y = eplen1, Geom.line, Theme(default_color
            = "turquoise"))
l2 = layer(x = collect(1:length(eplen2)) ,y = eplen2, Geom.line,
            Theme(default_color = "red"))
l3 = layer(x = collect(1:length(eplen3)) ,y = eplen3, Geom.line,
            Theme(default_color = "blue"))


plot(l1,l2,l3, Guide.manual_color_key("Stepsizes",["α = 1.1","α = 1/n","α = 1"],["turquoise","red", "blue"])) |> PDF("currentplot.pdf")
