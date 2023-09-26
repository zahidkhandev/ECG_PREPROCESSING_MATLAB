function filtered_ecg = moving_avg_filter(ecgData)
    windowSize = 10;
    filtered_ecg = zeros(size(ecgData)); 

    for i = 1:length(ecgData) - windowSize + 1
        window = ecgData(i:i + windowSize - 1);
        filtered_ecg(i) = mean(window);
    end
end
