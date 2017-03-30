int LastNode = 10,LastButton = 2;
int[] MouseOn;
float[][] Force,Veloc,Coord,mymouse;
float[] deltaCoord;
float delta_L,AxialStiffnessFactor,BendingStiffnessFactor,Damping,
freqtime,frequency,delta_t,OneOverNodeMass,
MassDisplacement,MassVelocity,MassStiffness,MassDamping,TunedMass,MassStiffnessFactor,MassDampingFactor;
void setup()
{
  size(1200,750,P2D);
  smooth();
  textMode(SCREEN);
  textFont(createFont("Arial",18));
  frameRate(30);
  float L = 0.9 * height;
  delta_L = L / (float)LastNode;
  float BuildingMass = 1.0;
  float NodeMass = BuildingMass / (float)(LastNode + 1);
  OneOverNodeMass = 1.0 / NodeMass;

  MouseOn = new int[LastButton + 1];
  deltaCoord = new float[2]; 
  mymouse = new float[LastButton + 1][2];
  Coord = new float[LastNode + 1][2];
  Veloc = new float[LastNode + 1][2];
  Force = new float[LastNode + 1][2];
  for(int Node = 0;Node <= LastNode;Node ++)
  {
    Veloc[Node][0] = 0.0;
    Veloc[Node][1] = 0.0;
    Coord[Node][0] = 0.0;
    Coord[Node][1] = float(Node) * delta_L;
  }

  float YoungsModulus = 1.0;
  float Diameter = L / 2.0;
  Damping = 0.00001;
  AxialStiffnessFactor = YoungsModulus * PI * (Diameter * Diameter / 4.0) / (delta_L * delta_L);
  BendingStiffnessFactor = YoungsModulus * PI * (Diameter * Diameter * Diameter * Diameter / 64.0) / (delta_L * delta_L * delta_L * delta_L);

  TunedMass = BuildingMass / 100.0;
  MassDisplacement = 0.0;
  MassVelocity = 0.0;
  MassStiffness = 0.0;
  MassDamping = 0.0;
  MassStiffnessFactor = 0.000002 * YoungsModulus * PI * (Diameter * Diameter * Diameter * Diameter / 64.0) /(L * L * L);
  MassDampingFactor = 10.0 * sqrt(MassStiffnessFactor * TunedMass);

  delta_t = 1.0 * sqrt(NodeMass / (AxialStiffnessFactor * delta_L));

  freqtime = 0.0;
  frequency = 0.0;
  mymouse[0][0] = - 0.4 * width; 
  mymouse[0][1] = 0.0;
  mymouse[1][0] = - 0.3 * width; 
  mymouse[1][1] = 0.0;
  mymouse[2][0] = - 0.2 * width; 
  mymouse[2][1] = 0.0;
}
void draw()
{
  background(255,255,255);
  fill(0,0,0,100);
  float shiftX = 0.5 * width;
  float shiftY = 0.95 * height;
  text("Move mouse to change frequency of load\nand properties of tuned mass damper.\nMass of tuned mass = 1% of building mass.",0.7 * width,0.9 * height);
  text("Load\nfrequency",mymouse[0][0] + shiftX + 5,mymouse[0][1] + shiftY);
  text("Tuned mass\nstiffness",mymouse[1][0] + shiftX + 5,mymouse[1][1] + shiftY);
  text("Tuned mass\ndamping",mymouse[2][0] + shiftX + 5,mymouse[2][1] + shiftY);
  translate(shiftX,shiftY);
  if(mousePressed == false)
  {
    for(int Button = 0;Button <= LastButton;Button ++)
    {
      if((mymouse[Button][0] - mouseX + shiftX) * (mymouse[Button][0] - mouseX + shiftX) +
        (mymouse[Button][1] - mouseY + shiftY) * (mymouse[Button][1] - mouseY + shiftY) < 400)
        MouseOn[Button] = 1;
      else MouseOn[Button] = 0;
    }
  }
  if(mousePressed == true)
  {
    for(int Button = 0;Button <= LastButton;Button ++)
    {
      if(MouseOn[Button] == 1)
      {
        mymouse[Button][1] = mouseY - shiftY - 5;
        if(mymouse[Button][1] > 0.0) mymouse[Button][1] = 0.0;
        if(Button == 0) frequency = 0.015 * mymouse[Button][1] * mymouse[Button][1] / (float) (height * height);
        if(Button == 1) MassStiffness = abs(MassStiffnessFactor * mymouse[Button][1] / (float) height);
        if(Button == 2) MassDamping = abs(MassDampingFactor * mymouse[Button][1] / (float) height);
      }
    }
  }

  float Load = 0.0;
  for(int intermediate = 0;intermediate <= 50;intermediate ++)
  {
    freqtime += abs(frequency);
    if(freqtime > TWO_PI)freqtime -= TWO_PI;
    Load = 10.0 * cos(freqtime);
    for(int Node = 0;Node <= LastNode;Node ++)
    {
      Force[Node][0] = 0.001 * Load;
      Force[Node][1] = 0.0;
    }

    float ForceOnMass = (Coord[LastNode][0] - MassDisplacement) * MassStiffness +
      (Veloc[LastNode][0] - MassVelocity) * MassDamping;
    Force[LastNode][0] -= ForceOnMass;

    for(int Node = 1;Node <= LastNode - 1;Node ++)
    {
      for(int xy = 0;xy <= 1;xy ++)
      {
        float ThisForce = (Coord[Node + 1][xy] - 2.0 * Coord[Node][xy] + Coord[Node - 1][xy]
          + Damping * (Veloc[Node + 1][xy] - 2.0 * Veloc[Node][xy] + Veloc[Node - 1][xy]))
          * BendingStiffnessFactor / 6.0;
        Force[Node - 1][xy] -= ThisForce;
        Force[Node + 0][xy] += 2.0 * ThisForce;
        Force[Node + 1][xy] -= ThisForce;
      }
    }
    for(int Node = 0;Node <= LastNode - 1;Node ++)
    {
      float ElementLength = 0.0;
      float RateofIncreaseofLength = 0.0;   
      for(int xy = 0;xy <= 1;xy ++)
      {
        deltaCoord[xy] = Coord[Node + 1][xy] - Coord[Node][xy];
        ElementLength += deltaCoord[xy] * deltaCoord[xy];
        RateofIncreaseofLength += deltaCoord[xy] * (Veloc[Node + 1][xy] - Veloc[Node][xy]);
      }
      ElementLength = sqrt(ElementLength);
      RateofIncreaseofLength = RateofIncreaseofLength / ElementLength;
      float tensionCoefficient = (ElementLength - delta_L + Damping * RateofIncreaseofLength) * AxialStiffnessFactor;
      for(int xy = 0;xy <= 1;xy ++)
      {
        float ThisForce = tensionCoefficient * deltaCoord[xy];
        Force[Node + 0][xy] += ThisForce;
        Force[Node + 1][xy] -= ThisForce;
      }
    }
    for(int Node = 2;Node <= LastNode;Node ++)
    {
      for(int xy = 0;xy <= 1;xy ++)
      {
        Veloc[Node][xy] += Force[Node][xy] * delta_t * OneOverNodeMass;
        Coord[Node][xy] += Veloc[Node][xy] * delta_t;
      }
    }
    MassVelocity += ForceOnMass * delta_t / TunedMass;
    MassDisplacement += MassVelocity;
  }
  stroke(0,0,0,200); 
  noFill();
  strokeWeight(1.0);
  for(int dash =  - 10;dash <= 10;dash ++)line(0.01 * height * dash,0.0,0.01 * height * (dash + 1),0.01 * height);
  strokeWeight(1.5);
  line(0.1 * height,0.0, - 0.45 * width,0.0);
  beginShape();
  for(int Node = 0;Node <= LastNode;Node ++)vertex(Coord[Node][0], - Coord[Node][1]);
  endShape();
  strokeWeight(1.0);
  stroke(255,0,0,255);
  fill(255,0,0,255);
  for(int Node = 1;Node <= LastNode;Node ++)
  {
    ellipse(Coord[Node][0] + Load, - Coord[Node][1],5,5);
    line(Coord[Node][0], - Coord[Node][1],Coord[Node][0] + Load, - Coord[Node][1]);
  }
  for(int Button = 0;Button <= LastButton;Button ++)
  {
    if(MouseOn[Button] == 1)
    {
      stroke(255,0,0,255);
      fill(255,0,0,255);
    }
    else
    {
      stroke(0,0,255,255);
      fill(0,0,255,255);
    }
    ellipse(mymouse[Button][0],mymouse[Button][1],5,5);
  }
  stroke(0,0,255,255);
  fill(0,0,255,255);
  ellipse(MassDisplacement,-Coord[LastNode][1],15,15);
  line(Coord[LastNode][0],-Coord[LastNode][1],MassDisplacement,-Coord[LastNode][1]);
}







