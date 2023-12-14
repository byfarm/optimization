classdef Beam

    properties
        node1; % the coords of one end of the beam
        node2; % the coords of the other end of the beam
        young; % young's modulus for the material of the beam
        area; % the cross-sectional area of the beam
        length; % the length of the beam
    end

    methods
        function obj = Beam(node1, node2, young, area)
            % initializes the beam object
            arguments
                node1 (1, 1) Node % the node1 object
                node2 (1, 1) Node % the node2 object
                young (1,1) double {mustBePositive} % young's modulus of the beam
                area (1,1) double {mustBePositive} % the area of the beam
            end
            obj.node1 = node1;
            obj.node2 = node2;
            obj.area = area;
            obj.young = young;
            obj.length = norm([node1.coords] - [node2.coords]);
        end
    end

end
