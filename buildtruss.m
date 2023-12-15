YOUNGS = 10000;
AREA = 10;

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


truss = Truss;


% this is the loads for case 1
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

for i = 1:10
    node1 = beam_nodes(i,1);
    node2 = beam_nodes(i,2);
    truss = truss.add_beam(node1, node2, YOUNGS, AREA);
end
