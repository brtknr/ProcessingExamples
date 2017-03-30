int LastNode = 50,LastLink,Cycle,SettleCycle = 1000;
float[][] Force,Veloc,Coord;
float[] deltaCoord,Pretension_over_Length,Pretension_over_Length_rate;
float EA_over_L,Mass,gravity,Damping,Stiffness,delta_t,RequiredLength,RequiredLengthSquared,CorrectSag;
void setup()
{
  LastLink = LastNode - 1;
  size(1200,750,P2D);
  smooth();
  frameRate(30);
  float Span = 0.9 * width;
  deltaCoord = new float[2];  
  Coord = new float[LastNode + 1][2];
  Veloc = new float[LastNode + 1][2];
  Force = new float[LastNode + 1][2];
  Pretension_over_Length = new float[LastLink + 1];
  Pretension_over_Length_rate = new float[LastLink + 1];
  float c = 5.0 * Span / 2.0;
  float Argument = Span / (2.0 * c);
  RequiredLength = 2.0 * c * ((exp(Argument) - exp( - Argument)) / 2.0) / ((float) (LastLink + 1));
  RequiredLengthSquared = RequiredLength * RequiredLength;
  CorrectSag = c * ((exp(Argument) + exp( - Argument)) / 2.0 - 1.0);
  for(int Link = 0;Link <= LastLink;Link++)
  {
    Pretension_over_Length[Link] = 0.0;
    Pretension_over_Length_rate[Link] = 0.0;
  }
  for(int Node = 0;Node <= LastNode;Node++)
  {
    Veloc[Node][0] = 0.0;
    Veloc[Node][1] = 0.0;
    Coord[Node][0] = 0.5 * width + Span * (float(Node) / float(LastNode) - 0.5);
    Coord[Node][1] = - 0.1 * Span;
  }
  EA_over_L = 1.0;
  float  EA = EA_over_L * RequiredLength;
  Mass = 1.0;
  gravity = 1.8;
  delta_t = 0.25 * sqrt(EA_over_L / Mass);
  Cycle =0;
}
void draw()
{
  background(255,255,255);
  for(int intermediate = 0;intermediate <= 10;intermediate ++)//Only draw occasionally
  {
    for(int Node = 0;Node <= LastNode;Node++)
    {
      Force[Node][0] = 0.0;
      Force[Node][1] = - Mass * gravity;
    }
    for(int Link = 0;Link <= LastLink;Link++)
    {
      float currentLengthSq = 0.0;
      for(int xy=0;xy<=1;xy++)
      {
        deltaCoord[xy] = Coord[Link + 1][xy] - Coord[Link][xy];
        currentLengthSq += deltaCoord[xy] * deltaCoord[xy];
      }
      float strain = (currentLengthSq / RequiredLengthSquared - 1.0) / 2.0;//This definition of strain avoids the square root
      float ForceDensity = strain * EA_over_L + Pretension_over_Length[Link];
      for(int xy=0;xy<=1;xy++)
      {
        float component = ForceDensity * deltaCoord[xy];
        Force[Link    ][xy] += component;
        Force[Link + 1][xy] -= component;
      }

      if(Cycle > SettleCycle)
      {
        Pretension_over_Length_rate[Link] = 0.99 * Pretension_over_Length_rate[Link] + 0.03 * strain * EA_over_L * delta_t;//Dynamic relaxation for pretension
        Pretension_over_Length[Link] += Pretension_over_Length_rate[Link] * delta_t;
      }
    }

    if(Cycle <= SettleCycle)Cycle ++;

    for(int Node = 1;Node <= LastNode - 1;Node++)
    {
      for(int xy=0;xy<=1;xy++)
      {
        Veloc[Node][xy] = 0.99 * Veloc[Node][xy] + Force[Node][xy] * delta_t / Mass;
        Coord[Node][xy] += delta_t * Veloc[Node][xy];
      }
    }
  }
  stroke(0,0,0,200); 
  noFill();
  strokeWeight(1.0);
  line(Coord[0][0], - Coord[0][1] + CorrectSag,Coord[LastNode][0], - Coord[LastNode][1] + CorrectSag);
  beginShape();
  for(int Node = 0;Node <= LastNode; Node++)vertex(Coord[Node][0], - Coord[Node][1]);
  endShape();
  noStroke();
  fill(255,0,0,255);
  for(int Node = 0;Node <= LastNode; Node++)
  {
    if(Node != 0 && Node != LastNode)ellipse(Coord[Node][0], - Coord[Node][1],6,6);
    else ellipse(Coord[Node][0], - Coord[Node][1],10,10);
  }
}







