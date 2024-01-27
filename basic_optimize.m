function opti_truss = basic_optimize(opti_truss, iters)
    % uses basic optimization to optimize the truss
    arguments
        opti_truss (1,1) Truss % truss object
        iters (1,1) int16 % number of iterations want performed
    end

    for i = 1:iters
        opti_truss = opti_truss.build();
        opti_truss = opti_truss.solve();
        max_dis = max(abs(opti_truss.x_mat));
        if max_dis > 2
            opti_truss = opti_truss.optimize_dis();
        else
            opti_truss = opti_truss.optimize_stress();
        end
    end

    opti_truss = opti_truss.optimize_dis();
    opti_truss = opti_truss.build();
    opti_truss = opti_truss.solve();
end
