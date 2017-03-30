int n;
float R,Spin,mapscale;
void setup() 
{
  size(1200,600);
  smooth();
  n=16;
  R=0.45*height;
  Spin=0.0;
  mapscale=R/PI;
}
void draw() 
{   
  background(255,255,255);
  translate(width/2,height/2);
  noFill();
  Spin+=0.001;
  if(Spin>1.0)Spin-=1.0;
  float DrawingSpin=phiValue(Spin);
  strokeWeight(1.5);
  stroke(0,0,0,100);
  float  shift=width/4;
  for(int i=0;i<=n;i++)
  {
    float psi=PI*float(2*i-n)/float(2*n);
    float xpoint=R*cos(psi); 
    float ypoint=R*sin(psi);
    line(xpoint-shift,ypoint,-xpoint-shift,ypoint);
  }
  for(int i=0;i<=2*n-1;i++)
  {
    float phi=PI*float(i)/float(n)+DrawingSpin;
    if(sin(phi)>=0.0)
    {
      float cosphi=cos(phi);
      int this_n=100;
      beginShape();
      for(int j=0;j<=this_n;j++)
      {
        float psi=PI*float(2*j-this_n)/float(2*this_n);
        vertex(R*cos(psi)*cosphi-shift,R*sin(psi));
      }
      endShape();
    }
  }
  for(int i=0;i<=n;i++)
  {
    float psi=PI*float(2*i-n)/float(2*n);
    float xpoint=mapscale*PI; 
    float ypoint=mapscale*psi;
    line(xpoint+shift,ypoint,-xpoint+shift,ypoint);
  }
  for(int i=0;i<=2*n;i++)
  {
    float phi=PI*float(i-n)/float(n);
    float xpoint=mapscale*phi; 
    float ypoint=mapscale*HALF_PI;
    line(xpoint+shift,ypoint,xpoint+shift,-ypoint);
  }
  int Outline_n=100;
  strokeWeight(1);
  stroke(0,0,255,150);  
  beginShape();
  for(int i=0;i<=Outline_n;i++)
  {
    float psi=TWO_PI*float(i)/float(Outline_n);
    vertex(R*cos(psi)-shift,R*sin(psi));
  }
  endShape();
  int curve_n=1000;
  stroke(150,150,20,255);
  strokeWeight(5);
  int Drawing=0;
  for(int i=0;i<=curve_n;i++)
  {
    float t=float(i)/float(curve_n);
    float phi=phiValue(t)+DrawingSpin;
    if(sin(phi)>=0.0)
    {
      if(Drawing==0)beginShape();
      Drawing=1;
      float psi=psiValue(t);
      vertex(R*cos(psi)*cos(phi)-shift,R*sin(psi));
    }
    else
    {
      if(Drawing==1)endShape();
      Drawing=0;
    }
  }
  if(Drawing==1)endShape();
  strokeWeight(3);
  beginShape();
  for(int i=0;i<=curve_n;i++)
  {
    float t=float(i)/float(curve_n);
    float phi=phiValue(t);
    float psi=psiValue(t);
    vertex(mapscale*(phi-PI)+shift,-mapscale*psi);
  }
  endShape();
  stroke(255,0,0,255);
  fill(0,0,255,100);
  strokeWeight(2);
  ellipse(-shift,-R*sin(psiValue(Spin)),15,15);
  ellipse(mapscale*(phiValue(Spin)-PI)+shift,-mapscale*psiValue(Spin),10,10);
}

float phiValue(float t)
{
  return TWO_PI*(t+0.05*sin(8.0*PI*t));
}

float psiValue(float t)
{
  return 0.35*PI*cos(4.0*PI*t);
}



