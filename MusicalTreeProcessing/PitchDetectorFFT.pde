
//Numero di armonici da estrarre
int nHarm=10;
int FHfactor=100;
float approx=1.2;
class PitchDetectorFFT implements AudioListener { 
  float sample_rate = 0;
  float last_period = 0;
  float[] current_frequency = new float[nHarm];
  float[] current_power = new float[nHarm];
  long t;
  
  
  FFT fft;

   
   
  PitchDetectorFFT () {
  }
  
  void ConfigureFFT (int bufferSize, float s) {
       fft = new FFT(bufferSize, s); 
       fft.window(FFT.HAMMING);
       SetSampleRate(s);
  }
  
  synchronized void StoreFrequency(float[] f,float[]powers) {
    current_frequency = f;
    current_power=powers;
  }
  
  synchronized float[] GetFrequency() {
    return current_frequency;
  }
  synchronized float[] GetPowers(){
    return current_power;
  }
  
  void SetSampleRate(float s) {
     sample_rate = s;
     t = 0;
  }
  
  synchronized void samples(float[] samp) {
    FFT(samp);
  }
  
  synchronized void samples(float[] sampL, float[] sampR) {
    FFT(sampL);
  }
  
  synchronized long GetTime() {
    return t;
  }
 
  void FFT (float []audio) {
    t++;
    float highest = 0;
    fft.forward(audio);
    float ScF=2; //Fattore di scala per taglio di scelta armonici
    int max_bin =  fft.freqToIndex(10000.0f);
    float [] powHarm = new float[nHarm];
    int highest_bin = 0;
    float[] Bande = new float[max_bin];
    int[] HighHarms = new int[nHarm];

    for(int n=0; n<max_bin;n++){
      Bande[n]=fft.getBand(n);
      if(Bande[n]>highest){
        highest=Bande[n];
        powHarm[0] = fft.getBand(n);
        highest_bin = n;
        HighHarms[0]=highest_bin;
      }
    }
   //Inserisco la ricerca di altri 5 armonici &&(notcontains(HighHarms,n))(fft.getBand(n) >= highest/ScF)&&
   //!!!!!!!!!!!!!!!!!!! FARE ARRAY DI HIGHEST cioè fi fft.getband IN MODO DA AVERE ANCHE LE INTENSITà
   highest=max(Bande);
   int fi=1;
   if(highest<600){
    while(fi<nHarm){
      float LocH=highest/ScF;
       for (int n = 0; n < max_bin; n++) {
         if ((fft.getBand(n)>LocH)&&(notcontains(HighHarms,n))){
         LocH=fft.getBand(n);  
         powHarm[fi]=LocH;
         HighHarms[fi]=n;
          }
      }
    fi++;
    }
   }
   if(highest<2){
     for(int i=0;i<nHarm;i++){
     HighHarms[i]=0;
     }
   }
    float[] freq = aggiusta(HighHarms,sample_rate,float(audio.length),powHarm);
    float[] power = powHarm;
    StoreFrequency(freq,power);
  }
};

boolean notcontains(int[] arr, int val) {
  for(int i=0; i<arr.length; i++) {
    if(arr[i]==val) {
      return false;
    }
  }
  return true;
}

float[] aggiusta(int[] A, float sample, float audL,float[] pote){
  float[] B = new float[A.length];
  for(int i=0; i<A.length;i++){
    B[i]=A[i]*sample/audL;
    if((pote[0]/pote[1])<1.2){
      B[0]=B[1];
    }
  }
  return B;
}
