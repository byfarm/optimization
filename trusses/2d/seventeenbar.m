AREA = 10;
YOUNGS = 1000;
MAXTRESS = 100;
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
for i = 1:length(bars)
    truss=truss.add_beam(bars(i,1),bars(i,2),YOUNGS,AREA,MAXSTRESS);
end

truss.plot()
