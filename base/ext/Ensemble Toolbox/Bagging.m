%training of classifiers
function [E]=...
    Bagging(TrainIn, WeakLearn, T_itrs, P_sampled, Classes)

% begin training the classifiers
for t=1:T_itrs
    S_btstrp = randsample(size(TrainIn),P_sampled*size(TrainIn),replacement);
    hyp = WeakLearn(S_btstrp); %output of Weaklearn(sample) is hypothesis
                                %hyp is function handle (classifier)                                %handle
    E{t} = hyp; %E must be cell-array; will have to instantiate
end


%simple majority voting
function [FinalCls] =...
    Test_SMV(x) %x is datum for testing

for t=1:T_itrs
    hyp = E{t};
    V(t) = hyp(x); %hyp is classifier; class is stored in V
end

CV = zeros(T_itrs,size(Classes));

for i=1:T_itrs; %NOTE -- can't Matlab cycle through a mx more efficiently?
    for j=1:size(Classes);
        if strcmp(V(i),Classes(j)) %checking equality of char types
            CV(i,j)=1;
        end
    end
end

Votes = sum(CV);
FinalCls = Classes(max(Votes)); %not sophisticated enough;
                                %doesn't account for ties