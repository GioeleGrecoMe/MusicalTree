


class ColorSound{

   float[] F;
   float[] A;
   float level;

    
    
   ColorSound(float[] freq, float[] amp,float l){
     level=l;
     F=freq;
     A=amp;
   }
   color[] getColor(){
     float VolRel = 3;
     float esp=2.1;
     int nH=F.length;
     float AmpSum =0;
     for(int i =0;i<nH;i++){
        AmpSum =A[i]+AmpSum;
     }

     AmpSum=AmpSum+3000;
     float[] H= new float[nH];
     float[] B=new float[nH];
     float[] T=new float[nH];
     float[] R=new float[nH];
     color[] c=new color[nH];
     
     for(int i=0; i<nH;i++){
       if((A[i]>1)&&(A[i]<20)){
          A[i]=A[i]+20;
        }
         T[i]=10*(log((A[i])*90/AmpSum)+1);
         if(T[i]>=90){
              T[i]=90;
           }
      H[i]=(abs(FreqPos(F[i])%12)*21.25);
      R[i]=pow(T[i]/VolRel,esp);
      while(R[i]>=height){
        VolRel=pow(VolRel+0.1,2);
        R[i]=pow(T[i]/VolRel,esp);
      }
      if(F[i]>=200){
       B[i]= round(32*log(F[i]+1-180));
      }
     if(F[i]<200){
     B[i]=F[i]/1.5;
     }
     c[i]=color(H[i],255,B[i]);
     } 
     return c;
   }
}
