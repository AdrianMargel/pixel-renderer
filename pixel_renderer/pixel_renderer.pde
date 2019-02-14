/*
  Pixel Renderer
  --------------
  This is a simple ray tracer that runs on the CPU. It supports 3d textures and lighting via a depth variable.
  It also supports colored light sources and textures as well as shadows.
  
  Controls:
    Mouse - controls position of player light source
    Scroll - moves player light source closer or further away
    Left Click - raises the texture making a bump
    Right Click - colors the texture making a green dot
  
  written by Adrian Margel, Summer 2017
*/

//texture displayed
Pixel[][] texture;
//light source for mouse
LightSource light = new LightSource(0,0,-10,50,new RGBColor(0,255,255));
//all smaller light sources
ArrayList<LightSource> lights = new ArrayList<LightSource>();

void setup() {
  //add many smaller light sources randomly
  for(int i=0;i<20;i++){
    lights.add(new LightSource((int)random(50,150),(int)random(50,150),0,30,new RGBColor(255,160,10)));
  }
  //spawn a birght white light
  lights.add(new LightSource((int)random(50,150),(int)random(50,150),-10,100,new RGBColor(255,255,255)));
  
  //turn off anti-aliasing
  noSmooth();
  //turn off stroke
  noStroke();
  //setup window size
  size(800, 800);
  
  //spawn in pixels
  texture = new Pixel[200][200];
  for (int x=0; x<200; x++) {
    for (int y=0; y<200; y++) {
      //create a grid pattern
      //texture[x][y]=(new Pixel(5+15-max(min(x%20,1)+min(y%20,1),1)*5));
      texture[x][y]=(new Pixel(5+max(min(x%20,1)+min(y%20,1),1)));
    }
  }
  
  //calculate the slope of the pixels
  for (int x=0; x<texture.length; x++) {
    for (int y=0; y<texture[x].length; y++) {
      texture[x][y].calcAngles(x,y,texture);
    }
  }
}

void draw() {
  //move small lights randomly
  for(int i=0;i<lights.size();i++){
    lights.get(i).x+=(int)random(-2,2);
    lights.get(i).y+=(int)random(-2,2);
  }
  //set the large light to the mouse pos
  light.x=mouseX/4;
  light.y=mouseY/4;
  //reset the displayed texture
  for (int x=0; x<texture.length; x++) {
    for (int y=0; y<texture[x].length; y++) {
      texture[x][y].resetColor();
    }
  }
  //apply lighting to the texture
  for(int i=0;i<lights.size();i++){
    lights.get(i).light(texture);
  }
  light.light(texture);
  
  //display the lit up texture
  for (int x=0; x<texture.length; x++) {
    for (int y=0; y<texture[x].length; y++) {
      texture[x][y].display(x,y,4);
    }
  }
}

//basic color class
//used to make it easier to move this code to another language
class RGBColor {
  int red;
  int green;
  int blue;
  RGBColor(int red, int green, int blue) {
    this.red=red;
    this.green=green;
    this.blue=blue;
  }
  void brighten(RGBColor addColor){
    red = min(red+addColor.red,255);
    green = min(green+addColor.green,255);
    blue = min(blue+addColor.blue,255);
  }
}

class Pixel {
  int depthStart;//if start == end then assume infinite depth
  int depthEnd;
  RGBColor baseColor;
  RGBColor displayColor= new RGBColor(0, 0, 0);
  float angleX;
  float angleY;
  Pixel(int depth) {
    this.depthEnd = depth;
    baseColor = new RGBColor(255,255,255);
  }
  void resetColor(){
    displayColor=new RGBColor(0,0,0);
  }
  
  //calculates the angle of the pixel based on the heights of it's neighbors
  void calcAngles(int x,int y,Pixel[][] texture) {
    //find surrounding depths
    int XDepth1=depthEnd;
    int XDepth2=depthEnd;
    int YDepth1=depthEnd;
    int YDepth2=depthEnd;
    if (texture.length>x+1) {
      XDepth1 = texture[x+1][y].depthEnd;
    }
    if (0<x-1) {
      XDepth2 = texture[x-1][y].depthEnd;
    }
    if (texture[x].length>y+1) {
      YDepth1 = texture[x][y+1].depthEnd;
    }
    if (0<y-1) {
      YDepth2 = texture[x][y-1].depthEnd;
    }
    //calculate correct angles
    angleX=atan2(XDepth1-XDepth2, 3);//3 is the space between the 2 pixels
    angleY=atan2(YDepth1-YDepth2, 3);//3 is the space between the 2 pixels
  }
  void display(int x,int y,float scale) {
    //fill((sin(angleX)+1)*255/2,(sin(angleY)+1)*255/2,255/2);
    fill(displayColor.red,displayColor.green,displayColor.blue);
    rect(x*scale, y*scale, scale, scale);
  }
}

//casts light
class LightSource {
  //position (the vector class uses float so it cant be used here)
  int x;
  int y;
  //the z coord of how deep into the screen it is
  int depth;
  
  //how bright the light is
  int brightness;
  //what color the light is
  RGBColor lightColor;
  
  LightSource(int x,int y,int depth,int brightness,RGBColor lightColor){
    this.x=x;
    this.y=y;
    this.depth=depth;
    this.brightness=brightness;
    this.lightColor=lightColor;
  }

  //apply lighting to the texture
  void light(Pixel[][] texture) {
    //for all pixels within range of the brightness 
    for (int tx=max(x-brightness,0); tx<min(x+brightness,texture.length); tx++) {
      for (int ty=max(y-brightness,0); ty<min(y+brightness,texture[tx].length); ty++) {
        RGBColor tempColor=new RGBColor(0, 0, 0);
        //if light is in front of the pixel
        if (texture[tx][ty].depthEnd>depth) {
          //calculate dist
          float lightDist=sqrt(sq(tx-x)+sq(ty-y)+sq(texture[tx][ty].depthEnd-depth));
          //if within light range
          if (lightDist<=brightness) {
            float shadow=1;

            //calculate distances
            int distX=tx-x;
            int distY=ty-y;
            int distZ=texture[tx][ty].depthEnd-depth;
            
            //cast shadows
            boolean posX=true;
            boolean posY=true;
            //make distances absolute
            if (distX<0) {
              posX=false;
              distX*=-1;
            }
            if (distY<0) {
              posY=false;
              distY*=-1;
            }
            //this works by drawing a line from the pixel to the light source
            //if the line hits something draw a shadow
            if (distX>distY) {
              int temp=0;
              //positivedraw a line based on all x values
              for (int x=0; x<distX; x++) {
                temp++;
                //real x y
                int Rx=x;
                int Ry=x*distY/distX;
                if (!posX) {
                  Rx*=-1;
                }
                if (!posY) {
                  Ry*=-1;
                }
                int Rz=x*distZ/distX;
                if (tx-Rx>=0&&tx-Rx<texture.length
                  &&ty-Ry>=0&&ty-Ry<texture[tx-Rx].length
                  &&texture[tx-Rx][ty-Ry].depthEnd<depth-Rz) {
                  shadow=0.1;
                }
              }
            } else {
              for (int y=0; y<distY; y++) {
                int Rx=y*distX/distY;
                int Ry=y;
                if (!posX) {
                  Rx*=-1;
                }
                if (!posY) {
                  Ry*=-1;
                }
                int Rz=y*distZ/distY;
                if (tx-Rx>=0&&tx-Rx<texture.length
                  &&ty-Ry>=0&&ty-Ry<texture[tx-Rx].length
                  &&texture[tx-Rx][ty-Ry].depthEnd<depth-Rz) {
                  shadow=0.1;
                }
              }
            }

            //calculate the vector that would yield the highest brightness
            Vector ideal = new Vector((tx-x)/lightDist, (ty-y)/lightDist, (texture[tx][ty].depthEnd-depth)/lightDist);
            
            //calculate the real vector of the surface (cross product)
            Vector vX = new Vector(cos(texture[tx][ty].angleX), 0, sin(texture[tx][ty].angleX));
            Vector vY = new Vector(0, cos(texture[tx][ty].angleY), sin(texture[tx][ty].angleY));
            Vector real=VectorCalc.crossProduct(vY, vX);

            //calculate the light based on the angle of the surface
            //use dot product to compare the real vector with the ideal vector
            float lightA = VectorCalc.dotProduct(real, ideal);
            //calculate the light based of the distance between the surface and the light source
            float lightD=1-((lightDist)/brightness);//should also consider depth
            //calculate the percentage the pixel will be lit (0 to 1)
            float light=max(-lightA*lightD*shadow, 0);
            
            //calculate the percentage of each color the pixel will be (0 to 1)
            float redPercent=light*((float)lightColor.red/255)*((float)texture[tx][ty].baseColor.red/255);
            float greenPercent=light*((float)lightColor.green/255)*((float)texture[tx][ty].baseColor.green/255);
            float bluePercent=light*((float)lightColor.blue/255)*((float)texture[tx][ty].baseColor.blue/255);
            //generate the lighting from the render
            tempColor=new RGBColor((int)(redPercent*255), (int)(greenPercent*255), (int)(bluePercent*255));
            //add the color to the pixel
            texture[tx][ty].displayColor.brighten(tempColor);
          }
        }
      }
    }
  }
}

//user clicks
void mousePressed() {
  if (mouseButton == LEFT) {
    //if left click raise the depth of the map
    int brushSize=5;
    for (int x=0; x<brushSize; x++) {
      for (int y=0; y<brushSize; y++) {
        int rx=(int)(mouseX/4)+x;
        int ry=(int)(mouseY/4)+y;
        if(rx>=0&&rx<texture.length&&ry>=0&&ry<texture[x].length)
          texture[rx][ry].depthEnd-=1;
      }
    }
    for (int x=0; x<brushSize+2; x++) {
      for (int y=0; y<brushSize+2; y++) {
        int rx=(int)(mouseX/4)+x-1;
        int ry=(int)(mouseY/4)+y-1;
        if(rx>=0&&rx<texture.length&&ry>=0&&ry<texture[x].length)
          texture[rx][ry].depthEnd-=1;
      }
    }
    for (int x=0; x<texture.length; x++) {
      for (int y=0; y<texture[x].length; y++) {
        texture[x][y].calcAngles(x,y,texture);
      }
    }
  }else{
    //if right click color the map green
    int brushSize=5;
    for (int x=0; x<brushSize; x++) {
      for (int y=0; y<brushSize; y++) {
        int rx=(int)(mouseX/4)+x;
        int ry=(int)(mouseY/4)+y;
        if(rx>=0&&rx<texture.length&&ry>=0&&ry<texture[x].length)
          texture[rx][ry].baseColor=new RGBColor((int)random(60,80),(int)random(200,240),(int)random(50,80));
      }
    }
  }
}

//scroll
void mouseWheel(MouseEvent event) {
  //change depth of the player's light
  float e = event.getCount();
  light.depth+=e;
}
