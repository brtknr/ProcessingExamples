
void Contribution(int Node,int OtherNode,int thisActualGo)
{
  LSq = 0.0;
  for(int i = 0;i <= 1;i++)
  {
    deltax[i] = x[i][OtherNode] - x[i][Node];
    LSq += deltax[i] * deltax[i];
  }

  if(LSq / aSq > 1.0e-24 && LSq < MinZoneSizeSq)
  {
    MyExp = exp(- LSq / aSq);
    float ToverL = exp(- LSq / aSq) / LSq;
    float dTbydL = - ToverL -(2.0 * LSq / aSq) * ToverL;

    for(int i = 0;i <= 1;i++)
    {
      float tempForce = ToverL * deltax[i];
      if(overNode[Node] == 0 || overNode[OtherNode] == 0)tempForce = 10.0 * tempForce;
      Force[i][Node] += tempForce;
      Force[i][OtherNode] -= tempForce;
      Stiffness[i][i][Node] += ToverL;
      Stiffness[i][i][OtherNode] += ToverL;
      for(int j = 0;j <= 1;j++)
      {
        float tempStiffness = (dTbydL-ToverL)*deltax[i]*deltax[j]/LSq;
        Stiffness[i][j][Node] += tempStiffness;
        Stiffness[i][j][OtherNode] += tempStiffness;
      }
    }
    if(thisActualGo == LastGo && Lines == 1)
    {
      strokeWeight(1.2);
      stroke(0,0,255 * MyExp, 255 * MyExp);
      line(x[0][Node], x[1][Node], x[0][OtherNode], x[1][OtherNode]);
    }
  }
}


