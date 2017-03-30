float x[][], v[][], f[][], HalfLengthSq[], dx[], maxX[], bounce, circleCentre, circleRadiusSq;
int thisEnd[], thatEnd[], lineExists[];

int n = 500, drawCircles, drawLines, alreadyPressed;
int lastLine = (n + 1) * n / 2 - 1;

void setup()
{
  size(1000, 700);
  drawCircles = 0;
  drawLines = 1;
  alreadyPressed = 0;
  dx = new float[2];
  maxX = new float[2];
  x = new float[2][n + 1];
  v = new float[2][n + 1];
  f = new float[2][n + 1];

  HalfLengthSq = new float[lastLine + 1];
  thisEnd = new int[lastLine + 1];
  thatEnd = new int[lastLine + 1];
  lineExists = new int[lastLine + 1];

  randomSeed(0);
  float border = 100.0;
  maxX[0] = 0.5 * (float)width - border;
  maxX[1] = 0.5 * (float)height - border;

  float circleRadius = 0.2 * height;
  circleCentre = - 0.07 * height;
  circleRadiusSq = circleRadius * circleRadius;

  for (int i = 0;i <= n;i++)
  {
    for (;;)
    {
      x[0][i] = random(- maxX[0], maxX[0]);
      x[1][i] = random(- maxX[1], maxX[1]);
      if (distanceFromCentreSq(i) > circleRadiusSq)break;
    }

    v[0][i] = 0.0;
    v[1][i] = 0.0;
  }
  bounce = -0.2;
}

void draw() 
{
  background(255, 255, 255);
  translate(width / 2, height / 2);
  smooth();
  noFill();
  if (keyPressed)
  {
    if (alreadyPressed == 0)
    {
      if (key == 'l' || key == 'L')
      {
        if (drawLines == 0)drawLines = 1; 
        else drawLines = 0;
      }
      if (key == 'c' || key == 'C')
      {
        if (drawCircles == 0)drawCircles = 1;
        else drawCircles = 0;
      }
      alreadyPressed = 1;
    }
  }
  else alreadyPressed = 0;

  for (int i = 0;i <= n;i++)
  {
    f[0][i] = 0.0;
    f[1][i] = 0.0;
  }

  {
    int thisLine = - 1;
    for (int i = 0;i <= n - 1;i++)
    {
      for (int j = i + 1;j <= n;j++)
      {
        thisLine ++;
        lineExists[thisLine] = 1;
        thisEnd[thisLine] = i;
        thatEnd[thisLine] = j;
        dx[0] = x[0][thisEnd[thisLine]] - x[0][thatEnd[thisLine]];
        dx[1] = x[1][thisEnd[thisLine]] - x[1][thatEnd[thisLine]];
        HalfLengthSq[thisLine] = (dx[0] * dx[0] + dx[1] * dx[1]) / 4.0;

        for (int k = 0;k <= n;k ++)
        {
          if (k != i && k != j)
          {
            float deltax = x[0][k] - (x[0][thisEnd[thisLine]] + x[0][thatEnd[thisLine]]) /2.0;
            float deltay = x[1][k] - (x[1][thisEnd[thisLine]] + x[1][thatEnd[thisLine]]) /2.0;
            float radiusSq = deltax * deltax + deltay * deltay;
            if (radiusSq < HalfLengthSq[thisLine])lineExists[thisLine] = 0;
          }
          if (lineExists[thisLine] == 0)break;
        }

        // if (lineExists[thisLine] == 1)
        {
          float multiplier = - 1.0 * exp(- HalfLengthSq[thisLine] / 100.0) / (0.001 + sqrt(HalfLengthSq[thisLine]));
          for (int xy = 0;xy <= 1; xy ++)
          {
            float ForceComponent = dx[xy] * multiplier;
            f[xy][thatEnd[thisLine]] += ForceComponent;
            f[xy][thisEnd[thisLine]] -= ForceComponent;
          }
        }
      }
    }
    if (thisLine != lastLine) {
      println("Problem with line numbers\n");
      exit();
    }
  }

  for (int thisLine = 0;thisLine <= lastLine;thisLine++)
  {
    if (lineExists[thisLine] == 1)
    {
      if (drawLines == 1)
      {
        stroke(0, 0, 0, 200);
        strokeWeight(2.0);
        line(x[0][thisEnd[thisLine]], x[1][thisEnd[thisLine]], x[0][thatEnd[thisLine]], x[1][thatEnd[thisLine]]);
      }
      if (drawCircles == 1)
      {
        float diameter = 2.0 * sqrt(HalfLengthSq[thisLine]);
        stroke(0, 0, 0, 100);
        strokeWeight(1.0);
        ellipse(
        (x[0][thisEnd[thisLine]] + x[0][thatEnd[thisLine]]) / 2.0, 
        (x[1][thisEnd[thisLine]] + x[1][thatEnd[thisLine]]) / 2.0, 
        diameter, diameter);
      }
    }
  }
  fill(0, 0, 255);
  for (int i = 0;i <= n;i++)ellipse(x[0][i], x[1][i], 5, 5);

  for (int i = 0;i <= n;i++)
  {
    for (int xy = 0;xy <= 1; xy ++)
    {
      v[xy][i] = 0.9 * v[xy][i] + f[xy][i];
      x[xy][i] += v[xy][i];
      if (x[xy][i] > + maxX[xy] && v[xy][i] > 0.0) {
        x[xy][i] = + maxX[xy];
        v[xy][i] *= bounce;
      }
      if (x[xy][i] < - maxX[xy] && v[xy][i] < 0.0) {
        x[xy][i] = - maxX[xy];
        v[xy][i] *= bounce;
      }
    }
    float rSq = distanceFromCentreSq(i);
    if (rSq < circleRadiusSq)
    {
      float ratio = sqrt(circleRadiusSq / rSq);
      x[0][i] = ratio * (x[0][i] - circleCentre) + circleCentre;
      x[1][i] = ratio * x[1][i];
      float scalarProd = v[0][i] * (x[0][i] - circleCentre) + v[1][i] * x[1][i];
      if (scalarProd < 0.0)
      {
        v[0][i] -= (1.0 - bounce) * scalarProd * (x[0][i] - circleCentre) / circleRadiusSq;
        v[1][i] -= (1.0 - bounce) * scalarProd * x[1][i] / circleRadiusSq;
      }
    }
  }
}

float distanceFromCentreSq(int i)
{
  float deltax = x[0][i] - circleCentre;
  float deltay = x[1][i];
  return deltax * deltax + deltay * deltay;
}

