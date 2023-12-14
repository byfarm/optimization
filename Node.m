classdef Node

    properties
        coords; % 3d coordinates of position
        constraints; % 3d constraints [x, y, z]
        forces; % 3d forces on node
    end

    methods
        function obj = Node(coords, constraints, forces)
            % initializes the node object
            arguments
                coords (1, 3) {mustBeNumeric}
                constraints (1, 3) {islogical} = [false, false, false]
                forces (1, 3) {mustBeNumeric} = [0,0,0]
            end

            obj.coords = coords;
            obj.constraints = constraints;
            obj.forces = forces;
        end

        function obj = add_force(obj, forces)
            % adds a force onto the existing node
            arguments
                obj (1,1) Node
                forces (1, 3) {mustBeNumeric}
            end
            obj.forces = obj.forces + forces;
        end

        function obj = change_constraints(obj, constraints)
            % makes it possible to change the constraints of a node once init
            arguments
                obj (1,1) Node
                constraints (1, 3) {mustBeNumeric}
            end
            obj.constraints = constraints;
        end

    end

end
