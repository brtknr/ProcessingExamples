
void draw() 
{ 
  background(0,0,0);
  int grey = 255;
  cycleCount ++;
  float actualLinesButtonPosn = linesButton[0] + Lines * 20;
  translate(width/2,height/2);
  int textdown = 6;
  int textacross = 10;
  float circleRadiusFactor = 0.1;
  if(overStart == 2 || mousePressed && overStart == 1 || cycleCount > 1000)
  {
    cycleCount = 0;
    Lines = 0;
    for(int i = 0;i <= 1;i++)HalfDimension[i] = InitialHalfDimension[i];
    circleRadius = circleRadiusFactor * min(HalfDimension[0],HalfDimension[1]);
    circleRadiusSq = circleRadius * circleRadius;
    float InitialBox = 0.6;
    for(int Node = 0;Node <= LastNode;Node ++ )
    {
      overNode[Node] = 0;
      float radiusSq;
      do{
        for(int i = 0;i <= 1;i ++ )x[i][Node] = HalfDimension[i] * random( - InitialBox, InitialBox);
        radiusSq = x[0][Node] * x[0][Node] + x[1][Node] * x[1][Node];
      }
      while(radiusSq < circleRadiusSq);

      for(int i = 0;i <= 1;i ++ )
      {
        Velocity[i][Node] = 0.0;
        for(int Previous = 0;Previous <= LastPrevious;Previous ++ )xPrevious[i][Node][Previous] = x[i][Node];
      }
    }
  }
  noStroke();
  if(overStart == 1)
  {
    fill(0,255,0,255);
    ellipse(startButton[0],startButton[1],10,10);
  }
  else
  {
    fill(0,0,255,255);
    ellipse(startButton[0],startButton[1],5,5);
  }
  fill(grey,grey,grey,100);
  text("Restart",startButton[0] + textacross,startButton[1] + textdown);
  if(overLines == 1)
  {
    fill(0,255,0,255);
    ellipse(actualLinesButtonPosn,linesButton[1],10,10);
  }
  else
  {
    fill(0,0,255,255);
    ellipse(actualLinesButtonPosn,linesButton[1],5,5);
  }
 fill(grey,grey,grey,100);
  if(Lines == 0)text("Show lines",actualLinesButtonPosn + textacross,linesButton[1] + textdown);
  else text("Hide lines",actualLinesButtonPosn + textacross,linesButton[1] + textdown);
  text("Individual nodes can be selected and dragged. The top right corner of the box can be selected and dragged. Press 'esc' to stop program.",actualLinesButtonPosn + 100 + textacross,linesButton[1] + textdown);
  text("Maud algorithm by Chris J K Williams, University of Bath", - InitialHalfDimension[0] + 5,InitialHalfDimension[1] - 5);
  float valueX = mouseX - float(width)/2.0;
  float valueY = mouseY - float(height)/2.0;
  if((startButton[0] - valueX) * (startButton[0] - valueX) + (startButton[1] - valueY) * (startButton[1] - valueY)<maximumDistanceSq)overStart = 1;
  else overStart = 0;
  if((actualLinesButtonPosn - valueX) * (actualLinesButtonPosn - valueX) + (linesButton[1] - valueY) * (linesButton[1] - valueY)<maximumDistanceSq)overLines = 1;
  else overLines = 0;
  if(mousePressed)
  {
    if(overCorner == 1)
    {
      HalfDimension[0] = abs(valueX);
      HalfDimension[1] = abs(valueY);
      for(int i = 0;i <= 1;i++)
      {
        if(HalfDimension[i] > InitialHalfDimension[i])HalfDimension[i] = InitialHalfDimension[i];
      }
      circleRadius = circleRadiusFactor * min(HalfDimension[0],HalfDimension[1]);
      circleRadiusSq = circleRadius * circleRadius;
    }
    for(int Node = 0;Node <= LastNode;Node ++ )
    {
      if(overNode[Node] == 1)
      {
        x[0][Node] = valueX;
        x[1][Node] = valueY;
      }
    }
    if(overLines == 1)
    {
      if(Lines == 0)Lines = 1;
      else Lines = 0;
    }
  }
  else
  {
    if((HalfDimension[0] - valueX) * (HalfDimension[0] - valueX) + (HalfDimension[1] + valueY) * (HalfDimension[1] + valueY)<maximumDistanceSq)overCorner = 1;
    else overCorner = 0;
    int foundOne = overCorner;
    for(int Node = 0;Node <= LastNode;Node ++ )
    {
      if((x[0][Node] - valueX) * (x[0][Node] - valueX) + (x[1][Node] - valueY) * (x[1][Node] - valueY) < maximumDistanceSq && foundOne == 0)
      {
        foundOne = 1;
        overNode[Node] = 1;
      }
      else overNode[Node] = 0;
    }
  }
  noStroke();
  if(overCorner == 1)
  {
    fill(0,255,0,255);
    ellipse(HalfDimension[0], - HalfDimension[1],10,10);
  }
  else
  {
    fill(0,0,255,255);
    ellipse(HalfDimension[0], - HalfDimension[1],5,5);
  }
  for(int go = 0;go <= LastGo;go ++ )Calculation(go);
  strokeWeight(1); 
  for(int Node = 0;Node <= LastNode;Node ++ )
  {
    for(int Previous = 0;Previous <= LastPrevious;Previous ++ )
    {
      float factor = float(LastPrevious + 1 - Previous)/float(LastPrevious + 1);
      factor = 255 * factor * factor;
      stroke(int(factor),0,255 - int(factor),int(factor));
      if(Previous == 0)line(x[0][Node],x[1][Node],xPrevious[0][Node][0],xPrevious[1][Node][0]);
      else line(xPrevious[0][Node][Previous - 1],xPrevious[1][Node][Previous - 1],xPrevious[0][Node][Previous],xPrevious[1][Node][Previous]);
    }
    noStroke();
    if(overNode[Node] == 1)
    {
      fill(255,0,0,255);
      ellipse(x[0][Node],x[1][Node],5,5);
    }
    else
    {
      fill(255,255,255,255);
      ellipse(x[0][Node],x[1][Node],2,2);
    }
  }
stroke(grey,grey,grey,100);
  noFill();
  beginShape();
  vertex( - HalfDimension[0], - HalfDimension[1]);
  vertex( + HalfDimension[0], - HalfDimension[1]);
  vertex( + HalfDimension[0], + HalfDimension[1]);
  vertex( - HalfDimension[0], + HalfDimension[1]);
  endShape(CLOSE);
  ellipse(0,0,2 * circleRadius,2 * circleRadius);
}


















