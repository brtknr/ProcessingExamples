float Flex[][];
void Invert(int Node)
{
  float determinant;
  Flex  =  new float[2][2];
  determinant = 
    Stiffness[0][0][Node] * Stiffness[1][1][Node]-
    Stiffness[0][1][Node] * Stiffness[1][0][Node];
  if(abs(determinant) > 1.0e-24)
  {
    Flex[0][0] = Stiffness[1][1][Node] / determinant;
    Flex[1][1] = Stiffness[0][0][Node] / determinant;
    Flex[0][1] = - Stiffness[0][1][Node] / determinant;
    Flex[1][0] = - Stiffness[1][0][Node] / determinant;
  }
  else{
    Flex[0][0] = 0.0;
    Flex[1][1] = 0.0;
    Flex[0][1] = 0.0;
    Flex[1][0] = 0.0;
  }
}
