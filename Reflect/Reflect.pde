int lasti,lastj,suction,NodeType[][],NodeArms[][];
float deltat,deltaxory,deltaxorySquared,cSquared,pressure[][],pressureDot[][],delSquaredPressure[][];
void setup() 
{
  size(1000,707);
  deltaxory = 10.0;
  deltaxorySquared = deltaxory * deltaxory;
  float c = 1.0;
  cSquared = c * c;
  deltat = 0.5 * deltaxory / c;

  lasti = width - 1;
  lastj = height - 1;
  pressure = new float[width][height];
  pressureDot = new float[width][height];
  delSquaredPressure = new float[width][height];

  NodeType = new int[width][height];
  NodeArms = new int[width][height];

  float r0 = 120.0 * deltaxory;
  float q = 5.0 * deltaxory;
  float A = 8.0;
  suction = 1;
  for (int i = 0; i <= lasti ; i++)
  {
    for (int j = 0; j <= lastj ; j++)
    {
      NodeType[i][j] = 0;
      NodeArms[i][j] = 0;
      float radius = deltaxory * sqrt((float)((2 * i - width) * (2 * i - width) + (2 * j - height) * (2 * j - height))) / 2.0;

      float dr = radius - r0;
      float argument = dr / q;
      float pulse = A * exp( - argument * argument);
      pressure[i][j] = pulse;
      pressureDot[i][j] = 2.0 * argument * pulse / q;
      if(suction == 1)
      {
        float ratio = 1.0;
        argument = ratio * ((dr / q) + 1.0);
        float suck = - ratio * A * exp( - argument * argument);
        pressure[i][j] += suck;
        pressureDot[i][j] += 2.0 * argument * ratio * suck / q;
      }
    }
  }

  for (int i = 5; i <= lasti - 5; i++)
  {
    for (int j = 5; j <= lastj - 5; j++)
    {
      NodeType[i][j] = 1;
      if(width - i < 50 && width - i > 45)NodeType[i][j] = 2;
      if(3.5 * (float) i < (float) j)NodeType[i][j] = 0;
      int di = 200 - i;
      int dj = 120 - j;
      if(di * di + dj * dj < 1000)NodeType[i][j] = 0;
      di = 300 - i;
      dj = height - 120 - j;
      if(di * di + dj * dj < 2000)NodeType[i][j] = 2;
      if(di * di + dj * dj < 1600)NodeType[i][j] = 0;
    }
  }

  for (int i = 0; i <= lasti ; i++)
  {
    for (int j = 0; j <= lastj ; j++)
    {
      if(NodeType[i][j] != 0)
      {
        if(i > 0    )NodeArms[i - 1][j] ++;
        if(i < lasti)NodeArms[i + 1][j] ++;
        if(j > 0    )NodeArms[i][j - 1] ++;
        if(j < lastj)NodeArms[i][j + 1] ++;
      }
    }
  }
}

void draw() 
{   
  for(int innerCycle = 0;innerCycle <= 2;innerCycle ++)
  {
    for (int i = 1; i <= lasti - 1; i++)
    {
      for (int j = 1; j <= lastj - 1; j++)
      {
        if(NodeType[i][j] != 0)delSquaredPressure[i][j] =
          (pressure[i - 1][j] + pressure[i + 1][j] + pressure[i][j - 1] + pressure[i][j + 1] - 4.0 * pressure[i][j]) / deltaxorySquared;
      }
    }

    for (int i = 1; i <= lasti - 1; i++)
    {
      for (int j = 1; j <= lastj - 1; j++)
      {
        if(NodeType[i][j] != 0)
        {
          pressureDot[i][j] += cSquared * delSquaredPressure[i][j] * deltat;
          if(NodeType[i][j] == 2)pressureDot[i][j] *= 0.9; 
          pressure[i][j] += pressureDot[i][j] * deltat;
        }
      }
    }

    for (int i = 0; i <= lasti ; i++)
    {
      for (int j = 0; j <= lastj ; j++)
      {
        if(NodeType[i][j] == 0 && NodeArms[i][j] != 0)
        {
          pressure[i][j] = 0.0;
          if(i > 0    ) {
            if(NodeType[i - 1][j] != 0) pressure[i][j] += pressure[i - 1][j];
          }
          if(i < lasti) {
            if(NodeType[i + 1][j] != 0) pressure[i][j] += pressure[i + 1][j];
          }
          if(j > 0    ) {
            if(NodeType[i][j - 1] != 0) pressure[i][j] += pressure[i][j - 1];
          }
          if(j < lastj) {
            if(NodeType[i][j + 1] != 0) pressure[i][j] += pressure[i][j + 1];
          }
          pressure[i][j] /= (float)NodeArms[i][j];
        }
      }
    }
  }

  loadPixels();
  for (int i = 0; i <= lasti ; i++)
  {
    for (int j = 0; j <= lastj ; j++)
    {
      int thisPixel = (lastj - j) * width + i;
      if(NodeType[i][j] != 0)
      {
        float ColourControl = exp(5.0 * pressure[i][j]);
        float ColourShift = exp( - 10.0);
        float basicColour = 255.0;
        if(NodeType[i][j] == 2)basicColour /= 1.2;
        int myBlue = (int)(basicColour / (1.0 + ColourShift * ColourControl));
        if(suction == 1)
        {
          int myRed   = (int)(basicColour / (1.0 + ColourShift / ColourControl));
          int myGreen = (int)(basicColour / (1.0 + ColourShift / ColourControl + ColourShift * ColourControl));
          pixels[thisPixel] = color(myRed,myGreen,myBlue);
        }
        else pixels[thisPixel] = color(myBlue,myBlue,myBlue);
      }
      else
      {
        if(NodeArms[i][j] == 0)pixels[thisPixel] = color(255,255,255);
        if(NodeArms[i][j] == 1 || NodeArms[i][j] == 3)pixels[thisPixel] = color(100,100,100);
        if(NodeArms[i][j] == 2)pixels[thisPixel] = color(150,150,150);
      }
    }
  }
  updatePixels();
}

