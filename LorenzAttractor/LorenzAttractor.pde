import processing.opengl.*;
float x_line[][],x[],xDot[],xDotDot[],xDotDotDot[],xDotDotDotDot[];
float xToPlot[],yToPlot[],a,theta,deltat,beta,ro,sigma,deltat2Over2,deltat3Over6,deltat4Over24;
int LastPrevious;
void setup() 
{
  size(800,800);
  smooth();
  theta=0.0;
  deltat=0.0005;
  a=12.0;
  LastPrevious = 4000;
  x_line=new float[3][LastPrevious+1];
  x=new float[3];
  xDot=new float[3];
  xDotDot=new float[3];
  xDotDotDot=new float[3];
  xDotDotDotDot=new float[3];
  xToPlot=new float[LastPrevious+1];
  yToPlot=new float[LastPrevious+1];
  x[0] = a;
  x[1] = a;
  x[2] = a;
  for(int Previous=0;Previous<=LastPrevious;Previous++)
  {
    x_line[0][Previous] = x[0];
    x_line[1][Previous] = x[1];
    x_line[2][Previous] = x[2];
  }
  deltat2Over2  = deltat * deltat / 2.0;
  deltat3Over6  = deltat * deltat * deltat / 6.0;
  deltat4Over24 = deltat * deltat * deltat * deltat / 24.0;
  strokeWeight(2);
  beta=8.0/3.0;
  ro=28.0;
  sigma=10.0;
}
void draw() 
{   
  background(255,255,255);
  translate(width/2,height/2);
  theta+=0.002;
  if(theta>TWO_PI)theta-=TWO_PI;
  float costheta=cos(theta);
  float sintheta=sin(theta);
  for(int innerLoop = 0;innerLoop <= 10; innerLoop++)
  {
    xDot[0] = sigma * (x[1] - x[0]);
    xDot[1] = ro * x[0] - (x[0] * x[2]) / a - x[1];
    xDot[2] = (x[0] * x[1]) / a - beta * x[2];

    xDotDot[0] = sigma * (xDot[1] - xDot[0]);
    xDotDot[1] = ro * xDot[0] - (xDot[0] * x[2] + x[0] * xDot[2]) / a - xDot[1];
    xDotDot[2] =                (xDot[0] * x[1] + x[0] * xDot[1]) / a - beta * xDot[2];

    xDotDotDot[0] = sigma * (xDotDot[1] - xDotDot[0]);
    xDotDotDot[1] = ro * xDotDot[0] - (xDotDot[0] * x[2] + 2.0 * xDot[0] * xDot[2] + x[0] * xDotDot[2]) / a - xDotDot[1];
    xDotDotDot[2] =                   (xDotDot[0] * x[1] + 2.0 * xDot[0] * xDot[1] + x[0] * xDotDot[1]) / a - beta * xDotDot[2];

    xDotDotDotDot[0] = sigma * (xDotDotDot[1] - xDotDotDot[0]);
    xDotDotDotDot[1] = ro * xDotDotDot[0] - (xDotDotDot[0] * x[2] + 3.0 * xDotDot[0] * xDot[2] + 3.0 * xDot[0] * xDotDot[2] + x[0] * xDotDotDot[2]) / a - xDotDotDot[1];
    xDotDotDotDot[2] =                      (xDotDotDot[0] * x[1] + 3.0 * xDotDot[0] * xDot[1] + 3.0 * xDot[0] * xDotDot[1] + x[1] * xDotDotDot[1]) / a - beta * xDotDotDot[2];

    for(int i = 0;i <= 2;i ++)x[i] += xDot[i] * deltat + xDotDot[i] * deltat2Over2 + xDotDotDot[i] * deltat3Over6 + xDotDotDotDot[i] * deltat4Over24;
  }
  for(int i = 0;i <= 2;i ++)x_line[i][0] = x[i];
  for(int Previous = LastPrevious;Previous >= 1;Previous --)
  {
    for(int i = 0;i <= 2;i ++)x_line[i][Previous] = x_line[i][Previous-1];
  }

  for(int Previous=0;Previous<=LastPrevious;Previous++)
  {
    xToPlot[Previous]=x_line[0][Previous]*costheta+x_line[1][Previous]*sintheta;
    yToPlot[Previous]=-x_line[2][Previous]+25.0*a;
  }
  for(int Previous=0;Previous<=LastPrevious-1;Previous++)
  {
    float factor=1.0-float(Previous)/float(LastPrevious);
    if(factor < 0.0)factor = 0.0;
    stroke(0,0,255*(1.0-factor),255*sqrt(factor));
    line(xToPlot[Previous],yToPlot[Previous],xToPlot[Previous+1],yToPlot[Previous+1]);
  }
  noStroke();
  fill(255,0,0,255);
  ellipse(xToPlot[0],yToPlot[0],8,8);
}

