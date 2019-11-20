#=
Definition of interface methods for grid.
=#


##########################################################
"""
$(TYPEDSIGNATURES)

Space dimension of grid
"""
dim_space(grid::Grid)= size(grid.coord,1)


##########################################################
"""
$(TYPEDSIGNATURES)


Number of nodes in grid
"""
num_nodes(grid::Grid)= size(grid.coord,2)


##########################################################
"""
$(TYPEDSIGNATURES)

Number of cells in grid
"""
num_cells(grid::Grid)= size(grid.cellnodes,2)

##########################################################
"""
$(TYPEDSIGNATURES)

Number of edges in grid
"""
num_edges(grid::Grid)= size(grid.edgenodes,2)

##########################################################
"""
$(TYPEDSIGNATURES)

Return index of i-th local node in cell icell
"""
cellnode(grid::Grid,inode,icell)=grid.cellnodes[inode,icell]

##########################################################
"""
$(TYPEDSIGNATURES)

Return view of coordinates of node `inode`.
"""
nodecoord(grid::Grid,inode)=view(grid.coord,:,inode)

##########################################################
"""
$(TYPEDSIGNATURES)

Return number of nodes per cell in grid.
"""
num_nodes_per_cell(grid::Grid)= size(grid.cellnodes,1)

##########################################################
"""
$(TYPEDSIGNATURES)

Return element type of grid coordinates.
"""
Base.eltype(grid::Grid)=Base.eltype(grid.coord)


################################################
"""
$(TYPEDSIGNATURES)

Bulk region number for cell
"""
reg_cell(grid::Grid,icell)=grid.cellregions[icell]

################################################
"""
$(TYPEDSIGNATURES)


Boundary region number for boundary face
"""
reg_bface(grid::Grid,icell)=grid.bfaceregions[icell]

################################################
"""
$(TYPEDSIGNATURES)


Topological dimension of grid
"""
dim_grid(grid::Grid)= size(grid.bfacenodes,1)

################################################
"""
$(TYPEDSIGNATURES)

Index of boundary face node.
"""
bfacenode(grid::Grid,inode,icell)=grid.bfacenodes[inode,icell]

################################################
"""
$(TYPEDSIGNATURES)

Index of cell edge node.
"""
celledge(grid::Grid,iedge,icell)=grid.celledges[iedge,icell]


################################################
"""
$(TYPEDSIGNATURES)

Index of cell edge node.
"""
celledgenode(grid::Grid,inode,iedge,icell)=grid.cellnodes[grid.local_celledgenodes[inode,iedge],icell]

################################################
"""
$(TYPEDSIGNATURES)
    
Number of edges per grid cell.
"""
num_edges_per_cell(grid::Grid)= size(grid.local_celledgenodes,2)

################################################
"""
$(TYPEDSIGNATURES)

Number of nodes per boundary face
"""
num_nodes_per_bface(grid::Grid)= size(grid.bfacenodes,1)

################################################
"""
$(TYPEDSIGNATURES)

Number of boundary faces in grid.
"""
num_bfaces(grid::Grid)= size(grid.bfacenodes,2)

################################################
"""
$(TYPEDSIGNATURES)

Number of cell regions in grid.
"""
num_cellregions(grid::Grid)= grid.num_cellregions

################################################
"""
$(TYPEDSIGNATURES)

Number of boundary face regions in grid.
"""
num_bfaceregions(grid::Grid)=grid.num_bfaceregions

################################################
"""
$(TYPEDSIGNATURES)

Provide information for PyPlot triangulation data for plotting.
Needs to be splatted. Use it e.g. like
```
    PyPlot.trisurf(tridata(g)...,U)
```
"""
tridata(g)=g.coord[1,:], g.coord[2,:],transpose(g.cellnodes.-1)
