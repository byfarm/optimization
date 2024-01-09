This library is used to create representations of trusses and can be used for truss optimisation

To initialize a 2d truss object, call the trust class
`truss = Truss(2)`
You can pass in 3 to create a 3d truss object.

To create the truss, you must first define the nodes of the truss. this can be done by calling the add_node() method. Each node must be passed a location for the node. The node can also be passed constrained conidtions and forces acting on the node.
for example 
`truss = truss.add_node([0,1], [false, true], [0,100])`
creates a node at location x = 0 and y = 1, which is constrained in the x direction but free in the y direction, which has a force acting 100 units in the positive y direction.

To add a beam to the truss call the add_beam() method.
for example:
`truss = truss.add_beam(idx1, idx2, youngs, area, maxstress)`
adds a beam to the truss object, with the start of the beam at the node at the index specified by idx1 in the truss object and the end specified by idx2. `youngs` is Young's modulus for the beam, `area` is the cross-sectional area of the beam, `maxstress` is the designed max stress of the beam.

For large trusses, it is recomended to set up both the nodes and the beams in for loops. see the examples for reference.

Once all nodes and beams are added to the truss, it is time to build the truss.
Call the method: init_build to build the a and b matrix. These matrix's will not change as we optimize, so this method only has to be called once.
```truss = truss.init_build()```

Now we can enter our loop of optimization. We first call the build method to build the s and k matrixes. From there, call the solve method to solve the truss and vuolla! the truss has been solved!

```
truss = truss.build()
truss = truss.solve()
```

The matrix is currently inverted using the built-in MATLAB \ operator, but that can be easily changed.

To find the total weight of the truss, call the calc_weight method
```truss = truss.calc_weight()```

finally to do a basic optimization, call the optimize method
```truss=truss.optimize()```

This does the basic 
    new_area = old_area * (stress / max_stress)
On each beam to optimize the truss 
