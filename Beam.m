classdef Beam
    properties
        node1;
        node2;
        young;
        area;
        length;
    end
    methods
        function obj = Beam(node1, node2, young, area)
            % initializes the beam object
            arguments
                node1 (3, 1) % the coords of node1
                node2 (3, 1) % the coords of node2
                young (1,1) % young's modulus of the beam
                area (1,1) % the area of the beam
            end
            obj.node1 = node1;
            obj.node2 = node2;
            obj.area = area;
            obj.young = young;
            obj.length = calc_dist();
        end

        function obj = calc_dist(obj)
            obj.length = norm(obj.node1 - obj.node2);
        end
    end

end
