function pe = getPositionalEncoding(time_steps, features)
    % time_steps: Number of time steps in your sequences (800)
    % features: Number of features in each time step (51)

    pe = zeros(features, time_steps);
    position = (0:time_steps-1)';
    div_term = exp(-log(10000.0) * (0:features-1)' / features);

    for i = 1:features
        if mod(i, 2) == 1
            pe(i, :) = sin(position / 10000^(i / features));
        else
            pe(i, :) = cos(position / 10000^(i / features));
        end
    end
end