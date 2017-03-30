//http://www.processing.org/
//import processing.opengl.*;
float[] stiffness,Area,ArchSlackLength,deltax,CurrentLength,ArchBaseStiffness,offsetfactor,temp_FictitiousQuadrilateralEdgeForce;
float[][] x,x_dot,SoapFilmForce,FictitiousQuadrilateralEdgeForce,ArchTension,ArchFictitiousTension,NodalArea;
float [][][] r;
int[] NodeType,TriangleCorner,NumberOfLinear,LastArchElement;
int[][] ElementNodes;
int[][][] ArchElementNodes;
float scalefactor,a,HalfBaseThickness,ControlLength,Tau0_over_w0;
int LastNode,LastElement,LastArch,Screen_or_dxf=0;
void setup()
{
  //size(1200,750,OPENGL);
  size(1200,750,P3D);
  //size(int(0.9*float(screen.width)),int(0.9*float(screen.height)),P3D);
  smooth();
  textFont(createFont("Arial",16));
  frameRate(30);
  textMode(SCREEN);
  PrepareData();
}
