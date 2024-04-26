classdef Results
% a class to call to get quick results from an optimized truss

    properties
        truss;
    end

    properties (Access = private)
    end

    methods
        function obj = Results(truss)
            obj.truss = truss;
        end

        function active_constrains = active_stresses(obj)
            % get active stress constraints
            active_constrains = zeros(length(obj.truss.beams), 1);
            for i = 1:length(obj.truss.beams)
                active_constrains(i, 1) = obj.truss.beams(i).exceed_stress();
            end
        end

        function active_constraints = active_displacements(obj)
            % get active displacement constraints
            active_constraints = abs(obj.truss.x_mat / obj.truss.max_displacement) >= 0.99;
        end

        function active_constraints = active_displacements_specific(obj, free_idxs)
            % get active displacement constraints given specific displacement constraints
            active_constraints = zeros(length(free_idxs), 2);
            for i = 1:length(free_idxs)
                idx = free_idxs(i);
                active = obj.truss.freedom(idx).displacement >= obj.truss.freedom(idx).max_displacement - 0.01;
                active_constraints(i, 1) = idx;
                active_constraints(i, 2) = active;
            end
        end

        function num = num_active_stresses(obj)
            num = sum(obj.active_stresses());
        end

        function num = num_active_dis_spc(obj, free_idxs)
            num = sum(obj.active_displacements_specific(free_idxs));
        end

    end
end
