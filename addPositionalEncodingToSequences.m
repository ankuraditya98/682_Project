function [encoded_pose_sequences] = addPositionalEncodingToSequences(pose_sequences)
    encoded_pose_sequences = cell(size(pose_sequences));

    for i = 1:length(pose_sequences)
        [features, time_steps] = size(pose_sequences{i});
        pe = getPositionalEncoding(time_steps, features);
        encoded_pose_sequences{i} = pose_sequences{i} + pe;
    end
end