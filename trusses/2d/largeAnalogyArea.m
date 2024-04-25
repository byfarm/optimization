YOUNGS = 10^7; % kips/in^2
MAX_STRESS = 25; % kips/in^2
AREAS = 0.40; % in^2

% load the data from th csv file
T = readtable('large.csv');
A = table2array(T);
node_coord_x = rmmissing(A(:,1));
node_coord_y = rmmissing(A(:,2));

node_idx_1 = rmmissing(A(:,3));
node_idx_2 = rmmissing(A(:,4));

dimentions = 2;
density = 0.1;  % lbs/in^3

truss = Truss(dimentions, density);

f1 = 70; % kips
f2 = 100;
f3 = 20;

constrained_nodes = [600, 800; 800, 800; 1400, 0; 1400, 200];

% add the nodes to the truss
for i = 1:length(node_coord_x)
    
    % default forces and constraints
    force = [ 0 ,0 , 0];
    constraints = [ false, false , 0];
    
    % get spectific forces and constraints
    if node_coord_x(i) == 0 && node_coord_y(i) == 0
        force = [ f1, -f3 , 0];
    elseif node_coord_x(i) == 0 && node_coord_y(i) == 200
        force = [ f1, 0 , 0];
    elseif node_coord_x(i) == 600 && node_coord_y(i) == -600
        force = [ f3, -f2 , 0];
    elseif node_coord_x(i) == 800 && node_coord_y(i) == -600
        force = [ 0, -f2 ,0 ];
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
    % put inital areas using beam truss analogy
    if ismember(i, [6 7 9 10 30 31 33 34 20 19 17 16])
        % diag
        area = 1.13;
    elseif ismember(i, [2 8 29 32 18 15])
        % vert
        area = 0.8;

    % TOP
    elseif ismember(i, [1 3 21])
        % top hor
        area = 21.5;
    elseif ismember(i, [2 4 22])
        % bottom hor
        area = 26.8;

    % BOTTOM
    elseif ismember(i, [23 14 12])
        area = 28;
        % vert left
    elseif ismember(i, [24 13 11])
        area = 20;
        % vert right

    else
        area = AREAS;
    end
    truss = truss.add_beam(node1_idx, node2_idx, YOUNGS, AREAS, MAX_STRESS);
end

% add group constraints to the truss (remove group constraints)
% truss = truss.create_groups(groups);

% build and solve the truss
truss = truss.build();
truss = truss.solve();
otruss = basic_optimize(truss, 50, freedom_check);

a_mat = []
s_mat = []
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
