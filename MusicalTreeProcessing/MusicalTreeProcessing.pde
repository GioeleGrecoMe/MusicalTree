import processing.opengl.*;
import javax.swing.JFileChooser;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import oscP5.*;
import netP5.*;
import peasy.*;

PeasyCam cam;
Tree tree;
PitchDetectorFFT PD; 
AudioSource AS;
Minim minim;
ColorSound CSM;

//GRANDEZZA BUFFER
int Buff = 8; //4 per 5m //8 per 10m //16 per 30m //32 per 1h e 30m circa//Il buffer lo puoi usare come fattore di crescita, con 16 in mezz'ora di musica cresce un bell'albero
float[] livelli = new float[100];
float[][] Fz = new float[300][Buff+2]; //righe= frequenze colonne: ampiezza media, ampiezze negli ultimi 100 frame
float[] FB=new float[1];
//TREE Parameter
float[] X={0};
float[] Y={0};
float[] Z={0};
float[] masse={1};
float min_dist = 0.9;
float max_dist = 20;
//star in sky parameter
float[] Xs={600};
float[] Ys={600};
float[] Zs={-100};
float AMPLI = 2; //Fattore moltiplicativo ampiezze;
int genere = 0;

int Silenzio = 0;

PImage maria;
PImage rockH;
PImage jazzM;
  
PShape sax;
PShape piano;
PShape column;
float col=0;
float hs,ss,bs;
int fulm=0;
//genere set
int DDD = 0;

OscP5 oscP5;
Float bpm;
String genre = "null";
String reg = "reggae";
String rock = "rock";
String jazz = "jazz";
String cla = "classical";
String pop = "pop";

float FreqPos(float f)
    {
     float fond=110;
     float esp=12*log(f/fond)/log(2);
     float n=esp;
     return n;
    }

void setup()
{
  //size(700,300, P3D);
  fullScreen(P3D);
  cam = new PeasyCam(this, 600);
  smooth(2);
  frameRate(10);
  colorMode(HSB);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  maria=loadImage("maria.png");
  rockH=loadImage("RockH.png");
  sax=loadShape("sax.obj");
  piano=loadShape("Piano.obj");
  column=loadShape("Column.obj");

  piano.scale(8);
  sax.scale(4);
  column.scale(0.1);
  
  minim = new Minim(this);
  minim.debugOn();
  AS = new AudioSource(minim);
  AS.OpenMicrophone();
  PD = new PitchDetectorFFT();
  PD.ConfigureFFT(2048, AS.GetSampleRate());
  PD.SetSampleRate(AS.GetSampleRate());
  AS.SetListener(PD);  
  
  //tree initialization
  for(int i=0; i<10; i++){
    X=append(X,0);
    Y=append(Y,0);
    Z=append(Z,0);
    masse=append(masse,1);
  }
 //sky stars inizialization
 for(int lp=0; lp<1000; lp++){
   float n1,n2,n3;
   n1=random(-1500,1500);
   n2=random(-1500,1500);
   n3=random(-400,400);
    Xs=append(Xs,n1);
    Ys=append(Ys,n2);
    Zs=append(Zs,n3);
  }
  
  tree = new Tree(X, Y, Z);

}


void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      AMPLI = AMPLI+0.1;
    } else if (keyCode == DOWN) {
      AMPLI = AMPLI-0.1;
    } else if (keyCode == ENTER ){
      println("l'amplificazione è"+AMPLI);
    } else if (keyCode == SHIFT ){
      if(DDD==0){
          DDD=1;
        }else{
          DDD=0;
        }
      println("Hai cambiato visualizzazione");
    }
    println("la nuova amplificazione è"+AMPLI);
      if (keyCode == ALT ) {
        println("RESET");
      X=new float[1];
      Y=new float[1];
      Z=new float[1];
      masse=new float[1];
   for(int i=0; i<10; i++){
    X[0]=0;
    Y[0]=0;
    Z[0]=0;
    masse=append(masse,1);
  }
    }
  }
 
}

void draw()
{ 
  
   if (genre.compareTo(cla)==0){
   genere=0;
   println("genere CLASSICA");}
   if (genre.compareTo(pop)==0){
   genere=1;
   println("genere POP");}
   if (genre.compareTo(reg)==0){
   genere=2;
   println("genere REGGAE");}
   if (genre.compareTo(rock)==0){
   genere=3;
   println("genere ROCK");}
   if (genre.compareTo(jazz)==0){
   genere=4;
   println("genere JAZZ");}
  
  
  if(genere!=2){
  background(0,0,0);
  }
  
  else{
    float sec = bpm/6;
    
    if(frameCount%(3*sec)==0){
      col=0;
      }
      if(frameCount%(3*sec)==sec){
      col=15;}
      if(frameCount%(3*sec)==2*sec){
      col=30;
    }
    background(col,255,255/(1+frameCount%sec));
  }
  
  


  //=========
  float eyeX=(0.85*50);
  float eyeY=(0.85*110);
  if(DDD=0){
    camera(eyeX, eyeY, 20, 0, 0, 40, 0, 0, -1);
  }
  int nHarmo=PD.GetPowers().length;
  float[] frequenze = new float[nHarmo];
  float[] ampiezze = new float[nHarmo];
  float level = AS.GetLevel();
  level=level*AMPLI;
  frequenze = PD.GetFrequency();
  ampiezze = PD.GetPowers();
  livelli[frameCount%Buff]=level;
  //AMPLITUDE PEAK CONTROL
  
  int conta=0;
  for(int i=0; i<Buff;i++){
    if(livelli[i]>=0.90){conta++;}
    if(conta>Buff/5){AMPLI=0.98*AMPLI;
  println(AMPLI+"HO NORMALIZZATO AMPIEZZA");
    conta=0;} 
  }
  //=======================
  
  //Mean sound level in a Buff length
  float mediaL = 0;
  if(frameCount>=Buff){
    for ( int i = 0; i < livelli.length; ++i ){
     mediaL += livelli[i];
    }
    mediaL /= (float)(livelli.length);
  }
  if(mediaL<0.01 && mediaL>0.0001){
  AMPLI*=1.005;
  println("mi sto amplificando "+ AMPLI);
  }
   //=================================

  //Stars in the sky for JAZZ
 if((mediaL<0.5 && genere==4)){
   pushMatrix();  
    for(int st=0; (st<Xs.length-1)&&(st<(1000*(1-2*mediaL))); st++){ 
      stroke(255);
      if(st%100==0){
        stroke(st*25.5/10,150,255);
      }
      strokeWeight(random(0+0.01*(100*(1-66.66*mediaL)),3));
      point(Xs[st],Ys[st],Zs[st]);    
    }
  popMatrix();
 }
 
//POPOLO Vettore frequenze totali
for(int i=0; i<frequenze.length; i++){
  if(IsIn(FB,frequenze[i])==false){
     FB= append(FB,frequenze[i]);
    }
    
  }
  FB=sort(FB);

float Ampimedia=0;
for(int i=0; i<FB.length; i++){
   Fz[i][0]=FB[i];
   Ampimedia=0;
   Fz[i][2+frameCount%Buff]=0;
   for(int j=0; j<frequenze.length; j++){
     if(FB[i]==frequenze[j]){
       //APPROSSIMO CON LE ISOFONICHE
     /* 
       if(frequenze[j]<1000 && frequenze[j]>19){
         ampiezze[j]*=1.2-(20/frequenze[j]);}
         else if(frequenze[j]>4000){ampiezze[j]*=1.2-(frequenze[j]/10000);}
        if(ampiezze[j]==max(ampiezze)){println(ampiezze[j]+"massima ampiezza" + frequenze[j]+"HZ");
  } 
  */
       Fz[i][2+frameCount%Buff]=AMPLI*ampiezze[j];
    }
  }
  for(int k=0; k<Buff; k++){
   Ampimedia +=Fz[i][2+k]/100; 
  }
  Fz[i][1]=Ampimedia;
  
}

  float[] FforS =new float[FB.length];
  float[] AforS = new float[FB.length];
  int[] MaxA = new int[FB.length];
  float Energy = 0;
  Energy=level;
  for(int i=0; i<FB.length; i++){
   FforS[i] =Fz[i][0];
   AforS[i] = Fz[i][1];
   MaxA[i]=round(AforS[i]);
   if(AforS[i]<0.98*max(AforS)&&(AforS[i]>0.8*max(AforS))){
     Energy=Energy*1.05;
   }
   if(Energy>1){
   Energy=0.9;}
  }
  println("L'energia in questo momento è di "+ Energy+ "il livello è "+level+"la media level è"+mediaL);
   tree.show(Energy,X.length,Silenzio,fulm,genere);
 
    CSM =new ColorSound(FforS,AforS,mediaL); 
   color[] c = CSM.getColor();
 

   int quant=0;
   int ind=0;
   int MAX= max(MaxA);
   color Csum = color(0,0,0); 
   hs=0;
   bs=0;
   ss=0;

  for(int i=0; i<FB.length; i++){
   if(MaxA[i] == MAX){ind=i;}
   if(MaxA[i]>=0.1*MAX){
     hs+=MaxA[i]*hue(c[i]);
     bs+=MaxA[i]*brightness(c[i]);
     ss+=MaxA[i]*saturation(c[i]);  
     quant+=MaxA[i]; 
   }
  }
  
  Csum=color(hs/quant,bs/quant,ss/quant);
   if(genere==2){
    pushMatrix();
    rotateX(PI/2);
    rotateZ(PI+PI*0.002*frameCount%1000);
    translate(0,0,300);
    imageMode(CENTER);
    image(maria,0,0,mediaL*2000,mediaL*2000);
    popMatrix();
  }

  if(genere==2 || genere == 0 ){
  pushMatrix();
  int Npunti=100;
  float Gig=1;
   if(genere==2){
     Npunti=20;
     rotateX(random(PI/20,PI/10));
     rotateY(random(PI/20,PI/10));
     rotateZ(random(PI/20,PI/10));
     Gig=1.5;
   }
   if(genere==0){
     translate(-100,0,150);
   }
   ShapeT(FforS,AforS,Gig*50+pow(mediaL*150,2),Npunti,Csum/*c[ind]*/,Energy*200);
   popMatrix();
  }
  if(genere!=2){
   spotLight(hue(Csum/*c[ind]*/),50+level*400,50+level*400,0,0,300,0,0,-1,PI/2,100000/(mediaL*100000+1));
  }else{
   pointLight(255,0,255,0,0,20);  
  }
  //FLASH DI PICCO
  if(genere==3||genere==1){
   if(Energy>0.80){
       background(hue(Csum),255,255);
     }
  } 
  
  //CLASSIC SETUP
  if(genere==0){
    float di=50;
    float Pos=FreqPos(FforS[ind])%12;
    float anc=Pos;
    if(Energy<=0.9){
      pushMatrix();
    spotLight(hue(c[ind]),255,255,(di-20)*cos(PI/1.5+anc*PI/8),(di-20)*sin(PI/1.5+anc*PI/8),-10,cos(PI/1.5+anc*PI/8),sin(PI/1.5+anc*PI/8),0.9,Energy*2*PI,100000/(level*100000+1));
    println(anc+"QUESTO è ANC");
    popMatrix();
    }
    else{
      pushMatrix();
      pointLight(255,0,255,0,0,0); 
      popMatrix();

    }    
    pushMatrix();
    translate(0,0,-13);
    if(Energy>=0.75){
      translate(0,0,random(1,5));
      rotateX(random(-1,1)*random(PI/50,PI/40));
      rotateY(random(-1,1)*random(PI/50,PI/40));
    }
    for(int ang=0; ang<7; ang++){
      shape(column,di*cos(PI/1.5+ang*PI*3/14),di*sin(PI/1.5+ang*PI*3/14));
    }
    popMatrix();
  }
  
//GENERAL SETuP OF THE WORLD
  pushMatrix();
  fill(27,38,50);
  if(genere==2){
    if((frameCount/10)%3==0){fill(0,255,255);}
    if((frameCount/10)%3==1){fill(35,255,255);}
    if((frameCount/10)%3==2){fill(80,255,180);}
  }
  translate(0,0,-25);
  noStroke();
  translate(0,0,-230);
  float Rag=250;
  if(genere==3){Rag=242+level*10;}
  sphere(Rag);
  popMatrix();

//TREE PARAMETER CALCULATION == POLAR COORDINATES 
//INITIALIZATION of the growing condition
 if((frameCount%round(Buff/4)==0)&&(mediaL>0.0001)){
  float[] alfaxy=new float[FforS.length];
  float[] gammaz = new float[FforS.length];
  float[] Ra = new float[FforS.length];
  alfaxy[0]=0;
  gammaz[0]=0;
  float endy=0;
  float endx=0;
  float endz=0;
  int inde=ind;
 //FOR each frequency and amplitude assign a location
  for(int po=1; po<FforS.length;po++){
    alfaxy[po]=(FreqPos(FforS[po])%12)*PI/6;
    gammaz[po]=(-PI/2-PI/3-log(FforS[po]*2)*8*PI/(60));
    Ra[po]=pow(AforS[po],1);
    if(Ra[po]>1000){Ra[po]=1000;}   
   }
   

   if(Energy>0.70/*(level>0.6)*/){
     float startx=300*cos(alfaxy[inde])*sin(gammaz[inde]);
     float starty=300*sin(alfaxy[inde])*sin(gammaz[inde]);
     float startz=300*cos(gammaz[inde]);
      //==================== BOLT ===============
     pushMatrix();
     for(int cc=1; cc<10;cc++){
     colorMode(HSB);
     stroke(hue(c[ind]),255,255);
     strokeWeight((Energy/0.5)*10/cc);
     endy = (starty+ random(-5,+5))*sin(-alfaxy[inde])*sin(-gammaz[inde]);    
     endx = (startx+ random(-5,+5))*cos(PI/2-alfaxy[inde])*sin(-gammaz[inde]) ;
      endz = (startz + random(-20,-4))*cos(PI/2-gammaz[inde]);
      if(genere!=2){
      line(startx,starty,startz,endx,endy,endz);
      }
      else{point(startx,starty,startz);point(endx,endy,endz);}
      startx = endx;
      starty = endy;
      startz= endz;
      fulm+=1;
      }
      popMatrix();
    }else{fulm = 0;}
    
  //Find the best position for the new leaf 
  float[] P = el(X,Y,Z,alfaxy,gammaz,AforS,masse,Energy);
 
 if(frameCount%round(Buff/4)==0){
  X=append(X,P[0]);
  Y=append(Y,P[1]);
  Z=append(Z,P[2]);
  tree.AddLeaf(X[X.length-1],Y[Y.length-1],Z[Z.length-1]);
  masse=append(masse,0.1);
 } 
 
 if((P[2]>(pow(0.025*X.length,0.5)))&&(level<0.75)&&(mediaL<0.2)&&(level>0.1)){
   float lino = 2*pow(0.8*X.length*mediaL,0.5);
    if(lino>9){lino=9;};
   for(int j=0; j<lino/1.5;j++){
     tree.AddLeaf(X[X.length-1]+random(-lino,+lino),Y[Y.length-1]+random(-lino,+lino),Z[Z.length-1]+random(-lino/2,+lino/2));
   }
 }

 
  
}

float n=0;
  for(int i =0; i<X.length;i++){
    PVector vi= new PVector(X[i],Y[i],Z[i]);
    PVector v0= new PVector(0,0,0);
    float D = v0.dist(vi);
    n=pow(((60+X.length-i)/(D/2+60)),0.8);
    
    masse[i]=n; 

    
  }
  
  if(genere==2){
    pushMatrix();
    rotateX(-PI/2);
    for(int i=1;i<Xs.length;i++){
      
        if(i%10==0){
       image(maria,Xs[i]*cos(0.00002*PI*(frameCount%100000)),Ys[i]*sin(0.00002*PI*(frameCount%100000)),round(random(10,15)),round(random(10,15)));
        }
    }
    
    popMatrix();    
  }
  
    if(genere==3){
      AMPLI*=1.01;
    pushMatrix();
    rotateX(PI/2);
    rotateZ(PI);
    translate(0,0,50);
    imageMode(CENTER);
    if(mediaL>0.03){
    image(rockH,(frameCount%10),(frameCount%10),400-(frameCount%10),400-(frameCount%10));
    }
    popMatrix();
    
  }
  if(genere==4){
    if(Energy>=0.7){AMPLI*=0.98;}
    pushMatrix();  
    spotLight(hue(c[ind]),saturation(c[ind]),brightness(c[ind]),15,8,10,0.8,0.1,0.5,Energy*2*PI,Energy);
    popMatrix();
    float angles=PI/2;
    if(Energy>=0.1){angles=random(PI/2,PI/(1.95));}
    if(Energy>=0.2){angles=random(PI/2,PI/(1.9));}
    if(Energy>=0.3){angles=random(PI/1.95,PI/(1.87));}
    if(Energy>=0.5){angles=random(PI/1.9,PI/(1.82));}
    
    pushMatrix();
    translate(-10,10,5);
    rotateX(angles);
    rotateY(angles);
    
    shape(sax,0,0);
    popMatrix();  
    pushMatrix();
    translate(20,0,-12);
    
    rotateX(angles);
    rotateY(angles);
    shape(piano,0,10);
    
    popMatrix();
    if(mediaL>0.03){
    pushMatrix();
    
    for(int i=1;i<bpm*2;i++){
      float DFact=(pow(i,0.3));
      if(i%2==0){
      stroke(255,0,255);
      }else{stroke(hue(c[ind]),255,255);}
      strokeWeight(random(Energy,Energy*15)/DFact);
      point(-10+(frameCount)%i*mediaL*60*random(-1,1)/DFact,15+(frameCount)%i*mediaL*60*random(-1,1)/DFact,7+((frameCount)%i)); 
    }
    popMatrix();
    }
  }
  if(genere==1){
    for(int i=0; i<level*200; i++){
      stroke(random(0,255),255,255);
      strokeWeight(random(1,15));
      if(i%3==0){
     point(Energy*2*i*random(-1,1)*cos(0.001*frameCount%100),random(-1,1)*Energy*200,50+Energy*2*i*random(-1,1)*sin(0.001*frameCount%100));
    
      }
    if(i%3==1){
       point(Energy*2*i*random(-1,1)*cos(0.001*frameCount%100),random(-1,1)*Energy*150,50+Energy*2*i*random(-1,1)*sin(0.001*frameCount%100));
    
    } 
    if(i%3==2){
       point(Energy*2*i*random(-1,1)*cos(0.001*frameCount%100),random(-1,1)*Energy*100,50+Energy*2*i*random(-1,1)*sin(0.001*frameCount%100));
    }
  }
  }
  
  
  pushMatrix();
  tree.grow();
  popMatrix();

 
 if(level<0.0016){
   Silenzio +=1;

  }else{Silenzio=0;}
 if(Silenzio>150){min_dist=1; max_dist=1000;}
 }

  

void stop()
{
  AS.Close();

  minim.stop();


  super.stop();
}



void ShapeT(float[] F, float[] A, float R, int el,color c,float T){
  int K = F.length;
  float AmpS=0;
  float x;
  float y;
  R=pow(R-10,1.1);
  float[] coseni = new float[el];
  float[] seni=new float [el];
  float[] zeta= new float[el];
  float[] AmpN = new float[K];
 rotateX(PI/2);
  translate(0,0,250);
  noStroke();
 for(int i =0; i<K;i++){
    AmpS+=A[i];
  }
  for(int i = 0; i<K;i++){
    AmpN[i]=A[i]/AmpS;
  }
  for(int j=0; j<el;j++){
    for(int i=0;i<K;i++){
      
     
    
     coseni[j]+= AmpN[i]*cos(((0.0078125*F[i]*j/el)*2*PI))*cos(((0.0078125*F[i]*j/el)*2*PI)%(2*PI));
     seni[j]+= AmpN[i]*sin(((0.0078125*F[i]*j/el)*2*PI))*cos(((0.0078125*F[i]*j/el)*2*PI)%(2*PI));
     zeta[j]+=AmpN[i]*sin(((0.0078125*F[i]*j/el)*2*PI));
    rotateZ(zeta[j]);
    
    float huE =abs(FreqPos(F[i])%12)*21.25;
    fill(huE,255,255,(T*100*AmpN[i]));
    if(AmpN[i]<max(AmpN)/100000){
      huE=hue(c);
      fill(huE,255,255,(T*0.9));
    }
    
   noStroke();
  
  if(i>K/1.5){
  x=R*coseni[j];
  y=R*seni[j];
  circle(x,y,R/50); 
  }
  
    }
    
  }


}

boolean IsIn(float[] A, float B){
  int c=0;
  for(int i=0; i<A.length; i++){
    if((A[i]==B)||((A[i]<=1.01*B)&&(B<=1.01*A[i]))){
      c++;
  }
  }
  return c>0;
}

float[] bari(float[] MX,float[] MY,float[] MZ,float[] m) {
  int S=MX.length;
  int ind=m.length;
  int diff=S-ind;
  if(diff!=0){
    for(int we=0; we<diff; we++){
      m=append(m,random(1,5));  
    }
  }
  float xB=0;
  float yB=0;
  float zB=0;
  float Bz=0;
  float Bx=0;
  float By=0;
  float M=0;
  for(int i=0;i<S-1;i++){
    xB=xB+MX[i]*m[i];
    yB=yB+MY[i]*m[i];
    zB=zB+MZ[i]*m[i];
    M=M+m[i];
  };
  
  Bx=xB/(M*S);
  By=yB/(M*S);
  Bz=zB/(M*S);
  float[] Bari={Bx,By,Bz};
  return Bari;
}





int[] distanze(float[] x, float[] y,float[] z, float alfaxy,float gammaz, float RP){
  float[] D = new float[x.length];
  int[] indici= new int[x.length];
  float Tx=(RP)*cos(alfaxy)*sin(gammaz);
  float Ty=(RP)*sin(alfaxy)*sin(gammaz);
  float Tz=(RP)*cos(gammaz);
  PVector L= new PVector(Tx,Ty,Tz);
  for(int i =0; i<x.length;i++){
    PVector v=new PVector(x[i],y[i],z[i]);
    D[i]=v.dist(L);
  }
  float[] DS=sort(D);
  for(int j=0; j<x.length; j++){
    for(int k=0; k<x.length; k++){
      if(D[k]==DS[j]){
        indici[j]=k;
      }
    }
  }
  return indici;
}

float[] el(float[] x, float[] y,float[]z, float[] alfaxy,float[] gammaz,float[] A,float[] masse,float lev){
  float xel=0;
  float yel=0;
  float zel=0;
  int Flen = alfaxy.length;
  int S=x.length-1;
  float[] P=new float[3]; 
  
  float IB=0;
  float alfaB=0;
  float gammaB=0;
for(int i =0; i<Flen; i++){
   alfaB= alfaB+alfaxy[i]*A[i];
    gammaB=gammaB+gammaz[i]*A[i];
    IB = IB+A[i];
  }
  alfaB=alfaB/(IB+1);
  gammaB=gammaB/(IB+1);
  float R=pow(lev*10,0.5);
    if(R>4.8){R=4.8;}
    
  if(R<min_dist){R=min_dist;}
  int[] dist=distanze(x,y,z,alfaB,gammaB,(R*100));
 

  println(R);
  //restituisce gli indici dei punti più vicini
  xel=R*cos(alfaB)*sin(gammaB);
  yel=R*sin(alfaB)*sin(gammaB);
  zel=R*cos(gammaB);
  
  float[] Bari = new float[3];
  x = append(x,0);
  y = append(y,0);
  z = append(z,0);
  int a=0;
  int q=dist[0];
  while ((q>=0)&&(a<S)){
    
    x[S+1]=xel+x[q];
    y[S+1]=yel+y[q];
    z[S+1]=zel+z[q];
    Bari = bari(x,y,z,masse);
    float AB = abs(Bari[0]-x[0]);
    float AY = abs(Bari[1]-y[0]);
    float AZ = abs(Bari[2]-z[0]);
    float absy=abs(y[S+1]-Bari[0]);
    float absx=abs(x[S+1]-Bari[1]);
    float C1=pow(S,0.8);
    float C2=pow(S,0.4);//(AZ>pow(C1,2))
    if(AB>pow(C1,0.15)||AY>pow(C1,0.15)||(AZ>pow(C1,1))||((x[S+1]<-C2)||(x[S+1]>C2))||
    ((y[S+1]>C2)||(y[S+1]<-C2))||((z[S+1]>2*C2)||(z[S+1]<-C2/2))||
    (absx>C2)||(absy>C2)){
       a++;
       q=dist[a];
       
      
   
     }
     else{
      P[0]=xel+x[q];
      P[1]=yel+y[q];
      P[2]=zel+z[q];
      break;
    }
  }
  return P;
}




// incoming osc message are forwarded to the oscEvent method.

void oscEvent(OscMessage message) {
  //message.print();
  //println(millis());
  if(message.checkAddrPattern("/genre")==true) {
    // check if the typetag is the right one. -> expecting float (genre)
    if(message.checkTypetag("s")) {
     genre = message.get(0).toString();
     //genre = "hiphop";
      print(genre+"MESSAGGIO ARRIVATOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
    }
  }
  if(message.checkAddrPattern("/bpm")==true) {
    // check if the typetag is the right one. -> expecting float (genre)
    bpm = message.get(0).floatValue();
    print(bpm);
  }
}
