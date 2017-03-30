void Writedxf()
{
  PrintWriter Julia;
  try
  {
    String[] FileName = new String[2];
    FileName[0] = selectOutput("3D model. Extension .dxf will be added");
    FileName[1] = "dxf";
    String OutputFile = join(FileName,".");
    Julia=createWriter(OutputFile);
    Julia.println("0\nSECTION\n2\nENTITIES");
    for(int Element = 0; Element <= LastElement; Element ++)
    {
      if(  NodeType[ElementNodes[Element][0]] == 1
        || NodeType[ElementNodes[Element][1]] == 1
        || NodeType[ElementNodes[Element][2]] == 1
        || NodeType[ElementNodes[Element][3]] == 1)
      {
        float ysum = 0;
        for(int Corner = 0;Corner <= 3;Corner ++)
        {
          int Node = ElementNodes[Element][Corner];
          float ScalarNodalAreaSq = 0.0;
          for(int xyz = 0; xyz <= 2; xyz ++)ScalarNodalAreaSq += NodalArea[Node][xyz] * NodalArea[Node][xyz];

          offsetfactor[Corner] = HalfBaseThickness * exp( - x[Node][2] / a) / sqrt(ScalarNodalAreaSq);

          ysum += x[Node][1];
        }
        int NorthOrSouth = 0;
        if(ysum < 0.0)NorthOrSouth = 1;
        for(int Layer = -1; Layer <= 1; Layer +=2)
        {
          Julia.println("0\n3DFACE\n8\n" + NorthOrSouth);

          for(int Corner = 0;Corner <= 3;Corner ++)
          {
            int Node = ElementNodes[Element][Corner];
            for(int xyz = 0; xyz <= 2; xyz ++)Julia.println(((xyz + 1) * 10 + Corner) + "\n" + (x[Node][xyz] + float(Layer) * offsetfactor[Corner] * NodalArea[Node][xyz]));
          }
        }
        for(int Corner = 0;Corner <= 3;Corner ++)
        {
          int NextCorner = Corner + 1;
          if(NextCorner > 3)NextCorner -= 4;

          Julia.println("0\n3DFACE\n8\n" + NorthOrSouth);

          int Node = ElementNodes[Element][Corner];
          for(int xyz = 0; xyz <= 2; xyz ++)Julia.println(((xyz + 1) * 10 + 0) + "\n" + (x[Node][xyz] + offsetfactor[Corner] * NodalArea[Node][xyz]));
          for(int xyz = 0; xyz <= 2; xyz ++)Julia.println(((xyz + 1) * 10 + 1) + "\n" + (x[Node][xyz] - offsetfactor[Corner] * NodalArea[Node][xyz]));
          Node = ElementNodes[Element][NextCorner];
          for(int xyz = 0; xyz <= 2; xyz ++)Julia.println(((xyz + 1) * 10 + 2) + "\n" + (x[Node][xyz] - offsetfactor[NextCorner] * NodalArea[Node][xyz]));
          for(int xyz = 0; xyz <= 2; xyz ++)Julia.println(((xyz + 1) * 10 + 3) + "\n" + (x[Node][xyz] + offsetfactor[NextCorner] * NodalArea[Node][xyz]));
        }
      }
    }
    Julia.println("0\nENDSEC\n0\nEOF");
    Julia.flush();
    Julia.close();
    println("3D dxf file written.");
  }
  catch(Exception e)
  {
    println("Error: Problem writing 3D dxf file");
  }
}












