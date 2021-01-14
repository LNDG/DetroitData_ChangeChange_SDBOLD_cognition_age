%% Plot PLS results
clear all
cd('/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/SDBOLD')

pn.root = '/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/figures/'; % save path

%% plot SD_diff_fMRIrest_N74_Mot_noDiab_COG_latentChange_Age_BfMRIresult.mat
% scatter VSC vs USC
load('SD_diff_fMRIrest_N74_Mot_noDiab_COG_latentChange_Age_BfMRIresult.mat');

a=scatter(result.vsc(:,1),result.usc(:,1),100,[0 0 1],'filled','MarkerEdgeColor',[1 1 1]);
xlim([-7 6])
a.MarkerFaceAlpha = .5;
hline=refline;
hline.LineWidth=1;
hline.Color=[0 0 0];
set(gca,'FontSize',18);

xlabel('Cognitive change score')
ylabel('Brain score')

set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,[pn.root,'Cog_latentChange_all_USCxVSC.pdf'],'-dpdf','-r0')

close

% save USC VSC correlation
Cog_change_all_USCxVSC_corr=corr(result.vsc(:,1),result.usc(:,1));
save([pn.root 'USCxVSC_latent_corrs.mat'],'Cog_change_all_USCxVSC_corr')

% plot indicator-brain score correlations
% sort indicators
prep_ind=zeros(1,length(behavname));
prep_corr=result.boot_result.orig_corr(:,1);

ult=result.boot_result.ulcorr(:,1);
llt=result.boot_result.llcorr(:,1);

% compute upper and lower bound of CI
prep_lb=zeros(1,length(prep_corr));
prep_ub=zeros(1,length(prep_corr));

prep_lb=abs(prep_corr-llt);
prep_ub=abs(prep_corr-ult);

Pos = 1:6;%[1 3 5 7 9 11]; % positions for bar labels

figure

%plot Gf
b=bar(Pos(1),prep_corr(1));
hold on
b.FaceColor=[0.2 0.8 0.8];
e=errorbar(Pos(1),prep_corr(1),prep_lb(1),prep_ub(1))
e.Color=[0,0,0];
e.LineStyle='none';

%plot Gc
b=bar(Pos(2),prep_corr(2));
b.FaceColor=[0 0.6 0.3];
e=errorbar(Pos(2),prep_corr(2),prep_lb(2),prep_ub(2))
e.Color=[0,0,0];
e.LineStyle='none';

%plot Mem
b=bar(Pos(3),prep_corr(3));
b.FaceColor=[0 0.5 1];
e=errorbar(Pos(3),prep_corr(3),prep_lb(3),prep_ub(3))
e.Color=[0,0,0];
e.LineStyle='none';

%plot WM
b=bar(Pos(4),prep_corr(4));
b.FaceColor=[1 0.2 0.2];
e=errorbar(Pos(4),prep_corr(4),prep_lb(4),prep_ub(4))
e.Color=[0,0,0];
e.LineStyle='none';

%plot Speed
b=bar(Pos(5),prep_corr(5));
b.FaceColor=[1 0.5 0];
e=errorbar(Pos(5),prep_corr(5),prep_lb(5),prep_ub(5))
e.Color=[0,0,0];
e.LineStyle='none';

%plot age
b=bar(Pos(6),prep_corr(6));
b.FaceColor=[1 0 1];
e=errorbar(Pos(6),prep_corr(6),prep_lb(6),prep_ub(6))
e.Color=[0,0,0];
e.LineStyle='none';

xticks(Pos);
xticklabels({'Gf' 'Gc' 'Mem' 'WM' 'Speed' 'age change'})
ylabel('Pearson''s r');
set(gca,'FontSize',18);
set(gcf,'position',[0,0,900,540])

set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,[pn.root,'Cog_latentChange_all_USCxBEH.pdf'],'-dpdf','-r0')

close

%% plot cross-sectional data: SD_w1w2_fMRIrest_N74_Mot_noDiab_latentCOG_all_Age_BfMRIresult.mat
% scatter VSC vs USC
load('SD_w1w2_fMRIrest_N74_Mot_noDiab_latentCOG_all_Age_BfMRIresult.mat');

%w1
a=scatter(result.vsc(1:74,1),result.usc(1:74,1),100,[0 0 1],'filled','MarkerEdgeColor',[1 1 1])
xlim([-50 0])
ylim([20 140])
a.MarkerFaceAlpha = .5;
hline=refline;
hline.LineWidth=1;
hline.Color=[0 0 0];
set(gca,'FontSize',18);

xlabel('Cognitive score Wave 1')
ylabel('Brain score')

set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,[pn.root,'LatentCog_w1_all_USCxVSC.pdf'],'-dpdf','-r0')

close

% save USC VSC correlation
Cog_w1_all_USCxVSC_corr=corr(result.vsc(1:74,1),result.usc(1:74,1));
save([pn.root 'USCxVSC_latent_corrs.mat'],'Cog_w1_all_USCxVSC_corr','-append')

%w2
a=scatter(result.vsc(75:end,1),result.usc(75:end,1),100,[0 0 1],'filled','MarkerEdgeColor',[1 1 1]) % reverse sign of brain scores to match positive plotting of saliences
xlim([-50 0])
ylim([20 140])
a.MarkerFaceAlpha = .5;
hline=refline;
hline.LineWidth=1;
hline.Color=[0 0 0];
set(gca,'FontSize',18);

xlabel('Cognitive score Wave 2')
ylabel('Brain score')

set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,[pn.root,'LatentCog_w2_all_USCxVSC.pdf'],'-dpdf','-r0')

close

% save USC VSC correlation
Cog_w2_all_USCxVSC_corr=corr(result.vsc(75:end,1),result.usc(75:end,1));
save([pn.root 'USCxVSC_latent_corrs.mat'],'Cog_w2_all_USCxVSC_corr','-append')

% plot indicator-brain score correlations
%split data by wave
corr_w1=result.boot_result.orig_corr(1:6,1);
corr_w2=result.boot_result.orig_corr(7:end,1);

ult_w1=result.boot_result.ulcorr(1:6,1);
llt_w1=result.boot_result.llcorr(1:6,1);
ult_w2=result.boot_result.ulcorr(7:end,1);
llt_w2=result.boot_result.llcorr(7:end,1);

% compute upper and lower bound of CI
prep_lb_w1=zeros(1,length(llt_w1));
prep_ub_w1=zeros(1,length(ult_w1));
prep_lb_w2=zeros(1,length(llt_w2));
prep_ub_w2=zeros(1,length(ult_w2));

prep_lb_w1=abs(corr_w1-llt_w1);
prep_ub_w1=abs(corr_w1-ult_w1);
prep_lb_w2=abs(corr_w2-llt_w2);
prep_ub_w2=abs(corr_w2-ult_w2);

Pos_w1 = 1:6; % positions for bar labels
Pos_div = 7; % divider position
Pos_w2 = Pos_w1+Pos_div;


figure
%w1

%plot Gf
b=bar(Pos_w1(1),corr_w1(1));
hold on
b.FaceColor=[0.2 0.8 0.8];
e=errorbar(Pos_w1(1),corr_w1(1),prep_lb_w1(1),prep_ub_w1(1))
e.Color=[0,0,0];
e.LineStyle='none';

%plot Gc
b=bar(Pos_w1(2),corr_w1(2));
b.FaceColor=[0 0.6 0.3];
e=errorbar(Pos_w1(2),corr_w1(2),prep_lb_w1(2),prep_ub_w1(2))
e.Color=[0,0,0];
e.LineStyle='none';

%plot Mem
b=bar(Pos_w1(3),corr_w1(3));
b.FaceColor=[0 0.5 1];
e=errorbar(Pos_w1(3),corr_w1(3),prep_lb_w1(3),prep_ub_w1(3))
e.Color=[0,0,0];
e.LineStyle='none';

%plot WM
b=bar(Pos_w1(4),corr_w1(4));
b.FaceColor=[1 0.2 0.2];
e=errorbar(Pos_w1(4),corr_w1(4),prep_lb_w1(4),prep_ub_w1(4))
e.Color=[0,0,0];
e.LineStyle='none';

%plot Speed
b=bar(Pos_w1(5),corr_w1(5));
b.FaceColor=[1 0.5 0];
e=errorbar(Pos_w1(5),corr_w1(5),prep_lb_w1(5),prep_ub_w1(5))
e.Color=[0,0,0];
e.LineStyle='none';

%plot age
b=bar(Pos_w1(6),corr_w1(6));
b.FaceColor=[1 0 1];
e=errorbar(Pos_w1(6),corr_w1(6),prep_lb_w1(6),prep_ub_w1(6))
e.Color=[0,0,0];
e.LineStyle='none';

% w2

%plot Gf
b=bar(Pos_w2(1),corr_w2(1));
b.FaceColor=[0.2 0.8 0.8];
e=errorbar(Pos_w2(1),corr_w2(1),prep_lb_w2(1),prep_ub_w2(1))
e.Color=[0,0,0];
e.LineStyle='none';

%plot Gc
b=bar(Pos_w2(2),corr_w2(2));
b.FaceColor=[0 0.6 0.3];
e=errorbar(Pos_w2(2),corr_w2(2),prep_lb_w2(2),prep_ub_w2(2))
e.Color=[0,0,0];
e.LineStyle='none';

%plot Mem
b=bar(Pos_w2(3),corr_w2(3));
b.FaceColor=[0 0.5 1];
e=errorbar(Pos_w2(3),corr_w2(3),prep_lb_w2(3),prep_ub_w2(3))
e.Color=[0,0,0];
e.LineStyle='none';

%plot WM
b=bar(Pos_w2(4),corr_w2(4));
b.FaceColor=[1 0.2 0.2];
e=errorbar(Pos_w2(4),corr_w2(4),prep_lb_w2(4),prep_ub_w2(4))
e.Color=[0,0,0];
e.LineStyle='none';

%plot Speed
b=bar(Pos_w2(5),corr_w2(5));
b.FaceColor=[1 0.5 0];
e=errorbar(Pos_w2(5),corr_w2(5),prep_lb_w2(5),prep_ub_w2(5))
e.Color=[0,0,0];
e.LineStyle='none';

%plot age
b=bar(Pos_w2(6),corr_w2(6));
b.FaceColor=[1 0 1];
e=errorbar(Pos_w2(6),corr_w2(6),prep_lb_w2(6),prep_ub_w2(6))
e.Color=[0,0,0];
e.LineStyle='none';

% divider
plot([Pos_div Pos_div],[-0.8 0.6],'k')

xticks([Pos_w1 Pos_w2]);
xticklabels({'Gf' 'Gc' 'Mem' 'WM' 'Speed' 'age' 'Gf' 'Gc' 'Mem' 'WM' 'Speed' 'age'})
ylabel('Pearson''s r');
set(gca,'FontSize',18);
set(gcf,'position',[0,0,1000,540])

set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,[pn.root,'LatentCog_w1w2_all_USCxBEH.pdf'],'-dpdf','-r0')

close
clear all