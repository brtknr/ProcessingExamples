//http://www.processing.org/
import processing.opengl.*;
int[][] End,MemberEndType;
int[] NodeType,MemberTyp;
int LastNode,LastMember,LastMemberType,DrawBendingMoments;
float[][] x,Load,Velocity,Theta,AngularVelocity,BendingMoment;
float[] EAminusT0,EAoverL0,EI,BasicEAminusT0,CurrentL,BasicEAoverL0,xMax,xMin,xAv,xShift;
float LoadFactor,myScale,NextScale,BasicEA,MinimumLength,MomentScale=0.1;
float a,b;
float error;
int LastLongLine;
int LastDataPoint;
float[] xDataPoint,yDataPoint;
int[][] LongLineEnd,NodeKey;
float [][]Vector;
String FileLocation;
void setup(){
  size(1200,750,OPENGL);
  smooth();
  frameRate(30);
  //FileLocation="/Users/Shared/Data/";//Macintosh
  FileLocation="/Users/Chris/Documents/ChrisMacBookPC/Data/";//Macintosh
  //FileLocation="C:\\Documents and Settings\\All Users\\Documents\\Data\\";//Windows
  //FileLocation="\\\\.PSF\\ChrisMacBookPC\\Data\\";//Windows
  LoadFactor=1.0;DrawBendingMoments=1;
  PrepareData();
  MinimumLength=b/20.0;
  SetVelocityAndScale();
}
