# Changes
## v0.5.2 Nov 19, 2019
- Reorganized grid stuff
- Included triangle (after Ideas from TriangleMesh.jl)

## v0.5.1 Nov 13, 2019
- Fixed performance regression: AbstractArrays for Grid components were slow.
- Added handling of cylindrical coordinates

## V0.5, November 10, 2019
- Velocity projections
- Added edge handling to grid struct

## V0.4.2, November 6, 2019
- Replaced PyPlot by Plots
- Better and more examples

## V0.4, July 12, 2019
- Registered with Julia ecosystem
- Enhance Newton solver by embedding, exception handling
- Replace SparseMatrixCSC with ExtendableSparseMatrix
- fixed allocation issues in assembly
- assured that users get allocation stuff right via
  typed functions in physics structure
- more julianic API

## V0.3, April 9 2019
- Renamed from TwoPointFluxFVM to  VoronoiFVM
- Complete rewrite of assembly allowing sparse or dense matrix 
  to store degree of freedom information
    - Solution is a nnodes x nspecies sparse or dense matrix
    - The wonderful array interface of Julia still provides slicing
      etc in oder to access  species without need to write
      any bulk_solution stuff or whatever when using the sparse variant
- Re-export value() for debugging in physics functions
- Test function handling for flux calculation
- First working steps to impedance handling
- Abolished Graph in favor of  Grid, Graph was premature optimization...

## V0.2, Feb 20, 2019

- Changed signature of all callback functions:
  This also allows to pass user defined arrays etc. to the callback functions.
  In particular, velocity vectors can be passed this way.

  - Besides of `flux!()`, they now all have `node::VoronoiFVM.Node`
    as a second argument.

  - `flux!()` has `edge::VoronoiFVM.Edge` as a second argument

  - the `x` argument in `source!()` is omitted, the same data
     are now found in `node.coord`


- New method `edgelength(edge::VoronoiFVM.Edge)`
  
## V0.1, Dec. 2018

- Initial release
