function createfigure(filenames,dir)

d = date;

%filenames = {sprintf('Experimental Data/21-Jul-2016/M0P0R2', d)};
sheets = [1];
lr = 0;

figures = [1 0 0];

% figures(1) is a graph of R and T
% figures(2) is a graph of PiPi*, PrPr*, and PtPt*
% figures(3) is a graph of the percentage of the sound that is being reflected off the foam

if ~isequal(length(sheets),length(filenames))
    disp('Filenames and Sheets have to be the same length.')
    return
end

minf = intmax;
maxf = 0;
LR = {' L', ' R'};

% dir = sprintf('Experimental Data/%s/', d);
% for d = 1:length(filenames)
%     data{d} = xlsread(filenames{d}, sheets(d));
%     freqs{d} = data{d}(:,1);
%     add = filenames{d}(regexp(filenames{d},'/M')+1:end);
%     dir = [dir add];
%     if d ~= length(filenames)
%         dir = [dir ' and '];
%     end
%     minf = min([minf min(freqs{d})]);
%     maxf = max([maxf max(freqs{d})]);
% end
% 
% dir = [dir ' Graphs'];

[s,m1, m2] = mkdir(dir);

if figures(1) == 1 % figures(1) is a graph of R and T
    % Create figure
    figure1 = figure;
    set(figure1, 'Position', [600 250 1000 700])
    
    for d = 1:length(filenames)
        R{d} = data{d}(:,8);
        T{d} = data{d}(:,9);
    end

    % Create axes
    axes1 = axes('FontSize',24);
    %% Uncomment the following line to preserve the X-limits of the axes
    xlim(axes1,[minf maxf]);
    %% Uncomment the following line to preserve the Y-limits of the axes
    ylim(axes1,[0 2]);
    box(axes1,'on');
    hold(axes1,'on');
    
    labels = cell.empty;
    for d = 1:length(filenames)
        plot1 = plot(freqs{d}, R{d}, freqs{d}, T{d}, 'LineWidth', 2);
        if lr == 0
            labels{end+1} = sprintf('R_%i', d);
            labels{end+1} = sprintf('T_%i', d);
        else
            labels{end+1} = sprintf('R_%i%s', ceil(d/2),LR{int64(1+abs(cos(pi/2*d)))});
            labels{end+1} = sprintf('R_%i%s', ceil(d/2),LR{int64(1+abs(cos(pi/2*d)))});
            if mod(d,2) == 0
                set(plot1(d),'LineStyle','--');
            end
        end
    end

    % Create xlabel
    xlabel('Frequency (Hz)');

    % Create ylabel
    ylabel('Normalized');
    
    title('Reflectance vs Transmittance');

    % Create legend
    legend1 = legend(labels);
    set(legend1,'FontSize',20);
    legend('boxoff');
    
    saveas(figure1,sprintf('%s/RT.png', dir));
end

if figures(2) == 1 % figures(2) is a graph of PiPi*, PrPr*, and PtPt*
    % Create figure
    figure2 = figure;
    set(figure2, 'Position', [600 250 1000 700])
    
    for d = 1:length(filenames)
        Pi{d} = data{d}(:,6);
        Pr{d} = data{d}(:,7);
        Pt{d} = data{d}(:,18);
    end

    % Create axes
    axes1 = axes('FontSize',24);
    %% Uncomment the following line to preserve the X-limits of the axes
    xlim(axes1,[minf maxf]);
    %% Uncomment the following line to preserve the Y-limits of the axes
    %ylim(axes1,[0 1]);
    box(axes1,'on');
    hold(axes1,'on');
    
    labels = cell.empty;
    for d = 1:length(filenames)
        plot1 = plot(freqs{d}, Pi{d}, freqs{d}, Pr{d}, freqs{d}, Pt{d}, 'LineWidth', 2);
        if lr == 0
            labels{end+1} = sprintf('P_iP_i^*_%i', d);
            labels{end+1} = sprintf('P_rP_r^*_%i', d);
            labels{end+1} = sprintf('P_tP_t^*_%i', d);
        else
            labels{end+1} = sprintf('P_iP_i^*%i%s', ceil(d/2),LR{int64(1+abs(cos(pi/2*d)))});
            labels{end+1} = sprintf('P_rP_r^*%i%s', ceil(d/2),LR{int64(1+abs(cos(pi/2*d)))});
            labels{end+1} = sprintf('P_tP_t^*%i%s', ceil(d/2),LR{int64(1+abs(cos(pi/2*d)))});
            if mod(d,2) == 0
                set(plot1,'LineStyle','--');
            end
        end
    end

    % Create xlabel
    xlabel('Frequency (Hz)');

    % Create ylabel
    ylabel('PP* (Pa^2)');
    
    title('Wave Pressures');

    % Create legend
    legend1 = legend(labels);
    set(legend1,'FontSize',20);
    legend('boxoff');
    
    saveas(figure2,sprintf('%s/PPC.png', dir));
end

if figures(3) == 1 % figures(3) is a graph of the percentage of the sound that is being reflected off the foam
    % Create figure
    figure3 = figure;
    set(figure3, 'Position', [600 250 1000 700])
    
    for d = 1:length(filenames)
        FR{d} = data{d}(:,17)./data{d}(:,18);
    end

    % Create axes
    axes1 = axes('FontSize',24);
    %% Uncomment the following line to preserve the X-limits of the axes
    xlim(axes1,[minf maxf]);
    %% Uncomment the following line to preserve the Y-limits of the axes
    ylim(axes1,[0 1]);
    box(axes1,'on');
    hold(axes1,'on');
    
    labels = cell.empty;
    % Create multiple lines using matrix input to plot
    for d = 1:length(filenames)
        plot1 = plot(freqs{d}, FR{d}, 'LineWidth', 2);
        if lr == 0
            labels{d} = sprintf('Reflection_%i', d);
        else
            labels{d} = sprintf('Reflection_%i%s', ceil(d/2),LR{int64(1+abs(cos(pi/2*d)))});
            if mod(d,2) == 0
                set(plot1,'LineStyle','--');
            end
        end
    end

    % Create xlabel
    xlabel('Frequency (Hz)');

    % Create ylabel
    ylabel('Normalized PP*');
    
    title('Foam Reflection');

    % Create legend
    legend1 = legend(labels);
    set(legend1,'FontSize',20);
    legend('boxoff');
    
    saveas(figure1,sprintf('%s/Foam Reflect.png', dir));
end

end