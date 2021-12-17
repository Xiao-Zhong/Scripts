# #sayhi("Xiao")
# function sayhi(name)
# 	println("Hi $name, it's great to see you!")
# end
# #sayhi("Xiao")
#
# #println(f(9))
function f(x)
	x^2
	#sayhi("--Xiao")
end
# #println(f(9))
#
# # a = rand(3, 3)
# # #println(a)
# # println(f(a))
# # #println(println("xxx"))
# # A = rand(3, 1)
# # println(A)
# # # println(f(A))
#
# v = [2, 1, 100, 20]
# println(v)
# println(sort(v))
# println(v)
# println(sort!(v))
# println(v)

A = [i + 3*j for j in 0:2, i in 1:3]
println(A)
println(f(A))
println(f.(A))

A = [1 3; 5 7; 9 11; 13 15; 17 19]
B = [2, 4, 6, 8, 10]
println(broadcast(+, A, B))
println(broadcast(-, A, B))
