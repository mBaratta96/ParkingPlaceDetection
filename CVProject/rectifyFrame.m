function [m] = rectifyFrame(frame, visualize)
% returns a rectified frame following a direct mathod
%
if visualize
    figure(1), imshow(frame);
end

p1=[359 236 1]'; %points detected of the appa_park.mp4 video
p2=[303 131 1]';
p3=[72 129 1]';
p5=[56 177 1]';

l1=cross(p1,p2);
l1=l1/l1(3);

l2=cross(p2,p3);
l2=l2/l2(3);

l3=cross(p3,p5);
l3=l3/l3(3);

linf=[0 0 1]';

dl2=cross(l2,linf);

l4=cross(p1,dl2);
l4=l4/l4(3);

p4=cross(l4,l3);
p4=round(p4/p4(3));

points=[p1 p2 p3 p4];
if visualize
    hold on;
    for i =1:4   
        if i==4
            plot([points(1,i), points(1,1)],[points(2,i), points(2,1)], 'Linewidth', 1.5);
        else
            plot([points(1,i), points(1,i+1)],[points(2,i), points(2,i+1)], 'Linewidth', 1.5);
        end
        plot(points(1,i), points(2,i), 'x');
        text(points(1,i), points(2,i), int2str(i), "Color", 'red', "FontWeight", 'bold', 'FontSize', 16);
    end
end

p3new=[p4(1) p3(2) 1]'; % form a rectangle
p2new=[p1(1) p2(2) 1]';

points_old = points(1:2,:)';
points_new = [p1 p2new p3new p4];
points_new = points_new(1:2,:)';
H=maketform('projective',points_old, points_new);
aff = imtransform(frame,H', "XYscale",1);
if visualize
    figure(2);
    imshow(aff);
end

p5=[306 360 1]';
p6=[531 364 1]';
p7=[468 392 1]';
p8=[481 404 1]';
p9=[497 399 1]';
aff_points=[p5 p6 p7 p8 p9];
if visualize
    hold on;
    for i =1:5
        plot(aff_points(1,i), aff_points(2,i), 'x');

        %text(aff_points(1,i), aff_points(2,i), int2str(i+4), 'Color','red',"FontWeight", 'bold');
        if i==4
           text(aff_points(1,i), aff_points(2,i), 'c', 'Color','red',"FontWeight", 'bold', 'FontSize', 16);
        end
    end
end

lbase=cross(p5,p6);
lbase=lbase/lbase(3);

l78=cross(p7,p8);
l78=l78/l78(3);

l89=cross(p8,p9);
l89=l89/l89(3);

a=cross(lbase,l78);
a=round(a/a(3));


b=cross(lbase,l89);
b=round(b/b(3));

if visualize
    plot([p7(1), p8(1)],[p7(2), p8(2)], 'Linewidth', 1.5);
    plot([p8(1), p9(1)],[p8(2), p9(2)], 'Linewidth', 1.5);
    plot([p5(1), p6(1)],[p5(2), p6(2)], 'Linewidth', 1.5);
    plot(a(1), a(2), 'x');
    text(a(1), a(2), 'a', 'Color','red',"FontWeight", 'bold', 'FontSize', 16);
    plot([p8(1), a(1)],[p8(2), a(2)],'Linewidth',1.5);
    plot(b(1),b(2),'x');
    text(b(1), b(2), 'b', 'Color','red',"FontWeight", 'bold', 'FontSize', 16);
    plot([p5(1), b(1)],[p5(2), b(2)], 'Linewidth', 1.5);
    plot([p8(1), b(1)],[p8(2), b(2)], 'Linewidth', 1.5);
end

dirbase=cross(linf, lbase);
dirperp=[1 -dirbase(1)/dirbase(2) 0]';

lh=cross(dirperp,p8);
lh=lh/lh(3);
h=cross(lh, lbase);
h=round(h/h(3));
if visualize
    plot(h(1), h(2), 'x');
    text(h(1), h(2), 'h', 'Color','red',"FontWeight", 'bold', 'FontSize', 16);
    plot([p8(1), h(1)],[p8(2), h(2)], 'Linewidth', 2);
end

ab=pdist([a(1:2)'; b(1:2)']);
ah=pdist([a(1:2)'; h(1:2)']);

syms xc yc
eqn1 = (xc-a(1))^2+(yc-a(2))^2 == ab*ah; %equation of report
eqn2 = lh(1)*xc + lh(2)*yc + 1 == 0;

sol = solve([eqn1, eqn2], [xc, yc],'Real',true);
xSol = round(double(sol.xc));
ySol = round(double(sol.yc));

p8new=[xSol(2) ySol(2) 1]';
tri_old=[a b p8];
tri_new=[a b p8new];       %map triangle ABC to ABC'
tri_old=tri_old(1:2,:)';
tri_new=tri_new(1:2,:)';
H=maketform('affine',tri_old, tri_new);
m = imtransform(aff,H', "XYscale",1);
if visualize
    figure(3);
    imshow(m);

    p5=[307 667 1]';
    p6=[535 669 1]';
    p7=[471 725 1]';
    p8=[483 744 1]';
    p9=[499 735 1]';
    aff_points=[p5 p6 p7 p8 p9];
    hold on;
    for i =1:5
        plot(aff_points(1,i), aff_points(2,i), 'x');
        %text(aff_points(1,i), aff_points(2,i), int2str(i+4), 'Color','red',"FontWeight", 'bold');
        if i==4
           text(aff_points(1,i), aff_points(2,i), 'c', 'Color','red',"FontWeight", 'bold', 'FontSize', 16);
        end
    end

    lbase=cross(p5,p6);
    lbase=lbase/lbase(3);
    plot([p5(1), p6(1)],[p5(2), p6(2)], 'Linewidth', 1.5);

    l78=cross(p7,p8);
    l78=l78/l78(3);
    plot([p7(1), p8(1)],[p7(2), p8(2)], 'Linewidth', 1.5);

    l89=cross(p8,p9);
    l89=l89/l89(3);
    plot([p8(1), p9(1)],[p8(2), p9(2)], 'Linewidth', 1.5);

    a=cross(lbase,l78);
    a=round(a/a(3));
    plot(a(1), a(2), 'x');
    text(a(1), a(2), 'a', 'Color','red',"FontWeight", 'bold', 'FontSize', 16);
    plot([p8(1), a(1)],[p8(2), a(2)],'Linewidth',1.5);

    b=cross(lbase,l89);
    b=round(b/b(3));
    plot(b(1),b(2),'x');
    text(b(1), b(2), 'b', 'Color','red',"FontWeight", 'bold', 'FontSize', 16);
    plot([p5(1), b(1)],[p5(2), b(2)], 'Linewidth', 1.5);
    plot([p8(1), b(1)],[p8(2), b(2)], 'Linewidth', 1.5);

    dirbase=cross(linf, lbase);
    dirperp=[1 -dirbase(1)/dirbase(2) 0]';

    lh=cross(dirperp,p8);
    lh=lh/lh(3);
    h=cross(lh, lbase);
    h=round(h/h(3));
    plot(h(1), h(2), 'x');
    text(h(1), h(2), 'h', 'Color','red',"FontWeight", 'bold', 'FontSize', 16);
    plot([p8(1), h(1)],[p8(2), h(2)], 'Linewidth', 2);
end




end

