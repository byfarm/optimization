YOUNGS = 1.17e6; 
MAX_STRESS = 500; 
AREAS = 0.25^2;  % in^2 

% read in the tables
T = readtable('planepoints.csv.txt');
A = table2array(T);

% coordinates of the nodes
xcoord = rmmissing(A(:,1));
ycoord = rmmissing(A(:,2));
zcoord = rmmissing(A(:,3));

% nodes for the beams
node1 = rmmissing(A(:,4));
node2 = rmmissing(A(:,5));

% create the truss
truss = Truss(3);

for i = 1:length(xcoord)
    coord = [xcoord(i),ycoord(i),zcoord(i)];
    constraints = [true true true];
    forces = [0 0 0];

    % set where the wing attaches to the truss to carry the loads
    if isequal(coord, [0,8,4]) || isequal(coord, [5,8,4])
        constraints = [false false false];
        forces = [0 0 100];

    % set top constraints to false
    elseif zcoord(i) == 4
        constraints = [false false false];
    end

    % add the node to the truss
    truss = truss.add_node(coord, constraints, forces);
end

% add the beams to the truss
for i = 1:length(node1)
    truss = truss.add_beam(node1(i), node2(i), YOUNGS, AREAS, MAX_STRESS);
end

% build and solve the truss
truss = truss.build();
truss = truss.solve();

% print the stresses    
fprintf('Stresses in the beams\n');
for i = 1:length(truss.beams)
    fprintf('%d: %f\n', i, truss.beams(i).stress)
end
% disp('Stresses in the beams');
% disp(stresses);
truss.plot_dis()
