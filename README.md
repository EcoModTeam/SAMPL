# Survey Analysis for Monitoring Population Levels (SAMPLE): An agent-based model to simulate surveys of immobile organisms

Survey Analysis for Monitoring Population Levels (SAMPL) is an Agent Based Model (ABM) designed to evaluate the performance of various spatial sampling strategies when the target of the sampling effort is a stationary organism. SAMPL is designed for field scientists and other interested parties who wish to understand the strengths and limitations of various sampling strategies. As such it allows the user to configure the true density, detectability, and distribution of the target of organism, as well as the sampling strategy and the intensity of the sampling effort. It then returns the estimated density, species detection rate (if applicable), and other information about the sampling effort, which can then be compared to the true density and number of organisms of interest. SAMPL was originially developed to simulate freshwater mussel surveys, thus the organism of interest is refered to as a mussel in the model. However, the sampling strategies replicated in this model have been used to survey for other organisms or even inanimate objects. 

SAMPL allows the user to replicate four sampling strategies: 
- simple random sampling: random quadrats are sampled.
- transect sampling: transects are laid vertically across the area of interest, and quadrats are placed randomly along the transects.
- adaptive cluster sampling: quadrats are randomly sampled. If an organism is detected, the four direct neighboring quadrats are also sampled. This repeats until no more organisms are detected orf the sampled 'cluster' reaches the edge of the modeled space.
- timed searches: a simulated surveyor 'searches' the area of interest by traveling in a correlated random walk. When the surveyor encounters a target organism, it turns more tightly, thus simulating how humans search for items.

For more information consult the model documentation, located in the 'Info' tab of the NetLogo model.

# Installation

SAMPL was designed to run on NetLogo 6.4.0 or later. To install NetLogo 6.4.0, go to ![https://ccl.northwestern.edu/netlogo/download.shtml] and follow the download instructions.

# Running a simulation

To run SAMPL, open the NetLogo 'interface' tab and use the green dropdown lists and input boxes to configure the model parameter inputs. Example paremeters include sampling method, density of mussels, distribution of mussels, frequency and detectablity of mussel species, the output file name, and parameters related to the specific sampling method. When the model is set up correctly, click the grey 'Initialize' button. Then click the 'Run Model' button.

For more information on model parameters consult the model documentation, located in the 'Info' tab of the NetLogo model.

To run multiple model scenarios or repeating model scenarios with random variation, make use of the behavior space tool under the tools tab. For more information on the behavior space tool consult the NetLogo 6.4.0 User Manual ![https://ccl.northwestern.edu/netlogo/docs/]

# Model Validation & Testing

SAMPL was based on strategies used to sample freshwater mussels in river and stream habitats. Specifically, the model was inspired by a study by Astrid Schwalb and 

# Contribution Instructions

We welcome bug reports and questions in the form of github issues. We also welcome code contributions. To make a contribution, please fork this repository, commit your changes to the fork, and then create a pull request. 

