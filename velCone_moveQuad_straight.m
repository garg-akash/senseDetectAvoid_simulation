rosinit('10.2.131.238');

v_x = 0.3;
v_y = 0.3;
v_z = 0.5;

Zinit = 2;
Yinit = 7;
Xinit = -7;
global pos_pub;
pos_pub = rospublisher('/firefly/command/trajectory','trajectory_msgs/MultiDOFJointTrajectory');
global msg;
msg = rosmessage(pos_pub);
msg.Points = rosmessage('trajectory_msgs/MultiDOFJointTrajectoryPoint');
msg.Points.Velocities = rosmessage('geometry_msgs/Twist');
msg.Points.Accelerations = rosmessage('geometry_msgs/Twist');
msg.Points.Transforms = rosmessage('geometry_msgs/Transform');
angles = zeros(1,3);

quat = eul2quat(angles);
msg.Points.Transforms.Rotation.W = quat(1);
msg.Points.Transforms.Rotation.X = quat(2);
msg.Points.Transforms.Rotation.Y = quat(3);
msg.Points.Transforms.Rotation.Z = quat(4);
send(pos_pub,msg);

t5 = 0;
while (msg.Points.Transforms.Translation.Z < Zinit)
    t1 = clock;
    t2 = t1(5)*60 + t1(6);
    msg.Points.Transforms.Translation.Z = msg.Points.Transforms.Translation.Z + 0.8 * t5;
    send(pos_pub,msg);
    t3 = clock;
    t4 = t3(5)*60 + t3(6);
    t5 = t4 - t2;
end
t5 = 0;
while (msg.Points.Transforms.Translation.Y < Yinit)
    t1 = clock;
    t2 = t1(5)*60 + t1(6);
    msg.Points.Transforms.Translation.Y = msg.Points.Transforms.Translation.Y + 0.8 * t5;
    send(pos_pub,msg);
    t3 = clock;
    t4 = t3(5)*60 + t3(6);
    t5 = t4 - t2;
end
t5 = 0;
while (msg.Points.Transforms.Translation.X > Xinit)
    t1 = clock;
    t2 = t1(5)*60 + t1(6);
    msg.Points.Transforms.Translation.X = msg.Points.Transforms.Translation.X - 0.8 * t5;
    send(pos_pub,msg);
    t3 = clock;
    t4 = t3(5)*60 + t3(6);
    t5 = t4 - t2;
end

t5 = 0;
r_prev = 0;
global flag;
while (msg.Points.Transforms.Translation.X < 7)
    flag = 0;
    t1 = clock;
    t2 = t1(5)*60 + t1(6);
    msg.Points.Transforms.Translation.X = msg.Points.Transforms.Translation.X + v_x * t5;
    send(pos_pub,msg);
    [r_return] = Visual_Check(v_x,0,0,r_prev)
    if (flag == 1)
        continue
    end
    r_prev = r_return;
    t3 = clock;
    t4 = t3(5)*60 + t3(6);
    t5 = t4 - t2;
end
