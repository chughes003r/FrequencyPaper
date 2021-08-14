# Code and data for "Perception of microstimulation frequency in human somatosensory cortex"

# The following is also available as a Word file on the Git

# This data and code corresponds to results published in Hughes, Christopher L., et al. "Perception of microstimulation frequency in human somatosensory cortex." Elife 10 (2021): e65128.

All of this code was run in MATLAB 2019b. 

Always change the directory to the folder that contains the code and data (i.e. “cd(*Insert location on computer where you put data and code*)”)

Many of these data sets depend on classes defined within MATLAB. You will need to have the data classes defined in your directory to load these data files in. All of the data class MATLAB files will depend on “OpenLoopStimData.m.” Magnitude Estimation data will also depend on the class definition “MagnitudeEstimationData.m” and Detection data will depend on “DiscriminationData.m.” Make sure the code defining these classes is in the same folder as the code scripts.

Put all code scripts in the same folder and make sure they are added to your path (so code runs properly with all dependencies).

Note: Figures won’t look exactly as they do in the paper due to post-processing for publication quality (trends should look the same though)

---------------------------------------------------------------------------------------------------------------------------------------------------------

Figure 1, and Supplementary Figures 1 and 2

To produce the figures in the paper run “magEst_Maincode” with the additional two functions in your directory: “magEst_responses” and “inputdialog.” The maincode loads in the appropriate data and calls inputdialog for the user to specify the parameters. The responses code processes and plots the responses based on the user input. 

This code also requires the loading of “consolidatedMagEst.mat.” This is a metadata structure which contains all reported magnitude values for all magnitude estimation experiments ever conducted. The code parses this structure based on user input and extracts the relevant data. 

All parameters for the function needed to be defined by the user are at the top of “magEst_Maincode.” The user will be prompted to input the desired parameters. The following is a list of the inputs used to produce each of the following figures in our paper. 

Make sure to “clear all” when switching between parameter types as this can cause the code to become confused (based on data assigned). 

You can select “Yes” on the last question to run stats on the selected data. Note: the stats don’t make sense for every selection. The stats will provide information on normality, homoscedasticity, and significant differences within a single group. These stats won’t make sense for the aggregated data and should only be used for individual electrodes to determine if there is a significant different or not within an electrode.  

Functions used: “magEst_Maincode.m”, “magEst_responses.m”, “inputdialog.m”

Data needed: consolidatedMagEst.mat

Class dependencies: “MagnitudeEstimationData.m”


Inputs

Figure 1a) 
Q1) norm
Q2) No
Q3) Yes
Q4) Yes
Q5) Piecewise
Q6) SEM Bars
Q7) All
Q8) No (stats don’t make sense for aggregated data)

Figure 1b-d)
Q1) norm
Q2) No
Q3) Yes
Q4) No
Q5) Piecewise
Q6) SEM Bars
Q7) 2
Q8) Optional (this will tell you if each trend shows a significant difference across frequencies)

Supplementary Figure 1a) 
Q1) amp
Q2) Yes
Q3) Yes
Q4) Yes
Q5) Function
Q6) SEM Bars
Q7) All 
Q8) No (stats don’t make sense for aggregated data)

Supplementary Figure 1b)
Q1) amp
Q2) Yes
Q3) Yes
Q4) No
Q5) Function
Q6) SEM Bars
Q7) 2
Q8) Optional (this will tell you if each trend shows a significant difference across amplitudes)

Note: “Function” fit may not work for “dur” plots on newer versions of MATLAB. If you run into an error, just use the “Piecewise” fit instead
Supplementary Figure 1c)
Q1) dur
Q2) Yes
Q3) Yes
Q4) Yes
Q5) Function
Q6) SEM Bars
Q7) All

Note: “Function” fit may not work for “dur” plots on newer versions of MATLAB. If you run into an error, just use the “Piecewise” fit instead
Supplementary Figure 1d)
Q1) dur
Q2) Yes
Q3) Yes
Q4) No
Q5) Function
Q6) SEM Bars
Q7) 2
Q8) No (stats don’t make sense for aggregated data)
Q8) Optional (this will tell you if each trend shows a significant difference across durations)

Supplementary Figures 2b-d)
Q1) norm
Q2) No
Q3) Yes
Q4) No
Q5) Piecewise
Q6) SEM Shaded
Q7) All
Q8) Optional (this will tell you if each trend shows a significant difference across frequencies)

------------------------------------------------------------------------------------------------------------------------------------------
Figure 2

To produce the figures and analysis for magnitude estimation with amplitude and frequency varied together, you will need to run the script “AmplitudeandFrequency.” This code will load in the data structure that contains all of the relevant data called “AmpandFreq_data.mat.” 
Functions used: “AmplitudeandFrequency.m”

Data needed: “AmpandFreq_data.mat”

Class dependencies: “MagnitudeEstimationData.m”

Figure 2a,b, and c should all be output by just running the script


------------------------------------------------------------------------------------------------------------------------------------------
Figure 3

To produce the figures and analysis for qualities, you will need to run two scripts. For Figure 3a, you will need “percept_count.m” and for Figure 3b, you will need “percept_count_frequency.m.”

Functions used: “percept_count.m,” “percept_count_frequency.m,” “spider_plot.m”

Data needed: channel_percepts.mat, channel_stim.mat

Class dependencies: N/A

Figure 3a)
When you run “percept_count.m,” you will receive a prompt asking you to indicate the desired frequency. The plot produced will have all three frequency preference types plotted for stimulation at the selected frequency.

Figure 3b)
When you run “percept_count_frequency.m,” you will receive a prompt asking you to indicate the desired group. The plot produced will have all three stimulation frequencies plotted for all tested electrodes within the selected group. For this code, make sure to clear all before running (some variables might conflict)

------------------------------------------------------------------------------------------------------------------------------------------

Figure 4

To produce the figures and analysis for spatial clustering use the “random_array_sim” code. This code will take the known distribution of relationships and randomly distribute them among stimulated electrodes and calculate a coefficient based on the number of electrodes with neighbors that have the same frequency-intensity relationship. It will then compare the real coefficient to 100,000 simulations and calculate a pseudo p-value.  Additionally, each time the code is run, heatmaps of the arrays will appear that show the categorization of each tested electrode on the array. 

The only required data is “category_locations” which is a vector of all 64 electrodes expressing which category they fall into (1,2, or 3, based on k-means). If an electrode was not tested, it will have a NaN value. 

Functions used: “random_array_sim.m,” “plot_spatial_data_blackedOut_frequency.m”, “inputdialog.m” 

Data needed: category_locations.mat

Class dependencies: N/A

------------------------------------------------------------------------------------------------------------------------------------------
Supplementary Figure 3

This code will plot each channel on which data was collected with each session that it was collected. In the paper, only channels on which three or more samples were collected were included. The statistics will calculate if there are significant differences between the magnitude of each frequency measured across sessions. 

When running the code, the user will be asked to specify which folder the data is to be loaded from and which folder the figures are to be saved in. 

Functions used: “MagEst_Individual.m”

Data needed: allData_sigChans.mat

Class dependencies: “MagnitudeEstimationData.m”

------------------------------------------------------------------------------------------------------------------------------------------

Supplementary Figure 2a, 4b, and 6

This code will perform and plot the results for each k-means clustering of both intensity values and perceptual values on intensity axes in 3D space.  

When running the code, the user will be asked to specify which folder the data is to be loaded from and which folder the figures are to be saved in. To plot figures 2a and 6, select “P2” as the participant. To plot figure 4b, select “P3” as the participant

Functions used: “k-means_clustering.m”

Data needed (2a and 6): allresponses_notnorm.mat, chans.mat, percept_ch_all.mat
Data needed (4b): P3_respsandchans.mat

Class dependencies: N/A


Supplementary Figure 4a and 4c

This code will show the frequency magnitude response plot (4b) and the spatial clustering plots (4c) for participant P3. Simply run “random_array_sim_P3” and it will output the plots.

Functions used: “random_array_sim_P3.m,” “plot_spatial_data_blackedOut_frequency_P3.m”
Data needed: P3_locations.mat

Class dependencies: N/A

Supplementary Figure 5

This code will perform and plot the results for detection at different frequencies across four tested electrodes.

When running the code, the user will be asked to specify which folder the data is to be loaded from and which folder the figures are to be saved in. 

Functions used: “Detection.m”

Data needed: allData_detection.mat

Class dependencies: “DiscriminationData.m”


