//Maud algorithm by Chris J K Williams: http://staff.bath.ac.uk/abscjkw/
int LastZone[],Zone[],WhichZone[],overNode[];
int LastInZone[][];
int InZone[][][];
float deltax[];
float InitialHalfDimension[],HalfDimension[],ZoneSize[];
float startButton[],linesButton[];
float x[][],Velocity[][],Force[][];
float Stiffness[][][],xPrevious[][][];
float slow,BasicCarryOver,SpeedSqDecayFactor,Bounce,a,aSq,MinZoneSizeSq,LSq,MyExp;
float maximumDistanceSq,circleRadius,circleRadiusSq;
int LastNode,MaxLastInZone,overCorner,overStart,overLines,LastGo,LastPrevious,Lines,cycleCount;
void setup() 
{
  int inBrowser = 0;
  if(inBrowser == 0)size(int(0.995 * screen.width),int(0.95 * screen.height));//For running outside browser
  else size(1000,600);//For applet to run in browser
  smooth();
  textFont(createFont("Arial",10));
  strokeWeight(1);

  LastNode = 100;
  MaxLastInZone = LastNode;
  LastGo = 0;
  LastPrevious = 200;

  maximumDistanceSq = 100.0;
  overStart = 2;
  overLines = 0;
  overCorner = 0;
  Lines = 0;

  InitialHalfDimension = new float[2];
  HalfDimension = new float[2];
  startButton = new float[2];
  linesButton = new float[2];
  LastZone = new int[2];
  Zone = new int[2];
  WhichZone = new int[2];
  ZoneSize = new float[2];
  x = new float[2][LastNode + 1];
  xPrevious = new float[2][LastNode + 1][LastPrevious + 1];
  Velocity = new float[2][LastNode + 1];
  Force = new float[2][LastNode + 1];
  Stiffness = new float[2][2][LastNode + 1];
  overNode = new int[LastNode + 1];
  deltax = new float[2];

  InitialHalfDimension[0] = 0.48 * float(width );
  InitialHalfDimension[1] = 0.48 * float(height);
  for(int i = 0;i <= 1;i++)HalfDimension[i] = InitialHalfDimension[i];
  startButton[0] = - 0.48 * float(width ) + 10.0;
  startButton[1] = - 0.48 * float(height) + 15.0;
  linesButton[0] = startButton[0] + 100.0;
  linesButton[1] = startButton[1];
  slow = 0.001;
  BasicCarryOver = 1.0;
  SpeedSqDecayFactor = 100.0;
  Bounce = 1.0;
  a = 0.4 * InitialHalfDimension[1];
  aSq = a * a;
  for(int i = 0;i <= 1;i++)
  {
    LastZone[i] = int(2.0 * HalfDimension[i] / (1.5 * a));
    ZoneSize[i] = 2.0 * HalfDimension[i] / (1.0 * LastZone[i]);
  }
  println("Number of zones is " + LastZone[0] + " by " + LastZone[1]);

  if(ZoneSize[0] < ZoneSize[1])MinZoneSizeSq = ZoneSize[0] * ZoneSize[0];
  else MinZoneSizeSq = ZoneSize[1] * ZoneSize[1];

  println("Value at edge of zone is " + exp(-MinZoneSizeSq / aSq));

  LastInZone = new int[LastZone[0] + 1][LastZone[1] + 1];
  InZone = new int[LastZone[0] + 1][LastZone[1] + 1][MaxLastInZone + 1];

  cycleCount = 0;
}











