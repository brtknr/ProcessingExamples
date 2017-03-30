float ZoomX=100.0;
float ZoomY=400.0;
float OriginalZoomY=400.0;
float dxfX=100.0;
float dxfY=100.0;
float ButtonRegion=20.0;
int OverZoom=0;
int Overdxf=0;
float zRot=0.0,xRot=0.0;
float MyMouseX=0.0,MyMouseXpressed=0.0,MyMouseY=0.0,MyMouseYpressed=0.0;
float xTrans=0.0,yTrans=0.0;
void draw()
{
  background(255,255,255);

  if(mousePressed)
  {
    if(Overdxf==1){
      Screen_or_dxf=1;
      Writedxf();
      exit();
    }
    MyMouseXpressed=mouseX;
    MyMouseYpressed=mouseY;
    if(OverZoom==1||Overdxf==1)
    {
      ZoomY+=MyMouseYpressed-MyMouseY;
      scalefactor*=1.0-0.01*(MyMouseYpressed-MyMouseY);
    }
    else
    {
      if(mouseButton==LEFT)
      {
        zRot+=(MyMouseXpressed-MyMouseX)/300.0;
        xRot+=(MyMouseYpressed-MyMouseY)/300.0;
      }
      else
      {
        xTrans+=(MyMouseXpressed-MyMouseX);
        yTrans+=(MyMouseYpressed-MyMouseY);
      }
      ZoomY=OriginalZoomY;
    }
    MyMouseX=MyMouseXpressed;
    MyMouseY=MyMouseYpressed;
  }
  else
  {
    MyMouseX=mouseX;
    MyMouseY=mouseY;
    ZoomY=OriginalZoomY;
    if((MyMouseX-ZoomX)*(MyMouseX-ZoomX)+(MyMouseY-ZoomY)*(MyMouseY-ZoomY)<ButtonRegion*ButtonRegion)
      OverZoom=1;
    else
      OverZoom=0;

    if((MyMouseX-dxfX)*(MyMouseX-dxfX)+(MyMouseY-dxfY)*(MyMouseY-dxfY)<ButtonRegion*ButtonRegion)
      Overdxf=1;
    else
      Overdxf=0;
  }

  for(int cycle=0;cycle<=20;cycle++)Calculation();

  stroke(0,0,0,200);
  fill(100,100,100,200);
  text("Zoom",ZoomX+20,ZoomY+10);
  if(OverZoom==1)fill(255,0,0,200);
  ellipse(ZoomX,ZoomY,10,10);

  fill(100,100,100,200);
  text("Write dxf files and quit program",dxfX+20,dxfY+10);
  if(Overdxf==1)fill(255,0,0,200);
  ellipse(dxfX,dxfY,10,10);

  translate(float(width)/2.0,float(height)/2.0);
  ortho(-float(width)/2.0,float(width)/2.0,-float(height)/2.0,float(height)/2.0,-width,width);
  rotateX(-xRot);
  rotateZ(-zRot);
  translate(xTrans*cos(zRot)-yTrans*sin(zRot),yTrans*cos(zRot)+xTrans*sin(zRot),yTrans*sin(xRot));
  scale(scalefactor);
  smooth();
  //strokeWeight(1.0/scalefactor);//OPENGL
  strokeWeight(1.0);//P3D

  for(int Element = 0; Element <= LastElement; Element ++)
  {
    if(  NodeType[ElementNodes[Element][0]] == 1
      || NodeType[ElementNodes[Element][1]] == 1
      || NodeType[ElementNodes[Element][2]] == 1
      || NodeType[ElementNodes[Element][3]] == 1)
    {
      for(int Corner = 0;Corner <= 3;Corner ++)
      {
        int Node = ElementNodes[Element][Corner];
        float ScalarNodalAreaSq = 0.0;
        for(int xyz = 0; xyz <= 2; xyz ++)ScalarNodalAreaSq += NodalArea[Node][xyz] * NodalArea[Node][xyz];

        offsetfactor[Corner] = HalfBaseThickness * exp( - x[Node][2] / a) / sqrt(ScalarNodalAreaSq);
      }
      for(int Layer = -1; Layer <= 1; Layer ++)
        //for(int Layer = 0; Layer <= 0; Layer ++)
      {
        if(Layer == 0)fill(200,200,0,100);
        else noFill();
        beginShape();
        for(int Corner = 0;Corner <= 3;Corner ++)
        {
          int Node = ElementNodes[Element][Corner];
          if(Layer !=0)
          {

            vertex(
            x[Node][0] + float(Layer) * offsetfactor[Corner] * NodalArea[Node][0],
            x[Node][1] + float(Layer) * offsetfactor[Corner] * NodalArea[Node][1],
            x[Node][2] + float(Layer) * offsetfactor[Corner] * NodalArea[Node][2]); 
          }
          else
            vertex(
            x[Node][0],
            x[Node][1],
            x[Node][2]);

        }
        endShape(CLOSE);
      }
    }
  }

  int drawdots = 1;
  if(drawdots != 0)
  {
    float dotSize = 10.0/scalefactor;
    for(int Node = 0; Node <= LastNode; Node ++)
    {
      if(NodeType[Node] == 0)
      {
        fill(0,0,255,255);
        ellipse(x[Node][0],x[Node][1],dotSize,dotSize);
      }
      if(NodeType[Node] == 2)
      {
        fill(255,0,0,255);
        ellipse(x[Node][0],x[Node][1],dotSize,dotSize);
      }
    }
  }

  stroke(255,0,0,255);
  strokeWeight(1.5);
  for(int Arch = 0;Arch <=LastArch; Arch ++)
  {
    for(int ArchElement = 0; ArchElement <= LastArchElement[Arch]; ArchElement++)
    {
      line(
      x[ArchElementNodes[Arch][ArchElement][0]][0],
      x[ArchElementNodes[Arch][ArchElement][0]][1],
      x[ArchElementNodes[Arch][ArchElement][0]][2],
      x[ArchElementNodes[Arch][ArchElement][1]][0],
      x[ArchElementNodes[Arch][ArchElement][1]][1],
      x[ArchElementNodes[Arch][ArchElement][1]][2]); 
    }
  }

  int DrawNormals = 0;
  if(DrawNormals != 0)
  {
    float NormalScale = - 1.0;
    stroke(0,0,0,100);
    strokeWeight(1.0);
    for(int Node = 0; Node <= LastNode; Node ++)
    {
      if(NodeType[Node] == 1)
      {
        line(x[Node][0],x[Node][1],x[Node][2],
        x[Node][0] + NormalScale * NodalArea[Node][0],
        x[Node][1] + NormalScale * NodalArea[Node][1],
        x[Node][2] + NormalScale * NodalArea[Node][2]); 
      }
    }
  }
}











