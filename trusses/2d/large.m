YOUNGS = 10^7; % kips/in^2
MAX_STRESS = 25; % kips/in^2
AREAS = 40; % in^2

% load the data from th csv file
T = readtable('large.csv');
A = table2array(T);
node_x = rmmissing(A(:,1));
node_y = rmmissing(A(:,2));
truss1 = rmmissing(A(:,3));
truss2 = rmmissing(A(:,4));
truss = Truss(2);

f1 = 70; % kips
f2 = 100;
f3 = 20;

constrained_nodes = [600, 800; 800, 800; 1400, 0; 1400, 200];

% add the nodes to the truss
for i = 1:length(node_x)

    % default forces and constraints
    force = [ 0 ,0 , 0];
    constraints = [ false, false , 0];

    % get spectific forces and constraints
    if node_x(i) == 0 && node_y(i) == 0
        force = [ f1, -f3 , 0];
    elseif node_x(i) == 0 && node_y(i) == 200
        force = [ f1, 0 , 0];
    elseif node_x(i) == 600 && node_y(i) == -600
        force = [ f3, -f2 , 0];
    elseif node_x(i) == 800 && node_y(i) == -600
        force = [ 0, -f2 ,0 ];
    elseif ismember([node_x(i), node_y(i)], constrained_nodes, "rows")
        constraints = [true, true, 0];
    end

    % add the node to the truss
    truss = truss.add_node([node_x(i), node_y(i), 0], constraints, force);
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



for i = 1:length(truss1)
    node1_idx = truss1(i);
    node2_idx = truss2(i);
    truss = truss.add_beam(node1_idx, node2_idx, YOUNGS, AREAS, MAX_STRESS);
end

truss = truss.build;
truss = truss.solve;
otruss = basic_optimize(truss, 50, freedom_check);

for i = 1:length(otruss.beams)
    fareas(i, 1) = otruss.beams(i).area;
end
x_matrix = otruss.x_mat
fareas

