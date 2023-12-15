

classdef DegreeFreedom
    properties
        node;
        vector;
    end

    methods
        function obj = DegreeFreedom(node, vector)
            % inits the class
            arguments
                node (1,1) % the node the degree of freedom is at
                vector (1, 3) % the vector of the degree of freedom
            end

            obj.node = node;
            obj.vector = vector;
        end
    end
end
