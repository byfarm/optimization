classdef Beam
    
    properties
        node1; % the coords of one end of the beam
        node2; % the coords of the other end of the beam
        idx1; % the index of the first node
        idx2; % the index of the second node
        young; % young's modulus for the material of the beam
        area; % the cross-sectional area of the beam
        length; % the length of the beam
        vector; % the vecotr of the beam
        
        max_stress; % the max design stress for the beam
        min_stress; % the min design stress for the beam
        stress = 0; % the stress once the beam is solved
    end
    
    methods
        function obj = Beam(node1, node2, young, area, i1, i2, max_stress)
            % initializes the beam object
            arguments
                node1 (1, 1) Node % the node1 object
                node2 (1, 1) Node % the node2 object
                young (1,1) double {mustBePositive} % young's modulus of the beam
                area (1,1) double {mustBePositive} % the area of the beam
                i1 (1,1) int16
                i2 (1,1) int16
                max_stress double
            end
            obj.node1 = node1;
            obj.node2 = node2;
            obj.area = area;
            obj.young = young;
            obj.vector = node1.coords - node2.coords;
            obj.length = norm(obj.vector);
            obj.idx1 = i1;
            obj.idx2 = i2;
            obj.max_stress = max_stress;
            obj.min_stress = -max_stress;
        end
        
        function obj = calc_stress(obj, force)
            % calculates the stress for the beam
            obj.stress = force / obj.area;
        end
        
        function obj = optimize(obj)
            % uses basic optimization fucntion to optimize beam
            if obj.stress < 0
                obj.area = obj.area * abs(obj.stress / obj.min_stress);
            else
                obj.area = obj.area * abs(obj.stress / obj.max_stress);
            end
            obj.area = max(obj.area, 0.1);
            
        end
        
        function obj = calc_buckling_stress(obj, beta)
            arguments
                obj (1,1) Beam
                beta (1,1) double   % the buckling factor
            end
            % calculates the buckling stress for the beam
            bar_buckling_stress = -beta * obj.young * obj.area / (obj.length^2);
            
            % set the minimum stress to the lesser of the min stress and
            % the buckling stress
            obj.min_stress = -min(abs([obj.min_stress, bar_buckling_stress]));
        end

        function buckle_const = buckling_const(obj, reg_stress, check_if_active)
            arguments
                obj (1,1) Beam
                reg_stress (1,1) 
                check_if_active (1,1) = true
            end

            if abs(obj.min_stress) == reg_stress
                buckle_const = false;

            elseif obj.stress <= obj.min_stress + 0.1 ...
                & obj.stress >= obj.min_stress - 0.1
                buckle_const = true;

            elseif check_if_active 
                buckle_const = false;

            else
                buckle_const = true;
            end

        end

        function exceeded = exceed_stress(obj)
            % function to see if the stress is exceeded
            if obj.stress < 0
                exceeded = abs(obj.stress / obj.min_stress) > 0.99;
            else
                exceeded = abs(obj.stress / obj.max_stress) > 0.99;
            end
        end
    end
    
end
