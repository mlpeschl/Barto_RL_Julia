w0 = rand(-1:0.01:1,(4))
#G = [14,11,26,21]
G = [3,-15,5,21]
vectors = [[4,7,1,1],[10,6,0,1],[20,1,15,1],[4,19,3,1]]
#-----------------------------------------------#
α = 0.001

w1 = w0 + α*(G[1] - w0' * vectors[1]).*vectors[1]


println("\nValue before $(w0'*vectors[1])")
println("Value after $(w1'*vectors[1])")
println("Error before $((G[1] - w0'vectors[1])^2)")
println("Error after $((G[1] - w1'vectors[1])^2)\n")


w2 = w1 + α*(G[2] - w1' * vectors[2]).*vectors[2]


println("\nValue before $(w1'*vectors[2])")
println("Value after $(w2'*vectors[2])")
println("Error before $((G[2] - w1'vectors[2])^2)")
println("Error after $((G[2] - w2'vectors[2])^2)\n")

#α = 0.01

w3 = w2 + α*(G[3] - w2' * vectors[3]).*vectors[3]


println("\nValue before $(w2'*vectors[3])")
println("Value after $(w3'*vectors[3])")
println("Error before $((G[3] - w2'vectors[3])^2)")
println("Error after $((G[3] - w3'vectors[3])^2)\n")


w4 = w3 + α*(G[4] - w3' * vectors[4]).*vectors[4]


println("\nValue before $(w3'*vectors[4])")
println("Value after $(w4'*vectors[4])")
println("Error before $((G[4] - w3'vectors[4])^2)")
println("Error after $((G[4] - w4'vectors[4])^2)\n")
#------------------------------------------------------#
append!(vectors,[[6,7,2,0],[3,8,4,1]])

#α = 0.01

δ = -1 + w4'*vectors[6] - w4'*vectors[5] #R_{t+1} + γ * q_hat(S_{t+1},A_{t+1},w_t) - q_hat(S_t,A_t,w_t)

w5 = w4 + α*δ.*vectors[5]

println("\nValue before $(w4'*vectors[5])")
println("Value after $(w5'*vectors[5])")
println("Error before $(δ^2)")
println("Error after $((-1 + w5'*vectors[6] - w5'*vectors[5])^2 )\n")



δ = -1 + w4'*vectors[6] - w4'*vectors[5] #R_{t+1} + γ * q_hat(S_{t+1},A_{t+1},w_t) - q_hat(S_t,A_t,w_t)

w5 = w4 + α*δ.*vectors[5]

println("\nValue before $(w4'*vectors[5])")
println("Value after $(w5'*vectors[5])")
println("Error before $(δ^2)")
println("Error after $((-1 + w5'*vectors[6] - w5'*vectors[5])^2 )\n")

δ = 19 - w5'*vectors[6]

w6 = w5 + α*δ.*vectors[6]

println("\nValue before $(w5'*vectors[6])")
println("Value after $(w6'*vectors[6])")
println("Error before $(δ^2)")
println("Error after $((19 - w6'*vectors[6])^2)\n")


w = w6
actions = []

if w'*[20,6,1,1] >= w'*[20,6,1,0]
    push!(actions,1)
else
    push!(actions,0)
end

if w'*[10,7,2,1] >= w'*[10,7,2,0]
    push!(actions,1)
else
    push!(actions,0)
end


if w'*[5,8,4,1] >= w'*[5,8,4,0]
    push!(actions,1)
else
    push!(actions,0)
end


w'*[20,6,1,1]
w'*[10,7,2,1]
w'*[5,8,4,1]

w
