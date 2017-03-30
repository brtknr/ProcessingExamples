
void PrepareData()
{
  //int StructureType = 0;//This is radial symmetry with variable thickness no oculus
  //int StructureType = 1;//This is radial symmetry with constant thickness no oculus
  //int StructureType = 2;//This is radial symmetry with variable thickness with oculus
  //int StructureType = 3;//This is complex shape variable thickness
  int StructureType = 3;

  int fineness,m,n,Source = 0,MaxLastArchElement;
  if(StructureType == 0||StructureType == 1||StructureType == 2)
  {
    fineness = 10;
    m = 3 * fineness;
    n = 5 * fineness;
    n += 1;//to make odd
    MaxLastArchElement = n;
  }
  else
  {
    fineness = 3;
    m = 12 * fineness;
    n = 30 * fineness;
    Source = 12 * fineness;
    MaxLastArchElement = n;
  }

  if(StructureType == 0||StructureType == 1)
    LastNode = (m + 1) * (n + 1);//Come to a point
  else
    LastNode = (m + 1) * (n + 1) - 1;

  if(StructureType == 0||StructureType == 1)LastElement = (m + 1) * (n + 1) - 1;
  if(StructureType == 2)LastElement = m * (n + 1) - 1;
  if(StructureType == 3)LastElement = m * n - 1;

  if(StructureType == 0||StructureType == 1)LastArch = -1;
  else LastArch = 0;

  x = new float[LastNode+1][3];
  x_dot = new float[LastNode+1][3];
  SoapFilmForce = new float[LastNode+1][3];
  FictitiousQuadrilateralEdgeForce = new float[LastNode+1][3];
  ArchTension = new float[LastNode+1][3];
  ArchFictitiousTension = new float[LastNode+1][3];
  NodalArea = new float[LastNode+1][3];
  stiffness = new float[LastNode+1];
  Area = new float[3];
  deltax = new float[3];
  temp_FictitiousQuadrilateralEdgeForce = new float[3];
  offsetfactor = new float[4];

  r = new float[3][3][3];

  NodeType = new int[LastNode+1];
  NumberOfLinear = new int[LastNode+1];

  ElementNodes = new int[LastElement+1][4];
  TriangleCorner = new int[3];

  LastArchElement = new int[LastArch + 1];
  ArchElementNodes = new int[LastArch + 1][MaxLastArchElement + 1][2];
  ArchSlackLength = new float[LastArch + 1];
  CurrentLength = new float[LastArch + 1];
  ArchBaseStiffness = new float[LastArch + 1];

  float L = 1000000.0;
  scalefactor = 0.45*float(height)/L;

  Tau0_over_w0 = 0.95 * L;//Membrane stress over Load on shell when z = z0

  //If a = Tau0_over_w0 then T_over_w is constant. Large a gives constant thickness
  //If a = Tau0_over_w0 then T_over_w is constant. Large a gives constant thickness

  if(StructureType != 1)a = Tau0_over_w0;
  else a = 10000.0 * Tau0_over_w0;

  HalfBaseThickness = L/60.0;
  ControlLength = 0.3 * L / float(n);

  if(StructureType == 0||StructureType == 1||StructureType == 2)
  {
    for(int i = 0;i <= m;i++)
    {
      float phi = TWO_PI * float(i) / float(n+1);
      for(int j = 0;j <= n;j++)
      {
        float psi = TWO_PI * float(j) / float(n+1);

        int Node = CalculateNode(i,j,m,n);
        //println(i + " " + j + " " + Node);

        x[Node][0] = L * exp(- phi) * cos(- psi);
        x[Node][1] = L * exp(- phi) * sin(- psi);
        x[Node][2] = 0.0;
        NodeType[Node] = 1;
        if(i == 0)NodeType[Node] = 0;
        if(i == m&&StructureType == 2)NodeType[Node] = 2;
      }
    }
    if(StructureType == 0||StructureType == 1)
    {
      int Node=LastNode;
      x[Node][0] = 0.0;
      x[Node][1] = 0.0;
      x[Node][2] = 0.0;
      NodeType[Node] = 1;
    }

    for(int i = 0;i <= m-1;i++)
    {
      for(int j = 0;j <= n;j++)
      {
        //int Element = i + j * m;
        int Element = i * (n + 1) + j;
        int jp1 = j + 1;
        if(j==n)jp1=0;
        ElementNodes[Element][0] =  CalculateNode(i,j,m,n);
        ElementNodes[Element][1] =  CalculateNode(i + 1,j,m,n);
        ElementNodes[Element][2] =  CalculateNode(i + 1,jp1,m,n);
        ElementNodes[Element][3] =  CalculateNode(i,jp1,m,n);
      }
    }

    if(StructureType == 0||StructureType == 1)
    {
      for(int j = 0;j <= n;j++)
      {
        int Element = m * (n + 1) + j;
        int jp1 = j + 1;
        if(j==n)jp1=0;
        ElementNodes[Element][0] =  CalculateNode(m,j,m,n);
        ElementNodes[Element][1] =  LastNode;
        ElementNodes[Element][2] =  LastNode;
        ElementNodes[Element][3] =  CalculateNode(m,jp1,m,n);
      }
    }

    if(StructureType == 2)
    {
      {
        int Arch = 0;
        LastArchElement[Arch] = n;
        if(LastArchElement[Arch] > MaxLastArchElement){
          println("Too many linear elements");
          exit();
        }

        ArchSlackLength[Arch] = 0.4 * L;
        ArchBaseStiffness[Arch] = Tau0_over_w0 / 3.0;

        CurrentLength[Arch] = 0.0;
        for(int ArchElement = 0; ArchElement <= LastArchElement[Arch]-1; ArchElement++)
        {
          ArchElementNodes[Arch][ArchElement][0] = CalculateNode(m,ArchElement  ,m,n);
          ArchElementNodes[Arch][ArchElement][1] = CalculateNode(m,ArchElement+1,m,n);
        }
        ArchElementNodes[Arch][LastArchElement[Arch]][0] = CalculateNode(m,LastArchElement[Arch],m,n);
        ArchElementNodes[Arch][LastArchElement[Arch]][1] = CalculateNode(m,0,m,n);
      }
    }
  }

  else
  {
    L*=0.45;
    scalefactor*=0.45;
    float reduce = 0.92;

    for(int i = 0;i <= m;i++)
    {
      float phi = log(4.0) + TWO_PI * reduce * float(i - Source) / float(n);
      for(int j = 0;j <= n;j++)
      {

        float psi = PI * (1.0 + reduce * float(n - 2 * j) / float(n));

        int Node = CalculateNode(i,j,m,n);

        float u = 1.0 - 4.0 * exp(- phi) * cos(- psi);
        float v =     - 4.0 * exp(- phi) * sin(- psi);
        float p = sqrt((sqrt(u * u + v * v) + u) / 2.0);
        float q = 1.0 * sqrt((sqrt(u * u + v * v) - u) / 2.0);
        if(2 * j < n)q = - q;
        float realpart = 1.0 + p;
        float imagpart = q;
        x[Node][0] = (L * exp(phi) / 2.0) * (cos(psi) * realpart - sin(psi) * imagpart);
        x[Node][1] = (L * exp(phi) / 2.0) * (sin(psi) * realpart + cos(psi) * imagpart);
        x[Node][2] = 0.0;

        NodeType[Node] = 1;
        if(i == 0 || i == m || j == 0 || j == n)NodeType[Node] = 0;
        if(i == 0 && j != 0 && j != n)NodeType[Node] = 2;

        for(int xyz = 0; xyz <= 2; xyz ++)
        {
          x_dot[Node][xyz] = 0.0;
          NodalArea[Node][xyz] = 0.0;
        }
      }
    }

    for(int i = 0;i <= m - 1;i++)
    {
      for(int j = 0;j <= n - 1;j++)
      {
        int Element = i + j * m;
        ElementNodes[Element][0] =  CalculateNode(i,j,m,n);
        ElementNodes[Element][1] =  CalculateNode(i + 1,j,m,n);
        ElementNodes[Element][2] =  CalculateNode(i + 1,j + 1,m,n);
        ElementNodes[Element][3] =  CalculateNode(i,j + 1,m,n);
      }
    }

    {
      int Arch = 0;
      LastArchElement[Arch] = n - 1;
      if(LastArchElement[Arch] > MaxLastArchElement){
        println("Too many linear elements");
        exit();
      }

      ArchSlackLength[Arch] = 0.2 * L;
      ArchBaseStiffness[Arch] = Tau0_over_w0 / 5.0;

      CurrentLength[Arch] = 0.0;
      for(int ArchElement = 0; ArchElement <= LastArchElement[Arch]; ArchElement++)
      {
        ArchElementNodes[Arch][ArchElement][0] = CalculateNode(0,ArchElement,m,n);
        ArchElementNodes[Arch][ArchElement][1] = CalculateNode(0,ArchElement + 1,m,n);
      }
    }
  }

  if(LastArch>=0)
  {
    for(int Arch = 0;Arch <= LastArch; Arch ++)
    {
      for(int ArchElement = 0; ArchElement <= LastArchElement[Arch]; ArchElement++)
      {
        if(NodeType[ArchElementNodes[Arch][ArchElement][0]] == 1 || NodeType[ArchElementNodes[Arch][ArchElement][1]] == 1)
        {
          println("Problem with linear element node types");
          exit();
        }
      }
    }
  }
}

int CalculateNode(int i,int j,int m, int n)
{
  return i + j * (m + 1);
}









