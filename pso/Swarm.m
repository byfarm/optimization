classdef Swarm
    properties
        particles;
        truss; % the truss to be solved
    end

    properties (Access = private)
        INERTIA = 10;
        C1 = 3;
        C2 = 2;
        MIN_AREA = 4;
        MAX_AREA = 16;

        global_best;
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
                s_truss = truss.simplify_truss(areas(i,:));

                obj.particles(i) = Particle(...
                    s_truss, obj.MIN_AREA, obj.MAX_AREA,...
                    obj.INERTIA, obj.C1, obj.C2...
                );
            end

            obj.truss = truss;
        end


    end
end
