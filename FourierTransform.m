function [fsig,f]=FourierTransform(sig,Fs,choice)
% [fsig,f]=fourierTransform(signal,sam)
% [fsig,f]=fourierTransform(signal,sam,choice)
% choice=1, ignore last point if length(signal) is odd
% choice=2, add zero to make even if length(signal) is odd
% Generates the fourier transform (using fft function) and then returns 'fsign and f'
% Inputs: Signal, Sampling rate
% Outputs: fsig, f

% Find n,f

if nargin < 2
    error('signal and sampling rate are required to perform a fourier transform!');
end

m = length(sig);
n = m/2;

if (rem(m,2)~=0)
    if (nargin==2)
        fprintf('\n Warning: The number of inputed values are odd. In order to get exact frequency values, an even number is required!'),pause(0.1);
        fprintf('\n You have two options: \n'),pause(0.1);
        fprintf('1) Ignore the last point (Will give exact results).\n'),pause(0.1);
        fprintf('2) Add a zero to the trajectory to make it even. (Will distort the frequency by +- 1).\n'),pause(0.1);
        fprintf('Select the option you want to use\n'),pause(0.1);
        choice = input('');
    end
    
    if choice==1
        m = length(sig)-1;
        n = m/2;
        sig = sig(1:m);
    else
        n = ceil(m/2);
    end    
end


% Find fft and frequencies
fsig = fftshift(fft(sig,2*n))./(2*n);
f = fftshift([0:Fs/m:((n-1)/m*Fs) -n/m*Fs:Fs/m:-Fs/m]);
end