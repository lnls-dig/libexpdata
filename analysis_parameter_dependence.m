function analysis_parameter_dependence(dataset, metadataset, Kx, Ky, sweep_parameter)

Kx = Kx/1e3;
Ky = Ky/1e3;

nexp = length(dataset);
for i=1:nexp
    aux = textscan(getfield(metadataset,{i},sweep_parameter), '%f %s');
    parameter_values(i,1) = aux{1};
    
    abcd_mean(i,:) = mean(dataset{i});
    pos_mean(i,:) = mean(calcpos(dataset{i}, Kx, Ky));
    abcd_std(i,:) = std(dataset{i});
    pos_std(i,:) = std(calcpos(dataset{i}, Kx, Ky));
end

[~, index_reordered] = sort(parameter_values);

parameter_values = parameter_values(index_reordered);
abcd_mean = abcd_mean(index_reordered,:);
pos_mean = pos_mean(index_reordered,:);
abcd_std = abcd_std(index_reordered,:);
pos_std = pos_std(index_reordered,:);


figure;
ax(1) = subplot(211);
y = abs(pos_mean(:,1)); % FIXME: remove abs
y = y - y(end);
errorbar(parameter_values, y, pos_std(:,1), 'r--')
hold on
y = abs(pos_mean(:,2));
y = y - y(end);
errorbar(parameter_values, y, pos_std(:,2))
legend('horizontal', 'vertical');
ylabel('Position [um]')

ax(2) = subplot(212);
errorbar(repmat(parameter_values, 1, 4), abcd_mean, abcd_std)
legend('A','B','C','D');
xlabel([sweep_parameter ' ' aux{2}], 'Interpreter', 'none') % FIXME: aux{2}
ylabel('Amplitude [a.u.]')


linkaxes(ax, 'x');
