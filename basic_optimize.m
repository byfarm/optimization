function opti_truss = basic_optimize(opti_truss, iters, freedom_idxs, autostop)
% uses basic optimization to optimize the truss
arguments
    opti_truss (1,1) Truss % truss object
    iters (1,1) int16 % number of iterations want performed
    freedom_idxs (:,1) int16 = false % the freedom indicies to check
    autostop (1,1) logical = true % whether to use autostop
end

for i = 1:iters
    % go through stress optimization
    opti_truss = opti_truss.build();
    opti_truss = opti_truss.solve();
    opti_truss = opti_truss.optimize_stress();
    
    % group rods
    opti_truss = opti_truss.group_rods();
    
    % now through displacement optimization
    opti_truss = opti_truss.build();
    opti_truss = opti_truss.solve();
    if freedom_idxs
        opti_truss = opti_truss.optimize_specific_dis(freedom_idxs);
    else
        opti_truss = opti_truss.optimize_dis();
    end
    
    % group rods
    opti_truss = opti_truss.group_rods();
    
    % calculate the weight
    opti_truss = opti_truss.calc_weight();
    weights(i, :) = [i, opti_truss.weight];
    
    if autostop
        stop = auto_stop(weights, 0.01);
        if stop
            break;
        end
    end
end

figure;
plot(weights(:, 1), weights(:, 2));
title('Weight vs. Iteration');
xlabel('Iteration number');
ylabel('Weight (lbs)');
opti_truss = opti_truss.build();
opti_truss = opti_truss.solve();

end
