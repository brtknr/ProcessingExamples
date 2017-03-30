
void SortIntoZones()
{
  for(Zone[0] = 0;Zone[0] <= LastZone[0];Zone[0]++)
  {
    for(Zone[1] = 0;Zone[1] <= LastZone[1];Zone[1]++)
      LastInZone[Zone[0]][Zone[1]] = - 1;
  }
  for(int Node = 0;Node <= LastNode;Node++)
  {
    for(int i = 0;i <= 1;i++)
    {
      Zone[i] = int((x[i][Node] + HalfDimension[i]) / ZoneSize[i]);
      if(Zone[i] < 0)Zone[i] = 0;
      if(Zone[i] > LastZone[i])Zone[i] = LastZone[i];
    }
    LastInZone[Zone[0]][Zone[1]]++;
    if(LastInZone[Zone[0]][Zone[1]] <= MaxLastInZone)InZone[Zone[0]][Zone[1]][LastInZone[Zone[0]][Zone[1]]] = Node;
  }
  for(Zone[0] = 0;Zone[0] <= LastZone[0];Zone[0]++)
  {
    for(Zone[1] = 0;Zone[1] <= LastZone[1];Zone[1]++)
    {
      if(LastInZone[Zone[0]][Zone[1]] > MaxLastInZone) LastInZone[Zone[0]][Zone[1]] = MaxLastInZone;
    }
  }
}
