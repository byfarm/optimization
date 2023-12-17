% Truss object which represents the entire truss
classdef Truss
    properties
        nodes; % all the nodes in the truss
        beams; % all the beams in the truss
        freedom; % the degrees of freedom
        s_mat; % the s-matrix
        b_mat; % the b-matrix
        k_mat; % the k-matrix
        a_mat; % the a-matrix
        p_mat; % the p-matrix
        x_mat; % the x-matrix
        f_mat; % the f-matrix
    end

    properties (Access = private)
        deg_free = 0; % the degrees of freedom
        num_beams = 0; % the number of beams
        num_nodes = 0; % the number of nodes
        dimention; % the number of dimentions analyzing
        plot_multiplier = 0; % how big the arrows will be when plotting
    end

    methods
        function obj = Truss(dimention)
            arguments
                dimention (1,1) uint8 {mustBePositive} = 2 
            end
            % sets the number of dimentions that will be analyzed
            obj.dimention = dimention;
        end


        function obj = add_node(obj, coords, constraint, forces)
            % adds a node to the truss
            arguments
                obj (1, 1) Truss % truss object
                coords (1, 3) % coordinates for the node
                constraint (1, 3) = [false,false,false] % constraint for the node
            % false is free
                forces (1, 3) = [0,0,0] % the force vector on the node
            end

            % make sure all in 2d if only anayzing two dimentions
            if obj.dimention == 2
                constraint(end) = false;
                forces(end) = 0;
                coords(end) = 0;
            end

            new_node = Node(coords, constraint, forces); % create node

            % add the degrees of freedom for the node and make p_mat
            for i = 1:obj.dimention
                if constraint(i) == false
                    tmp = [false,false,false];
                    tmp(i) = true;
                    obj.freedom = [obj.freedom, DegreeFreedom(new_node, tmp)];

                    % make p_mat
                    ptmp = dot(double(tmp), forces);
                    obj.p_mat = [obj.p_mat; ptmp];
                end
            end

            % adds the node to the list of nodes
            obj.nodes = [obj.nodes, new_node];
        end


        function obj = add_beam(obj, idx_node1, idx_node2, E, A, max_stress)
            % adds a beam to the truss
            arguments
                obj (1, 1) Truss % the truss object
                idx_node1 (1, 1) uint16 % the index of node 1 for the beam
                idx_node2 (1, 1) uint16 % the index of the 2nd node for the beam in the Truss object
                E (1, 1) double % young's modulus
                A (1, 1) double % area of the beam
                max_stress (1,1) double % max allowable stress on beam
            end

            % finds the nodes based off the indexes passed in
            node1 = obj.nodes(idx_node1);
            node2 = obj.nodes(idx_node2);

            % adds the beam to the list of beam objects
            obj.beams = [obj.beams, Beam(node1, node2, E, A, idx_node1, idx_node2, max_stress)];
            obj.num_beams = obj.num_beams + 1;
        end


        function obj = build(obj)
            % builds all the matrixis
            obj.num_nodes = size(obj.nodes, 2);
            obj.num_beams = size(obj.beams, 2);
            obj.deg_free = size(obj.freedom, 2);

            obj = obj.build_s_mat();
            obj = obj.build_a_mat();

            obj.b_mat = obj.a_mat.';

            obj.k_mat = obj.a_mat * obj.s_mat * obj.b_mat;
        end

        function obj = solve(obj)
            % solve for displacemnt and stress
            obj.x_mat = obj.k_mat\obj.p_mat;
            obj.f_mat = obj.s_mat * obj.b_mat * obj.x_mat;

            % calc displacement along each degree of freedom
            for i = 1:obj.deg_free
                obj.freedom(i).displacement = obj.x_mat(i);
            end

            % calc stress for each beam
            for i = 1:obj.num_beams
                obj.beams(i) = obj.beams(i).calc_stress(obj.f_mat(i));
            end

        end


        function obj = optimize(obj)
            % do basic optimization for each beam
            for i = 1:obj.num_beams
                obj.beams(i) = obj.beams(i).optimize();
            end
        end
        

        function obj = plot(obj)
            figure('Position', [10 10 1200 600])
            obj = obj.find_plot_multiplier();

            % plot the beams
            plot_matrix = obj.get_beam_points();
            if obj.dimention == 3
                bm = plot3([plot_matrix(1,:);plot_matrix(4,:)],[plot_matrix(2,:);plot_matrix(5,:)],[plot_matrix(3,:);plot_matrix(6,:)], 'Color', 'black', 'DisplayName', 'Beams');
            elseif obj.dimention == 2
                bm = line([plot_matrix(1,:);plot_matrix(4,:)],[plot_matrix(2,:);plot_matrix(5,:)], 'Color', 'black', 'DisplayName', 'Beams');
            end

            title('Truss')
            hold on

            % plot the degrees of freedom
            deg_freedom = obj.get_free_points();
            if obj.dimention == 3
                df = quiver3(deg_freedom(1,:), deg_freedom(2,:), deg_freedom(3,:), deg_freedom(4,:)-deg_freedom(1,:),deg_freedom(5,:)-deg_freedom(2,:), deg_freedom(6,:)-deg_freedom(3,:),0,'Color', 'blue', 'DisplayName', 'Degrees of Freedom');
            elseif obj.dimention == 2
                df = quiver(deg_freedom(1,:), deg_freedom(2,:), deg_freedom(4,:)-deg_freedom(1,:),deg_freedom(5,:)-deg_freedom(2,:),0,'Color', 'blue', 'DisplayName', 'Degrees of Freedom');
            end

            % plot the forces
            forces = obj.get_force_points();
            if obj.dimention == 3
                forc = quiver3(forces(1,:), forces(2,:), forces(3,:), forces(4,:)-forces(1,:),forces(5,:)-forces(2,:), forces(6,:)-forces(3,:),0,'Color', 'red', 'DisplayName', 'Forces');
            elseif obj.dimention == 2
                forc = quiver(forces(1,:), forces(2,:), forces(4,:)-forces(1,:),forces(5,:)-forces(2,:),0,'Color', 'red', 'DisplayName', 'Forces');
            end

            % plot the constraints
            constraints = obj.get_constraint_points();
            if obj.dimention == 3
                cons = quiver3(constraints(1,:), constraints(2,:), constraints(3,:), constraints(4,:)-constraints(1,:),constraints(5,:)-constraints(2,:), constraints(6,:)-constraints(3,:),0,'Color', 'green', 'DisplayName', 'Constraints');
            elseif obj.dimention == 2
                cons = quiver(constraints(1,:), constraints(2,:), constraints(4,:)-constraints(1,:),constraints(5,:)-constraints(2,:),0,'Color', 'green', 'DisplayName', 'Constraints');
            end
            hold off
            legend([bm(1), df, forc, cons],'Beams','Degrees of Freedom', 'Forces', 'Constraints', 'Location', 'northeastoutside')
        end
    end

    methods (Access = private)

        function obj = build_s_mat(obj)
            % builds the s matrix
            s_mat = zeros(obj.num_beams);
            for i = 1:obj.num_beams
                area = obj.beams(i).area;
                length = obj.beams(i).length;
                young = obj.beams(i).young;
                s_mat(i,i) = (young * area) / length;
            end
            obj.s_mat = s_mat;
        end


        function obj = build_a_mat(obj)
            % builds the a matrix
            obj.a_mat = zeros(obj.deg_free, obj.num_beams);

            % go thru each and column
            for col = 1:obj.num_beams
                for row = 1:obj.deg_free

                    % if nodes match then insert the angle int a_mat
                    if obj.freedom(row).node.coords == obj.beams(col).node1.coords

                        % find the cos by normalizing the dot product
                        v1 = double(obj.freedom(row).vector);
                        v2 = obj.beams(col).vector;
                        dotprod = dot(v1, v2);
                        cos_angle = dot(v1, v2) / (norm(v1) * norm(v2));
                        obj.a_mat(row, col) = cos_angle;

                    elseif obj.freedom(row).node.coords == obj.beams(col).node2.coords

                        v1 = double(obj.freedom(row).vector);
                        v2 = obj.beams(col).vector;
                        dotprod = dot(v1, v2);
                        % I honestly don't know how this works but it does
                        cos_angle = -dot(v1, v2) / (norm(v1) * norm(v2));
                        obj.a_mat(row, col) = cos_angle;

                    end
                end
            end
        end


        function beampnts = get_beam_points(obj)
            % put cords of each beam into matrix
            for i = 1:obj.num_beams
                beampnts(:,i) = [obj.beams(i).node1.coords, obj.beams(i).node2.coords];
            end
        end


        function freepnts = get_free_points(obj)
            % get the coordinates to plot the deg of freedom vectors
            for i = 1:obj.deg_free
                newpnt = obj.freedom(i).node.coords + obj.plot_multiplier*(obj.freedom(i).vector);
                freepnts(:,i) = [obj.freedom(i).node.coords, newpnt];
            end
        end


        function forcepnts = get_force_points(obj)
            % gets the coordinates to plot the force vectors
            for i = 1:obj.num_nodes
                forcefactor = obj.nodes(i).forces ./ norm(obj.nodes(i).forces);
                newpnt = obj.nodes(i).coords + forcefactor*obj.plot_multiplier;
                forcepnts(:,i) = [obj.nodes(i).coords, newpnt];
            end
        end

        
        function constraintpnts = get_constraint_points(obj)
            % gets the coordinates to plot the constraint vectors
            for i = 1:obj.num_nodes
                for j = 1:3
                    zerarr = zeros(1, 3);
                    zerarr(j) = obj.plot_multiplier*double(obj.nodes(i).constraints(j));
                    newpnt = obj.nodes(i).coords + zerarr;
                    constraintpnts(:,3*i+j) = [obj.nodes(i).coords, newpnt];
                end
            end
        end


        function obj = find_plot_multiplier(obj)
            % sets the size of the vectors to be plotted to be 1/4 the size of a beam
            for i=1:obj.num_beams
                obj.plot_multiplier = max(obj.plot_multiplier, obj.beams(i).length);
            end
            obj.plot_multiplier = obj.plot_multiplier/4;
        end

    end
end
