int LastBit = 200,LastIntermediate;
float[][] Left_Force,Left_Veloc,Left_Coord;
float[][] RightForce,RightVeloc,RightCoord;
float[] deltaCoord,mymouse,MaxBendingForce,Box;
int[] Broken;
float L,delta_s,delta_s_Sq,AxialStiffness,BendingStiffness,NodeMass,delta_t,decay,Reverse,MaxTensionCoefficient;
void setup()
{
  size(1200,750,P2D);
  smooth();
  textMode(SCREEN);
  textFont(createFont("Arial",12));
  frameRate(30);
  L = 0.9 * width;
  delta_s = L / float(LastBit + 1);
  delta_s_Sq = delta_s * delta_s;
  deltaCoord = new float[2];  
  mymouse = new float[2];

  Left_Coord = new float[LastBit + 1][2];
  Left_Veloc = new float[LastBit + 1][2];
  Left_Force = new float[LastBit + 1][2];

  RightCoord = new float[LastBit + 1][2];
  RightVeloc = new float[LastBit + 1][2];
  RightForce = new float[LastBit + 1][2];
  Box = new float[2];

  MaxBendingForce = new float[LastBit + 1];//Should not need the last one of these
  Broken = new int[LastBit + 1];//Should not need the last one of these

  float YoungsModulus = 1.0;
  float Diameter = L / 40.0;

  AxialStiffness = YoungsModulus * PI * (Diameter * Diameter / 4.0) / (2.0 * delta_s * delta_s * delta_s);
  BendingStiffness = YoungsModulus * PI * (Diameter * Diameter * Diameter * Diameter / 64.0) / (delta_s * delta_s * delta_s);
  float Density = 1.0;
  NodeMass = Density * PI * Diameter * Diameter / 4.0;
  delta_t = 0.1 * sqrt(NodeMass * delta_s / (YoungsModulus * PI * (Diameter * Diameter / 4.0)));
  MaxTensionCoefficient = delta_s_Sq * AxialStiffness;

  decay = 0.999;
  Reverse = - 0.1;

  randomSeed(0);
  float MaxCurvature = 8.0 / L;
  for(int Bit = 0;Bit <= LastBit;Bit ++)
  {
    Broken[Bit] = 0;
    MaxBendingForce[Bit] = (MaxCurvature * BendingStiffness * delta_s * delta_s);
    float chance = random(0.0, 1.0);
    if(chance > 0.99)MaxBendingForce[Bit] *= 0.5;

    Left_Veloc[Bit][0] = 0.0;
    Left_Veloc[Bit][1] = 0.0;
    Left_Coord[Bit][0] = float(Bit) * delta_s - L /2.0;
    Left_Coord[Bit][1] = 0.0;

    RightVeloc[Bit][0] = 0.0;
    RightVeloc[Bit][1] = 0.0;
    RightCoord[Bit][0] = float(Bit + 1) * delta_s - L /2.0;
    RightCoord[Bit][1] = 0.0;
  }

  LastIntermediate = 0;
  Box[0] = 0.49 * width;
  Box[1] = 0.49 * height;
}

void draw()
{
  background(255,255,255);
  fill(0,0,0,150);
  float lefttext = 0.02 * width;
  float downtext = 0.05 * height;
  float textline = 0.03 * height;
  text("Tips will follow mouse and its mirror when mouse is pressed.",lefttext,downtext);
  text("Spagetto will only break when mouse released.",lefttext,downtext + textline);
  text("Blue dots indicate overstress. Random strength fluctuations.",lefttext,downtext + 2.0 * textline);
  text("Repared when mouse pressed.",lefttext,downtext + 3.0 * textline);
  float shiftX = 0.5 * width;
  float shiftY = 0.5 * height;
  translate(shiftX,shiftY);
  mymouse[0] = mouseX - shiftX - 5; 
  mymouse[1] = mouseY - shiftY - 5;

  int LastIntermediateToUse = LastIntermediate;

  for(int intermediate = 0;intermediate <= LastIntermediateToUse;intermediate ++)
  {
    for(int Bit = 0;Bit <= LastBit;Bit ++)
    {
      for(int xy = 0;xy <= 1;xy ++) 
      {
        Left_Force[Bit][xy] = 0.0;
        RightForce[Bit][xy] = 0.0;
      }
    }

    for(int Bit = 0;Bit <= LastBit - 1;Bit ++)
    {
      if(Broken[Bit] == 0 || mousePressed)
      {
        for(int xy = 0;xy <= 1;xy ++)
        {
          float ThisForce = BendingStiffness * (RightCoord[Bit + 1][xy] - Left_Coord[Bit + 1][xy] - RightCoord[Bit][xy] + Left_Coord[Bit][xy]);
          if(abs(ThisForce) > MaxBendingForce[Bit])Broken[Bit] = 1;
          else
          {
            if(mousePressed)Broken[Bit] = 0;
          }
          if(Broken[Bit] == 0 || mousePressed)
          {
            RightForce[Bit + 1][xy] -= ThisForce;
            Left_Force[Bit + 1][xy] += ThisForce;
            RightForce[Bit + 0][xy] += ThisForce;
            Left_Force[Bit + 0][xy] -= ThisForce;
          }
        }
      }
    }

    for(int Bit = 0;Bit <= LastBit;Bit ++)
    {
      float ElementLengthSq = 0.0;
      for(int xy = 0;xy <= 1;xy ++)
      {
        deltaCoord[xy] = RightCoord[Bit][xy] - Left_Coord[Bit][xy];
        ElementLengthSq += deltaCoord[xy] * deltaCoord[xy];
      }
      float tensionCoefficient = (ElementLengthSq - delta_s_Sq) * AxialStiffness;//This definition of strain avoids the square root
      if(tensionCoefficient > MaxTensionCoefficient)tensionCoefficient = MaxTensionCoefficient;
      for(int xy = 0;xy <= 1;xy ++)
      {
        float ThisForce = tensionCoefficient * deltaCoord[xy];
        Left_Force[Bit][xy] += ThisForce;
        RightForce[Bit][xy] -= ThisForce;
      }
    }

    for(int Bit = 0;Bit <= LastBit;Bit ++)
    {
      if((Bit >= 1 && Bit <= LastBit - 1) || mousePressed)
      {
        for(int xy = 0;xy <= 1;xy ++)
        {
          RightVeloc[Bit][xy] *= decay;
          if(Bit <= LastBit - 1 && (Broken[Bit] == 0 || mousePressed))
            RightVeloc[Bit][xy] += Left_Force[Bit + 1][xy] * delta_t / NodeMass;
          RightVeloc[Bit][xy] += RightForce[Bit][xy] * delta_t / NodeMass;
          RightCoord[Bit][xy] += RightVeloc[Bit][xy];

          Left_Veloc[Bit][xy] *= decay;
          if(Bit >= 1 && (Broken[Bit - 1] == 0 || mousePressed))
            Left_Veloc[Bit][xy] += RightForce[Bit - 1][xy] * delta_t / NodeMass;
          Left_Veloc[Bit][xy] += Left_Force[Bit][xy] * delta_t / NodeMass;
          Left_Coord[Bit][xy] += Left_Veloc[Bit][xy];
        }
      }
    }

    for(int Bit = 0;Bit <= LastBit;Bit ++)
    {
      for(int xy = 0;xy <= 1;xy ++)
      {
        if(RightCoord[Bit][xy] >   Box[xy]) {
          RightCoord[Bit][xy] =   Box[xy];
          RightVeloc[Bit][xy] *= Reverse;
        }
        if(Left_Coord[Bit][xy] >   Box[xy]) {
          Left_Coord[Bit][xy] =   Box[xy];
          Left_Veloc[Bit][xy] *= Reverse;
        }
        if(RightCoord[Bit][xy] < - Box[xy]) {
          RightCoord[Bit][xy] = - Box[xy];
          RightVeloc[Bit][xy] *= Reverse;
        }
        if(Left_Coord[Bit][xy] < - Box[xy]) {
          Left_Coord[Bit][xy] = - Box[xy];
          Left_Veloc[Bit][xy] *= Reverse;
        }
      }
    }

    for(int Bit = 0;Bit <= LastBit - 1;Bit ++)
    {
      if(Broken[Bit] == 0 || mousePressed)
      {
        for(int xy = 0;xy <= 1;xy ++)
        {
          RightCoord[Bit][xy] += Left_Coord[Bit + 1][xy];
          RightCoord[Bit][xy] /= 2.0;
          Left_Coord[Bit + 1][xy] = RightCoord[Bit][xy];
        }
      }
    }

    if(mousePressed)
    {
      LastIntermediate = 100;
      decay = 0.999;
      for(int xy = 0;xy <= 1;xy ++)
        RightVeloc[LastBit][xy] += 0.01 * ( mymouse[xy] - RightCoord[LastBit][xy]);
      Left_Veloc[       0][ 0] += 0.01 * (- mymouse[ 0] - Left_Coord[      0][ 0]);
      Left_Veloc[       0][ 1] += 0.01 * (  mymouse[ 1] - Left_Coord[      0][ 1]);
    }
    else
    {
      LastIntermediate = 10;
      decay = 1.0;
    }
  }
  stroke(0,0,0,200);
  strokeWeight(1.5);
  fill(0,0,255,255);
  for(int Bit = 0;Bit <= LastBit;Bit ++)
  {
    line(Left_Coord[Bit][0],Left_Coord[Bit][1],RightCoord[Bit][0],RightCoord[Bit][1]);
    if(Broken[Bit] != 0 && mousePressed)
    {
      ellipse(RightCoord[Bit][0],RightCoord[Bit][1],4,4);
    }
  }
  strokeWeight(1.0);
  stroke(0,0,0,255);
  fill(255,0,0,255);
  ellipse(Left_Coord[0][0],Left_Coord[0][1],8,8);
  ellipse(RightCoord[LastBit][0],RightCoord[LastBit][1],8,8);
  stroke(0,0,0,200); 
  noFill();
  ellipse(mymouse[0],mymouse[1],10,10);
}

