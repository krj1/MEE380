function [weight,Area]=truss_tron_3000(A, Coordinate)
%only looking at internal forces
Force=A([1:13]);
stress=20;
%finding coordinate B
little_vec= Coordinate(6,:);

length_a=sqrt((little_vec(1,1)^2)+(little_vec(1,2)^2));
length_h=little_vec(1,1);
length_v=little_vec(1,2);

Area=abs(Force/stress);

area_a=Area([1,5,9,12],:);
area_h=Area([2,4,6,8,10,13],:);
area_v=Area([3,7,9],:);

W_a=area_a*length_a*0.284;
W_h=area_h*length_h*0.284;
W_v=area_v*length_v*0.284;

weight=sum(abs(W_a))+sum(abs(W_h))+sum(abs(W_v));

end