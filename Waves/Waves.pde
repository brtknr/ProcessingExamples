import processing.opengl.*;
int n=100,j,i,m;
float lambda[],omega[],PHI[],beta[],xmax,x,y,xPlot,yPlot,lastxPlot,lastyPlot,t,
minlambda,maxlambda,myscale,meanDepth,g,theta,sigmaSq,sigma,windSpeed,maximum,minimum;
void setup()
{
  size(1200,720,OPENGL);
  smooth();
  omega=new float[n+1];
  lambda=new float[n+1];
  PHI=new float[n+1];
  beta=new float[n+1];
  minlambda=0.1;
  maxlambda=1000.0;
  t=0.0;
  m=1000;
  xmax=200.0;
  myscale=width/xmax;
  meanDepth=50.0;
  windSpeed=20.0;
  g=9.81;
  for(j=0;j<=n;j++)
  {
    lambda[j]=1.0/pow(1.0/sqrt(maxlambda)+(1.0/sqrt(minlambda)-1.0/sqrt(maxlambda))*j/n,2);
    theta=TWO_PI*meanDepth/lambda[j];
    omega[j]=sqrt((g/meanDepth)*theta)*(1.0-exp(-2.0*theta)/(1.0+exp(-2.0*theta)));
    PHI[j]=(0.0081*g*g/pow(omega[j],5))*exp(-0.74*pow(omega[j]*windSpeed/g,-4));
    beta[j]=random(TWO_PI);
  }
  sigmaSq=0.0;
  for(j=0;j<=n-1;j++)
    sigmaSq+=((PHI[j]+PHI[j+1])/2.0)*abs(omega[j+1]-omega[j]);
  sigma=sqrt(sigmaSq);
  maximum=meanDepth;
  minimum=meanDepth;
  println("standard deviation = "+sigma);
}

void draw()
{
  background(255,255,255);
  t+=0.1;
  strokeWeight(2);
  stroke(200,200,200);
  line(0,height-myscale*meanDepth,width,height-myscale*meanDepth);
  line(0,height-myscale*(meanDepth+sigma),width,height-myscale*(meanDepth+sigma));
  line(0,height-myscale*(meanDepth-sigma),width,height-myscale*(meanDepth-sigma));
  strokeWeight(2);
  stroke(255,100,100);
  line(0,height-myscale*maximum,width,height-myscale*maximum);
  line(0,height-myscale*minimum,width,height-myscale*minimum);
  strokeWeight(3);
  stroke(50,50,150);
  for(i=0;i<=m;i++)
  {
    x=xmax*i/m;
    y=meanDepth;
    for(j=0;j<=n-1;j++)
      y+=sqrt((PHI[j]+PHI[j+1])*abs(omega[j+1]-omega[j]))
        *cos((TWO_PI*(1.0/lambda[j+1]+1.0/lambda[j])*x-(omega[j+1]+omega[j])*t+beta[j+1]+beta[j])/2.0);
    xPlot=myscale*x;
    yPlot=height-myscale*y;
    if(maximum<y)maximum=y;
    if(minimum>y)minimum=y;
    if(yPlot<0.0)yPlot=0.0;
    if(yPlot>height)yPlot=height;
    if(i!=0)line(xPlot,yPlot,lastxPlot,lastyPlot);
    lastxPlot=xPlot;
    lastyPlot=yPlot;
  }
}
