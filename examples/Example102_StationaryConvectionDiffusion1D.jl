#=
# 102: 1D Stationary convection-diffusion equation

Solve the equation

```math
-\nabla ( D \nabla u - v u) = 0
```
in $\Omega=(0,1)$ with boundary condition $u(0)=0$ and $u(1)=1$.
$v$ could be e.g. the velocity
of a moving medium or the gradient of an electric field.

This is a convection dominant second order boundary value problem which obeys
a local and a global maximum principle:
the solution which is bounded by the values at the boundary and has no local extrema in the
interior. 
If $v$ is large compared to $D$, a boundary layer is observed. 

The maximum principle of the solution can only be guaranteed it the discretization is
performed accordingly: the flux function must monotonically increase in the first argument
and monotonically decrease in the second argument. 

The example describes three possible ways to define the flux function and demonstrates
the impact on the qualitative properties of the solution. 
=# 

module Example102_StationaryConvectionDiffusion1D
using Printf
using VoronoiFVM
if isinteractive()
    using Plots
end

## Data  passed to the different functions
struct XData <: VoronoiFVM.AbstractData
    v
    D
end

#=
Central difference flux. The velocity term is discretized using the
average of the solution in the endpoints of the grid. If the local Peclet
number $\frac{vh}{D}>1$, the monotonicity property is lost.  Grid refinement
can fix this situation by decreasing $h$.
=#

function central_flux!(f,u,edge,data)
    uk=viewK(edge,u)  
    ul=viewL(edge,u)
    h=edgelength(edge)
    f_diff=data.D*(uk[1]-ul[1])
    f[1]=f_diff+data.v*h*(uk[1]+ul[1])/2
end

#=
The simple upwind flux corrects the monotonicity properties essentially
via brute force and loses one order of convergence for small $h$ compared
to the central flux.
=#
function upwind_flux!(f,u,edge,data)
    uk=viewK(edge,u)  
    ul=viewL(edge,u)
    h=edgelength(edge)
    fdiff=data.D*(uk[1]-ul[1])
    if data.v>0
        f[1]=fdiff+data.v*h*uk[1]
    else
        f[1]=fdiff+data.v*h*ul[1]
    end
end


#=
The exponential fitting flux has the proper monotonicity properties and
kind of interpolates in a clever way between central
and upwind flux. It can be derived by solving the two-point boundary value problem
at the grid interval analytically. 
=#

## Bernoulli function used in the exponential fitting discretization
function bernoulli(x)
    if abs(x)<nextfloat(eps(typeof(x)))
        return 1
    end
    return x/(exp(x)-1)
end

function exponential_flux!(f,u,edge,data)
    uk=viewK(edge,u)  
    ul=viewL(edge,u)
    h=edgelength(edge)
    Bplus= data.D*bernoulli(data.v*h/data.D)
    Bminus=data.D*bernoulli(-data.v*h/data.D)
    f[1]=Bminus*uk[1]-Bplus*ul[1]
end




function calculate(grid,data,flux,verbose)
    sys=VoronoiFVM.DenseSystem(grid,VoronoiFVM.Physics(flux=flux, data=data))
    
    ## Add species 1 to region 1
    enable_species!(sys,1,[1])
    
    ## Set boundary conditions
    sys.boundary_values[1,1]=0.0
    sys.boundary_values[1,2]=1.0
    sys.boundary_factors[1,1]=VoronoiFVM.Dirichlet
    sys.boundary_factors[1,2]=VoronoiFVM.Dirichlet
    
    ## Create a solution array
    inival=unknowns(sys)
    solution=unknowns(sys)

    ## Broadcast the initial value
    inival.=0.5
    
    ## Create solver control info
    control=VoronoiFVM.NewtonControl()
    control.verbose=verbose

    ## Stationary solution of the problem
    solve!(solution,inival,sys, control=control)
    return solution
end

function main(;n=10,doplot=false,verbose=false,D=0.01,v=1.0)
    
    ## Create a one-dimensional discretization
    h=1.0/convert(Float64,n)
    grid=VoronoiFVM.Grid(collect(0:h:1))
    
    data=XData(v,D)
    
    solution_exponential=calculate(grid,data,exponential_flux!,verbose)
    solution_upwind=calculate(grid,data,upwind_flux!,verbose)
    solution_central=calculate(grid,data,central_flux!,verbose)
    if doplot
        p=Plots.plot(title="Convection-Diffusion",grid=true)
        Plots.plot!(p,grid.coord[1,:],solution_exponential[1,:],label="exponential")
        Plots.plot!(p,grid.coord[1,:],solution_upwind[1,:],label="upwind")
        Plots.plot!(p,grid.coord[1,:],solution_central[1,:],label="central")
        Plots.plot!(p,show=true)
    end
    
    return sum(solution_exponential)+sum(solution_upwind)+sum(solution_central)
end


function test()
    testval=2.523569744561089
    main() ≈ testval
end

# End of module
end 

