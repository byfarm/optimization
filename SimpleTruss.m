classdef SimpleTruss
    % this is the much faster truss solver which will be used to optimize
    properties
        areas; % a vector of areas for each beam
        lengths; % a vector of lengths for each beam
        youngs; % young's modulus for each beam (or singular)
        densities; % the densities for each beam (or singular)
        weight; % the weight of the truss

        p_matrix; % the loading conditions
        a_matrix; % the a-matrix for the truss
        b_matrix; % the b-matrix for the truss (transpose of a)
        s_matrix; % the s-matrix for the truss
        k_matrix; % the stiffness matrix for the truss

        f_matrix; % the force matrix once solved
        x_matrix; % the displacement matrix once solved
        stresses; % the stress for each beam once solved
    end

    properties (Access = private)
    end

    methods
        function obj = SimpleTruss(...
                areas, lengths, youngs, densities, a_matrix, p_matrix ...
            )
        arguments
            areas (:,1)
            lengths (1,:)
            youngs (1,:)
            densities (1,:)
            a_matrix (:,:)
            p_matrix (:,1)
        end
            obj.areas = areas;
            obj.lengths = lengths;
            obj.youngs = youngs;
            obj.densities = densities;

            obj.a_matrix = a_matrix;
            obj.b_matrix = a_matrix.';

            obj.p_matrix = p_matrix;
        end


        function obj = build(obj)
            obj.s_matrix = diag(obj.areas) .* obj.youngs ./ obj.lengths;
            obj.k_matrix = obj.a_matrix * obj.s_matrix * obj.b_matrix;
        end


        function obj = solve(obj)
            obj.x_matrix = obj.k_matrix \ obj.p_matrix;
            obj.f_matrix = obj.s_matrix * obj.b_matrix * obj.x_matrix;
            obj.stresses = obj.f_matrix ./ obj.areas;
        end


        function obj = find_weight(obj)
            weight_per_beam = obj.areas.' .* obj.lengths .* obj.densities;
            obj.weight = sum(weight_per_beam);
        end
    end
end
