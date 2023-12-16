clear;


h = hypot(9,12); % find geometry

% build a and b matrix
a_mat = [
    -1, 0, 0, 0, 0, -9/h, 0, 0; 
    0, 0, 0, 1, 0, 12/h, 0, 0;
    1, 0, 0, 0, 0, 0, 9/h, -9/h;
    0, 0, 0, 0, 1, 0, 12/h, 12/h;
    0, 1, -1, 0, 0, 9/h, 0, 0;
    0, 0, 1, 0, 0, 0, 0, 9/h;
    ];
b_mat = a_mat.';

% build p matrix
p_mat = [
  0;
  0;
  -1440;
  1920;
  0;
  1440;
];

% calculate the s matrix 
elastic_modulus(1,1:8) = 30000; % ksi
areas = [3, 3, 3, 5, 5, 2, 2, 2]; % in2
lenghts = [9, 9, 9, 12, 12, 15, 15, 15];
eal = elastic_modulus .* areas ./ lenghts;
s_mat = zeros(8);
for i = 1:1:8
    s_mat(i,i) = eal(i);
end

k_mat = a_mat * s_mat * b_mat; % calc global stiffness matrix
fprintf("stiffness matrix\n");
disp(k_mat);

x_mat = k_mat \ p_mat; % find displacement

f_mat = s_mat * b_mat * x_mat; % find forces

areas = areas.'; % transpose Area matrix for sigma calc

sigma_mat = f_mat ./ areas; % find stress

fprintf("Stresses\n");
disp(sigma_mat);
