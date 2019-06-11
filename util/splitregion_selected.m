%Copyright (c) 2019 Hakki Mert Torun
%Splits given domain into 2^d regions along the dimensions 'd'(array).
function output_domains = splitregion_selected(domain,d)
D = size(domain,1);
n_region = 2^length(d);

temp = zeros(D,3);
temp(:,1) = domain(:,1);
temp(:,3) = domain(:,2);
temp(:,2) = (domain(:,2)+domain(:,1))/2;


output_domains_temp = repmat(domain,[1,1,n_region]);
% index = decimalToBinaryVector(0:1:2^length(d)-1,D);
% index = fliplr(de2bi(0:1:2^length(d)-1,D));
index = fliplr(d2b(0:1:2^length(d)-1,D));

index = index + 1;
index = fliplr(index);
index = flipud(index);
for a = 1:length(d)
    output_domains_temp(d(a),1,end:-1:1) = temp(d(a),index(:,a)); 
    output_domains_temp(d(a),2,end:-1:1) = temp(d(a),index(:,a)+1); 
end
output_domains = output_domains_temp;

end
