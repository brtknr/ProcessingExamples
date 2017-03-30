int LastNode=50;
float[][] Force,Veloc,Coord;
float[] deltaCoord,mymouse;
float L,delta_s,AxialStiffnessFactor,BendingStiffnessFactor,Damping,Stiffness;
void setup()
{
  size(1200,750,P2D);
  smooth();
  textMode(SCREEN);
  textFont(createFont("Arial",24));
  frameRate(30);
  L=0.9*width;
  delta_s=L/float(LastNode);
  deltaCoord=new float[2];  
  mymouse=new float[2];
  Coord=new float[LastNode+1][2];
  Veloc=new float[LastNode+1][2];
  Force=new float[LastNode+1][2];
  for(int Node=0;Node<=LastNode;Node++)
  {
    Veloc[Node][0]=0.0;
    Veloc[Node][1]=0.0;
    Coord[Node][0]=float(Node)*delta_s;
    Coord[Node][1]=float(Node)*float(Node)*float(Node)*delta_s/(3.0*float(LastNode)*float(LastNode));
  }
  float YoungsModulus=1.0;
  float Diameter=L/2.0;
  float Damping=500.0;
  AxialStiffnessFactor=YoungsModulus*PI*(Diameter*Diameter/4.0)/(delta_s*delta_s);
  BendingStiffnessFactor=YoungsModulus*PI*(Diameter*Diameter*Diameter*Diameter/64.0)/(delta_s*delta_s*delta_s*delta_s);
  Stiffness=5.0*YoungsModulus*PI*(Diameter*Diameter/4.0)/delta_s;
}
void draw()
{
  background(255,255,255);
  fill(0,0,0,100);
  text("Tip will follow mouse when it is pressed.",0.6*width,0.1*height);
  float shiftX=0.05*width;
  float shiftY=0.5*height;
  translate(shiftX,shiftY);
  mymouse[0]=mouseX-shiftX-5; 
  mymouse[1]=mouseY-shiftY-5;
  for(int intermediate=0;intermediate<=100;intermediate++)
  {
    for(int Node=0;Node<=LastNode;Node++)
    {
      Force[Node][0]=0.0;
      Force[Node][1]=0.0;
    }
    for(int Node=1;Node<=LastNode-1;Node++)
    {
      for(int xy=0;xy<=1;xy++)
      {
        float ThisForce=(Coord[Node+1][xy]-2.0*Coord[Node][xy]+Coord[Node-1][xy]
          +Damping*(Veloc[Node+1][xy]-2.0*Veloc[Node][xy]+Veloc[Node-1][xy]))
          *BendingStiffnessFactor/6.0;
        Force[Node-1][xy]-=ThisForce;
        Force[Node+0][xy]+=2.0*ThisForce;
        Force[Node+1][xy]-=ThisForce;
      }
    }
    for(int Node=0;Node<=LastNode-1;Node++)
    {
      float ElementLength=0.0;
      float RateofIncreaseofLength=0.0;   
      for(int xy=0;xy<=1;xy++)
      {
        deltaCoord[xy]=Coord[Node+1][xy]-Coord[Node][xy];
        ElementLength+=deltaCoord[xy]*deltaCoord[xy];
        RateofIncreaseofLength+=deltaCoord[xy]*(Veloc[Node+1][xy]-Veloc[Node][xy]);
      }
      ElementLength=sqrt(ElementLength);
      RateofIncreaseofLength=RateofIncreaseofLength/ElementLength;
      float tensionCoefficient=(ElementLength-delta_s+Damping*RateofIncreaseofLength)*AxialStiffnessFactor;
      for(int xy=0;xy<=1;xy++)
      {
        float ThisForce=tensionCoefficient*deltaCoord[xy];
        Force[Node+0][xy]+=ThisForce;
        Force[Node+1][xy]-=ThisForce;
      }
    }
    for(int Node=2;Node<=LastNode;Node++)
    {
      for(int xy=0;xy<=1;xy++)
      {
        Veloc[Node][xy]=0.999*Veloc[Node][xy]+Force[Node][xy]/Stiffness;
        Coord[Node][xy]+=Veloc[Node][xy];
      }
    }
    if(mousePressed)
    {
      for(int xy=0;xy<=1;xy++)Veloc[LastNode][xy]+=0.01*(mymouse[xy]-Coord[LastNode][xy]);
    }
  }
  stroke(0,0,0,200); 
  noFill();
  strokeWeight(1.0);
  for(int dash=-10;dash<=10;dash++)line(0.0,0.01*L*dash,-0.01*L,0.01*L*(dash+1));
  strokeWeight(1.5);
  line(0.0,0.1*L,0.0,-0.1*L);
  beginShape();
  for(int Node=0;Node<=LastNode;Node++)vertex(Coord[Node][0],Coord[Node][1]);
  endShape();
  strokeWeight(1.0);
  stroke(255,0,0,255);
  fill(255,0,0,255);
  ellipse(Coord[LastNode][0],Coord[LastNode][1],8,8);
  stroke(0,0,0,200); 
  noFill();
  ellipse(mymouse[0],mymouse[1],10,10);
}











