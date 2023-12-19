YOUNGS = 10000;
areas = [2, 2, 4, 4];
MAXSTRESS = 300;

beam_nodes = [
    1,5;
    2,5;
    3,5;
    4,5;
];

truss = Truss(3);

truss = truss.add_node([0,0,0], [true,true,true]);
truss = truss.add_node([0,2,0], [true,true,true]);
truss = truss.add_node([2,0,0], [true,true,true]);
truss = truss.add_node([2,2,0], [true,true,true]);
truss = truss.add_node([1,1,1], [false,false,false], [0,4000,100000]);

for i = 1:size(beam_nodes)
    truss=truss.add_beam(beam_nodes(i,1),beam_nodes(i,2),YOUNGS,areas(i),MAXSTRESS);
end

truss=truss.build();
truss=truss.solve();

displacement = truss.x_mat
forces = truss.f_mat

truss.plot();
