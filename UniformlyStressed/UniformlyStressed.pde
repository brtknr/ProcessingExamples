//http://www.processing.org/
import processing.opengl.*;
int Lasti,Middlei;
float[] r;
float[] z;
float[] zDot;
float[] rDot;
float[] zDash;
float[] rDash;
float[] xOffset;
float[] yOffset;
float a;
float[] CircleX;
float[] CircleY;
float CircleR=10.0;
float BigCircleR=10.0;
int[] OverCircle;
float LX=0.0,LXpressed=0.0,LY=0.0,LYpressed=0.0;
float CentreOfCurvature;
void setup()
{
  //size(1200,750,OPENGL);
  size(1200,750,P3D);
  smooth();
  frameRate(30);
  Middlei=50;
  Lasti=2*Middlei+1;//must be odd to avoid r = 0
  r=new float[Lasti+1];
  z=new float[Lasti+1];
  rDash=new float[Lasti+1];
  zDash=new float[Lasti+1];
  rDot=new float[Lasti+1];
  zDot=new float[Lasti+1];
  xOffset=new float[Lasti+1];
  yOffset=new float[Lasti+1];
  CircleX=new float[2];
  CircleY=new float[2];
  OverCircle=new int[2];
  r[0]=(0.5-0.3)*float(width);
  r[Lasti]=float(width)-r[0];
  a=0.46*(r[Lasti]-r[0]);
  for(int i=0;i<=Lasti;i++)
  {
    r[i]=r[0]+(r[Lasti]-r[0])*float(i)/float(Lasti);
    z[i]=-0.9*float(height);
    rDot[i]=0.0;
    zDot[i]=0.0;
  }
  CircleX[0]=r[0];
  CircleY[0]=-z[0];
  CircleX[1]=(r[0]+r[Lasti])/2.0-a;
  CentreOfCurvature=z[0];
  CircleY[1]=CentreOfCurvature;
  strokeWeight(1.0);
}
void draw()
{
  background(255,255,255);
  noStroke();
  for(int Circle=0;Circle<=1;Circle++)
  {
    if((LX-CircleX[Circle])*(LX-CircleX[Circle])+(LY-CircleY[Circle])*(LY-CircleY[Circle])<BigCircleR*BigCircleR)
    {
      OverCircle[Circle]=1;
      fill(255,0,0,255);
    }
    else
    {
      OverCircle[Circle]=0;
      fill(0,0,255,255);
    }
    if(mousePressed&&mouseButton==LEFT)
    {
      if(OverCircle[Circle]==1)
      {
        LXpressed=mouseX;
        LYpressed=mouseY;
        CircleX[Circle]+=LXpressed-LX;
        CircleY[Circle]+=LYpressed-LY;
        LX=LXpressed;
        LY=LYpressed;
        for(int i=1;i<=Lasti-1;i++)zDot[i]=0.0;
      }
    }
    else
    {
      LX=mouseX;
      LY=mouseY;
      CircleY[1]=-CentreOfCurvature;
    }
    ellipse(CircleX[Circle],CircleY[Circle],CircleR,CircleR);
  }
  r[0]=CircleX[0];
  r[Lasti]=float(width)-r[0];
  z[0]=-CircleY[0];
  z[Lasti]=-CircleY[0];
  a=(r[0]+r[Lasti])/2.0-CircleX[1];
  for(int i=1;i<=Lasti-1;i++)
  {
    rDash[i]=(r[i+1]-r[i-1])/2.0;//Even
    zDash[i]=(z[i+1]-z[i-1])/2.0;//Odd
    float rDashDash=r[i+1]-2.0*r[i]+r[i-1];//Odd
    float zDashDash=z[i+1]-2.0*z[i]+z[i-1];//Even
    float factor=zDash[i]/r[i]+rDash[i]/a;//Even
    float rforce=rDashDash-zDash[i]*factor;//Odd
    float zforce=zDashDash+rDash[i]*factor;//Even
    rDot[i]=0.98*rDot[i]+0.5*rforce;
    zDot[i]=0.98*zDot[i]+0.5*zforce;
  }
  for(int i=1;i<=Lasti-1;i++)
  {
    r[i]+=rDot[i];
    z[i]+=zDot[i];
  }
  for(int i=1;i<=Lasti-1;i++)//This averaging seems the only way to maintain symmetry
  {
    if(i<=Middlei)
    {
      r[i]=(r[i]-r[Lasti-i]+r[0]+r[Lasti])/2.0;
      z[i]=(z[i]+z[Lasti-i])/2.0;
    }
    else
    {
      r[i]=-r[Lasti-i]+r[0]+r[Lasti];
      z[i]=z[Lasti-i];
    }
  }
  rDash[0]=rDash[1];
  rDash[Lasti]=rDash[Lasti-1];
  zDash[0]=zDash[1];
  zDash[Lasti]=zDash[Lasti-1];
  for(int i=0;i<=Lasti;i++)
  {
    float cosine=rDash[i]/sqrt(rDash[i]*rDash[i]+zDash[i]*zDash[i]);
    float sine=cosine*zDash[i]/rDash[i];
    float Thickness=0.015*a*exp(-(z[i]-(z[Middlei]+z[Middlei+1])/2.0)/a);
    xOffset[i]=Thickness*sine;
    yOffset[i]=-Thickness*cosine;
  }
  stroke(0,0,0,200);
  noFill();
  beginShape();
  for(int i=0;i<=Lasti;i++)vertex(r[i],-z[i]);
  endShape();
  stroke(255,0,255,200);
  beginShape();
  fill(100,100,255,50);
  vertex(r[0]-xOffset[0],-z[0]+yOffset[0]);
  for(int i=0;i<=Lasti;i++)vertex(r[i]+xOffset[i],-z[i]-yOffset[i]);
  for(int i=Lasti;i>=0;i--)vertex(r[i]-xOffset[i],-z[i]+yOffset[i]);
  endShape(CLOSE);
  noFill();
  stroke(0,0,0,50);
  CentreOfCurvature=(z[Middlei]+z[Middlei+1])/2.0-a;
  ellipse((r[0]+r[Lasti])/2.0,-CentreOfCurvature,2.0*a,2.0*a);
  line(float(width)/2.0,float(height),float(width)/2.0,0.0);
  noStroke();
  fill(0,0,255,255);
  int dotsize=3;
  for(int i=1;i<=Lasti-1;i++)ellipse(r[i],-z[i],dotsize,dotsize);
  fill(255,0,0,255);
  dotsize=5;
  ellipse(r[0],-z[0],dotsize,dotsize);
  ellipse(r[Lasti],-z[Lasti],dotsize,dotsize);
}







