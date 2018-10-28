% plot correlation between right STS at age 5 and incidental touch at age 6 2016-12-01
figure(1)
clf(1)
[r,p]=corrcoef(incidental_6yo,GMV_5yo_signal(:,1));
pR2.linear=r(1,2)^2;
r=roundn(r,-2); % keep two decimals
p=roundn(p,-4); % keep three decimals
scatter(incidental_6yo,GMV_5yo_signal(:,1),30,'b','filled');

hold on
xlabel('incidental touch at age 6','FontSize',16);% y-axis label
ylabel('GMV in the right STS at age 5','FontSize',16);

ftype=fittype('a*x+b');
[fresult,gof]=fit(incidental_6yo,GMV_5yo_signal(:,1),ftype);
xx=0.14:0.01:6.4;%[(max(min(x_p))-1):0.01:(min(max(x_p)))+1]
yy=fresult.a*xx+fresult.b;
plot(xx,yy,'-r','LineWidth',2);
hold on
set(gca, 'FontName','Arial','FontSize',12,'LineWidth', 1.5);
set(gcf, 'WindowStyle','normal');
xlim([-1,7]);
ylim([0.5,1]);
set(gca,'Box','on','tickdir','in','XTick',[-1:2:7],'YTick',[0.5:0.1:1.1]);

text(0, 0.95, ['r = 0.38' ], 'HorizontalAlignment','left','FontName','Arial','FontSize',12);
text(0, 0.92, ['p = 0.024' ], 'HorizontalAlignment','left','FontName','Arial','FontSize',12);
filename=['results/GMV_5yo_incidental_6yo'];
print(1,'-dtiff',filename);

% plot correlation between right STS at age 5 and total touch at age 6
figure(2)
clf(2)
[r,p]=corrcoef(total_6yo,GMV_5yo_signal(:,1));
pR2.linear=r(1,2)^2;
r=roundn(r,-2); % keep two decimals
p=roundn(p,-4); % keep three decimals
scatter(total_6yo,GMV_5yo_signal(:,1),30,'b','filled');

hold on
xlabel('total touch at age 6','FontSize',16);% y-axis label
ylabel('GMV in the right STS at age 5','FontSize',16);

ftype=fittype('a*x+b');
[fresult,gof]=fit(total_6yo,GMV_6yo_signal(:,1),ftype);
xx=0.13:0.01:6.35;%[(max(min(x_p))-1):0.01:(min(max(x_p)))+1]
yy=fresult.a*xx+fresult.b;
plot(xx,yy,'-r','LineWidth',2);
hold on
set(gca, 'FontName','Arial','FontSize',12,'LineWidth', 1.5);
set(gcf, 'WindowStyle','normal');
xlim([-1,7]);
ylim([0.5,1]);
set(gca,'Box','on','tickdir','in','XTick',[-1:2:7],'YTick',[0.5:0.1:1.1]);

text(0, 0.95, ['r = 0.36' ], 'HorizontalAlignment','left','FontName','Arial','FontSize',12);
text(0, 0.92, ['p = 0.033' ], 'HorizontalAlignment','left','FontName','Arial','FontSize',12);
filename=['results/GMV_5yo_total_6yo'];
print(2,'-dtiff',filename);

% 2016-11-28  

diff_incidental = incidental_6yo - incidental_5yo;
diff_instrumental= instrumental_6yo - instrumental_5yo;
diff_total = total_6yo - total_5yo;

[r p] = corrcoef(GMV_5yo_signal(:,1), incidental_5yo); % r = -0.246, p = 0.154
[r p] = corrcoef(GMV_5yo_signal(:,1), instrumental_5yo); % r = 0.064, p = 0.71
[r p] = corrcoef(GMV_5yo_signal(:,1), total_5yo); % r = -0.215, p = 0.214

[r p] = corrcoef(GMV_5yo_signal(:,2), incidental_5yo); % 
[r p] = corrcoef(GMV_5yo_signal(:,2), instrumental_5yo); % 
[r p] = corrcoef(GMV_5yo_signal(:,2), total_5yo);

[r p] = corrcoef(GMV_6yo_signal(:,1), incidental_6yo); % r = 0.373, p = 0.027
[r p] = corrcoef(GMV_6yo_signal(:,1), instrumental_6yo); % r = -0.15, p = 0.38
[r p] = corrcoef(GMV_6yo_signal(:,1), total_6yo); % r = 0.35, p = 0.038

[r p] = corrcoef(diff_incidental_5yo, GMV_diff(:,1)); % ns.
[r p] = corrcoef(diff_instrumental_5yo, GMV_diff(:,1)); % ns.
[r p] = corrcoef(diff_total_5yo, GMV_diff(:,1)); % ns.


% plot correlation between right STS and incidental touch at age 6
figure(1)
clf(1)
[r,p]=corrcoef(incidental_6yo,GMV_6yo_signal(:,1));
pR2.linear=r(1,2)^2;
r=roundn(r,-2); % keep two decimals
p=roundn(p,-4); % keep three decimals
scatter(incidental_6yo,GMV_6yo_signal(:,1),30,'b','filled');

hold on
xlabel('incidental touch','FontSize',16);% y-axis label
ylabel('GMV in the right STS','FontSize',16);

ftype=fittype('a*x+b');
[fresult,gof]=fit(incidental_6yo,GMV_6yo_signal(:,1),ftype);
xx=0.14:0.01:6.4;%[(max(min(x_p))-1):0.01:(min(max(x_p)))+1]
yy=fresult.a*xx+fresult.b;
plot(xx,yy,'-r','LineWidth',2);
hold on
set(gca, 'FontName','Arial','FontSize',12,'LineWidth', 1.5);
set(gcf, 'WindowStyle','normal');
xlim([-1,7]);
ylim([0.5,1]);
set(gca,'Box','on','tickdir','in','XTick',[-1:2:7],'YTick',[0.5:0.1:1.1]);

text(0, 0.95, ['r = 0.37' ], 'HorizontalAlignment','left','FontName','Arial','FontSize',12);
text(0, 0.92, ['p = 0.027' ], 'HorizontalAlignment','left','FontName','Arial','FontSize',12);
filename=['results/GMV_incidental_6yo'];
print(1,'-dtiff',filename);

% plot correlation between right STS and total touch at age 6
figure(2)
clf(2)
[r,p]=corrcoef(total_6yo,GMV_6yo_signal(:,1));
pR2.linear=r(1,2)^2;
r=roundn(r,-2); % keep two decimals
p=roundn(p,-4); % keep three decimals
scatter(total_6yo,GMV_6yo_signal(:,1),30,'b','filled');

hold on
xlabel('total touch','FontSize',16);% y-axis label
ylabel('GMV in the right STS','FontSize',16);

ftype=fittype('a*x+b');
[fresult,gof]=fit(total_6yo,GMV_6yo_signal(:,1),ftype);
xx=0.13:0.01:6.35;%[(max(min(x_p))-1):0.01:(min(max(x_p)))+1]
yy=fresult.a*xx+fresult.b;
plot(xx,yy,'-r','LineWidth',2);
hold on
set(gca, 'FontName','Arial','FontSize',12,'LineWidth', 1.5);
set(gcf, 'WindowStyle','normal');
xlim([-1,7]);
ylim([0.5,1]);
set(gca,'Box','on','tickdir','in','XTick',[-1:2:7],'YTick',[0.5:0.1:1.1]);

text(0, 0.95, ['r = 0.35' ], 'HorizontalAlignment','left','FontName','Arial','FontSize',12);
text(0, 0.92, ['p = 0.038' ], 'HorizontalAlignment','left','FontName','Arial','FontSize',12);
filename=['results/GMV_total_6yo'];
print(2,'-dtiff',filename);
