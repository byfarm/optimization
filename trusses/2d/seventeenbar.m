
P = 10;
truss = Truss(2);
for i = 6:-1:0
    if i == 0
        forces = [0,0,0];
        constraints = [true,true,true];
    else
        forces = [0,-P,0];
        constraints = [false,false,false];
    end

    truss = truss.add_node([250*i,250,0],constraints,forces);
    if i ~= 0
        truss = truss.add_node([250*i,250,0],constraints,[0,0,0]);
    end

end
