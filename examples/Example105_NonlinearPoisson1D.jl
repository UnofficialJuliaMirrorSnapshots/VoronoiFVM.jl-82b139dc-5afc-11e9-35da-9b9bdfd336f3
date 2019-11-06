#=
# 105: 1D Nonlinear Poisson equation

Solve the nonlinear Poisson equation

```math
-\nabla \varepsilon \nabla u + e^{u}-e^{-u} = f
```
in $\Omega=(0,1)$ with boundary condition $u(0)=0$ and $u(1)=1$ with 
```math
f(x)=
    \begin{cases}
    1&,x>0.5\\
    -1&, x<0.5
    \end{cases}.
```
    
This stationary problem is an example of a nonlinear Poisson equation or Poisson-Boltzmann equation.
Such equation occur e.g. in simulations of electrochemical systems and semicondutor devices.
 
=# 

# 
#  Start the module
# 
module Example105_NonlinearPoisson1D


# This gives us he @printf macro (c-like output)
using Printf

# That's the thing we want to do
using VoronoiFVM

# Allow plotting
if isinteractive()
    using Plots
end



# Main function for user interaction from REPL and
# for testing. Default physics need to generate correct
# test value.
function main(;n=10,doplot=false,verbose=false, dense=false)
    
    ## Create a one-dimensional discretization
    h=1.0/convert(Float64,n)
    grid=VoronoiFVM.Grid(collect(0:h:1))

    ## A parameter which is "passed" to the flux function via scope
    ϵ=1.0e-3
   

    ## Flux function which describes the flux
    ## between neigboring control volumes
    function flux!(f,u,edge,data)
        uk=viewK(edge,u)  
        ul=viewL(edge,u)
        f[1]=ϵ*(uk[1]-ul[1])
    end

    ## Source term
    function source!(f,node,data)
        if node.coord[1]<=0.5
            f[1]=1
        else
            f[1]=-1
        end
    end
    
    ## Reaction term
    function reaction!(f,u,node,data)
        f[1]=exp(u[1]) - exp(-u[1]) 
    end
    
    ## Create a physics structure
    physics=VoronoiFVM.Physics(
        flux=flux!,
        source=source!,
        reaction=reaction!)
    

    ## Create a finite volume system - either
    ## in the dense or  the sparse version.
    ## The difference is in the way the solution object
    ## is stored - as dense or as sparse matrix
    if dense
        sys=VoronoiFVM.DenseSystem(grid,physics)
    else
        sys=VoronoiFVM.SparseSystem(grid,physics)
    end

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

    if doplot
        Plots.plot(grid.coord[1,:],solution[1,:],
                   label="",
                   title="Nonlinear Poisson",
                   grid=true,show=true)
    end
    
    return sum(solution)
end


function test()
    testval=1.5247901344230088
    main(dense=false) ≈ testval && main(dense=true) ≈ testval
end

# End of module
end 

