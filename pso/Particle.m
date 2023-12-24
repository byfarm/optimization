classdef Particle
    properties
        position; % the position of the particle
        velocity; % the velo of the particle
        truss; % the simpletruss object
    end

    properties (Access = private)
        inertia_weight;
        c1; % acceleration constant 1
        c2; % acceleration constant 2
        best_past_position;
    end

    methods
        function obj = Particle(truss, min_area, max_area, inertia_weight, c1, c2)
        arguments
            truss (1,1) SimpleTruss % the truss object for the particle
            min_area (1,1) % the design constraint on the minimum area
            max_area (1,1) % design constraint on the max area
            inertia_weight (1,1)
            c1 (1,1)
            c2 (1,1)
        end
            % initializes the particle
            obj.truss = truss;

            range = max_area - min_area;
            length = max(size(truss.lengths));

            obj.position = truss.areas;
            obj.best_past_position = obj.position;
            obj.velocity = 0.2 * range * rand(length);

            obj.inertia_weight = inertia_weight;
            obj.c1 = c1;
            obj.c2 = c2;
        end


        function obj = calc_velo(obj, pos_global_best)
        arguments
            obj (2,2) % Particle object
            pos_global_best (1,1) % the best position amoungst all particles
        end

            inertia_term = obj.inertia_weight * obj.velocity;
            local_term = obj.c1 * rand(1) * (obj.best_past_position - obj.position);
            global_term = obj.c2 * rand(1) * (pos_global_best - obj.position);

            obj.velocity = inertia_term + local_term + global_term;
        end


        function obj = update_best_pos(obj)
            obj.position = obj.position + obj.velocity;

            obj.truss.areas = obj.position;
            obj.truss = obj.truss.build();
            obj.truss = obj.truss.solve();
            obj.truss = obj.truss.find_weight();

            if obj.position.truss.weight < obj.best_past_position.truss.weight
                obj.best_past_position = obj.position;
            end
        end
    end
end


