#To install the R required packages execute the following command:

Rscript install_packages.R

#This package takes as input a matrix containing normalized gene expression and IC50 values for 
#265 drugs for each cell line in the panel. You need to decompress the file iorio_et_al_preprocessed.txt.gz

#Get the predictions using the following command
R -f dre.r iorio_et_al_preprocessed.txt

#Note that in this script users can change the number of permutations through parameter called n_perm
#The results will have a line for each tested drug together with the mean and standard deviation of 
#the prediction performance. The prediction performance is measured as Pearson Correlation between 
#the experimentally determined and predicted IC50 values across the cell lines.

#An example output file is provided.
