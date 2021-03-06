function [r_receive] = Visual_Check(vx,vy,vz,r_received) %vx,vy,vz are the quad present velocities
safe_dist = 7; %safe distance to divert the direction of quad
global flag;

posesub = rossubscriber('/gazebo/model_states');
obs1sub = rossubscriber('/obstacle1/velocity');
posedata = receive(posesub, 10);
obs1data = receive(obs1sub, 10);
qX = posedata.Pose(2,1).Position.X;
qY = posedata.Pose(2,1).Position.Y;
qZ = posedata.Pose(2,1).Position.Z;
oX = posedata.Pose(3,1).Position.X;
oY = posedata.Pose(3,1).Position.Y;
oZ = posedata.Pose(3,1).Position.Z;
cla;
end_pts = [qX, qY, qZ; oX, oY, oZ];
% draw the cone
figure(1);
hold on
axis equal
set(gca, 'Projection', 'orthographic');
R = 0.85; %radius of inflated cone
Cone(end_pts(1,:), end_pts(2,:),[0, R], 20 ,'b',0,1);
alpha(0.3);
% position vector from quad to obstacle
rX = posedata.Pose(3,1).Position.X - posedata.Pose(2,1).Position.X;
rY = posedata.Pose(3,1).Position.Y - posedata.Pose(2,1).Position.Y;
rZ = posedata.Pose(3,1).Position.Z - posedata.Pose(2,1).Position.Z;
r = [rX rY rZ];
r_Mag = sqrt(power(r(1),2) + power(r(2),2) + power(r(3),2));
% relative linear velocity vector
L_velX = -obs1data.Linear.X + vx;
L_velY = -obs1data.Linear.Y + vy;
L_velZ = -obs1data.Linear.Z + vz;
L_vel = [L_velX L_velY L_velZ];
L_velMag = sqrt(power(L_velX,2) + power(L_velY,2) + power(L_velZ,2));

Vo1_vec = [obs1data.Linear.X obs1data.Linear.Y obs1data.Linear.Z];
Vo1 = sqrt(power(obs1data.Linear.X,2) + power(obs1data.Linear.Y,2) + power(obs1data.Linear.Z,2)); % magnitude of obstacle1 velocity
%draw relative velocity vector
plot3([qX L_velX+qX], [qY L_velY+qY], [qZ, L_velZ+qZ],'r');
%collisoin check
dp = dot(L_vel,r);
slant = (dp/power(L_velMag, 2)).*L_vel;
d = slant - r;
d_Mag = sqrt(power(d(1),2) + power(d(2),2) + power(d(3),2));
r_dot = r_Mag - r_received;

if (d_Mag < R && r_dot < 0)
    fprintf('Collision!!!!!!\n');
    if (r_Mag<safe_dist)
        [az,el,Vq] = cart2sph(vx,vy,vz)   %get spherical coordinates of quad_velocity for avoidance
        % az and el are in radians
        H = ((power(r_Mag,2))-(R^2))/(Vq^2);
        K = dot(r,Vo1_vec)/Vq;
        a1 = (rX^2)*(cos(el)^2);
        a2 = (rY^2)*(cos(el)^2);
        a3 = 2*rX*rY*(cos(el)^2);
        a4 = 2*H*Vq*(obs1data.Linear.X)*cos(el)-2*rX*rZ*cos(el)*sin(el)-2*K*rX*cos(el);
        a5 = 2*H*Vq*(obs1data.Linear.Y)*cos(el)-2*rY*rZ*cos(el)*sin(el)-2*K*rY*cos(el);
        b = H*(Vq^2+Vo1^2)+2*H*Vq*obs1data.Linear.Z*sin(el)-(rZ^2)*(sin(el)^2)-2*K*rZ*sin(el)-K^2;
        
        p4 = a1-a4-b;
        p3 = 2*(a5-a3);
        p2 = 2*(2*a2-a1-b);
        p1 = 2*(a3+a5);
        p0 = a1+a4-b;
        syms t
        fprintf( 'Iteration \n');
        th = double(solve(p4*(t^4)+p3*(t^3)+p2*(t^2)+p1*t+p0==0,t));
        theta = 2*atan(th)
        del_theta = zeros(size(theta));
        for i=1:length(theta)
            del_theta(i) = abs(theta(i) - az);
        end
        [min_theta, ind] = min(del_theta);
        if (theta(ind) < az)
            min_theta = -1*min_theta;
        end
        new_theta = min_theta + az
        
        [Vq_new_X,Vq_new_Y,Vq_new_Z] = sph2cart(new_theta,el,Vq)
        Divert(Vq_new_X,Vq_new_Y,Vq_new_Z,safe_dist,(Vq + Vo1))
        del_Vq_new_X = vx - Vq_new_X; 
        del_Vq_new_Y = vy - Vq_new_Y;
        %[Vo1_new_X,Vo1_new_Y,Vo1_new_Z] = sph2cart(pi-new_theta,el,Vq)
        %Divert(Vo1_new_X,Vo1_new_Y,Vo1_new_Z,safe_dist,(Vq + Vo1))
        Divert(vx + del_Vq_new_X,vy + del_Vq_new_Y,Vq_new_Z,safe_dist,(Vq + Vo1))
        flag = 1;
%         pause();
    end
end
r_receive = r_Mag;
