float x[], y[];
int thisEnd[], thatEnd[];

int n = 20;
int lastLine = (n + 1) * n / 2 - 1;

void setup()
{
  size(1000, 700);
  x = new float[n + 1];
  y = new float[n + 1];
  thisEnd = new int[lastLine + 1];
  thatEnd = new int[lastLine + 1];

  randomSeed(0);
  float border = 100.0;
  float maxX = 0.5 * (float)width - border;
  float maxY = 0.5 * (float)height - border;

  for (int i = 0;i <= n;i++)
  {
    x[i] = random(- maxX, maxX);
    y[i] = random(- maxY, maxY);
  }

  int thisLine = - 1;
  for (int i = 0;i <= n - 1;i++)
  {
    for (int j = i + 1;j <= n;j++)
    {
      thisLine ++;
      thisEnd[thisLine] = i;
      thatEnd[thisLine] = j;
    }
  }
  if (thisLine != lastLine) {
    println("Problem with line numbers\n");
    exit();
  }
}


void draw() 
{
  background(255, 255, 255);
  x[0] = mouseX - width / 2;
  y[0] = mouseY - height / 2;
  translate(width / 2, height / 2);
  smooth();

  stroke(0, 0, 0, 200);
  strokeWeight(2.0);

  for (int thisLine = 0;thisLine <= lastLine;thisLine++)
    line(x[thisEnd[thisLine]], y[thisEnd[thisLine]], x[thatEnd[thisLine]], y[thatEnd[thisLine]]);

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

