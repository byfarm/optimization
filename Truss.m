

classdef Truss
    properties
        nodes; % all the nodes in the truss
        beams; % all the beams in the truss
        s_mat; % the s-matrix
    end

    methods
        % need to make a node object to keep coords and constraints in same place
        function obj = add_node(obj, coords, constraint, forces)
            % adds a node to the truss
            arguments
                obj (1, 1) Truss % truss object
                coords (1, 3) % coordinates for the node
                constraint (1, 3) = [false,false,false] % constraint for the node
                forces (1, 3) = [0,0,0] % the force vector on the node
            end

            new_node = Node(coords, constraint, forces); % create node

            % adds the node to the list of nodes
            obj.nodes = [obj.nodes, new_node];
        end

        function obj = add_beam(obj, idx_node1, idx_node2, E, A)
            % adds a beam to the truss
            arguments
                obj (1, 1) Truss % the truss object
                idx_node1 (1, 1) int8 % the index of node 1 for the beam
                idx_node2 (1, 1) int8 % the index of the 2nd node for the beam in the Truss object
                E (1, 1) double % young's modulus
                A (1, 1) double % area of the beam
            end

            % finds the nodes based off the indexes passed in
            node1 = obj.nodes(idx_node1);
            node2 = obj.nodes(idx_node2);

            % adds the beam to the list of beam objects
            obj.beams = [obj.beams, Beam(node1, node2, E, A)];
        end

        function build()
        end
        function solve()
        end

        function obj = build_s_mat(obj)
            sz = size(obj.beams)
            s_mat = zeros(sz);
            for i = 1:sz(2)
                area = obj.beams(i).area;
                length = obj.beams(i).length;
                young = obj.beams(i).young;
                s_mat(i,i) = (young * area) / length;
            end
            obj.s_mat = s_mat;
        end

    end
end


% need to add an external force function
