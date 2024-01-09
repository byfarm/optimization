This library is used to create representations of trusses and can be used for truss optimisation

To initialize a 2d truss object, call the trust class
```
truss = Truss(2)
```
You can pass in 3 to create a 3d truss object.

To create the truss, you must first define the nodes of the truss. this can be done by calling the add_node() method. Each node must be passed a location for the node. The node can also be passed constrained conidtions and forces acting on the node.
for example 
```
truss = truss.add_node([0,1], [false, true], [0,100])
```
creates a node at location x = 0 and y = 1, which is constrained in the x direction but free in the y direction, which has a force acting 100 units in the positive y direction.

To add a beam to the truss call the add_beam() method.
for example:
```
truss = truss.add_beam(idx1, idx2, youngs, area, maxstress)
```
adds a beam to the truss object, with the start of the beam at the node at the index specified by idx1 in the truss object and the end specified by idx2. `youngs` is Young's modulus for the beam, `area` is the cross-sectional area of the beam, `maxstress` is the designed max stress of the beam.

For large trusses, it is recomended to set up both the nodes and the beams in for loops. see the examples for reference.

Once all nodes and beams are added to the truss, it is time to build the truss.
Call the method: init_build to build the a and b matrix. These matrix's will not change as we optimize, so this method only has to be called once.
```
truss = truss.init_build()
```

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

Bellow is an example from the research paper found in trusses/2d/paper2d
```
YOUNGS = 10000;
MAXSTRESS = 65;

beam_nodes = [
    5, 3;
    3, 1;
    6, 4;
    4, 2;
    4, 3;
    2, 1;
    5, 4;
    6, 3;
    3, 2;
    4, 1;
];

areas = rand(size(beam_nodes)) * 10;


% 2 is the number of dimentions
truss = Truss(2);


% this is the loads for case 1
% build the nodes
for i = 3:-1:1
    if i == 1
        constrained = true;
        forces = [0,0,0];
    else
        constrained = false;
        forces = [0,-100,0];
    end
    % coordes are in inches
    truss = truss.add_node([(i-1) * 360,360,0], [constrained, constrained, false]);
    truss = truss.add_node([(i-1) * 360,0,0], [constrained, constrained, false], forces);
end

% adds the beam to the structure
for i = 1:size(beam_nodes)
    node1 = beam_nodes(i,1);
    node2 = beam_nodes(i,2);
    truss = truss.add_beam(node1, node2, YOUNGS, areas(i), MAXSTRESS);
end

truss = basic_optimize(truss, 50)
```

To visualize the trusses, call the `plot` method once the truss is built.
```
truss.plot()
```

Or to see displacements, call the `plot_dis` method once the truss is solved
```
truss.plot_dis()
```
