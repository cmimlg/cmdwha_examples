# cmdwha_examples
Clustering Mixed Datasets with Homogeneity Analysis
This repository contains the code and data associated with "Clustering Mixed Datasets with Homogeniety Analysis"

The Auto-MPG and Heart Disease R files show how to apply homogeniety analysis with the homals package to learn the euclidean representation of the categorical variables in a mixed dataset. The learned euclidean representation yields very meaningful clusters in both cases.

The Cluster_2016_Airline_Delay.R implements the following:
(1) Since the dataset is large, we pick a sample of size 10000 from this dataset to learn the euclidean representation
of the categorical variables. We pick the sample using stratified sampling such that all routes (origin - destination) pairs
are represented.
(2) We apply this learned representation on the original dataset. This involves recoding each categorical value in the original
dataset by the learned euclidean representation. This file is now written to disk for further analysis by mini-batch K Means clustering

The Jan_2016_Airline_Delay_Unsup.py is a python script that uses the mini-batch K Means code from sklearn to cluster the large
dataset (all numerical variables) obtained from running Cluster_2016_Airline_Delay.R. The optimal number of clusters, K is determined by using an elbow plot.
