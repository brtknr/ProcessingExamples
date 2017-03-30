import processing.opengl.*;
int m,n;
float[][] x,y,z;
float a,b,c,lambda,scalefactor;

void setup()
{
  size(screen.width-20,screen.height-50,OPENGL);

  m = 100;
  n = m / 3;
  x = new float[m + 1][n + 1];
  y = new float[m + 1][n + 1];
  z = new float[m + 1][n + 1];

  a = 300.0;
  b = 300.0;
  c = 300.0;
  lambda = 0.0;

  scalefactor=0.8;
}

float zRot=0.0,xRot=0.0;
float lastMouseX=0.0,lastMouseY=0.0;
float xTrans=0.0,yTrans=0.0;
void draw() 
{
  background(0,0,0);
  if(mousePressed)
  {
    if(mouseButton==LEFT)
    {
      if(!keyPressed)
      {
        zRot += (mouseX - lastMouseX)/300.0;
        xRot += (mouseY - lastMouseY)/300.0;
      }
      else
      {
        if(key == 'z')scalefactor *= 1.0-0.01*(mouseY - lastMouseY);
        if(key == 'a')a *= 1.0-0.01*(mouseY - lastMouseY);
        if(key == 'b')b *= 1.0-0.01*(mouseY - lastMouseY);
        if(key == 'c')c *= 1.0-0.01*(mouseY - lastMouseY);
        if(key == 'l')lambda += 0.01*(mouseY - lastMouseY);
      }
    }
    else
    {
      xTrans += (mouseX - lastMouseX);
      yTrans += (mouseY - lastMouseY);
    }
  }

  lastMouseX = mouseX;
  lastMouseY = mouseY;

  translate(float(width)/2.0,float(height)/2.0);
  ortho(-float(width)/2.0,float(width)/2.0,-float(height)/2.0,float(height)/2.0,-width,width);
  rotateX(-xRot);
  rotateZ(-zRot);
  translate(xTrans*cos(zRot)-yTrans*sin(zRot),yTrans*cos(zRot)+xTrans*sin(zRot),yTrans*sin(xRot));
  scale(scalefactor);

  for(int i = 0;i <= m;i++)
  {
    float u = TWO_PI * float(i)/float(m);
    for(int j = 0;j <= n;j++)
    {
      float v = TWO_PI * float(2 * j - n)/float(2 * m);
      x[i][j] = a * ((exp(v) + exp(- v)) / 2.0) * exp(lambda * u) * cos(u);
      y[i][j] = b * ((exp(v) + exp(- v)) / 2.0) * exp(lambda * u) * sin(u);
      z[i][j] = c * ((exp(v) - exp(- v)) / 2.0);
    }
  }

  fill(255,255,255,150);
  stroke(0,0,255,200);
  smooth();

  float p = 0.5;
  float q = 1.0 - p;
  for(int i = 0;i <= m - 1;i++)
  {
    for(int j = 0;j <= n - 1;j++)
    {
      float xAverage = (x[i][j] + x[i + 1][j] + x[i][j + 1] + x[i + 1][j + 1])/4.0;
      float yAverage = (y[i][j] + y[i + 1][j] + y[i][j + 1] + y[i + 1][j + 1])/4.0;
      float zAverage = (z[i][j] + z[i + 1][j] + z[i][j + 1] + z[i + 1][j + 1])/4.0;

      beginShape();
      vertex(p * x[i    ][j    ] + q * xAverage, p * y[i    ][j    ] + q * yAverage, p * z[i    ][j    ] + q * zAverage);
      vertex(p * x[i + 1][j    ] + q * xAverage, p * y[i + 1][j    ] + q * yAverage, p * z[i + 1][j    ] + q * zAverage);
      vertex(p * x[i + 1][j + 1] + q * xAverage, p * y[i + 1][j + 1] + q * yAverage, p * z[i + 1][j + 1] + q * zAverage);
      vertex(p * x[i    ][j + 1] + q * xAverage, p * y[i    ][j + 1] + q * yAverage, p * z[i    ][j + 1] + q * zAverage);
      endShape(CLOSE);
    }
  }

  if(keyPressed && key == ' ')
  {
    writeDXF();
    exit();
  } 
}

void writeDXF()
{
  FileWriter Madeleine=null;
  try
  {
    String OutputFile = selectOutput("Name of dxf file");
    Madeleine=new FileWriter(OutputFile + ".dxf");

    Madeleine.write("0\nSECTION\n2\nENTITIES\n");

    for(int i = 0;i <= m - 1;i++)
    {
      for(int j = 0;j <= n - 1;j++)
      {
        Madeleine.write("0\n3DFACE\n8\nSurface\n");
        Madeleine.write("10\n" + x[i][j] + "\n");
        Madeleine.write("20\n" + y[i][j] + "\n");
        Madeleine.write("30\n" + z[i][j] + "\n");
        Madeleine.write("11\n" + x[i][j+1] + "\n");
        Madeleine.write("21\n" + y[i][j+1] + "\n");
        Madeleine.write("31\n" + z[i][j+1] + "\n");
        Madeleine.write("12\n" + x[i+1][j+1] + "\n");
        Madeleine.write("22\n" + y[i+1][j+1] + "\n");
        Madeleine.write("32\n" + z[i+1][j+1] + "\n");
        Madeleine.write("13\n" + x[i+1][j] + "\n");
        Madeleine.write("23\n" + y[i+1][j] + "\n");
        Madeleine.write("33\n" + z[i+1][j] + "\n");
      }
    }
    Madeleine.write("0\nENDSEC\n0\nEOF\n");

    Madeleine.close();
    println("Data saved");
  }
  catch(Exception e)
  {
    println("Error: Problem writing file");
    exit();
  }
}







