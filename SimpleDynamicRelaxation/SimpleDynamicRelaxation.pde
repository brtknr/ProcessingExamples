//http://www.processing.org/
//This program uses Alistair Day's Dynamic Relaxation technique
//Simplified version of the Verlet algorithm
//import processing.opengl.*;
float[][] Coord;
float[][] Force;
float[][] Veloc;
float[] Stiffness;
float[] EA_over_L0;
float[] T0_minus_EA;
float[] delta;
int [][] End;
int[] Fixed;
float scalefactor;
int LastMember,LastNode;
void setup()
{
  //size(1200,750,OPENGL);
  size(1200,750,P3D);
  //size(int(0.9*float(screen.width)),int(0.9*float(screen.height)),P3D);
  smooth();
  textFont(createFont("Arial",24));
  frameRate(30);
  textMode(SCREEN);
  int m=2*10;//Must be even;
  LastNode=(m+1)*(m+1)-1;
  Coord = new float[LastNode+1][3];
  Force = new float[LastNode+1][3];
  Veloc = new float[LastNode+1][3];
  Stiffness = new float[LastNode+1];
  Fixed = new int[LastNode+1];
  delta = new float[3];
  LastMember=4*m+m*m-1;
  EA_over_L0 = new float[LastMember+1];
  T0_minus_EA = new float[LastMember+1];
  End = new int[LastMember+1][2];
  scalefactor=10.0;
  float a=float(height)/(1.5*2.0*scalefactor);
  {
    int Node=-1;
    for(int j=0;j<=m;j++)
    {
      for(int i=0;i<=m;i++)
      {
        Node++;
        Coord[Node][0]=a*float(2*i-m)/float(m);//nodes in x direction
        Coord[Node][1]=a*float(2*j-m)/float(m);//nodes in y direction
        Coord[Node][2]=0.2*Coord[Node][0]*Coord[Node][1]/a;//relative difference in height, higher the initial value, greater the difference
        if(Node==0||Node==m||Node==LastNode||Node==LastNode-m)Fixed[Node]=1;
        if(Fixed[Node]==0){
          for(int xyz=0;xyz<=2;xyz++)Coord[Node][xyz]*=0.2;
        }
      }
    }
    println("Check on last node number: Should be " + Node + " and is "+ LastNode);
  }
  {
    float NetEA_over_L0=1.0;
    float NetT0_minus_EA=-NetEA_over_L0*a/float(m);
    float EdgeEA_over_L0=2.0*float(m)*NetEA_over_L0;
    float EdgeT0_minus_EA=0.0;
    int Member=-1;
    for(int i=0;i<=m-1;i++)
    {
      Member++;
      EA_over_L0[Member]=EdgeEA_over_L0;
      T0_minus_EA[Member]=EdgeT0_minus_EA;
      End[Member][0]=i;
      End[Member][1]=i+1;
      Member++;
      EA_over_L0[Member]=EdgeEA_over_L0;
      T0_minus_EA[Member]=EdgeT0_minus_EA;
      End[Member][0]=LastNode-m+i;
      End[Member][1]=LastNode-m+i+1;
    }
    for(int j=0;j<=m-1;j++)
    {
      Member++;
      EA_over_L0[Member]=EdgeEA_over_L0;
      T0_minus_EA[Member]=EdgeT0_minus_EA;
      End[Member][0]=j*(m+1);
      End[Member][1]=(j+1)*(m+1);
      Member++;
      EA_over_L0[Member]=EdgeEA_over_L0;
      T0_minus_EA[Member]=EdgeT0_minus_EA;
      End[Member][0]=j*(m+1)+m;
      End[Member][1]=(j+1)*(m+1)+m;
    }
    for(int j=0;j<=m-1;j+=2)
    {
      for(int i=0;i<=m-1;i+=2)
      {
        Member++;
        EA_over_L0[Member]=NetEA_over_L0;
        T0_minus_EA[Member]=NetT0_minus_EA;
        End[Member][0]=j*(m+1)+i;
        End[Member][1]=(j+1)*(m+1)+i+1;
      }
    }
    for(int j=0;j<=m-1;j+=2)
    {
      for(int i=1;i<=m-1;i+=2)
      {
        Member++;
        EA_over_L0[Member]=NetEA_over_L0;
        T0_minus_EA[Member]=NetT0_minus_EA;
        End[Member][0]=j*(m+1)+i+1;
        End[Member][1]=(j+1)*(m+1)+i;
      }
    }
    for(int j=1;j<=m-1;j+=2)
    {
      for(int i=1;i<=m-1;i+=2)
      {
        Member++;
        EA_over_L0[Member]=NetEA_over_L0;
        T0_minus_EA[Member]=NetT0_minus_EA;
        End[Member][0]=j*(m+1)+i;
        End[Member][1]=(j+1)*(m+1)+i+1;
      }
    }
    for(int j=1;j<=m-1;j+=2)
    {
      for(int i=0;i<=m-1;i+=2)
      {
        Member++;
        EA_over_L0[Member]=NetEA_over_L0;
        T0_minus_EA[Member]=NetT0_minus_EA;
        End[Member][0]=j*(m+1)+i+1;
        End[Member][1]=(j+1)*(m+1)+i;
      }
    }
    println("Check on last member number: Should be " + Member + " and is "+ LastMember);
  }
  for(int Node=0;Node<=LastNode;Node++)Stiffness[Node]=0.0;
  for(int Member=0;Member<=LastMember;Member++)
  {
    Stiffness[End[Member][0]]+=EA_over_L0[Member];
    Stiffness[End[Member][1]]+=EA_over_L0[Member];
  }
}
float TextX=100.0;
float TextY=400.0;
float OriginalTextY=400.0;
float TextRegion=100.0;
int OverText=0;
float zRot=0.0,xRot=0.0;
float MyMouseX=0.0,MyMouseXpressed=0.0,MyMouseY=0.0,MyMouseYpressed=0.0;
float xTrans=0.0,yTrans=0.0;
void draw()
{
  background(0,0,0);
  if(mousePressed)
  {
    MyMouseXpressed=mouseX;
    MyMouseYpressed=mouseY;
    if(OverText==1)
    {
      TextY+=MyMouseYpressed-MyMouseY;
      scalefactor*=1.0-0.01*(MyMouseYpressed-MyMouseY);
    }
    else
    {
      if(mouseButton==LEFT)
      {
        zRot+=(MyMouseXpressed-MyMouseX)/300.0;
        xRot+=(MyMouseYpressed-MyMouseY)/300.0;
      }
      else
      {
        xTrans+=(MyMouseXpressed-MyMouseX);
        yTrans+=(MyMouseYpressed-MyMouseY);
      }
      TextY=OriginalTextY;
    }
    MyMouseX=MyMouseXpressed;
    MyMouseY=MyMouseYpressed;
  }
  else
  {
    MyMouseX=mouseX;
    MyMouseY=mouseY;
    TextY=OriginalTextY;
    if((MyMouseX-TextX)*(MyMouseX-TextX)+(MyMouseY-TextY)*(MyMouseY-TextY)<TextRegion*TextRegion)
    {
      OverText=1;
      fill(200,0,0,255);
    }
    else
    {
      OverText=0;
      fill(255,255,255,255);
    }
  }
  for(int Node=0;Node<=LastNode;Node++)
  {
    for(int xyz=0;xyz<=2;xyz++)Force[Node][xyz]=0.0;
  }
  for(int Member=0;Member<=LastMember;Member++)
  {
    float LengthSq=0.0;
    for(int xyz=0;xyz<=2;xyz++)
    {
      delta[xyz]=Coord[End[Member][1]][xyz]-Coord[End[Member][0]][xyz];
      LengthSq+=delta[xyz]*delta[xyz];
    }
    //Tension = T = T0 + (EA/L0)*(L - L0)
    //TensionCoefficient = T/L = EA/L0 + (T0 - EA)/L
    float TensionCoefficient=EA_over_L0[Member];
    if(T0_minus_EA[Member]!=0.0)TensionCoefficient+=T0_minus_EA[Member]/sqrt(LengthSq);
    for(int xyz=0;xyz<=2;xyz++)
    {
      float ForceComponent=TensionCoefficient*delta[xyz];
      Force[End[Member][0]][xyz]+=ForceComponent;
      Force[End[Member][1]][xyz]-=ForceComponent;
    }
  }
  for(int Node=0;Node<=LastNode;Node++)
  {
    if(Fixed[Node]==0)
    {
      for(int xyz=0;xyz<=2;xyz++)
      {
        Veloc[Node][xyz]=0.99*Veloc[Node][xyz]+Force[Node][xyz]/Stiffness[Node];
        Coord[Node][xyz]+=Veloc[Node][xyz];
      }
    }
  }
  text("Zoom",TextX,TextY);
  translate(float(width)/2.0,float(height)/2.0);
  ortho(-float(width)/2.0,float(width)/2.0,-float(height)/2.0,float(height)/2.0,-width,width);
  rotateX(-xRot);
  rotateZ(-zRot);
  translate(xTrans*cos(zRot)-yTrans*sin(zRot),yTrans*cos(zRot)+xTrans*sin(zRot),yTrans*sin(xRot));
  scale(scalefactor);
  smooth();
  //strokeWeight(1.0/scalefactor);//OPENGL
  strokeWeight(1.0);//P3D
  stroke(255,255,255,100);
  for(int Member=0;Member<=LastMember;Member++)
  {
    line(Coord[End[Member][0]][0],Coord[End[Member][0]][1],Coord[End[Member][0]][2],
    Coord[End[Member][1]][0],Coord[End[Member][1]][1],Coord[End[Member][1]][2]);
  }
}

