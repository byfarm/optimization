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
    end

    methods
        function obj = Truss(dimention)
            arguments
                dimention (1,1) uint8 {mustBePositive} = 2 
            end
            % sets the number of dimentions that will be analyzed
            obj.dimention = dimention;
        end

        % need to make a node object to keep coords and constraints in same place
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

        function obj = add_beam(obj, idx_node1, idx_node2, E, A)
            % adds a beam to the truss
            arguments
                obj (1, 1) Truss % the truss object
                idx_node1 (1, 1) uint16 % the index of node 1 for the beam
                idx_node2 (1, 1) uint16 % the index of the 2nd node for the beam in the Truss object
                E (1, 1) double % young's modulus
                A (1, 1) double % area of the beam
            end

            % finds the nodes based off the indexes passed in
            node1 = obj.nodes(idx_node1);
            node2 = obj.nodes(idx_node2);

            % adds the beam to the list of beam objects
            obj.beams = [obj.beams, Beam(node1, node2, E, A, idx_node1, idx_node2)];
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
            obj.x_mat = obj.k_mat\obj.p_mat;
            obj.f_mat = obj.s_mat * obj.b_mat * obj.x_mat;
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

    end
end
