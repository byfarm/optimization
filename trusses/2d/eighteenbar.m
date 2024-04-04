AREA = 50;  % in^2
YOUNGS = 10000;  % ksi
MAXSTRESS = 20;  % ksi
DENSITY = 0.1e-3;  % kip/in^3
BETA = 4;
MAX_DISPLACEMENT = 6;  % in

P = 20;  % kips
truss = Truss(2, DENSITY);

% Add nodes
for i = 5:-1:0
    if i == 0
        forces = [0,0,0];
        constraints = [true,true,true];
    else
        forces = [0,-P,0];
        constraints = [false,false,false];
    end
    truss = truss.add_node([250*i,250,0],constraints,forces);
    if i ~= 5
        truss = truss.add_node([250*i,0,0],constraints,[0,0,0]);
    end
end

% set the displacement constraint
for i = 1:length(truss.freedom)
    if isequal(truss.freedom(i).node.coords,truss.nodes(1).coords)...
            && truss.freedom(i).vector(2) == 1
        
        truss.freedom(i).max_displacement = MAX_DISPLACEMENT;
        displacement_check = i;
        break;
    end
end

bars = [
    1,2;
    1,3;
    2,3;
    2,4;
    3,4;
    3,5;
    4,5;
    4,6;
    5,6;
    5,7;
    6,7;
    6,8;
    7,8;
    7,9;
    8,9;
    8,10;
    9,10;
    9,11;
    ];

for i = 1:18
    truss=truss.add_beam(bars(i,1),bars(i,2),YOUNGS,AREA,MAXSTRESS);
    truss.beams(i) = truss.beams(i).calc_buckling_stress(BETA);
end

groups = [
    0 0 0 0;
    1 2 3 5;
    4 6 7 9;
    8 10 11 13;
    12 14 15 17;
    16 18 NaN NaN;
    ];

truss = truss.create_groups(groups);

truss = truss.build();
truss = truss.solve();
otruss = basic_optimize(truss, 50, displacement_check, false);
otruss.x_mat

a_mat = [];
s_mat = [];
for i = 1:max(size(otruss.beams))
    a_mat(i, 1) = otruss.beams(i).area;
    s_mat(i, 1) = otruss.beams(i).stress;
end
disp('Displacements:')
x_matrix = otruss.x_mat
disp('Areas:')
a_mat
disp('Stresses:')
s_mat
disp('Weight of the optimized truss:')
otruss.weight


buckling_constrained = [];
for i = 1:max(size(otruss.beams))
    buckling_constrained(i, 1) = otruss.beams(i).buckling_const(MAXSTRESS, false);
    buckling_constrained(i, 2) = otruss.beams(i).buckling_const(MAXSTRESS, true);
end
disp("column 1: if the buckling constraint is applicable")
disp("column 2: if the buckling constraint is active")
buckling_constrained
