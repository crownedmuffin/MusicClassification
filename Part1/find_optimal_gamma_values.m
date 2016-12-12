function [max_avg_genre_distances, optimal_gamma_values] = find_optimal_gamma_values(avg_genre_distance_matrix)
%Gamma value used in computing the avg_genre_distance_matrix values
gamma_value_used_to_compute_avg_distance_matrix = 100;

%Need to solve for the average KL value (refer to equation 24)
average_KL = (-gamma_value_used_to_compute_avg_distance_matrix./log(1-avg_genre_distance_matrix))-eps;

optimal_gamma_values = zeros(6,6);
%genre_distances = zeros(6,6);
max_avg_genre_distances = zeros(6,6);

for gamma = 10:100
    
   genre_distances = abs(1 - exp(-gamma./(average_KL + eps)));
   
   max_occurances = genre_distances > max_avg_genre_distances;
   
   %Find the maximum values
   max_avg_genre_distances = (genre_distances.*max_occurances) ...
                            +(~max_occurances).*max_avg_genre_distances;
   
   %Find the optimal gamma values
   optimal_gamma_values = (gamma*max_occurances) ...
                            +(~max_occurances).*optimal_gamma_values;
end

end