
from time import time
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as colors
from itertools import cycle
import pandas as pd
from sklearn.decomposition import IncrementalPCA


from sklearn.cluster import MiniBatchKMeans

def do_mini_batch_km_analysis():
    fp = "/home/admin123/Clustering_MD/Paper/clustering.experiments/"\
    "Jan_2016_Delays_Recoded.csv"
    df = pd.read_csv(fp)
    X = df.as_matrix()
    
    krange = np.arange(start = 2, stop = 50, step = 1)
    inertia_values = []
    for k in krange:
        # Compute clustering with MiniBatchKMeans.
        print ("Calculating solution for k = " + str(k))
        mbk = MiniBatchKMeans(init='k-means++', n_clusters= k, batch_size= 2000,
                      n_init=10, max_no_improvement=10, verbose=0,
                      random_state=0)
        mbk.fit(X)
        inertia_values.append(mbk.inertia_)

    

    plt.scatter(krange, inertia_values, color = "blue")
    plt.title("Inertia Versus K - Airline Delay, batch-size = 2000")
    plt.xlim([0,50])
    plt.xlabel("K")
    plt.ylabel("Inertia")
    plt.grid()
    plt.show()

    return

def do_mini_batch_kmeans():
    fp = "/home/admin123/Clustering_MD/Paper/clustering.experiments/"\
    "Jan_2016_Delays_Recoded.csv"
    df = pd.read_csv(fp)
    X = df.as_matrix()
    mbk = MiniBatchKMeans(init='k-means++', n_clusters= 35, batch_size=100,
                      n_init=10, max_no_improvement=10, verbose=0,
                      random_state=0)

    
    t0 = time()
    mbk.fit(X)
    t_mini_batch = time() - t0
    print("Time taken to run MiniBatchKMeans %0.2f seconds" % t_mini_batch)
    mbk_means_labels_unique = np.unique(mbk.labels_)
    df.loc[:,"Cluster"] = mbk.labels_
    fp_out = "/home/admin123/Clustering_MD/Paper/clustering.experiments/" \
            "jan2016_delay_data_clustered.csv"
    df.to_csv(fp_out, index = False)
    

    print("Done with Minibatch K-Means, starting incremental PCA...")
    ipca = IncrementalPCA(n_components = 2)
    X_ipca = ipca.fit_transform(X)
    
    # Use all colors that matplotlib provides by default.
    colors_ = cycle(colors.cnames.keys())

    ax = plt.gca()
    n_clusters = 35
    for this_centroid, k, col in zip(mbk.cluster_centers_,
                                     range(n_clusters), colors_):
        mask = mbk.labels_ == k
        ax.plot(X_ipca[mask, 0], X_ipca[mask, 1], 'w', markerfacecolor=col, marker='.')


    ax.set_title("Mini Batch KMeans Airline Delay for January 2016")
    ax.set_xlabel("Principal Component 1")
    ax.set_ylabel("Principal Component 2")
    plt.grid()

    plt.show()

    return






def do_inc_pca():
    fp = "/home/admin123/Big_Data_Paper_Code_Data/HD_problems/CaliforniaHousing/cal_housing.csv"
    df = pd.read_csv(fp)
    X = df.as_matrix()

    ipca = IncrementalPCA(n_components = 2, batch_size = 100)
    X_ipca = ipca.fit_transform(X)
    
##    krange = np.arange(start = 1, stop = 6, step = 1)

##    plt.figure(1)
##    plt.scatter(krange, ipca.explained_variance_, color = "blue")
##    plt.title("Explained Variance")
##
##    plt.figure(2)
##    plt.scatter(krange, ipca.explained_variance_ratio_, color = "red")
##    plt.title("Explained Variance Ratio")



    return ipca, df

def do_naive_mini_batch_km_analysis():
    fp = "/home/admin123/Big_Data_Paper_Code_Data/TKDE_Review_Exp/"\
         "flightsDB_D0.csv"
    df = pd.read_csv(fp)
    X = df.as_matrix()
    
    krange = np.arange(start = 2, stop = 50, step = 1)
    inertia_values = []
    for k in krange:
        # Compute clustering with MiniBatchKMeans.
        print ("Calculating solution for k = " + str(k))
        mbk = MiniBatchKMeans(init='k-means++', n_clusters= k, batch_size= 2000,
                      n_init=10, max_no_improvement=10, verbose=0,
                      random_state=0)
        mbk.fit(X)
        inertia_values.append(mbk.inertia_)

    

    plt.scatter(krange, inertia_values, color = "blue")
    plt.title("Inertia Versus K - Airline Delay, batch-size = 2000")
    plt.grid()
    plt.xlim([0,50])
    plt.show()

    return
