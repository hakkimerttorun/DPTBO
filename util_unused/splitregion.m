function output_domains = splitregion(domain,d)
n_region = 2^d;

output_domains = zeros(d,2,n_region);
temp = zeros(d,3);
for i = 1:d
    temp(i,3) = domain(i,2);
    temp(i,1)  = domain(i,1);
    temp(i,2) = (temp(i,3)+temp(i,1))/2;
end

i = 1;
count = 0;
while (count < n_region)
    index = decimalToBinaryVector(count,d);
    index = index + 1;
    index = flip(index);
    for a = 1:d
        output_domains(a,:,count+1) = [temp(a,index(a)) temp(a,index(a)+1)]; 
    end
    count = count + 1;
end

end




%         output_domains(1,:,i) = [temp(1,index(1)) temp(1,3)];
%         output_domains(2,:,i) = [temp(2,index(2)) temp(2,3)];
%         output_domains(3,:,i) = [temp(3,index(3)) temp(3,3)];
%         output_domains(4,:,i) = [temp(4,index(4)) temp(4,3)];
%         output_domains(5,:,i) = [temp(5,index(5)) temp(5,3)];
%         output_domains(6,:,i) = [temp(6,index(6)) temp(6,3)];
%         output_domains(7,:,i) = [temp(7,index(7)) temp(7,3)];
%         output_domains(8,:,i) = [temp(8,index(8)) temp(8,3)];
%         output_domains(9,:,i) = [temp(9,index(9)) temp(9,3)];   