# Packages
using Pkg
#using Plots
using DifferentialEquations
using PyPlot


# Parameters
i = 1.25 # 0.089;%nutrient input HG 4.5 gram per 4 days, LG 1 gram per four days, on fourth day 4/45/4=1.25
f = .25 #0.0015; %nutrient removal, I/f = 50? 100% every four days=.25 per day
u = .4#uptake by X red
w = 1.14 #1.14;%uptake by green
a = 1.19 #  growth rate for red X is ln(2)*24/14
d = .25 #.005;%death of P red
s = .02 #10;%numerical half saturation X uptake red, controls passage to quiescence
b = 0.55 # growth rate for green Y is ln(2)*24/30
e = .15 #death of Q green
r = 5 #numerical half saturation Y uptake green
m = 0 #.05;0 when looking at single pop
q = .00001
h =1 # return loop P to X
v = .03 # half saturation for return loop P to X

# Time
maxtime = 30
tspan = (0.0, maxtime)

# Dose
stim = 50

# Initial conditions
x0 = [100 1 20.0 200.0 200.0]


# Model equations
function system(dy, y, p, t)

V = y[1]
X = y[2]
Y = y[3]
P = y[4]
Q = y[5]

V, X, Y, P, Q, = y
T = X+Y
E = (V)./(v+T+V)
A = (V)./(s+V)
B = (V)./(r+T+V)
C =  X./(X+Y+q)
D = Y./(X+Y+q)

  dy[1] = i - f.*V - u.*X.*A- w.*Y.*B
  dy[2] = a.*X.*A  - a.*X.*(1-A) + m.*P - m.*P.*C + h.*P.*E
  dy[3] = b.*Y.*B -e.*Y - b.*Y.*(1-B) - m.*P.*D
  dy[4] = a.*X.*(1-A) - m.*P + m.*P.*C - d.*P - h.*P.*E
  dy[5] = b.*Y.*(1-B) + m.*P.*D - e.*Q
end

# Events
function condition1(y, t, integrator)
    t - 6.0
end
function condition2(y, t, integrator)
    t-20.0
end

function affect!(integrator)
    integrator.u[1] += stim
end

cb1 = ContinuousCallback(condition1, affect!)
cb2 = ContinuousCallback(condition2, affect!)
cb = CallbackSet(cb1,cb2)
# Solve
prob = ODEProblem(system, x0, tspan)
sol = solve(prob, Rodas4(), callback = cb)

# Plotting
#plot(sol, layout = (2, 3))
legends = [:V :X :Y :P :Q]
#linetypes = = [:path :steppre :steppost :sticks :scatter]
#plot(sol, line=(linetypes, 3), background_color=RGB(0.2, 0.2, 0.2), layout = (2, 3), #xlim=(0, 10), label=map(string, legends))

plot(sol, vars=(0,4),background_color=RGB(0.2, 0.2, 0.2), xaxis="Time",label = "P", lw=3,ls=:dash)

#xlabel(''Time (days)'')
# title!("TITLE")
# yaxis!("YLABEL", :log10)
