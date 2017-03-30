void Calculation()
{
  for(int Node = 0; Node <= LastNode; Node ++)
  {
    NumberOfLinear[Node] = 0;
    stiffness[Node] = 0;
    for(int xyz = 0; xyz <= 2; xyz ++)
    {
      NodalArea[Node][xyz] = 0.0;
      SoapFilmForce[Node][xyz] = 0.0;
      FictitiousQuadrilateralEdgeForce[Node][xyz] = 0.0;
      ArchTension[Node][xyz] = 0.0;
      ArchFictitiousTension[Node][xyz] = 0.0;
    }
  }

  for(int Element = 0; Element <= LastElement; Element ++)
  {
    if(  NodeType[ElementNodes[Element][0]] == 1
      || NodeType[ElementNodes[Element][1]] == 1
      || NodeType[ElementNodes[Element][2]] == 1
      || NodeType[ElementNodes[Element][3]] == 1)
    {
      for(int Triangle = 0; Triangle <=3; Triangle++)
      {
        for(int ThisCorner = 0; ThisCorner <= 2; ThisCorner ++)
        {
          int Corner = Triangle + ThisCorner + 1;
          if(Corner > 3)Corner -= 4;
          TriangleCorner[ThisCorner] = ElementNodes[Element][Corner];
        }

        for(int ThisCorner = 0; ThisCorner <= 2; ThisCorner ++)
        {
          for(int ThatCorner = 0; ThatCorner <= 2; ThatCorner ++)
          {
            for(int xyz = 0; xyz <= 2; xyz ++)
              r[ThisCorner][ThatCorner][xyz] = x[TriangleCorner[ThisCorner]][xyz] -  x[TriangleCorner[ThatCorner]][xyz];
          }
        }

        for(int xyz = 0; xyz <= 2; xyz ++)
        {
          int xyzp1 = xyz + 1;
          if(xyzp1 > 2)xyzp1 -= 3;
          int xyzp2 = xyz + 2;
          if(xyzp2 > 2)xyzp2 -= 3;

          Area[xyz] = (r[1][0][xyzp1] * r[2][0][xyzp2] - r[1][0][xyzp2] * r[2][0][xyzp1]) / 2.0;
        }

        float ScalarAreaSq = 0.0;
        for(int xyz = 0; xyz <= 2; xyz ++)ScalarAreaSq += Area[xyz] * Area[xyz];
        if(ScalarAreaSq != 0.0)
        {
          float ScalarArea =  sqrt(ScalarAreaSq);
          for(int Corner = 0;Corner <= 2; Corner ++)
          {
            stiffness[TriangleCorner[Corner]] += 1.0;
            int Cornerp1 = Corner + 1;
            if(Cornerp1 > 2)Cornerp1 -= 3;
            int Cornerp2 = Corner + 2;
            if(Cornerp2 > 2)Cornerp2 -= 3;

            float ScalarProduct = 0.0;
            for(int xyz = 0; xyz <= 2; xyz ++)ScalarProduct += r[Cornerp1][Corner][xyz] * r[Cornerp2][Corner][xyz];

            float ratio = ScalarProduct / (8.0 * ScalarArea);
            for(int xyz = 0; xyz <= 2; xyz ++)
            {
              NodalArea[TriangleCorner[Corner]][xyz] += Area[xyz]/6.0;

              SoapFilmForce[TriangleCorner[Cornerp1]][xyz] += ratio * r[Cornerp2][Cornerp1][xyz];
              SoapFilmForce[TriangleCorner[Cornerp2]][xyz] += ratio * r[Cornerp1][Cornerp2][xyz];
            }
          }
        }
      }
    }

    for(int Corner = 0;Corner <= 3;Corner ++)
    {
      int Cornerp1 = Corner + 1;
      if(Cornerp1 > 3)Cornerp1 -= 4;

      float LengthSq = 0;
      for(int xyz = 0; xyz <= 2; xyz ++)
      {
        temp_FictitiousQuadrilateralEdgeForce[xyz] = x[ElementNodes[Element][Cornerp1]][xyz] - x[ElementNodes[Element][Corner]][xyz];
        LengthSq += temp_FictitiousQuadrilateralEdgeForce[xyz] * temp_FictitiousQuadrilateralEdgeForce[xyz];
      }
      float Multiplier = 1.0 + sqrt(LengthSq) / ControlLength;
      for(int xyz = 0; xyz <= 2; xyz ++)
      {
        temp_FictitiousQuadrilateralEdgeForce[xyz] = temp_FictitiousQuadrilateralEdgeForce[xyz] * Multiplier;
        FictitiousQuadrilateralEdgeForce[ElementNodes[Element][Corner  ]][xyz] += temp_FictitiousQuadrilateralEdgeForce[xyz];
        FictitiousQuadrilateralEdgeForce[ElementNodes[Element][Cornerp1]][xyz] -= temp_FictitiousQuadrilateralEdgeForce[xyz];
      }
    }
  }

  for(int Arch = 0;Arch <=LastArch; Arch ++)
  {
    float lengthsofar = 0.0;
    if(LastArchElement[Arch] >= 0)
    {
      for(int ArchElement = 0; ArchElement <= LastArchElement[Arch]; ArchElement++)
      {
        NumberOfLinear[ArchElementNodes[Arch][ArchElement][0]]++;
        NumberOfLinear[ArchElementNodes[Arch][ArchElement][1]]++;

        if( NumberOfLinear[ArchElementNodes[Arch][ArchElement][0]] > 2
          ||NumberOfLinear[ArchElementNodes[Arch][ArchElement][1]] > 2)
        {
          println("More than two edge linear elements meeting at node");
          exit();
        }

        float LengthSq = 0.0;
        for(int xyz = 0; xyz <= 2; xyz ++)
        {
          deltax[xyz] = x[ArchElementNodes[Arch][ArchElement][1]][xyz] - x[ArchElementNodes[Arch][ArchElement][0]][xyz];
          LengthSq += deltax[xyz] * deltax[xyz];
        }

        float Length = sqrt(LengthSq);
        lengthsofar += Length;
        float BaseTensionCofficient = (ArchBaseStiffness[Arch] * (CurrentLength[Arch] - ArchSlackLength[Arch]))/ Length;

        for(int xyz = 0; xyz <= 2; xyz ++)
        {
          ArchTension[ArchElementNodes[Arch][ArchElement][0]][xyz] += BaseTensionCofficient * deltax[xyz];
          ArchTension[ArchElementNodes[Arch][ArchElement][1]][xyz] -= BaseTensionCofficient * deltax[xyz];

          if(NumberOfLinear[ArchElementNodes[Arch][ArchElement][0]] == 1)
            ArchFictitiousTension[ArchElementNodes[Arch][ArchElement][0]][xyz] += deltax[xyz];
          else
            ArchFictitiousTension[ArchElementNodes[Arch][ArchElement][0]][xyz] -= deltax[xyz];

          if(NumberOfLinear[ArchElementNodes[Arch][ArchElement][1]] == 1)
            ArchFictitiousTension[ArchElementNodes[Arch][ArchElement][1]][xyz] -= deltax[xyz];
          else
            ArchFictitiousTension[ArchElementNodes[Arch][ArchElement][1]][xyz] += deltax[xyz];
        }
      }
      CurrentLength[Arch] = lengthsofar;
    }
  }

  for(int Node = 0; Node <= LastNode; Node ++)
  {
    if(NodeType[Node] == 1) 
    {
      float NodalAreaMagnitudeSq = 0.0;
      float SoapScalarProduct = 0.0;
      float EdgeScalarProduct = 0.0;
      for(int xyz = 0; xyz <= 2; xyz ++)
      {
        NodalAreaMagnitudeSq += NodalArea[Node][xyz] * NodalArea[Node][xyz];
        SoapScalarProduct += NodalArea[Node][xyz] * SoapFilmForce[Node][xyz];
        EdgeScalarProduct += NodalArea[Node][xyz] * FictitiousQuadrilateralEdgeForce[Node][xyz];
      }

      float NodalAreaMagnitude = sqrt(NodalAreaMagnitudeSq);

      for(int xyz = 0; xyz <= 2; xyz ++)
      {
        float SoapNormalComponent = NodalArea[Node][xyz] * SoapScalarProduct / NodalAreaMagnitudeSq;
        float EdgeNormalComponent = NodalArea[Node][xyz] * EdgeScalarProduct / NodalAreaMagnitudeSq;

        //NOTE THAT THE FOLLOWING IS THE CORRECT VERSION FOR UNIFORMLY STRESSED SHELL UNDER GRAVITY
        float WeightNormalComponent = NodalArea[Node][xyz] * NodalArea[Node][2] / NodalAreaMagnitude;

        WeightNormalComponent *= 1.0 / (a * (1.0 - exp(x[Node][2] / a) * (1.0 - Tau0_over_w0 / a)));

        //NOTE THAT THE FOLLOWING IS MODIFIED TO GIVE SOAP FILM WITH CONSTANT PRESSURE
        //float WeightNormalComponent = w_over_sigma * NodalArea[Node][xyz];

        x_dot[Node][xyz] = 0.98 * x_dot[Node][xyz] 
          + 0.02 * (SoapNormalComponent + WeightNormalComponent
          + 0.1 * (FictitiousQuadrilateralEdgeForce[Node][xyz] - EdgeNormalComponent));

        x[Node][xyz] += x_dot[Node][xyz];
      }
    }
    if(NodeType[Node] == 2) 
    {
      float SurfaceTensionFactor = a * (exp( - x[Node][2] / a) - (1.0 - Tau0_over_w0 / a));

      float MagnitudeSq = 0.0;
      float EdgeScalarProduct = 0.0;
      for(int xyz = 0; xyz <= 2; xyz ++)
      {
        MagnitudeSq += ArchFictitiousTension[Node][xyz] * ArchFictitiousTension[Node][xyz];
        EdgeScalarProduct += ArchFictitiousTension[Node][xyz] * FictitiousQuadrilateralEdgeForce[Node][xyz];
      }

      if(MagnitudeSq == 0.0)
      {
        println("Zero magnitude for node " + Node);
        exit();
      }

      for(int xyz = 0; xyz <= 2; xyz ++)
      {
        x_dot[Node][xyz] = 0.99 * x_dot[Node][xyz] 
          + 0.01 * (SoapFilmForce[Node][xyz] + ArchTension[Node][xyz] / SurfaceTensionFactor
          + 1.0 * ArchFictitiousTension[Node][xyz] * EdgeScalarProduct / MagnitudeSq);

        x[Node][xyz] += x_dot[Node][xyz];
      }
    }
  }
}































