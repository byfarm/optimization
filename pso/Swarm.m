classdef Swarm
    properties
        particles; % a vector of all the particles in the swarm
        truss; % the truss to be solved
    end

    properties (Access = private)
        INERTIA = 10;
        C1 = 3;
        C2 = 2;
        MIN_AREA = 4;
        MAX_AREA = 16;

        global_best = inf;
    end

    methods
        function obj = Swarm(truss, num_particles)
        % inits the Swarm object with the specified number of particles
        arguments
            truss (1,1) Truss % the init built truss (with nodes and such)
            num_particles (1,1) uint16 % the number of particles wanted initialized
        end
            areas = rand(num_particles, truss.num_beams);
            obj.particles = Particle.empty(truss.num_beams, 0);

            for i = 1:num_particles
                % convert truss to simple using given area
                s_truss = truss.simplify_truss(areas(i,:));

                obj.particles(i) = Particle(...
                    s_truss, obj.MIN_AREA, obj.MAX_AREA,...
                    obj.INERTIA, obj.C1, obj.C2...
                );

                obj.particles(i) = obj.particles(i).build();
                obj.particles(i) = obj.particles(i).solve();
            end

            obj.truss = truss;

            % init the global best's weight to be inf (dummy)
            obj.global_best = obj.particles(1);
            obj.global_best.truss.weight = inf;

            obj.global_best = obj.find_global_best();
        end

        function obj = find_global_best(obj)
            % find the global best from the particles
            for i = 1:max(size(obj.particles))
                if obj.global_best.truss.weight > obj.particles(i).truss.weight
                    obj.global_best = obj.particles(i);
                end
            end
        end


    end
end
