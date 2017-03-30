void Calculation(int thisGo)
{
  for(int Node = 0;Node <= LastNode;Node++)
  {
    for(int i = 0;i <= 1;i++)
    {
      Force[i][Node] = 0.0;
      for(int j = 0;j <= 1;j++)Stiffness[i][j][Node] = 0.0;
    }
  }

  SortIntoZones();
  for(Zone[0] = 0;Zone[0] <= LastZone[0];Zone[0]++)
  {
    for(Zone[1] = 0;Zone[1] <= LastZone[1];Zone[1]++)
    {
      for(int NodeInZone = 0;NodeInZone <= LastInZone[Zone[0]][Zone[1]];NodeInZone++)
      {
        int Node = InZone[Zone[0]][Zone[1]][NodeInZone];
        for(WhichZone[0] = Zone[0]-1;WhichZone[0] <= Zone[0]+1;WhichZone[0]++)
        {
          if(0 <= WhichZone[0]&&WhichZone[0] <= LastZone[0]){
            for(WhichZone[1] = Zone[1]-1;WhichZone[1] <= Zone[1]+1;WhichZone[1]++)
            {
              if(0 <= WhichZone[1]&&WhichZone[1] <= LastZone[1])
              {
                for(int OtherNodeInZone = 0;OtherNodeInZone <= LastInZone[WhichZone[0]][WhichZone[1]];OtherNodeInZone++){
                  int OtherNode = InZone[WhichZone[0]][WhichZone[1]][OtherNodeInZone];
                  if(OtherNode < Node)Contribution(Node, OtherNode, thisGo);
                }
              }
            }
          }
        }
      }
    }
  }
  for(int Node = 0;Node <= LastNode;Node++)
  {
    if(mousePressed == false||overNode[Node] == 0)
    {
      Invert(Node);
      float SpeedSq = 0.0;
      for(int i = 0;i <= 1;i++)SpeedSq += Velocity[i][Node] * Velocity[i][Node];
      float CarryOver = BasicCarryOver * exp( - SpeedSq / SpeedSqDecayFactor);
      for(int i = 0;i <= 1;i++)
      {
        Velocity[i][Node] = CarryOver * Velocity[i][Node];
        for(int j = 0;j <= 1;j++)Velocity[i][Node] += slow * Flex[i][j] * Force[j][Node];
        x[i][Node] += Velocity[i][Node];
      }
    }
    for(int i = 0;i <= 1;i++)
    {
      if(x[i][Node] > HalfDimension[i])
      {
        x[i][Node] = HalfDimension[i];
        if(Velocity[i][Node] > 0.0)Velocity[i][Node] = - Bounce * Velocity[i][Node];
      }
      if(x[i][Node] < - HalfDimension[i])
      {
        x[i][Node] = - HalfDimension[i];
        if(Velocity[i][Node] < 0.0)Velocity[i][Node] = - Bounce * Velocity[i][Node];
      }
    }

    float radiusSq = x[0][Node] * x[0][Node] + x[1][Node] * x[1][Node];

    if(radiusSq < circleRadiusSq)
    {
      float radius = sqrt(radiusSq);
      for(int i = 0;i <= 1;i++)x[i][Node] *= circleRadius / radius;
      float dotProduct = x[0][Node] * Velocity[0][Node] + x[1][Node] * Velocity[1][Node];
      if(dotProduct < 0.0)for(int i = 0;i <= 1;i++)Velocity[i][Node] -= (1.0 + Bounce) * dotProduct * x[i][Node] / radiusSq;
    }

    for(int Previous = LastPrevious;Previous >= 0;Previous --)
    {
      for(int i = 0;i <= 1;i++)
      {
        if(Previous == 0)xPrevious[i][Node][0] = x[i][Node];
        else xPrevious[i][Node][Previous] = xPrevious[i][Node][Previous - 1];
      }
    }
  }
}









