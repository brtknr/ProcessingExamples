import processing.opengl.*;
int nMax=50,m=1000;
float Omega[],P[],PhiP[],X[],PhiX[],tleft,tmax;
float ZeroCirclePosition=50.0;
float cScale=1.0/10000.0;
float c=0.01;
float minFrequency=0.01;
float maxFrequency=2.0;
float meanFrequency=(maxFrequency+minFrequency)*0.5;
float FrequencyScale=meanFrequency/200.0;
float OmegaNatural=TWO_PI*meanFrequency;
float CircleX=ZeroCirclePosition+c/cScale;
float CircleY=ZeroCirclePosition+OmegaNatural/(TWO_PI*FrequencyScale);
float CircleR=20.0;
boolean OverCircle=false;
boolean CircleLockedOn=false;
float CircleDiffX=0.0; 
float CircleDiffY=0.0;

void setup()
{
  size(1100,720);
  smooth();
  Omega=new float[nMax+1];
  P=new float[nMax+1];
  PhiP=new float[nMax+1];
  X=new float[nMax+1];
  PhiX=new float[nMax+1];
  tleft=0.0;
  tmax=30.0;
  CalculateValues();
}

void draw()
{
  background(0,0,0);
  tleft+=0.05;
  strokeWeight(1);
  stroke(255,255,255,255);
  line(0,0.5*height,width,0.5*height);
  strokeWeight(2);
  stroke(255,255,255,255);
  noFill();
  beginShape();
  for(int i=0;i<=m;i++)
  {
    float t=tleft+tmax*float(i)/float(m);
    float x=0.0;
    for(int n=0;n<=nMax;n++)
    {
      x+=X[n]*cos(Omega[n]*t+PhiX[n]);
    }
    vertex(width*float(i)/float(m),0.5*height+x);
  }
  endShape();
  stroke(255,0,0,200);
  noFill();
  beginShape();
  for(int i=0;i<=m;i++)
  {
    float t=tleft+tmax*float(i)/float(m);
    float p=0.0;
    for(int n=0;n<=nMax;n++)
    {
      p+=P[n]*cos(Omega[n]*t+PhiP[n]);
    }
    vertex(width*float(i)/float(m),0.5*height+p);
  }
  endShape();
  if((mouseX-CircleX)*(mouseX-CircleX)+(mouseY-CircleY)*(mouseY-CircleY)<CircleR*CircleR)
  {
    OverCircle=true;  
    if(CircleLockedOn)
    { 
      stroke(255,255,255,255); 
      fill(0,0,255,255);
    } 
    else
    { 
      stroke(255,0,255,255); 
      fill(0,0,0,255);
    } 
  }
  else
  {
    stroke(255,0,0,100);
    fill(255,0,0,255);
    OverCircle=false;
  }
  ellipse(CircleX,CircleY,CircleR,CircleR);
  fill(255,255,255,255);
  PFont font;
  font = loadFont("TimesNewRomanPS-ItalicMT-18.vlw"); 
  textFont(font); 
  String s = "c";
  text(s,CircleX+1.5*CircleR,CircleY-0.5*CircleR);
  font = loadFont("Times-Roman-18.vlw"); 
  textFont(font); 
  s = "=";
  text(s,CircleX+2.0*CircleR,CircleY-0.5*CircleR);
  text(100.0*c,CircleX+2.5*CircleR,CircleY-0.5*CircleR);
  s = "%";
  text(s,CircleX+5.0*CircleR,CircleY-0.5*CircleR);
  s = "Frequency ratio =";
  text(s,CircleX+1.5*CircleR,CircleY+1.0*CircleR);
  text(OmegaNatural/(TWO_PI*meanFrequency),CircleX+8.0*CircleR,CircleY+1.0*CircleR);
}

void mousePressed()
{
  if(OverCircle)CircleLockedOn=true;
  else CircleLockedOn=false;
  CircleDiffX=mouseX-CircleX; 
  CircleDiffY=mouseY-CircleY; 
}

void mouseDragged()
{
  if(CircleLockedOn)
  {
    CircleX=mouseX-CircleDiffX; 
    CircleY=mouseY-CircleDiffY; 
    c=(CircleX-ZeroCirclePosition)*cScale;
    OmegaNatural=(CircleY-ZeroCirclePosition)*TWO_PI*FrequencyScale;
    CalculateValues();
  }
}

void mouseReleased()
{
  CircleLockedOn=false;
}

void CalculateValues()
{
  for(int n=0;n<=nMax;n++)
  {
    Omega[n]=TWO_PI*(minFrequency+(maxFrequency-minFrequency)*float(n)/float(nMax));
    float q=2.0*(Omega[n]-TWO_PI*(maxFrequency+minFrequency)/2.0)/(TWO_PI*(maxFrequency-minFrequency));
    P[n]=30.0*exp(-q*q)/sqrt(nMax);
    PhiP[n]=random(TWO_PI);
    float real=1.0-Omega[n]*Omega[n]/(OmegaNatural*OmegaNatural);
    float imaginary=2.0*c*Omega[n]/OmegaNatural;
    X[n]=P[n]/sqrt(real*real+imaginary*imaginary);
    PhiX[n]=PhiP[n]-atan2(imaginary,real);
  }
}



