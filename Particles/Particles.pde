import processing.opengl.*; 

Form form;

String font;

boolean start = false;
boolean collision = false;
boolean reset = true;
boolean colour = false;
boolean renderS = false;
boolean bouncy = false;
boolean ground = true;
boolean groundtog = true;
boolean strut = false;
boolean buro = false;
boolean lastatt = false;
boolean rotation = false;
boolean drag = false;
boolean view = false;
boolean impact = false;
int viewy = 0;

int n = 0;
int c;
int mass = 15;

int q;
int look = 1;
int contacted = 1;

int am = 0;

int sep5 = 0;

int startTime;
int endTime;

//mouse settings
int zoom = 0;

//angle rotations for view
float rotBuffX = 0;
float rotBuffY = 0;

//initial pan
int panX = 0;
int panY = 0;

//track mouse movement
int mouseDragX;
int mouseDragY;
int mouseDragXpan;
int mouseDragYpan;

boolean rotateMode = false; // mouse rotation
boolean rotateYaw = false;  // mouse yaw
boolean pan = false;        // mouse pan

void setup() {
  size(800, 800, OPENGL);
  frameRate(20);
  form = new Form();
  ////    Initial parts into system    ////
  initial();
  c = n;
  smooth();

  font = "Courier New";

  addMouseWheelListener(new java.awt.event.MouseWheelListener() {  
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
      if (evt.getWheelRotation()<0) { 
        zoom+=evt.getScrollAmount()+10;
      }  
      else { 
        zoom-=evt.getScrollAmount()+10;
      } 
      redraw();
    }
  } 
  );
}

void draw() {

  background(255);
  lights();    

  if (look == 3) {
    pushMatrix();
    translate(width - 85, height, -100);
    stroke(0);
    strokeWeight(3);
    line(-45, 0, 45, 0);
    line(-35, -10, -55, 10);
    line(55, -10, 35, 10);    
    popMatrix();

    pushMatrix();
    textFont(createFont(font, 44));
    fill(0);
    textAlign(CENTER, CENTER);
    text(sep5, width - 130, height - 85);
    popMatrix();
  }


  if (look == 2) {
    pushMatrix();
    translate(width - 85, height - 40, -100);
    fill(255, 0, 0);
    sphereDetail(12);
    sphere(45);
    popMatrix();
  }
  if (look == 1) {
    pushMatrix();
    translate(width - 85, height - 40, -100);
    rotateY(radians(30));
    fill(255, 0, 0);
    box(45*sqrt(2));
    popMatrix();
  }

  pushMatrix();
  if (look == 2 || look == 1) {
    textFont(createFont(font, 44));
    fill(255);
    textAlign(CENTER, CENTER);
    text(c, width - 130, height - 85);
  }

  if (start && drag != true) {
    int p = (millis() - startTime)/100;
    if (p < 1) {
      p = 1;
    }
    else {
      p = round(p);
    }
    fill(255);
    strokeWeight(2);
    stroke(0);
    if (look == 2) {
      ellipse(width - 40, height - 85, 60, 60);
    }
    if (look == 1) {
      rect(width - 65, height - 110, 50, 50);
    }
    popMatrix();
    pushMatrix();
    if (look == 2 || look == 1) {
      fill(0);
      text(p, width - 40, height - 85);
    }
  }
  popMatrix();


  float rotVitX = 2*PI/width; // step of rotation 
  float rotVitY = 2*PI/height; // step of rotation 

  if (rotateMode) { 
    rotBuffX= (mouseDragX)*rotVitX; 
    rotBuffY= (mouseDragY)*rotVitY;
  } 

  if (pan) {
    panX = mouseDragXpan;
    panY = mouseDragYpan;
  }

  translate(width/2 + panX, height/2 + panY, zoom); // center screen

  rotateX(rotBuffY + PI/4); 

  if (rotateYaw) {
    rotateY(rotBuffX);
  }
  else {
    rotateZ(rotBuffX + PI/4);
  }
  if (view) {
    rotateZ(viewy*PI/4);
  }



  fill(200, 100);
  noStroke();
  int h = width/4;
  int g = 4;
  int r ;
  r = h/g;

  stroke(0);
  strokeWeight(1);
  if (groundtog) {
    for ( int i = -g; i < g; i++) {

      for ( int j = -g; j < g; j++) {
        line(i*r, j*r, 0, i*r, (j+1)*r, 0);
        line(i*r, j*r, 0, (i+1)*r, j*r, 0);
        line(-h, h, 0, h, h, 0);
        line(h, h, 0, h, -h, 0);
      }
    }
  }
  strokeWeight(2);
  int yh;
  if (groundtog) {
    yh = 0;
  }
  else {
    yh = -100;
  }
  //x axis//
  stroke(255, 0, 0);
  line(-h, -h, yh, 0, -h, yh);
  //y axis//
  stroke(0, 255, 0);
  line(-h, -h, yh, -h, 0, yh);
  //z axis//
  stroke(0, 0, 255);
  line(-h, -h, yh, -h, -h, h+yh);
  perspective();

  form.run();
}

void initial () {


  float beta = 2*PI/n;
  float R = mass/tan(beta*0.5);


  for (int i = 0; i < n; i++) {

    if (n == 3) {
      R = mass*1.16;
    }
    if (n == 4) {
      R = mass*sqrt(2);
    }
    float x = R * sin(beta * i);
    float y = R * cos(beta * i);

    //      form.addPart(new Part(i, new PVector(x, y, mass), new PVector(0, 0, 0), mass));
    ////            form.addPart(new Part(i, new PVector(random(-width/6, width/6), -mass, random(-width/6, width/6)), mass, v));
    form.addPart(new Part(i, new PVector(x, y, 11), new PVector(0, 0, 0), mass)); 
    //            
    //////      test wotate    ////
    //                form.addPart(new Part(n-3, new PVector(0, 0, mass +1), new PVector(0, 0, 0), mass)); 
    //                form.addPart(new Part(n-2, new PVector(20, 0, mass +1), new PVector(0, 0, 0), mass));             
    //                form.addPart(new Part(n-1, new PVector(40, 0, mass +1), new PVector(0, 0, 0), mass));    

    c = n;
  }

}

void spawn () {
  if (start == true) {
    q = (endTime - startTime);
    if (q < 100) {
      q = 1;
    }
    else {
      q = round(q/100);
    }
    for (int i = 0; i< q; i++) {      
      //      form.addPart(new Part( c, new PVector(X, Y, height), new PVector(0, 0, random(0, -2)), mass, v));
      //      c++;

      //      form.addPart(new Part( c, new PVector(random(-100, 100), random(-100, 100), height), new PVector(random(-2, 2), random(-2, 2), random(-2, 0)), mass));
      //      c++;

      //            if(buro) {
      //          form.addPart(new Part( c, new PVector(0, -200, 20), new PVector(1, 0, 1.5), mass));
      //          c++;
      //          form.addPart(new Part( c, new PVector(200, 0, 20), new PVector(0, 1, 1.5), mass));
      //          c++;
      //          form.addPart(new Part( c, new PVector(0, 200, 20), new PVector(-1, 0, 1.5), mass));
      //          c++;
      //          form.addPart(new Part( c, new PVector(-200, 0, 20), new PVector(0, -1, 1.5), mass));
      //          c++;
      //      form.addPart(new Part( c, new PVector(random(-100, 100), random(-100, 100), 2*height/5), new PVector(random(-1, 1), random(-1, 1), random(-1, 0)), mass));
      //      c++; 
      //            }
      //            else {
      //          form.addPart(new Part( c, new PVector(-200, -200, 20), new PVector(0, 0, 2), mass));
      //          c++;
      //          form.addPart(new Part( c, new PVector(200, -200, 20), new PVector(0, 0, 2), mass));
      //          c++;
      //          form.addPart(new Part( c, new PVector(-200, 200, 20), new PVector(0, 0, 2), mass));
      //          c++;
      //          form.addPart(new Part( c, new PVector(200, 200, 20), new PVector(0, 0, 2), mass));
      //          c++; 
      //            }
//      form.addPart(new Part( c, new PVector(random(-100, 100), random(-100, 100), height/2), new PVector(random(-1, 1), random(-1, 1), random(-2, 0)), mass));
//      c++;       
            form.addPart(new Part( c, new PVector(random(-100, 100), random(-100, 100), height/4), new PVector(random(-1, 1), random(-1, 1), random(-1, 0)), random(10, 15)));
                  c++;

      ////    test velocity and replusion    ////

      //          form.addPart(new Part( c, new PVector(0, 200, height/2), new PVector(0, 0, -5), mass, v));
      //          c++;
      //          form.addPart(new Part( c, new PVector(-200, 0, height/2), new PVector(2, 0, 0), mass, v));
      //          c++;

      ////    test wotate      ////
      //        form.addPart(new Part( c+2, new PVector(50, 0, height/8), new PVector(0, 0, -1), mass));
      //              form.addPart(new Part( c, new PVector(am, height/12, mass +1), new PVector(0, -1, 0), mass));
      //              c++;
      ////    test bouncy    ////
      //              form.addPart(new Part( c, new PVector(am, -height/12, mass +1), new PVector(0, 1, 0), mass));
      //              c++;
      //              form.addPart(new Part( c, new PVector(am, height/12, mass +1), new PVector(0, -1, 0), mass));
      //              form.addPart(new Part( c, new PVector(am, 0, height/2), new PVector(0, 0, -1), mass));              
      //              c++;

      ////      TEST DIS    ////
      //      form.addPart(new Part( c, new PVector(random(-150, 150), random(-150, 150), 300), new PVector(random(-1, 1), random(-1, 1), random(-1, 0)), mass));
      //      c++; 
      //      form.addPart(new Part( c, new PVector(random(-150, 150), random(-150, 150), 300), new PVector(random(-2, 2), random(-2, 2), random(-2, 0)), mass));
      //      c++;       
      //      form.addPart(new Part( c, new PVector(random(-150, 150), random(-150, 150), 300), new PVector(random(-1, 1), random(-1, 1), random(-1, 0)), random(10,20)));
      //      c++;       

      //          form.addPart(new Part( c, new PVector(am, 0, height/3), new PVector(0, 0, -5), mass));
      //          c++;

      ////      hemispherical spawning plane    ////
      if (buro) {
        float phiI = random(-PI/2, PI/2);
        float thetaI = random(0, 2*PI);
        float radI = random(150, 200);

        if (groundtog) {
          phiI = random(0, PI/2);
          thetaI = random(0, 2*PI);
          radI = 200;
        }

        form.addPart(new Part( c, new PVector(radI*cos(phiI)*cos(thetaI), radI*cos(phiI)*sin(thetaI), radI*sin(phiI)), new PVector(random(-1, 1), random(-1, 1), random(-1, 0)), mass));
        c++;
      }


      //      if (!ground) {
      //      ////      spherical spawning volume    ////
      //
      //      
      //      form.addPart(new Part( c, new PVector(radI*cos(phiI)*cos(thetaI), radI*cos(phiI)*sin(thetaI), radI*sin(phiI)), new PVector(random(-1, 1), random(-1, 1), random(-1, 1)), mass));
      //      c++; 
      //      }





      collision = true;
    }
  }
  q = 0;
}


void keyPressed() {

  if (key == 'n') {
    start = true;
    spawn();
  }

  if (key == 'r' || key == 'v') {
    rotBuffX = 0;
    rotBuffY = 0;
    panX = 0;
    panY = 0;
    zoom = -200;
    strut = false;
    renderS = false;
  }  

  if (key == 'r') {
    form.reset();
    sep5 = 0;
    setup();
  }

  if (keyCode == CONTROL) {
    rotateYaw = true;
  }

  if (keyCode == SHIFT) {
    colour = true;
  }

  if (key == '+') {
    n++;
    setup();
  }

  if (key == '-') {
    n--;
    setup();
  }

  if (key == 'g') {

    if (groundtog) {
      groundtog = false;
    }
    else {
      groundtog = true;
    }
  }

  if (key == 'c') {
    contacted++;
    if (contacted == 3) {
      contacted = 1;
    }
  }

  if (key == 'l') {

    if (lastatt) {
      lastatt = false;
    }
    else {
      lastatt = true;
    }
  }  

  if (key == 'u') {

    if (buro) {
      buro = false;
    }
    else {
      buro = true;
    }
  }

  if (key == 'i') {

    if (impact) {
      impact = false;
    }
    else {
      impact = true;
    }
  }

  if (key == 's') {
    look++;
    if (look == 4) {
      look = 1;
    }
  }

  if (key == 'y') {
    view = true;
    viewy++;
    if (viewy == 9) {
      viewy = 1;
    }
  }

  if (key == '8') {
    sep5++;
  }

  if (key == '9') {
    sep5--;
  }

  if (key == '5') {
    am++;
  }

  if (key == '2') {
    am--;
  }
}

void keyReleased() {

  if (keyCode == CONTROL) {
    rotateYaw = false;
  }
}

void mouseDragged() {
  drag = true;
  if (mouseButton == LEFT) {
    rotateMode = true;
    mouseDragX += (mouseX - pmouseX);
    mouseDragY += (mouseY - pmouseY);
  }

  if (mouseButton == RIGHT) {
    rotateMode = false;
    pan = true;
    mouseDragXpan += (mouseX - pmouseX);
    mouseDragYpan += (mouseY - pmouseY);
  }

  if (pan) {
    rotateMode = false;
  }
}

void mouseReleased() {
  rotateMode = false;
  pan = false;

  if (mouseButton == LEFT && drag != true) {
    endTime = millis();
  }
  else {
    start = false;
  }
  drag = false;
  spawn();
  start = false;
}

void mouseClicked() {
  if (mouseButton == RIGHT) {
    if (mouseEvent.getClickCount() == 2) {
      panX = 0;
      panY = 0;
    }
  }
}  

void mousePressed() {
  if (mouseButton == LEFT) {
    startTime = millis();
    start = true;
  }
}

