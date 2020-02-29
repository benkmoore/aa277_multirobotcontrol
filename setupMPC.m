N = 4;
nx = 6 * N;
nu = 3 * N;

mpc.N = N;
mpc.nx = nx;
mpc.nu = nu;
mpc.duration = 100;
mpc.controlHorizon = 4;
mpc.predictionHorizon = 30;
mpc.dt = 1;

x_d = getDesiredReference(mpc,0);

A = [1 mpc.dt;
    0 1];
B = [mpc.dt^2/2;
    mpc.dt];
A_kron = kron(kron(A, eye(3, 3)), eye(N, N));
B_kron = kron(kron(B, eye(3, 3)), eye(N, N));
mpc.stateFct = @(x,u) A_kron * x + B_kron * u;
mpc.costFct = @costFunction;
mpc.xMin = [-Inf; -Inf; -Inf; -15; -15; -15];
mpc.xMax = [Inf; Inf; Inf; 15; 15; 15];
mpc.uMin = [-4; -4; 4];
mpc.uMax = -mpc.uMin;
mpc.Q = kron(diag([10, 10, 10, 5, 5, 5]), eye(N, N));
mpc.P = kron(eye(3,3), eye(N, N));
mpc.Qn = kron(diag([50, 50, 50, 50, 50, 50]), eye(N ,N));
mpc.x0 = zeros(6 * mpc.N, 1);
mpc.u0 = zeros(3 * mpc.N, 1);


con = zeros(mpc.nx*mpc.duration,size(B_kron,2));
con(1:mpc.nx,:) = B_kron;
for k=1:mpc.duration-1
  con(k*mpc.nx+1:(k+1)*mpc.nx,:) = A_kron * con((k-1)*mpc.nx+1:k*mpc.nx,:);
end
conB = zeros(mpc.duration*mpc.nx,size(B_kron,2));
for k=1:mpc.duration
    conB((k-1)*mpc.nx+1:end,(k-1)*size(B_kron,2)+1:k*size(B_kron,2)) =  con(1:end-(k-1)*mpc.nx,:); 
end

conA = zeros(mpc.nx*mpc.duration,mpc.nx*mpc.duration);
conA(1:mpc.nx,1:mpc.nx) = A_kron;
for k=1:mpc.duration-1
  conA(k*mpc.nx+1:(k+1)*mpc.nx,1:mpc.nx) = A_kron * conA((k-1)*mpc.nx+1:k*mpc.nx,1:mpc.nx);
end

