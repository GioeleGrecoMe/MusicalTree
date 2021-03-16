class Tree {
  ArrayList<Branch> branches = new ArrayList<Branch>();
  ArrayList<Leaf> leaves = new ArrayList<Leaf>();

  Tree(float[] x, float[] y, float[] z) {

    for (int o = 0; o < x.length-1; o++) {
      leaves.add(new Leaf(x[o],y[o],z[o]));
      float tot=0;
      if(x.length>(30+x.length/2)&&(o%4==0)&&(o>30)){
        for(int p = 1; p<pow(x.length,0.2);p++){
          tot=random(-p,p);
          leaves.add(new Leaf(x[o]+random(-p,p),y[o]+random(-p,p),z[o]+tot));
        }
      }
    }    
    Branch root = new Branch(new PVector(0,0,-10), new PVector(0, 0,1));
    branches.add(root);
    Branch current = new Branch(root);

    while (!closeEnough(current)) {
      Branch trunk = new Branch(current);
      branches.add(trunk);
      current = trunk;
    }
  }
void AddLeaf(float x, float y, float z){
  leaves.add(new Leaf(x,y,z));
}

  boolean closeEnough(Branch b) {

    for (Leaf l : leaves) {
      float d = PVector.dist(b.pos, l.pos);
      if (d < max_dist) {
        return true;
      }
    }
    return false;
  }

  void grow() {
    for (Leaf l : leaves) {
      Branch closest = null;
      PVector closestDir = null;
      float record = -1;

      for (Branch b : branches) {
        PVector dir = PVector.sub(l.pos, b.pos);
        float d = dir.mag();
        if (d < min_dist) {
          l.reached();
          closest = null;
          break;
        } else if (d > max_dist) {
        } else if (closest == null || d < record) {
          closest = b;
          closestDir = dir;
          record = d;
        }
      }
      if (closest != null) {
        closestDir.normalize();
        closest.dir.add(closestDir);
        closest.count++;
      }
    }

    for (int i = leaves.size()-1; i >= 0; i--) {
      if ((leaves.get(i).reached)){
        leaves.remove(i);
    }
   }

    for (int i = branches.size()-1; i >= 0; i--) {
      Branch b = branches.get(i);
      if (b.count > 0) {
        b.dir.div(b.count);
        PVector rand = PVector.random2D();
        rand.setMag(0.5);
        b.dir.add(rand);
        b.dir.normalize();
        Branch newB = new Branch(b);
        branches.add(newB);
        b.reset();
      }
    }
  }

  void show(int siz,int Silenzio, int fulm, int gener) {
    for (Leaf l : leaves) {
      //l.show();
    }   
      pushMatrix();
      for (int i = 0; i < branches.size(); i++) {
      Branch b = branches.get(i);
      if (b.parent != null) {
        
        PVector v0 =new PVector(b.pos.x, b.pos.y, b.pos.z);
          PVector v1 =new PVector(0,0,-20);
          float d = pow(v0.dist(v1),2);
          float Nmax=60+2*log(branches.size());
          
         float n=pow((1*Nmax*siz)/(d/2+pow(i,2)/2+Nmax),0.4);
         float nMin = pow((1*Nmax*siz)/(d/2+pow(branches.size(),2)/2+Nmax),0.4);
         float n0=0;
         
         nMin=min(nMin,0.1);
         if(fulm!=0 && n<nMin*2){branches.remove(b);};
         if(i>0){
          n0=pow((1*Nmax*siz)/(d/2+pow(i,2)/2-1+Nmax),0.4);
     }
      
        if(Silenzio==100){
         println(Silenzio+"c'è sinlenzio");
        }
        
        colorMode(HSB);
        stroke(60,10+100*pow((Nmax-n)/Nmax,2),10+100*pow((Nmax-n)/Nmax,2),99.99);
        if(gener==0){
          stroke(0,0,255);
        }
        strokeWeight(n);
        //EFFETTO DEL SILENZIO FINALE
        if(Silenzio>100 && frameCount%2==0){
          int tec=branches.size()-1;
            Branch bp=branches.get(tec);           
           branches.remove(bp);
           
        }
        
        //EFFETTO DEL FULMINE
        if(fulm!=0){
         for (int f=0; f<leaves.size(); f++){
            Leaf lmorta=leaves.get(f);
            leaves.remove(lmorta);
          }
          
          int tes=branches.size()-1;
          while(tes>0.5*siz && branches.size()>0.75*siz){
            
            Branch bp=branches.get(tes);
            if(bp.pos.z>-5){
              branches.remove(bp);
              
            }
            if(bp.parent==null){branches.remove(bp);}
              
            tes--;
          }
          
         
     
        }
     if(n>11){
         strokeWeight(n/3);
          Shaping(n/12,b.pos.x+n/12*cos(PI/4), b.pos.y+n/12*sin(PI/4), b.pos.z,n0/13, b.parent.pos.x+n0/13*cos(PI/4), b.parent.pos.y+n0/13*cos(PI/4), b.parent.pos.z);
        Shaping(n/12,b.pos.x-n/12*cos(PI/4), b.pos.y-n/12*cos(PI/4), b.pos.z,n0/13, b.parent.pos.x-n0/13*cos(PI/4), b.parent.pos.y-n0/13*cos(PI/4), b.parent.pos.z);
         }    
     if(n>5){
          strokeWeight(n/3);
          Shaping(n/12,b.pos.x, b.pos.y, b.pos.z,n0/13, b.parent.pos.x, b.parent.pos.y, b.parent.pos.z);
        
      
          
        }else{
        strokeWeight(n);
        line(b.pos.x, b.pos.y, b.pos.z,b.parent.pos.x, b.parent.pos.y, b.parent.pos.z);}
         if((n<4)&&(i%2==0)&&(b.pos.z>-8)){
          color LC = color(120,255,255,99);
          float dire = PVector.angleBetween(v0,v1)+PI/3+random(-PI/60,PI/60);
          float direz=random(-PI/7,PI/15);
          if(i%3==1){dire = PVector.angleBetween(v0,v1)-PI/3+random(-PI/60,PI/60);
        direz=random(-PI/10,PI/10);if(gener==2){LC = color(15,255,255,99);}}
          if(i%3==0){dire = PVector.angleBetween(v0,v1)-2*PI/3+random(-PI/60,PI/60);
        direz=random(-PI/15,0);if(gener==2){LC = color(60,255,255,99);}}
          
          float LL=0.02*pow(0.002*(1000-(siz/6)),0.2)*pow(sin((i-(branches.size()))*0.01*PI),2); //se non funziona al posto di frameCount metti branches.size()
          leafes(b.pos.x, b.pos.y, b.pos.z,LL,dire,direz,LC);
          
        }
  
    }
    }
    int frameB=branches.size()-1;
    
    if((frameCount%1==0)){
      if((frameCount%5==0)){
        frameB=branches.size()-1;
      }
        for (int i = branches.size()-1; i >= frameB; i--) {
      Branch b = branches.get(i);

     
      if (b.parent != null) {
        PVector v0 =new PVector(b.pos.x, b.pos.y, b.pos.z);
          PVector v1 =new PVector(0,0,0);
          float d = pow(v0.dist(v1)/1.5+i,1.3);
          float Nmax=60;
          float n=pow(((60+siz-i)/(d/2+Nmax)),0.8);  
          if((b.pos.z>0)&&(n<1.5)&&frameCount%2==0){
            branches.remove(b);
            //println("pulizia");
            if(leaves.size()>0){
             Leaf lmorta=leaves.get(leaves.size()-1);
             leaves.remove(lmorta);
            }
          }
          
        }
      }
    }
    popMatrix();
  }
  
}

void leafes(float x, float y,float z, float lfSize, float dir,float dirz,color c) {
  // Preserve the current transformation matrix
  pushMatrix();
  fill(c);
  noStroke();
  strokeWeight(1);
  // Perform transformations in TRS order
  translate(x, y, z);            // Define origin for the drawing
  rotate(dir); // rotate by 'dir' radians
  rotateY(dirz);
  rotateX(dirz);
  scale(lfSize);// scale the image
  beginShape();
  vertex(0,0);
  bezierVertex(50, -60, 100, -30, +150, -50);
  bezierVertex(100, 30, 50, 30, 0, 0);
  endShape();
  // Restore matrix
  popMatrix();
}

void Shaping(float r,float x,float y, float z,float r0, float x0, float y0, float z0){
  if(r>1){
  line(x+r*cos(PI/4),y,z,x0+r0*cos(PI/4),y0,z0);
   line(x-r*cos(PI/4),y,z,x0-r0*cos(PI/4),y0,z0);
   
   line(x,y+r*cos(PI/4),z,x0,y0+r0*cos(PI/4),z0);
   line(x,y-r*cos(PI/4),z,x0,y0-r0*cos(PI/4),z0);
  } 
  line(x,y,z,x0,y0,z0);
   line(x+r,y,z,x0+r0,y0,z0);
   line(x-r,y,z,x0-r0,y0,z0);
   
   line(x,y+r,z,x0,y0+r0,z0);
   line(x,y-r,z,x0,y0-r0,z0);
   
  
}
