This library is used to create representations of trusses and can be used for truss optimisation

To initialize a 2d truss object, call the trust class
`truss = Truss(2)`
You can pass in 3 to create a 3d truss object.

To create the truss, you must first define the nodes of the truss. this can be done by calling the add_node() method. Each node must be passed a location for the node. The node can also be passed constrained conidtions and forces acting on the node.
for example 
`truss = truss.add_node([0,1], [false, true], [0,100])`
creates a node at location x = 0 and y = 1, which is constrained in the x direction but free in the y direction, which has a force acting 100 units in the positive y direction.

To add a beam to the truss call the add_beam() method.
for example
`truss = truss.add_beam(idx1, idx2, youngs, area, maxstress)`
adds a beam to the the truss object, with the start of the beam at the node at the index specified by idx1 in the truss object and the end specified by idx2. `youngs` is Young's modulus for the beam, `area` is the cross-sectional area of the beam, `maxstress` is the designed max stress of the beam.

For large trusses, it is recomended to set up both the nodes and the beams in for loops. see the examples for reference.


