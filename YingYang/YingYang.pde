import processing.opengl.*;
float x[][],R,Beta;
int LastPrevious,i,m;
void setup() 
{
  size(700,700,OPENGL);
  smooth();
  R=0.4*float(height);
  LastPrevious=800;
  x=new float[2][LastPrevious+1];
  for(int Previous=0;Previous<=LastPrevious;Previous++)
  {
    for(int i=0;i<=1;i++)x[i][Previous]=0.0;
  }
  Beta=0.8;
  i=0;
  m=1500;
  strokeWeight(1);
}
void draw() 
{   
  background(255,255,255);
  translate(width/2,height/2);
  float e=exp(3.5*sin(TWO_PI*float(i)/float(m)));
  float theta=HALF_PI+Beta*((e+1.0/e)/2.0-1.0);
  float r=R*(e-1.0/e)/(e+1.0/e);
  x[0][0]=+r*cos(theta);
  x[1][0]=-r*sin(theta);
  i++;
  if(i>m)i=-m;
  for(int Previous=LastPrevious;Previous>=1;Previous--)
  {
    for(int i=0;i<=1;i++)x[i][Previous]=x[i][Previous-1];
  }
  for(int Previous=0;Previous<=LastPrevious-1;Previous++)
  {
    stroke(0,0,0,(1.0-float(Previous)/float(LastPrevious))*255);
    line(x[0][Previous],x[1][Previous],x[0][Previous+1],x[1][Previous+1]);
  }
  noStroke();
  fill(255,0,0,255);
  ellipse(x[0][0],x[1][0],4,4);
}
