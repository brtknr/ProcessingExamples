float x[], y[];

int n = 20;

void setup()
{
  size(1000, 700);
  x = new float[n + 1];
  y = new float[n + 1];

  randomSeed(0);
  float border = 100.0;
  float maxX = 0.5 * (float)width - border;
  float maxY = 0.5 * (float)height - border;

  for (int i = 0;i <= n;i++)
  {
    x[i] = random(- maxX, maxX);
    y[i] = random(- maxY, maxY);
  }
}

void draw() 
{
  background(255, 255, 255);
  x[0] = mouseX - width / 2;
  y[0] = mouseY - height / 2;
  translate(width / 2, height / 2);
  smooth();

  for (int i = 0;i <= n;i++)
  {
    if (i !=0)
    {
      fill(0, 0, 255);
      ellipse(x[i], y[i], 5, 5);
    }
    else
    {
      fill(255, 0, 0);
      ellipse(x[i], y[i], 15, 15);
    }
  }
}

