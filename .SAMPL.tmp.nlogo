
@#$#@#$#@
GRAPHICS-WINDOW
26
329
1034
538
-1
-1
10.0
1
10
1
1
1
0
0
0
1
0
99
0
19
1
1
1
ticks
30.0

BUTTON
33
544
119
577
NIL
Initialize
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
209
544
329
577
Run Model
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
29
170
140
230
mussels-per-meter
1.0
1
0
Number

CHOOSER
29
95
200
140
sampling-method
sampling-method
"simple-random-sample" "transect" "adaptive-cluster" "timed-search"
1

INPUTBOX
931
41
1041
101
transect-spacing
10.0
1
0
Number

INPUTBOX
1090
41
1194
101
num-initial-clusters
10.0
1
0
Number

INPUTBOX
931
109
1041
169
quadrats-on-transect
5.0
1
0
Number

TEXTBOX
930
11
1101
29
TRANSECT
16
0.0
1

TEXTBOX
1089
11
1239
31
ADAPTIVE CLUSTER
16
0.0
1

CHOOSER
29
38
168
83
quadrat-size
quadrat-size
0.25 0.5 1
1

INPUTBOX
1091
109
1187
169
max-clusters
2000.0
1
0
Number

TEXTBOX
453
10
682
50
FREQUENCY & DETECTABILITY
16
0.0
1

INPUTBOX
454
177
541
237
freq-common
0.65
1
0
Number

INPUTBOX
455
38
542
98
freq-rare
0.1
1
0
Number

INPUTBOX
455
107
542
167
freq-med-rare
0.25
1
0
Number

BUTTON
342
544
485
577
Calculate Metrics
calculate-metrics
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
247
41
389
86
spatial-distribution
spatial-distribution
"random" "Clumped-Poisson" "Clumped-Matern"
2

INPUTBOX
246
114
324
174
num-groups
3.0
1
0
Number

INPUTBOX
244
194
357
254
poisson-mean-meters
6.0
1
0
Number

CHOOSER
243
277
482
322
matern-clump-placement
matern-clump-placement
"Randomly placed" "One shore only" "One shore; one middle" "One shore; one middle; 2 additional" "One shore; 2 additional"
0

OUTPUT
1051
356
1408
467
10

TEXTBOX
1054
329
1264
376
Mussel Sampling Metrics
16
0.0
1

TEXTBOX
738
10
941
33
SIMPLE RANDOM SAMPLE
15
0.0
1

INPUTBOX
738
37
893
99
quadrats-to-sample
1999.0
1
0
Number

TEXTBOX
30
10
180
29
MODEL SETUP
15
0.0
1

TEXTBOX
30
150
180
169
DENSITY
15
0.0
1

TEXTBOX
248
11
398
30
DISTRIBUTION
15
0.0
1

TEXTBOX
247
92
397
110
CLUMP PARAMETERS
13
0.0
1

TEXTBOX
739
126
889
145
TIMED SEARCH
15
0.0
1

INPUTBOX
739
190
894
250
person-hours-to-search
10.0
1
0
Number

INPUTBOX
563
38
652
98
detect-rare
1.0
1
0
Number

INPUTBOX
556
107
651
167
detect-med-rare
1.0
1
0
Number

INPUTBOX
558
177
651
237
detect-common
1.0
1
0
Number

INPUTBOX
740
258
895
318
detect-reduction
0.0
1
0
Number

SWITCH
740
150
894
183
variable-search-mode
variable-search-mode
0
1
-1000

INPUTBOX
26
261
192
321
file-name
placeholder_results
1
0
String

TEXTBOX
25
241
175
266
FILE NAME
15
0.0
1

BUTTON
830
544
927
577
Initialize File
initialize-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
937
544
1035
577
Save Results
save-results
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
133
544
196
577
Step
tick build-cluster timed-search
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
246
176
402
194
Poisson Only
10
0.0
1

TEXTBOX
244
258
394
276
Matern Only
10
0.0
1

@#$#@#$#@
## WHAT IS IT? 

This model simulates field sampling of freshwater mussels in a riverine system, as described by Sanchez and Schwalb (2021). By adjusting sampling method and intensity and mussel abundance, distribution, and detectability, the user can explore tradeoffs between sampling efficiency and accuracy. The goal of the model is not to predict actual populations of mussels, but rather to inform real-world surveyors of the strengths and limitations of different sampling methods as they relate to estimating population densities and maximizing detection rate.  

## HOW IT WORKS 

The model domain is a grid that represents a channelized river/stream reach that is 50 meters long and 10 meters wide, for a total area of 500 square meters. Grid cell size is initialized as one of three user-defined options for edge length: 1m, 0.5m, or 0.25m, representing the size of sampling quadrats used for freshwater mussels. The world is featureless, and habitat quality is assumed to be the same throughout. The model consists of two types of agents: mussels and surveyors, with the former being sessile and the latter being mobile. The model simulates four freshwater mussel sampling techniques: simple random sampling, transect sampling, adaptive-cluster sampling, and timed searches (Strayer and Smith 2003). The former three are quadrat-based methods, while the timed searches involve surveyor agents moving through the model domain. The rules governing agent-behavior depend on the selected survey method and specific options for each. Mussels are initialized across all survey methods, but surveyors are only explicitly modeled in the timed search method. In the other three methods, surveyors are implicit with the sampling decisions represented only by the sampling protocol (e.g., if patches are sampled, they are considered “quadrats”). The model is initialized by establishing mussels within the domain, choosing sampling method, and defining the behaviors of the surveyors (if present).  

### Mussel Initialization 

Mussels populate the domain based on parameters set in the user interface: density, spatial distribution, frequency and detectability (see “how to use it” section below). Density represents the overall number of mussels per square meter (m<sup>2</sup>). Spatial distribution represents how mussels are placed within the model domain and can be one of three general distributions: random, Poisson, or Matérn (described in more detail below). Frequency of occurrence is represented by three different species of mussels (i.e., rare, medium-rare, and common), mimicking real world distributions of mussel species within communities. Detectability represents the probability that mussels will be detected if the quadrat they are located in is sampled. Each mussel is assigned a random number from a uniform distribution between zero and one that represents the probability of detection (henceforth detectability score). If a mussel’s assigned detectability score is below the species-specific detectability threshold defined by the user, that mussel will be detected. Once initialized, mussel location and attributes do not change throughout the model run. If a mussel is detected, it turns red. A mussel can only be detected once. If the mussel is not detected at first, it can be detected if the patch is sampled again. 

### Sampling Method and Surveyor Behaviors 

 

In the simple random sample method, mussels are initialized at a given density and distribution, then a user-defined number of quadrates are placed randomly throughout the domain. If a mussel intersects with a quadrat, it may be detected, according to its detectability.  

In the transect method, transects are placed at user defined intervals throughout the stream reach with each transect running the entire length of the y-axis. Transects are the width of one cell (i.e., a sampling quadrat). Within each transect, users define the number of quadrats to be sampled, then these are placed randomly within each transect. Mussels within a quadrat may be detected, according to its detectability. 

In the adaptive cluster method, a user-defined number of initial sample quadrats are placed randomly throughout the model domain. If a mussel intersects with a quadrat, it may be detected, according to its detectability. If a mussel is detected, the 4 non-diagonal neighboring quadrats are searched and added to the cluster. This process repeats until either no more mussels are detected, the maximum number of quadrats (defined by the user) is reached, or the adaptive cluster reaches the edge of the model domain. Each cluster has a unique ID and is represented by a different color, and quadrats that are added to an initial cluster are represented with progressively lighter shades with each iteration.  

The timed search method is the most complex and involves the surveyor agent. During initialization, in addition to mussels being placed in the domain, three surveyor agents are initialized. Surveyors are parameterized as a Netlogo breed. Surveyors begin evenly spaced and proceed from the left to the right using a correlated random walk. During the model run, surveyors move according to one of two behavioral states: searching or traveling. When a surveyor is searching, each patch/grid cell is searched for mussels, and mussels may be detected, according to its detectability score. To account for the fact that timed searches may be less comprehensive than quadrat searches, the user can reduce the probability of detection for all mussel species with the `detect-reduction` input. During the travel behavior, surveyors move through the grid cells without searching. We assume that it takes surveyors 2 minutes to search 1 square meter, and 3 seconds to travel through 1 square meter (Smith et al. 2001, Smith and Crabtree 2010, Bird et al. 2022). This estimated time is tabulated and used to calculate mussels-per-person-hour, which is a metric of catch per unit effort (CPUE) that represents the number of individual mussels captured per cumulative hours of search time (cumulative across number of surveyors). Because this model uses three surveyors, one person-hour is equivalent to 20 minutes of searching (3 surveyors x 20 min = 60 min total). 

After detecting a mussel, surveyors begin localized searching where the radius of movement is decreased and they search neighboring and nearby cells. Surveyors can observe other surveyors and will move towards surveyors that are finding mussels if they have not detected mussels recently themselves. Surveyors avoid colliding with other surveyors and with the edges of the model domain. To ensure adequate coverage of the world, a surveyor can only spend up to one fourth of their allotted time in each quarter of the model domain (lengthwise). If surveyors are still finding mussels but their time in a given quarter has ended, they travel ahead to the next quarter. 

## HOW TO USE IT 

Under “Model Setup”, the user sets the quadrat size and the sampling method. Quadrat size (edge length) can be 1 meter, 0.5 meter, or 0.25 meter. Quadrat size is synonymous with patch size in this model. The four sampling methods to choose from are simple random sample, transect, adaptive cluster, and timed search. These each have unique inputs.  

Under “Density” the user can input the number of mussels per square meter, which determines how many mussels are populated into the world. If the mussel density is set to 1, that means on average there is 1 mussel per square meter, so there would be a total of 500 mussels.  

Under “File Name” the user can name a file to output results to. Note: if this name is not changed, the program will overwrite any results saved therein!  

Under “Distribution”, the user sets the spatial distribution for the mussels, as well as specific parameters for clumps (if using). Random distribution will distribute mussels randomly throughout the reach with no discernible pattern. Clumped Poisson will distribute mussels in Poisson-pattern clumps, and Clumped Matern will distribute them in Matern-pattern clumps, which are meant to simulate predicted spatial distribution of mussels (Smith et al. 2011). Number of groups determines how many clumps exist (for both Poisson and Matern clumps, provided a Matern clump placement is set to “Randomly placed.” Poisson mean represents the mean distance each mussel is from the center of the Poisson clump, and determines how tightly clustered each clump is (if using Poisson clump distribution). Each Poisson clump is placed randomly in the reach. Clumps may overlap, especially with loose clumps or high mussel density. If Clumped Matern is chosen, the clumps are represented by light blue patches. The user can choose between 4 preset clump designs, or the “Randomly placed” setting in which the inputted number of clumps will be randomly distributed. Design 1 clumps the mussels in an ellipse along one shore, replicating a pattern often seen in the field. Design 2 includes the shoreline clump, plus a circular clump in the middle of the channel. Design 3 includes the shoreline clump and the mid-channel clump, plus 2 randomly placed elliptical clumps. Design 4 includes only the shoreline clump and 2 randomly placed elliptical clumps.  

Under “Frequency and Detectability”, the user sets the frequency and detectability for each of the three mussel species (rare, medium-rare, and common). Frequency values for the three species must add up to 1. Frequency for each species is equal to the proportion of the total mussel population that consists of that species. Therefore, the rare species should have a lower frequency than the medium-rare species, which in turn should have a lower frequency than the common species. Detectability indicates the probability that the mussel will be detected should the patch it is located in be searched. Detectability can be the same or different across all species but cannot be less than 0 or greater than 1. A detectability of 1 means that a surveyor (or quadrat) that intersects with a mussel will detect it 100% of the time; a detectability of 0 means that a mussel will never be detected. This parameter allows the user to account for factors that may affect detectability in the field, such as mussel size, texture, color, and burrowing depth. In the case of timed searches, if a mussel is not detected by a surveyor, it may still be detected in subsequent searches. For example, if a mussel has a detectability of 0.5 and is not detected at first, there is still a 50% chance it will be detected if the quadrat is searched again. Note that species detectability here refers to whether an individual mussel of a given species will be detected, not the probability that a species of mussel will be detected in the entire sampling area, so a species could be classified as rare in the study area but may still have high detectability (for example, a rare species that is easy to search for because it tends to be found sitting on top of the substrate). 

Under “Simple Random Sample”, the user may set the number of quadrats to be used in the simple random sample method.  

Under “Transect”, the user may set transect spacing and the number of quadrats in each transect. Note that the user specifies the spacing of transects (i.e., number of quadrats/patches between individual transects) rather than the total number of transects sampled, which helps ensure adequate coverage of the study area. Given that quadrat/patch size may differ according to user input (0.25, 0.5, or 1m), the number of transects and the actual measured distance between transects will differ according to selected quadrat-size (e.g., a transect spacing of 10 produces 5 transects distributed 10m apart when quadrat-size is set to 1, whereas the same spacing produces 10 transects distributed 5m apart when quadrat-size is set to 0.5). 

Under “Adaptive Cluster”, the user may set the number of initial clusters (quadrats) and the maximum number of quadrats. The model run stops if the maximum number of quadrats is reached (or if no more mussels are detected as detailed above). Note that limiting the number of quadrats that are sampled introduces bias in density estimations (Turk & Borkowski 2005). However, limitations are often necessary to prevent prohibitively long search times. For this reason, Adaptive Cluster Sampling is typically only recommended at sites with low mussel densities (Turk & Borkowski 2005). 

Under “Timed Search” the user may set parameters for the timed search method. The `variable-search-mode` toggle tells the surveyors whether or not they should be searching the entire time. If it is off, the surveyors continually search for mussels until and unless their allotted time in a quarter is exceeded, in which case they pause searching to move to the next quarter. If variable search mode is on, the surveyors alternate between searching and traveling for intervals of 10 quadrats. This is to account for the fact that a surveyor may move to a new area if their searching is unsuccessful. `Person-hours-to-search` determines the total number of person-hours that a model run will take. In a given model run, this number might be exceeded by a few seconds to account for traveling time. `detect-reduction` subtracts a user-specified amount from the species detectability values, to account for the fact that surveyors may search areas less thoroughly during a timed search than other methods, reducing the probability of detecting mussels. If `detect-reduction` is set to 0, there is no reduction in detectability compared to other survey methods (beyond those associated with each mussel species). If detect-reduction is set to 1, no mussels will be detected, regardless of the individual species’ detectabilities.  

All methods require the model to be initialized, but only the adaptive cluster and timed search methods require the `Run Model` button to run through iterative sampling steps. When the simulation is done running, summarizing metrics will appear in the Mussel Sampling Metrics output box. If desired, the user can click the `Initialize File` and `Save Results` button to save results to a CSV file. 

## THINGS TO TRY 

Explore how changing mussel distributions affect sampling accuracy. Do the sampling methods improve or worsen when mussels are more or less clustered?  

Examine how detectability influences sampling performance. This will be especially relevant for adaptive cluster sampling and timed searches, as these sampling methods change course based on whether mussels are detected. 

## EXTENDING THE MODEL 

While this model assumes all habitat to be of equal quality, this is oftentimes untrue in the real world. Especially while performing timed searches, surveyors often use prior knowledge to prioritize searching areas of perceived good mussel habitat (e.g. boulders, stream edges, etc.). Similarly, surveyors may be more reluctant to search areas that are more difficult to access (e.g. deep or fast flowing water, thick vegetation, natural hazards, etc.). This model might be extended by creating habitat that attracts or deters surveyors during timed searches. These same features might make a mussel more or less likely to be detected (for example, it may be more difficult to find a mussel in fast flowing water), so the model could be extended to include spatial variation in detectability. 

The model could also be extended to accommodate different sampling strategies. For example, there are many variations of adaptive cluster sampling which include various rules for limiting cluster growth, or thresholds for expanding clusters. Also, the rules and strategies used in timed searches may vary considerably according to research goals, experience level, and researcher preferences.  

## NETLOGO FEATURES 

This NetLogo model uses a custom function to initialize a CSV file and to write results at the end of model runs. When used in combination with the Behavior Space tool, we recommend calling the `initialize-file` function as a pre-experiment command and calling the `save-results` function as a post run command.  

## RELATED MODELS 

This model adapts components of several existing NetLogo Models. For example, in timed searches surveyor edge avoidances was inspired by the Bounce Example in the NetLogo Code Examples and the correlated random walk underlying the surveyor movement was adapted from the Mushroom Hunt model from Railsback and Grimm. 

## CREDITS AND REFERENCES 

Bird, C.T., Kaller, M.D., Pasco, T.E., Kelso, W.E. Microhabitat and landscape drivers of richness and abundance of freshwater mussels (Unionida: Unionidae) in a coastal plain river. Applied Sciences 12(20), 10300 (2022). https://doi.org/10.3390/app122010300 

Sanchez, B., Schwalb, A.N. Detectability affects the performance of survey methods: a comparison of sampling methods of freshwater mussels in Central Texas. Hydrobiologia 848, 2919–2929 (2021). https://doi.org/10.1007/s10750-019-04017-y 

Smith, T.A., Crabtree, D. Freshwater mussel (Unionidae: Bivalvia) distributions and densities in French Creek, Pennsylvania. Northeastern Naturalist 17(3), 387-414 (2010). https://doi.org/10.1656/045.017.0304 

Smith, D.R., Villella, R.F., Lemarie, D.P. Survey protocol for assessment of endangered freshwater mussels in the Allegheny River, Pennsylvania. Journal of the North American Benthological Society 20(1), 118-132 (2001). https://doi.org/10.2307/1468193 

Smith, D.R., Rogala, J.T., Gray, B.R., Zigler, S.J., Newton, T.J. Evaluation of single and two-stage adaptive sampling designs for estimation of density and abundance of freshwater mussels in a large river. River Research and Applications 27, 122-133 (2011). https://doi.org/10.1002/rra.1334 

Strayer, D.L., Smith, D.R. A Guide to sampling freshwater mussel populations. Monograph 8. Bethesda, Maryland: American Fisheries Society (2003). 

Turk, Philip, and John J. Borkowski. A Review of Adaptive Cluster Sampling: 1990-2003. Environmental and Ecological Statistics 12 (1): 55–94 (2005). https://doi.org/10.1007/s10651-005-6818-0. 
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
