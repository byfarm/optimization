function stop = auto_stop(weights, threshold)
    % function to stop the iterating if weights stop changing
    arguments
        weights (:,:) double  % an array of the weights from the truss
        threshold double  % the threshold to stop iterating
    end

    diff = abs(weights(end) - weights(end-1));

    if diff < threshold
        stop = true;
    else
        stop = false;
    end
end
