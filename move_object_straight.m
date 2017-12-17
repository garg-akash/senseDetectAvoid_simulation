try
    rosinit('10.2.131.238');
end
    pos_pub = rospublisher('gazebo/set_model_state','gazebo_msgs/ModelState');
    msg = rosmessage(pos_pub);
    vel_pub = rospublisher('/obstacle1/velocity','geometry_msgs/Twist');
    vel = rosmessage(vel_pub); %to publish velocity for further calculation
    angles = zeros(1,3);

msg.ModelName = 'unit_sphere_1';
msg.ReferenceFrame = 'world';
msg.Pose.Position.X = 7;
msg.Pose.Position.Y = 7;
msg.Pose.Position.Z = 2.0;

quat = eul2quat(angles);    
msg.Pose.Orientation.W = quat(1);
msg.Pose.Orientation.X = quat(2);
msg.Pose.Orientation.Y = quat(3);
msg.Pose.Orientation.Z = quat(4);

v_x = 0.2;
angles = zeros(1,3);
msg.Twist.Linear.Z = 0;

t5 = 0;
while (msg.Pose.Position.X >= -7)
    t1 = clock; 
    t2 = t1(5)*60 + t1(6);
    msg.Pose.Position.X = msg.Pose.Position.X - v_x * t5;
    vel.Linear.X = -v_x;
    vel.Linear.Y = 0;
    send(pos_pub,msg);
    send(vel_pub,vel);
    t3 = clock;
    t4 = t3(5)*60 + t3(6);
    t5 = t4 - t2;
end

