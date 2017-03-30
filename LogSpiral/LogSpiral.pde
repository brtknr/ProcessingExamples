import processing.opengl.*;
float x[],y[],R0;
int LastPoint,MaxLastPoint=400;
void setup() 
{
  size(1200,700,OPENGL);
  smooth();
  x=new float[MaxLastPoint+1];
  y=new float[MaxLastPoint+1];
  R0=0.9*height/2.0;
  LastPoint=0;
  x[0]=R0;
  y[0]=0.0;
}
void draw() 
{   
  background(255,255,255);
  translate(width/2,height/2);
  LastPoint++;
  if(LastPoint>MaxLastPoint)LastPoint=1;
  float theta=4.0*TWO_PI*float(LastPoint)/float(MaxLastPoint);
  float R=R0*exp(-0.1*theta);
  x[LastPoint]=R*cos(theta);
  y[LastPoint]=R*sin(theta);
  for(int Point=1;Point<=LastPoint;Point++)
  {
    float factor=255*float(Point)/float(LastPoint);
    stroke(0,0,0,factor);
    line(x[Point-1],y[Point-1],x[Point],y[Point]);
  }
  noStroke();
  fill(0,0,255,255);
  ellipse(x[LastPoint],y[LastPoint],5,5);
}
