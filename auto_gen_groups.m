%Copyright (c) 2019 Hakki M. Torun
%Auto generate groups of parameters based on some emprical tests.
%Users are HIGHLY ENCOURAGED to provide their own groups of parameters, 
%however, this function can also be used.
function group_length = auto_gen_groups(dimension)

if(mod(sqrt(dimension),1)==0 && dimension > 10)
    group_length = sqrt(dimension).*ones(1,sqrt(dimension));
    return
end

candidateD = round(sqrt(dimension)):1:10;
candidateM = (dimension - rem(dimension,candidateD))./candidateD;

candidateGroups = cell(length(candidateM),1);
for a = 1:length(candidateM)
    groups = candidateD(a).*ones(1,candidateM(a));
    if(sum(groups) ~= dimension)
       groups = [groups, dimension-sum(groups)]; 
    end
    candidateGroups{a} = groups;
end

prods = cellfun(@prod,candidateGroups);
spread = cellfun(@max, candidateGroups)-cellfun(@min, candidateGroups);

group_score = prods./(2.^cellfun(@length,candidateGroups));

inf_indices = find(isinf(group_score));

[~,sel_group] = max(group_score);
group_length = candidateGroups{sel_group};
% candidateGroups{:}

end