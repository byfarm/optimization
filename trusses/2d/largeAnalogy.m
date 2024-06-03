YOUNGS = 10^7; % kips/in^2
MAX_STRESS = 25; % kips/in^2
AREAS = 0.40; % in^2

% load the data from th csv file
T = readtable('largeAnalogy.csv');
A = table2array(T);
node_coord_x = rmmissing(A(:,1));
node_coord_y = rmmissing(A(:,2));

node_idx_1 = rmmissing(A(:,3));
node_idx_2 = rmmissing(A(:,4));

dimentions = 2;
density = 0.1;  % lbs/in^3

truss = Truss(dimentions, density);

% add the extra bars that we took out with the beam-truss analogy
avert = 0.8;
ahor = 24;
adiag = 1.13;
extra_areas = [
12,adiag,200*sqrt(2);
12,ahor,200;
6,avert,200
];
density = 0.1;
extra_weight = 0;
for i = 1:3
    extra_weight = extra_weight + extra_areas(i, 1) * extra_areas(i, 2) * extra_areas(i,3) * density;
end
truss.base_weight = extra_weight;

f_mom = 60;

% reaction Forces
R7 = [70+f_mom, -100-f_mom, 0];
R8 = [70-f_mom, 0, 0];
R15 = [0, -100+f_mom, 0];

constrained_nodes = [600, 800; 800, 800; 1400, 0; 1400, 200];

% add the nodes to the truss
for i = 1:length(node_coord_x)
    
    % default forces and constraints
    force = [ 0 ,0 , 0];
    constraints = [ false, false , 0];
    
    % get spectific forces and constraints
    if node_coord_x(i) == 600 && node_coord_y(i) == 0
        force = R7;
    elseif node_coord_x(i) == 600 && node_coord_y(i) == 200
        force = R8;
    elseif node_coord_x(i) == 800 && node_coord_y(i) == 0
        force = R15;
    elseif ismember([node_coord_x(i), node_coord_y(i)], constrained_nodes, "rows")
        constraints = [true, true, 0];
    end
    
    % add the node to the truss
    truss = truss.add_node([node_coord_x(i), node_coord_y(i), 0], constraints, force);
end


freedom_check = [];
% add constraints to degrees of freedom
for i = 1:length(truss.freedom)
    
    % find the wanted nodes
    if isequal(truss.freedom(i).node.coords,truss.nodes(1).coords)...
            && truss.freedom(i).vector(2) == 1
        % set the max displacement
        truss.freedom(i).max_displacement = 10;
        % add the index to the freedom check
        freedom_check = [freedom_check, i];
        
    elseif isequal(truss.freedom(i).node.coords,truss.nodes(9).coords)...
            && truss.freedom(i).vector(1) == 1
        truss.freedom(i).max_displacement = 10;
        freedom_check = [freedom_check, i];
    end
end

% add the beams to the truss
for i = 1:length(node_idx_1)
    node1_idx = node_idx_1(i);
    node2_idx = node_idx_2(i);
    truss = truss.add_beam(node1_idx, node2_idx, YOUNGS, AREAS, MAX_STRESS);
end

% build and solve the truss
truss = truss.build();
truss = truss.solve();
otruss = basic_optimize(truss, 50, freedom_check);

a_mat = [];
s_mat = [];
for i = 1:length(otruss.beams)
    a_mat(i, 1) = [ otruss.beams(i).area ];
    s_mat(i, 1) = [ otruss.beams(i).stress ];
end
x_matrix = otruss.x_mat
disp('Areas:')
a_mat
disp('Stresses:')
s_mat
disp('Weight of the optimized truss:')
otruss.weight

% replace the forces with a reaction moments, treated the truss as a beam.
% make the moment two forces times perpinduclar distance.
