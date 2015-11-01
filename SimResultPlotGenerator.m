set (0, 'DefaultTextFontName','Arial')
set (0, 'DefaultTextFontWeight' ,'bold')
set (0, 'DefaultLineLineWidth', 1.5)

set(0,'DefaultAxesFontSize',14)
set(0,'DefaultAxesFontWeight','demi')
set(0,'DefaultTextFontSize',14)
set(0,'DefaultTextFontWeight','demi')
set(0,'DefaultFigureRenderer','zbuffer')
%% Generate vectors
load('input')
t(1)=0;
t(2)=0.005;
v(1)=-70;
v(2)=-70;
for i=1:length(rit_p)
    if rit_p(i)< plotduration+800
        t((i-1)*4+3)=rit_p(i);
        t((i-1)*4+4)=rit_p(i);
        t((i-1)*4+5)=rit_p(i)+1;
        t((i-1)*4+6)=rit_p(i)+1;
        v((i-1)*4+3)=-70;
        v((i-1)*4+4)=20;
        v((i-1)*4+5)=20;
        v((i-1)*4+6)=-70; 
    end
end
t(length(t)+1)=t(length(t))+1;
v(length(t))=-70;

t(3:length(t))=t(3:length(t))-800;

load('output')
output=output(801:plotduration+800)-74;
load('NeuronHome/simresults.dat') 
%load('simresults')
%% Plot Results
subplot(4,1,1);plot(t,v)
axis([0 plotduration -70 40])
set(gca,'XTick',[])
title('2Hz RIT Input Stimulation @ Schaffer Collateral Axon Bundle')
subplot(4,1,[2:4]);
plot(1:plotduration,output(1:plotduration),simresults(:,1),simresults(:,3),simresults(:,1),simresults(:,2))
title('EPSP @ CA1 Soma')
legend('Experimental - Soma','Simulation - Soma','Simulation - Spine')
ylabel('EPSP mV')
xlabel('time ms')
set(gcf, 'color', 'white', 'PaperUnits','inches','PaperSize',[14 8.5], 'PaperPosition',[1,1,13,8]);
saveas (gcf, 'NeuronHome/simresults.fig');
% ONLY WAY TO CHANGE RESOLUTION TO 300 dpi
print -r300 -depsc 'NeuronHome/simresults.eps';

% %% Spikecount
% spikecount=0;
% parfor i=5:length(sim)
%     if sim(i,2)>=30 && sim(i-1,2)<=30 && sim(i-2,2)<=30 && sim(i-3,2)<=30
%         spikecount=spikecount+1;
%     end
% end
% add=0;
% avg=0;
% parfor i=1:4000
%     add=0;
%     avg=0;
%     for j=1:2000
%         add=add+sim(2000*(i-1)+j,2);
%         avg=add/2000;
%     end
%     data(i)=avg;
% end
% 
% %% NRMSE
% diff=output-data';
% rms_error=sqrt(sum(diff.^2)/(sum(output.^2)));
% 
% aprint=sprintf('RMS Error - %d Spike Count - %d',rms_error, spikecount);
% disp(aprint)
