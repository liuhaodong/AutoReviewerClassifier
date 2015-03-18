function out = wica(sig)
if (isempty(sig))
    out = sig;
    return;
end
[Lo_D,Hi_D,Lo_R,Hi_R] = wfilters('db6');
[C, L] = wavedec(sig, 3, Lo_D, Hi_D);

wave_len = L(end-1);
C2 = C;
wave_mat = nan(length(L) - 1, wave_len);

for l = 1:length(L)-1
    right = sum(L(1:l));
    left = sum(L(1:l)) - L(l) + 1;
    wave = C(left:right);
    wave2 = interp1(1:length(wave), wave, (length(wave)/wave_len):(length(wave)/wave_len):length(wave)); 
    wave_mat(l, :) = wave2;
end
wave_mat(isnan(wave_mat)) = 0;
z = wave_mat;
[z_ic A T mean_z] = myICA(z,length(L)-1);
[v, zero_out_i] = max(range(z_ic'));
z_ic(zero_out_i, :) = 0;
z_LD = T \ pinv(A) * z_ic + repmat(mean_z,1,size(z,2));

for l = 1:length(L)-1
    right = sum(L(1:l));
    left = sum(L(1:l)) - L(l) + 1;
    wave2 = z_LD(l, :);
    wave3 = interp1(1:length(wave2), wave2, 1:(length(wave2)/L(l)):length(wave2));
    C2(left:right) = wave3;
end
sig_rec = waverec(C2, L, Lo_R, Hi_R);

out = sig_rec;
end