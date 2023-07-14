% Test script
x = 0:0.1:10;
p1 = 1;
p2 = 3;
t = 'one';

p1 = p1+p2;
result1 = p1*x.^2+p2*x;
result2 = p2*p1./x;

figure()
hold on
plot(x, result1, 'DisplayName', ['r1 ' t])
plot(x, result2, 'DisplayName', ['r2 ' t])
legend()