%%
%input : microstate_label,xy coordinate of the data. 
%output: depends on the microstate number in each label. return 50*1 CELL
%of xy coordinate which correstpond microstates
label = microstate_labels;
head_x = x_coordinate.';
head_y = y_coordinate.';

returnmicro= cell(num_microstates,1);

for nom = 1:length(label) %nom = number of movie
    for frame = 1:length(label{nom})
        micros = label{nom}(frame);
        x = head_x{nom}(1,frame);
        y = head_y{nom}(1,frame);
        returnmicro{micros} = [returnmicro{micros} [x;y]];
    end

end
%%
figure(4)
clf
for i = 1:length(returnmicro)
    subplot(5,10,i)

    scatter(returnmicro{i}(1,:),returnmicro{i}(2,:))
    xlim([0,320])
    ylim([0,240])
    set(gca,'YDir','reverse')
    title('microstate',i)
    
end
%%
figure(5)
clf
levels = 10;
for i = 1:length(returnmicro)

    map = dataDensity(returnmicro{i}(1,:),returnmicro{i}(2,:), 320, 240);
    map = map - min(min(map));
    map = floor(map ./ max(max(map)) * (levels-1));
    
    subplot(5,10,i)
    image(map);
    colormap(jet(levels));
    set(gca, 'XTick', [0 320]);
    set(gca, 'XTickLabel', [0 320]);
    set(gca, 'YTick', [0 240]);
    set(gca, 'YTickLabel', [0 240]);
    title('microstate',i)

        
end


