# MusicalTree
This is the repository for our CPAC project. 
A demo video can be found at this link: https://youtu.be/7pRX-LU2cJ0

## Abstract:
The Musical Tree is a 3D music visualizer that can adapt itself depending on the musical genre to which it is exposed.
It is composed by a tree that grows “following” the music and by other interactive elements. 

## Music Genre Classification:
We implemented a machine learning based algorithm to perform the genre classification. The feature extraction process is applied to the GTZAN dataset in order to discriminate five music genres: 'Classical', 'Pop', 'Reggae', 'Rock', 'Jazz'. Each song in the database was stored as a 22050 [Hz], 16bits, and mono audio file.

### Feature Extraction Process:
Different kind of *low-level* and *high level* audio features are computed. They are categorized into rhythmic, spectral and tonal. They are decomposed into low-level and high-level according to the frame size: low-level features are extracted from a short window (1024 samples, 44.45 [ms] of duration) while high-level features are extracted from longer windows to gain a better frequency resolution (4096 samples, 186 [ms]), the first with 50% of overlap between successive windows, the second with 75%.
The different frame-based features are computed and then integrated over the all audio extract duration by means of the different **statistical moments** like *maximum* value, *minimum* value, *mean*, *standard deviation*, *skewness* and *kurtosis*.

### Splitting the data into Training Set and Test Set:
Here we build the sets `X_train` and `y_train` which are the training set of features and their corresponding set of labels, and the sets `X_test` and `y_test` which are the testing set of features. 

### SVM: Classification Model
The classification model is built up using Support Vector Machine available in the library '`sklearn`'.

### Model Training:
The training is done using `GridSearchCV` which exhaustively considers all parameter combinations identifying the one that maximizes the '`accuracy`'.

### Model Testing and Accuracy Evaluation:
The model is evaluated on the test set extracted at the beginning from the feature dataset in performing class prediction on newly unseen data.
Here we report the obtained confusion matrix.
<p> <img width="500" height="500" src="images/Confusion.png"> </p>

### Recording and Communication with Processing
The application makes a recording with a duration of 1 second every second of music.
After the recording the code extracts the features on the recorded signal and predicts the genre. Finally the labelled genre is sent to processing via OSC messages.

## Visualization with Processing
The implementation can be divided in three parts:
  - elaboration of the audio input
  - graphical components
  - comunication from Python to Processing
### Audio
Starting from the “Audio analysis for pitch extraction” made by L. Anton-Canalis (https://gist.github.com/uberjosh/5001856#file-gistfile1-txt) that uses Minim library.
This code was rearranged to our purposes and extract some useful parameters:
 -	Spectrum 
 -	first 10 high intensity harmonics (frequency and amplitude)
 -	total amplitude of the signal
 -	energy of the signal
Each one of these parameters is also stored in a buffer that allow to calculate:
 -	mean intensity level
 -	mean spectrum


It is also possible to correct the implementation by uncomment the approximated phone curve
### graphical components
The graphical component can be devided in two time-dependent macro classes:
 - instantaneous reactive components
 - stored datas component: tree.
#### Tree
The main component is the tree, starting from the "3D fractal tree"(https://www.youtube.com/watch?v=JcopTKXt8L8) was created some functions that make tree interact with the stored sound datas.
Tree grows trhought points that are calculated and stored during all the time.
The points coordinates are stored every 0.8s.
The location of the points 

Developed by Gioele Greco, Tommaso Botti and Nicolò Botti.
