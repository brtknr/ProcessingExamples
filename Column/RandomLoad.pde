int LastNode = 10;
int FirstFrequencyComponent = 10;
int LastFrequencyComponent = 1000;
float[][] Force,Veloc,Coord;
float[] deltaCoord,phaseShift;
float L,delta_s,AxialStiffnessFactor,BendingStiffnessFactor,Damping,Stiffness,freqtime,BaseFrequency;
void setup()
{
  size(1200,750,P2D);
  smooth();
  frameRate(30);
  L = 0.9 * height;
  delta_s = L / float(LastNode);
  deltaCoord = new float[2];
  phaseShift = new float[LastFrequencyComponent - FirstFrequencyComponent + 1];
  Coord = new float[LastNode + 1][2];
  Veloc = new float[LastNode + 1][2];
  Force = new float[LastNode + 1][2];
  for(int Node = 0;Node <= LastNode;Node ++)
  {
    Veloc[Node][0] = 0.0;
    Veloc[Node][1] = 0.0;
    Coord[Node][0] = 0.0;
    Coord[Node][1] = float(Node) * delta_s;
  }
  float YoungsModulus = 1.0;
  float Diameter = L / 2.0;
  Damping = 0.0;
  AxialStiffnessFactor = YoungsModulus * PI * (Diameter * Diameter / 4.0) / (delta_s * delta_s);
  BendingStiffnessFactor = YoungsModulus * PI * (Diameter * Diameter * Diameter * Diameter / 64.0) / (delta_s * delta_s * delta_s * delta_s);
  Stiffness = 5.0 * YoungsModulus * PI * (Diameter * Diameter / 4.0) / delta_s;

  freqtime = 0.0;
  BaseFrequency = 0.00001;
  for(int FrequencyComponent = FirstFrequencyComponent;FrequencyComponent <= LastFrequencyComponent; FrequencyComponent ++)
    phaseShift[FrequencyComponent - FirstFrequencyComponent] = random(TWO_PI);
}
void draw()
{
  background(255,255,255);
  fill(0,0,0,100);
  float shiftX = 0.5 * width;
  float shiftY = 0.95 * height;
  translate(shiftX,shiftY);
  float Load = 0.0;
  for(int intermediate = 0;intermediate <= 50;intermediate ++)
  {
    freqtime += BaseFrequency;
    if(freqtime > TWO_PI)freqtime -= TWO_PI;
    for(int Node = 0;Node <= LastNode;Node ++)
    {
      Force[Node][0] = 0.0;
      Force[Node][1] = 0.0;
    }

    Load = 0.0;
    for(int FrequencyComponent = FirstFrequencyComponent;FrequencyComponent <= LastFrequencyComponent; FrequencyComponent ++)
      Load += 10.0 * cos(((float) FrequencyComponent) * freqtime + phaseShift[FrequencyComponent - FirstFrequencyComponent]);

    Force[LastNode][0] = 0.1 * Load / sqrt((float) (LastFrequencyComponent - FirstFrequencyComponent));
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
      float tensionCoefficient = (ElementLength - delta_s + Damping * RateofIncreaseofLength) * AxialStiffnessFactor;
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
        Veloc[Node][xy] = 0.9999 * Veloc[Node][xy] + 4.0 * Force[Node][xy] / Stiffness;
        Coord[Node][xy] += Veloc[Node][xy];
      }
    }
  }
  stroke(0,0,0,200); 
  noFill();
  strokeWeight(1.0);
  for(int dash =  - 10;dash <= 10;dash ++)line(0.01 * L * dash,0.0,0.01 * L * (dash + 1),0.01 * L);
  strokeWeight(1.5);
  line(0.1 * L,0.0, - 0.1 * L,0.0);
  beginShape();
  for(int Node = 0;Node <= LastNode;Node ++)vertex(Coord[Node][0], - Coord[Node][1]);
  endShape();
  strokeWeight(1.0);
  stroke(255,0,0,255);
  fill(255,0,0,255);
  ellipse(Coord[LastNode][0], - Coord[LastNode][1],8,8);
  ellipse(Coord[LastNode][0] + Load, - Coord[LastNode][1],5,5);
  line(Coord[LastNode][0], - Coord[LastNode][1],Coord[LastNode][0] + Load, - Coord[LastNode][1]);
  stroke(0,0,255,255);
  fill(0,0,255,255);
}







