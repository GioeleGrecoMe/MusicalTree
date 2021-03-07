# MusicalTree
This is the repository for our CPAC project. 
A demo video can be found at this link: 

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
