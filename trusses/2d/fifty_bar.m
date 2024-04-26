clear; clc;
YOUNGS = 30e6;  % psi
MAXSTRESS = 20e3;  % psi
DENSITY = 0.289;  % lb/in^3

TIP_DISPLACEMENT = 0.5;  % in
% 2 is the number of dimentions

truss = Truss(2, DENSITY);

for i = 0:10
    constraints = [false, false, false];
    forces = [0, -10e3, 0];  % lbs
    if i == 0
        constraints(1) = true;
        constraints(2) = true;
        forces = [0 0 0];
    elseif i == 10
        forces(2) = -110e3;  % lbs
    end
    truss = truss.add_node([i*20, 0, 0], constraints);
    truss = truss.add_node([i*20, 40, 0], constraints, forces);
end

% set the displacement constraint
dis_const = [22 21 11];
for d = 1:length(dis_const)
    free_idx = dis_const(d);
    if free_idx == 11
        dis_constraint = TIP_DISPLACEMENT/4;
    else
        dis_constraint = TIP_DISPLACEMENT;
    end
    [truss, i] = truss.set_displacement(dis_constraint, free_idx, [0 1 0]);

    % replace the displacement constraint array with the idx of the freedom vector
    dis_const(d) = i;
end

AVERT = 10.00;  % in^2
AHOR = 38.75;
ADIAG = 11.18;
% adds the beam to the structure
for i = 1:10
    idx = 2 * i;
    truss = truss.add_beam(idx-1, idx+1, YOUNGS, AHOR, MAXSTRESS);
    truss = truss.add_beam(idx  , idx+1, YOUNGS, ADIAG, MAXSTRESS);

    truss = truss.add_beam(idx-1, idx+2, YOUNGS, ADIAG, MAXSTRESS);
    truss = truss.add_beam(idx  , idx+2, YOUNGS, AHOR, MAXSTRESS);
    truss = truss.add_beam(idx+1, idx+2, YOUNGS, AVERT, MAXSTRESS);
end


truss = basic_optimize(truss, 1000, dis_const);
for i = 1:max(size(truss.beams))
    a_mat(i, 1) = truss.beams(i).area;
    s_mat(i, 1) = truss.beams(i).stress;
end
disp('Displacements:')
x_matrix = truss.x_mat
disp('Areas:')
a_mat
disp('Stresses:')
s_mat
disp('Weight of the optimized truss:')
truss.weight
