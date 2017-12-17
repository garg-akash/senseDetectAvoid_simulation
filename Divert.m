function Divert(vxx,vyy,vzz,d,vqq) %vxx vyy vzz are the quad new velocities, d-modified safe distance, vqq previous(new is also same)quad velocity magnitude  

global pos_pub;
global msg;
%send(pos_pub,msg);
t5 = 0;
count = 0;
%now proceed to goal position
while (count < d/vqq)
    t1 = clock;
    t2 = t1(5)*60 + t1(6);
    msg.Points.Transforms.Translation.X = msg.Points.Transforms.Translation.X + vxx * t5;
    msg.Points.Transforms.Translation.Y = msg.Points.Transforms.Translation.Y + vyy * t5;
    msg.Points.Transforms.Translation.Z = msg.Points.Transforms.Translation.Z + vzz * t5;
    send(pos_pub,msg);
    t3 = clock;
    t4 = t3(5)*60 + t3(6);
    t5 = t4 - t2;
    count = count + t5
    fprintf( 'Iteration VX= %f VY= %f \n',vxx,vyy);
end
