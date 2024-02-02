% load the data from th csv file
T = readtable('large.csv');
A = table2array(T);
node_x = A(:,1);
node_y = A(:,2);
truss1 = rmmissing(A(:,3));
truss2 = rmmissing(A(:,4));



