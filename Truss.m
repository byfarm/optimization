

classdef Truss
    properties
        nodes;
        beams;
        constraints;
        loads;
    end

    methods
        % need to make a node object to keep coords and constraints in same place
        function obj = add_node(obj, coords, constriant)
            % adds a node to the truss
            arguments
                obj (1, 1) Truss % truss object
                coords (3, 1) % coordinates for the node
                constraint (3, 1) % constraint for the node
            end

            % adds the node to the list of nodes
            obj.nodes = [obj.nodes, coords];
        end

        function obj = add_beam(obj, node1, node2, E, A)
            % adds a beam to the truss
            arguments
                obj (1, 1) Truss % the truss object
                node1 (1, 1) % the index of node 1 for the beam
                node2 (1, 1) % the index of the 2nd node for the beam in the Truss object
                E (1, 1) % young's modulus
                A (1, 1) % area of the beam
            end

            % finds the nodes based off the indexes passed in
            node1 = obj.nodes(node1);
            node2 = obj.nodes(node2);

            % adds the beam to the list of beam objects
            obj.beams = [obj.beams, Beam(node1, node2, E, A)];
        end

        function obj = add_consrtaint(obj, node, constraint)
            % adds a constraint to the truss
            arguments
                obj (1, 1) Truss
                node (1, 1)
                constraint (3, 1)
            end
            obj.constraints = [obj.constraints, node; constraint];
        end
        function build()
        end
        function solve()
        end
    end
end


% need to add an external force function
