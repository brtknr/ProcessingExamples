//http://www.processing.org/
import processing.opengl.*;
int Lasti,Lastj,LastiSpecial,Intermediate,ShowNodes;
float[][][] Posn;
float[][][] Force;
float[][][] Vely;
int [] Fixed;
float scalefactor,Damping,Stiffness,Bending;
void setup()
{
  //size(1200,750,OPENGL);
  size(1200,750,P3D);
  smooth();
  frameRate(30);
  Intermediate=6;
  int Fine=3;
  Lasti=10*Fine*Intermediate;
  LastiSpecial=9*Fine*Intermediate;
  Lastj=20*Fine*Intermediate-1;
  ShowNodes=0;
  Fixed=new int[Lastj+1];
  for(int j=0;j<=Lastj;j++)Fixed[j]=0;
  Fixed[1*Fine*Intermediate]=1;
  Fixed[5*Fine*Intermediate]=1;
  Fixed[9*Fine*Intermediate]=1;
  Fixed[15*Fine*Intermediate]=1;
  Fixed[17*Fine*Intermediate]=1;
  Posn=new float[Lasti+1][Lastj+1][3];
  Force=new float[Lasti+1][Lastj+1][3];
  Vely=new float[Lasti+1][Lastj+1][3];
  scalefactor=10.0;
  Damping=0.99;
  Bending=10.0;
  Stiffness=5.0*(1.0+Bending);
  float border=10.0/scalefactor;
  for(int j=0;j<=Lastj;j++)
  {
    float Theta=TWO_PI*float(j)/float(Lastj+1);
    float Radius=(1.0+0.8*cos(Theta))*float(height)/(2.0*scalefactor)-5.0;
    for(int i=0;i<=Lasti;i++)
    {
      float Multiplier=float(i)/float(LastiSpecial);
      if(Multiplier>1.0)Multiplier=1.0;
      Posn[i][j][2]=(0.5-Multiplier)*float(height)/(2.0*scalefactor);
      Multiplier=Multiplier*Multiplier*Multiplier*Multiplier;
      Posn[i][j][0]=Radius*Multiplier*cos(Theta)-0.4*float(height)/(2.0*scalefactor);
      Posn[i][j][1]=Radius*Multiplier*sin(Theta);
      for(int xyz=0;xyz<=2;xyz++)
      {
        Force[i][j][xyz]=0.0;
        Vely[i][j][xyz]=0.0;
      }
    }
  }
}
float CircleX=100.0;
float CircleY=400.0;
float ToggleCircleY=20.0;
float OriginalCircleY=400.0;
float CircleR=10.0;
float BigCircleR=100.0;
int OverCircle=0;
int OverToggleCircle=0;
int LeftOrRight=0;
float CircleDiffX=0.0,CircleDiffY=0.0;
float zRot=0.0,xRot=0.0;
float LX=0.0,LXpressed=0.0,LY=0.0,LYpressed=0.0;
float xTrans=0.0,yTrans=0.0;
float RX=0.0,RXpressed=0.0,RY=0.0,RYpressed=0.0;
void draw()
{
  background(255,255,255);
  if((LX-CircleX)*(LX-CircleX)+(LY-CircleY)*(LY-CircleY)<BigCircleR*BigCircleR)
  {
    OverCircle=1;
    fill(255,0,0,255);
  }
  else
  {
    OverCircle=0;
    fill(0,0,255,255);
  }
  if((LX-CircleX)*(LX-CircleX)+(LY-ToggleCircleY)*(LY-ToggleCircleY)<BigCircleR*BigCircleR)
    OverToggleCircle=1;
  else OverToggleCircle=0;
  if(keyPressed)
  {
    if (key==' '){
      if(LeftOrRight==0)LeftOrRight=1;
      else LeftOrRight=0;
    }
  }
  if(mousePressed&&mouseButton==RIGHT)LeftOrRight=0;
  if(mousePressed&&mouseButton==LEFT)
  {
    if(OverCircle==1)
    {
      LXpressed=mouseX;
      LYpressed=mouseY;
      CircleY+=LYpressed-LY;
      scalefactor*=1.0-0.01*(LYpressed-LY);
      LX=LXpressed;
      LY=LYpressed;
    }
    else
    {
      if(OverToggleCircle==1)
      {
        if(LeftOrRight==0)LeftOrRight=1;
        else LeftOrRight=0;
      }
      else 
      {
        if(LeftOrRight==0)
        {
          LXpressed=mouseX;
          LYpressed=mouseY;
          zRot+=(LXpressed-LX)/300.0;
          xRot+=(LYpressed-LY)/300.0;
          LX=LXpressed;
          LY=LYpressed;
        }
      }
    }
  }
  else
  {
    LX=mouseX;
    LY=mouseY;
    CircleY=OriginalCircleY;
  }
  if(mousePressed&&(mouseButton==RIGHT||LeftOrRight==1))
  {
    RXpressed=mouseX;
    RYpressed=mouseY;
    xTrans+=(RXpressed-RX);
    yTrans+=(RYpressed-RY);
    RX=RXpressed;
    RY=RYpressed;
  }
  else
  {
    RX=mouseX;
    RY=mouseY;
  }
  noStroke();
  ellipse(CircleX,CircleY,CircleR,CircleR);
  if(OverToggleCircle==1)
  {
    fill(0,255,0,100);
    ellipse(CircleX,ToggleCircleY,1.5*CircleR,1.5*CircleR);
  }
  if(LeftOrRight==0)fill(255,0,255,255);
  else fill(0,0,255,255);
  ellipse(CircleX,ToggleCircleY,CircleR,CircleR);
  translate(float(width)/2.0,float(height)/2.0);
  rotateX(-xRot);
  rotateZ(-zRot);
  translate(xTrans*cos(zRot)-yTrans*sin(zRot),yTrans*cos(zRot)+xTrans*sin(zRot),yTrans*sin(xRot));
  scale(scalefactor);
  smooth();
  //strokeWeight(1.0/scalefactor);//OPENGL
  strokeWeight(1.0);//P3D
  stroke(0,0,0,128);
  for(int j=0;j<=Lastj;j+=Intermediate)
  {
    for(int i=0;i<=Lasti-1;i++)
      line(Posn[i][j][0],Posn[i][j][1],Posn[i][j][2],Posn[i+1][j][0],Posn[i+1][j][1],Posn[i+1][j][2]);
  }
  for(int i=Intermediate;i<=Lasti;i+=Intermediate)
  {
    for(int j=0;j<=Lastj;j++)
    {
      int nextj=j+1;
      if(nextj>Lastj)nextj-=Lastj+1;
      line(Posn[i][j][0],Posn[i][j][1],Posn[i][j][2],Posn[i][nextj][0],Posn[i][nextj][1],Posn[i][nextj][2]);
    }
  }
  if(ShowNodes!=0)
  {
    noStroke();
    for(int j=0;j<=Lastj;j+=Intermediate)
    {
      for(int i=1;i<=Lasti;i++)
      {
        if(i<LastiSpecial||Fixed[j]==0)fill(255,0,0);
        else fill(0,255,0);
        ellipse(Posn[i][j][0],Posn[i][j][1],4.0/scalefactor,4.0/scalefactor);
      }
    }
    for(int i=Intermediate;i<=Lasti;i+=Intermediate)
    {
      for(int j=0;j<=Lastj;j++)
      {
        if(j%Intermediate!=0)
          ellipse(Posn[i][j][0],Posn[i][j][1],4.0/scalefactor,4.0/scalefactor);
      }
    }
  }
  for(int j=0;j<=Lastj;j+=Intermediate)
  {
    for(int i=0;i<=Lasti;i++)
    {
      for(int xyz=0;xyz<=2;xyz++)Force[i][j][xyz]=0.0;
    }
  }
  for(int i=Intermediate;i<=Lasti;i+=Intermediate)
  {
    for(int j=0;j<=Lastj;j++)
    {
      for(int xyz=0;xyz<=2;xyz++)Force[i][j][xyz]=0.0;
    }
  }
  for(int j=0;j<=Lastj;j+=Intermediate)
  {
    for(int i=0;i<=Lasti-1;i++)
    {
      for(int xyz=0;xyz<=2;xyz++)
      {
        float temp=Posn[i+1][j][xyz]-Posn[i][j][xyz];
        Force[i  ][j][xyz]+=temp;
        Force[i+1][j][xyz]-=temp;
      }
    }
  }
  for(int i=Intermediate;i<=Lasti;i+=Intermediate)
  {
    for(int j=0;j<=Lastj;j++)
    {
      int nextj=j+1;
      if(nextj>Lastj)nextj-=Lastj+1;
      for(int xyz=0;xyz<=2;xyz++)
      {
        float temp=Posn[i][nextj][xyz]-Posn[i][j][xyz];
        Force[i][j    ][xyz]+=temp;
        Force[i][nextj][xyz]-=temp;
      }
    }
  }
  for(int j=0;j<=Lastj;j+=Intermediate)
  {
    for(int i=1;i<=Lasti-1;i++)
    {
      for(int xyz=0;xyz<=2;xyz++)
      {
        float temp=Bending*(Posn[i-1][j][xyz]-2.0*Posn[i][j][xyz]+Posn[i+1][j][xyz]);
        Force[i-1][j][xyz]-=temp;
        Force[i  ][j][xyz]+=2.0*temp;
        Force[i+1][j][xyz]-=temp;
      }
    }
  }
  for(int i=Intermediate;i<=Lasti;i+=Intermediate)
  {
    for(int j=0;j<=Lastj;j++)
    {
      if(i<LastiSpecial||Fixed[j]==0)
      {
        int prevj=j-1;
        if(prevj<0)prevj+=Lastj+1;
        int nextj=j+1;
        if(nextj>Lastj)nextj-=Lastj+1;
        for(int xyz=0;xyz<=2;xyz++)
        {
          float temp=Bending*(Posn[i][prevj][xyz]-2.0*Posn[i][j][xyz]+Posn[i][nextj][xyz]);
          Force[i][prevj][xyz]-=temp;
          Force[i][    j][xyz]+=2.0*temp;
          Force[i][nextj][xyz]-=temp;
        }
      }
    }
  }
  for(int j=0;j<=Lastj;j+=Intermediate)
  {
    for(int i=1;i<=Lasti;i++)
    {
      if(i<LastiSpecial||Fixed[j]==0)
      {
        float ThisStiffness=Stiffness;
        if(j%Intermediate==0)ThisStiffness=2.0*ThisStiffness;
        for(int xyz=0;xyz<=2;xyz++)
        {
          Vely[i][j][xyz]=Damping*Vely[i][j][xyz]+Force[i][j][xyz]/ThisStiffness;
          Posn[i][j][xyz]+=Vely[i][j][xyz];
        }
      }
    }
  }
  for(int i=Intermediate;i<=Lasti;i+=Intermediate)
  {
    for(int j=0;j<=Lastj;j++)
    {
      if(j%Intermediate!=0)
      {
        for(int xyz=0;xyz<=2;xyz++)
        {
          Vely[i][j][xyz]=Damping*Vely[i][j][xyz]+Force[i][j][xyz]/Stiffness;
          Posn[i][j][xyz]+=Vely[i][j][xyz];
        }
      }
    }
  }
  for(int xyz=0;xyz<=2;xyz++)
  {
    float AvPosn=0.0;
    float AvVely=0.0;
    for(int j=0;j<=Lastj;j++)
    {
      AvPosn+=Posn[1][j][xyz];
      AvVely+=Vely[1][j][xyz];
    }
    AvPosn=AvPosn/float(Lastj+1);
    AvVely=AvVely/float(Lastj+1);
    for(int j=0;j<=Lastj;j++)
    {
      Posn[1][j][xyz]=AvPosn;
      Vely[1][j][xyz]=AvVely;
    }
  }
}









