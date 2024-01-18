function truss = basic_optimize(truss, iters)
    % uses basic optimization to optimize the truss
    arguments
        truss (1,1) Truss % truss object
        iters (1,1) int16 % number of iterations want performed
    end

    for i = 1:iters
        truss = truss.build();
        truss = truss.solve();
        truss = truss.optimize_stress();
    end
end
