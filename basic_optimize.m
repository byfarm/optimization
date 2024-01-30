function opti_truss = basic_optimize(opti_truss, iters)
    % uses basic optimization to optimize the truss
    arguments
        opti_truss (1,1) Truss % truss object
        iters (1,1) int16 % number of iterations want performed
    end

    weights = zeros(iters, 2);
    for i = 1:iters
        opti_truss = opti_truss.build();
        opti_truss = opti_truss.solve();
        opti_truss = opti_truss.optimize_stress();

        opti_truss = opti_truss.build();
        opti_truss = opti_truss.solve();
        opti_truss = opti_truss.optimize_dis();
        
        weight = opti_truss.calc_weight();
        weights(i, :) = [i, weight];
    end

    figure;
    plot(weights(:, 1), weights(:, 2));
    title('Weight vs. Iteration');
    xlabel('Iteration number');
    ylabel('Weight (lbs)');
    opti_truss = opti_truss.build();
    opti_truss = opti_truss.solve();

end
