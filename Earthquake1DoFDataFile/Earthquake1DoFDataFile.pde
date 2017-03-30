float timeOfRecord[],xAcceleration[],yAcceleration[],zAcceleration[];
float GroundAccelerationToSave[],GroundMovementToSave[],ThetaToSave[],bendingMomentOverRotationalStiffnessToSave[];
float groundMovement[],groundMovementDoubleDot[],theta[],bendingMomentOverRotationalStiffness[];
float delta_time;
float omega_n,omega_nSq,c,yieldTheta,DampingFactor,h;
//float momentOfInertia,rotationalLambda,rotationalStiffness,mass,h,yieldBendingMoment;
float thetaDot,groundMovementDot,plasticTheta,gravity,gravityOver_h;
float graphOrigin,graphHalfWidth,graphHalfLength,groundPloty,graphScale,graphAccelerationScale,pictureScale,momentGraphScale;
int graphMove,graphInterval,lastLongLine,boldLineInterval,lastPoint = 1000;
int LastRecord,startRecord,currentRecord;
String InputFile;

void setup()
{
  size(screen.width-20,screen.height-50);
  smooth();
  textFont(createFont("Arial",12));

  //This is the start of the physical parameters

  h = 4.46;
  omega_n = 0.5 * TWO_PI;//0.877*TWO_PI;
  c = 5.0/100.0;
  gravity=9.81;
  yieldTheta = 0.03;

  //This is the end of the physical parameters

  omega_nSq=omega_n*omega_n;
  gravityOver_h=gravity/h;
  DampingFactor = 2.0*c*omega_n;

  graphOrigin = 0.2*float(width);
  graphAccelerationScale = 100.0;
  graphScale = 1000.0;
  pictureScale = 550.0/h;
  momentGraphScale = 200.0/yieldTheta;
  groundPloty = 0.42*float(height);

  groundMovement = new float[lastPoint+1];
  groundMovementDoubleDot = new float[lastPoint+1];
  bendingMomentOverRotationalStiffness = new float[lastPoint+1];

  ReadEarthquakeData();

  theta = new float[lastPoint+1];
  boldLineInterval = 5;
  graphInterval = lastPoint/100;
  lastLongLine = 12*boldLineInterval;
  graphHalfLength = 0.4*float(height);
  graphHalfWidth = float(graphInterval)*graphHalfLength*float(lastLongLine)/float(lastPoint);
  graphMove = -1;
  startRecord = int(20.0/delta_time);
  currentRecord = startRecord-1;

  for(int myPoint = 0;myPoint <= lastPoint;myPoint++)
  {
    groundMovement[myPoint] = 0.0;
    groundMovementDoubleDot[myPoint] = 0.0;
    theta[myPoint] = 0.0;
    bendingMomentOverRotationalStiffness[myPoint] = 0.0;
  }
  thetaDot = 0.0;
  groundMovementDot = 0.0;
  plasticTheta = 0.0;
}

void draw() 
{
  if((mousePressed&&startRecord<=currentRecord)||currentRecord==LastRecord)
  {
    SaveResults(startRecord,currentRecord);
    exit();
  }
  currentRecord++;
  if(currentRecord<=LastRecord)
  {
    groundMovementDoubleDot[0] = xAcceleration[currentRecord];

    background(255,255,255);
    fill(0,0,0,150);
    translate(0.0,float(height)/2.0);
    text("Time in seconds = " + timeOfRecord[currentRecord],0.02*width,-0.45*height);
    text("Saves results and stops when mouse pressed",0.25*width,-0.45*height);
    text("Input file: " + InputFile,0.5*width,-0.45*height);

    //This is the breginning of the calculation

    bendingMomentOverRotationalStiffness[0] = theta[0]-plasticTheta;
    if(bendingMomentOverRotationalStiffness[0] > +yieldTheta)
    {
      bendingMomentOverRotationalStiffness[0] = yieldTheta;
      plasticTheta = theta[0]-bendingMomentOverRotationalStiffness[0];
    }
    if(bendingMomentOverRotationalStiffness[0] < -yieldTheta)
    {
      bendingMomentOverRotationalStiffness[0] = -yieldTheta;
      plasticTheta = theta[0]-bendingMomentOverRotationalStiffness[0];
    }

    float thetaDoubleDot = -DampingFactor*thetaDot-(groundMovementDoubleDot[0]/h)*cos(theta[0])
      +gravityOver_h*sin(theta[0])-omega_nSq*bendingMomentOverRotationalStiffness[0];

    thetaDot += thetaDoubleDot*delta_time;
    theta[0] += thetaDot*delta_time;

    groundMovementDot += groundMovementDoubleDot[0]*delta_time;
    groundMovement[0] += groundMovementDot*delta_time;
    groundMovement[0] -= groundMovement[0]*delta_time/1000.0;// This is to remove drift

    //This is the end of the calculation

    GroundAccelerationToSave[currentRecord] = groundMovementDoubleDot[0];
    GroundMovementToSave[currentRecord] = groundMovement[0];
    ThetaToSave[currentRecord] = theta[0];
    bendingMomentOverRotationalStiffnessToSave[currentRecord] = bendingMomentOverRotationalStiffness[0];

    for(int myPoint = lastPoint;myPoint >= 1;myPoint--)
    {
      groundMovement[myPoint] = groundMovement[myPoint-1];
      groundMovementDoubleDot[myPoint] = groundMovementDoubleDot[myPoint-1];
      theta[myPoint] = theta[myPoint-1];
      bendingMomentOverRotationalStiffness[myPoint] = bendingMomentOverRotationalStiffness[myPoint-1];
    }
    strokeWeight(1.0);
    stroke(100,100,100,150);
    graphMove++;
    if(graphMove >= graphInterval*boldLineInterval)graphMove = 0;
    int lineCount = boldLineInterval;
    for(int myPoint = 0;myPoint <= lastPoint-graphInterval;myPoint+=graphInterval)
    {
      if(lineCount == boldLineInterval)
      {
        strokeWeight(1.5);
        stroke(50,50,50,255);
        lineCount = 0;
      }
      else
      {
        strokeWeight(1.0);
        stroke(100,100,100,150);
      }
      lineCount++;
      float linePosition = graphHalfLength*(-1.0+2.0*float(myPoint+graphMove)/float(lastPoint));
      if(linePosition>graphHalfLength)linePosition -= 2.0*graphHalfLength;
      line(graphOrigin-graphHalfWidth,linePosition,graphOrigin+graphHalfWidth,linePosition);
    }
    lineCount = boldLineInterval;
    for(int longLine = 0;longLine <= lastLongLine;longLine++)
    {
      if(lineCount == boldLineInterval)
      {
        strokeWeight(1.5);
        stroke(50,50,50,255);
        lineCount = 0;
      }
      else
      {
        strokeWeight(1.0);
        stroke(100,100,100,150);
      }   
      lineCount++;
      float linePosition = graphOrigin+graphHalfWidth*(-1.0+2.0*float(longLine)/float(lastLongLine));
      line(linePosition,-graphHalfLength,linePosition,graphHalfLength);
    }

    stroke(255,100,0,255);
    float yieldDriftLine=graphScale*h*sin(yieldTheta);
    line(graphOrigin+yieldDriftLine,-graphHalfLength,graphOrigin+yieldDriftLine,graphHalfLength);
    line(graphOrigin-yieldDriftLine,-graphHalfLength,graphOrigin-yieldDriftLine,graphHalfLength);

    noFill();
    stroke(0,0,0,150);
    strokeWeight(1.5);
    beginShape();
    vertex(graphOrigin+graphHalfWidth,+graphHalfLength); 
    vertex(graphOrigin+graphHalfWidth,-graphHalfLength); 
    vertex(graphOrigin-graphHalfWidth,-graphHalfLength); 
    vertex(graphOrigin-graphHalfWidth,+graphHalfLength);
    endShape(CLOSE);

    stroke(0,0,0,150);
    beginShape();
    for(int myPoint = 0;myPoint <= lastPoint;myPoint++)
    {
      float graphCoordinate=graphAccelerationScale*groundMovementDoubleDot[myPoint];
      if(graphCoordinate>+graphHalfWidth)graphCoordinate = +graphHalfWidth;
      if(graphCoordinate<-graphHalfWidth)graphCoordinate = -graphHalfWidth;
      vertex(graphCoordinate+graphOrigin,graphHalfLength*(-1.0+2.0*float(myPoint)/float(lastPoint)));
    }
    endShape();
    stroke(0,0,0,150);
    fill(255,0,0,255);
    ellipse(graphAccelerationScale*groundMovementDoubleDot[0]+graphOrigin,-graphHalfLength,3,3);

    noFill();
    stroke(255,0,0,255);
    beginShape();
    for(int myPoint = 0;myPoint <= lastPoint;myPoint++)
    {
      float graphCoordinate=graphScale*groundMovement[myPoint];
      if(graphCoordinate>+graphHalfWidth)graphCoordinate = +graphHalfWidth;
      if(graphCoordinate<-graphHalfWidth)graphCoordinate = -graphHalfWidth;
      vertex(graphCoordinate+graphOrigin,graphHalfLength*(-1.0+2.0*float(myPoint)/float(lastPoint)));
    }
    endShape();
    stroke(0,0,0,150);
    fill(255,0,0,255);
    ellipse(graphScale*groundMovement[0]+graphOrigin,-graphHalfLength,3,3);

    noFill();
    stroke(0,0,255,255);
    beginShape();
    for(int myPoint = 0;myPoint <= lastPoint;myPoint++)
    {
      float graphCoordinate=graphScale*h*sin(theta[myPoint]);
      if(graphCoordinate>+graphHalfWidth)graphCoordinate = +graphHalfWidth;
      if(graphCoordinate<-graphHalfWidth)graphCoordinate = -graphHalfWidth;
      vertex(graphCoordinate+graphOrigin,graphHalfLength*(-1.0+2.0*float(myPoint)/float(lastPoint)));
    }
    endShape();
    stroke(0,0,0,150);
    fill(255,0,0,255);
    ellipse(graphScale*h*sin(theta[0])+graphOrigin,-graphHalfLength,3,3);

    float MomentGraphOrigin_x = 0.6*float(width);
    float MomentGraphOrigin_y = 0.05*float(width);
    stroke(0,0,0,150);
    line(MomentGraphOrigin_x+momentGraphScale*yieldTheta,MomentGraphOrigin_y,MomentGraphOrigin_x-momentGraphScale*yieldTheta,MomentGraphOrigin_y);
    line(MomentGraphOrigin_x,MomentGraphOrigin_y+momentGraphScale*yieldTheta,MomentGraphOrigin_x,MomentGraphOrigin_y-momentGraphScale*yieldTheta);
    noFill();
    beginShape();
    for(int myPoint = 0;myPoint <= lastPoint-1;myPoint++)
    {
      stroke(0,0,255,int(255.0*(1.0-float(myPoint*myPoint)/float(lastPoint*lastPoint))));
      line(MomentGraphOrigin_x+momentGraphScale*theta[myPoint],MomentGraphOrigin_y-momentGraphScale*bendingMomentOverRotationalStiffness[myPoint],
      MomentGraphOrigin_x+momentGraphScale*theta[myPoint+1],MomentGraphOrigin_y-momentGraphScale*bendingMomentOverRotationalStiffness[myPoint+1]);
    }
    endShape();
    stroke(0,0,0,150);
    fill(255,0,0,255);
    ellipse(MomentGraphOrigin_x+momentGraphScale*theta[0],MomentGraphOrigin_y-momentGraphScale*bendingMomentOverRotationalStiffness[0],3,3);

    int lastPicture = 100;
    if(lastPicture>lastPoint)lastPicture=lastPoint;
    for(int picture = 0;picture <= lastPicture;picture+=10)
    {
      float fade=1.0-float(picture)/float(lastPicture);
      noFill();
      stroke(0,0,0,150*fade);
      float groundPlotx = 0.6*float(width)+groundMovement[picture]*pictureScale;
      float topPlotx = groundPlotx+h*pictureScale*sin(theta[picture]);
      float topPloty = groundPloty-h*pictureScale*cos(theta[picture]);
      float rectangleHalfHeight = 0.05*h;
      float rectangleHalfWidth = 0.4*h;
      beginShape();
      vertex(topPlotx+rectangleHalfWidth*pictureScale,topPloty+rectangleHalfHeight*pictureScale);
      vertex(topPlotx+rectangleHalfWidth*pictureScale,topPloty-rectangleHalfHeight*pictureScale);
      vertex(topPlotx-rectangleHalfWidth*pictureScale,topPloty-rectangleHalfHeight*pictureScale);
      vertex(topPlotx-rectangleHalfWidth*pictureScale,topPloty+rectangleHalfHeight*pictureScale);
      endShape(CLOSE);
      if(picture == 0)
      {
        rectangleHalfHeight = 0.02*h;
        rectangleHalfWidth = 0.6*h;
        noStroke();
        fill(200,200,200,150*fade);
        beginShape();
        vertex(groundPlotx+rectangleHalfWidth*pictureScale,groundPloty+rectangleHalfHeight*pictureScale);
        vertex(groundPlotx+rectangleHalfWidth*pictureScale,groundPloty);
        vertex(groundPlotx-rectangleHalfWidth*pictureScale,groundPloty);
        vertex(groundPlotx-rectangleHalfWidth*pictureScale,groundPloty+rectangleHalfHeight*pictureScale);
        endShape();
        stroke(0,255,0,150*fade);
        line(groundPlotx+rectangleHalfWidth*pictureScale,groundPloty,groundPlotx-rectangleHalfWidth*pictureScale,groundPloty);
      }
      stroke(0,0,0,150*fade);
      fill(255,0,0,255*fade);
      float columnHalfSeparation = 0.2*h;
      for(int leftOrRight = -1;leftOrRight <= 1;leftOrRight += 2)
      {
        ellipse(groundPlotx+columnHalfSeparation*pictureScale*float(leftOrRight),groundPloty,4,4);
        ellipse(topPlotx   +columnHalfSeparation*pictureScale*float(leftOrRight),topPloty,4,4);  
        line(groundPlotx+columnHalfSeparation*pictureScale*float(leftOrRight),
        groundPloty,topPlotx+columnHalfSeparation*pictureScale*float(leftOrRight),topPloty);
      }
    }
  }
}



