function [Cone,EndPlate1,EndPlate2] = Cone(X1,X2,R,n,cyl_color,closed,lines)

% Calculating the length of the Cone
length_cyl=norm(X2-X1);

% Creating 2 circles in the YZ plane
t=linspace(0,2*pi,n)';
xa2=R(1)*cos(t);
xa3=R(1)*sin(t);
xb2=R(2)*cos(t);
xb3=R(2)*sin(t);

% Creating the points in the X-Direction
x1=[0 length_cyl];

% Creating (Extruding) the cylinder points in the X-Directions
xx1=repmat(x1,length(xa2),1);
xx2=[xa2 xb2];%xx2=repmat(x2,1,2);
xx3=[xa3 xb3];%xx3=repmat(x3,1,2);

% Drawing two filled cirlces to close the cylinder
if closed==1
    hold on
    EndPlate1=fill3(xx1(:,1),xx2(:,1),xx3(:,1),'r');
    EndPlate2=fill3(xx1(:,2),xx2(:,2),xx3(:,2),'r');
end

% Plotting the cylinder along the X-Direction with required length starting
% from Origin
Cone=mesh(xx1,xx2,xx3);

% Defining Unit vector along the X-direction
unit_Vx=[1 0 0];

% Calulating the angle between the x direction and the required direction
% of Cone through dot product
angle_X1X2=acos( dot( unit_Vx,(X2-X1) )/( norm(unit_Vx)*norm(X2-X1)) )*180/pi;

% Finding the axis of rotation (single rotation) to roate the Cone in
% X-direction to the required arbitrary direction through cross product
axis_rot=cross([1 0 0],(X2-X1) );

if angle_X1X2~=0 % Rotation is not needed if required direction is along X
    rotate(Cone,axis_rot,angle_X1X2,[0 0 0]);
    if closed==1
        rotate(EndPlate1,axis_rot,angle_X1X2,[0 0 0]);
        rotate(EndPlate2,axis_rot,angle_X1X2,[0 0 0]);
    end
end
if closed==1
    set(EndPlate1,'XData',get(EndPlate1,'XData')+X1(1));
    set(EndPlate1,'YData',get(EndPlate1,'YData')+X1(2));
    set(EndPlate1,'ZData',get(EndPlate1,'ZData')+X1(3));
    
    set(EndPlate2,'XData',get(EndPlate2,'XData')+X1(1));
    set(EndPlate2,'YData',get(EndPlate2,'YData')+X1(2));
    set(EndPlate2,'ZData',get(EndPlate2,'ZData')+X1(3));
end
set(Cone,'XData',get(Cone,'XData')+X1(1));
set(Cone,'YData',get(Cone,'YData')+X1(2));
set(Cone,'ZData',get(Cone,'ZData')+X1(3));

% Setting the color to the Cone and the end plates
set(Cone,'AmbientStrength',1,'FaceColor',cyl_color,'FaceLighting','gouraud');%,'EdgeColor','none');
if closed==1
    set([EndPlate1 EndPlate2],'AmbientStrength',1,'FaceColor',cyl_color,'FaceLighting','gouraud');%,'EdgeColor','none');
else
    EndPlate1=[];
    EndPlate2=[];
end
if lines==0
    set(Cone,'EdgeAlpha',0);
end
material shiny;
