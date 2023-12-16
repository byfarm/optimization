YOUNGS = 30000;
areas = [3,3,3,5,5,2,2,2];

beam_nodes = [
    1,3;
    2,4;
    4,5;
    1,2;
    4,3;
    1,4;
    2,3;
    5,3;
];


truss = Truss(2);

truss = truss.add_node([0,12,0]);
truss = truss.add_node([0,0,0],[true,true,false]);
truss = truss.add_node([9,12,0],[false,false,false],[-1400,1920,0]);
truss = truss.add_node([9,0,0],[false,true,false]);
truss = truss.add_node([18,0,0],[false,true,false],[1440,0,0]);

for i = 1:size(beam_nodes)
    node1 = beam_nodes(i,1);
    node2 = beam_nodes(i,2);
    truss = truss.add_beam(node1, node2, YOUNGS, areas(i));
end
