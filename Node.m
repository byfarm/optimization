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

    end

end
