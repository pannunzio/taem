import netP5.*;
import oscP5.*;
import processing.video.*;

Movie clip;
Boolean isPlaying = false;

OscP5 oscNet;
int listeningPort = 11999;

NetAddress destination;
int destinationPort = 12000;

String[] parsedMessage;
String fileDirectory = "../tags.csv";
String destinationIP = "127.0.0.1";
String selectedClip;
String FILEPATH = "../../../clips/";

int timer = 1000;
float deltaTime = 0;

int WAITING = 0;
int DANCING = 1;
int currentState = 0;

void setup(){
  //fullScreen(2);
  size(800, 600);
  
  oscNet = new OscP5(this, listeningPort);
  destination = new NetAddress(destinationIP, destinationPort);
  triggerListener();
  //printTable();
  selectAClip(currentState);
  clip.play();
}

void draw() {
  updateState();
  //delay(1000);
  if(isPlaying){
    image(clip, 0, 0);
  } else {
   selectAClip(currentState);
   clip.play();
  }
  
}

void updateState(){
  //TO DO <3
}

void selectAClip(String[] parsedMessage){
  this.selectedClip = getRandomVid();
  isPlaying = true;
  this.clip = new Movie(this, FILEPATH + this.selectedClip) {
    @ Override public void eosEvent() {
      super.eosEvent();
      myEoS();
    }
  };
}

void selectAClip(int state){
  switch(state){
    case 1:
      //  TO DO
      break;
    case 0:
      //TO DO
      break;
    default:
      break;
  }
  
  this.selectedClip = getRandomVid();
  isPlaying = true;
  this.clip = new Movie(this, FILEPATH + this.selectedClip) {
    @ Override public void eosEvent() {
      super.eosEvent();
      myEoS();
    }
  };
}

String getRandomVid(){
  Table t = loadTable(fileDirectory, "header");
  int count = t.getRowCount();
  float r = random(2, count-1);
  TableRow row = t.getRow((int) r);
  return row.getString("Clip Name");
}

void printTable(){
  Table table;

  table = loadTable(fileDirectory, "header");

  for (TableRow row : table.rows()) {

    String name = row.getString("Clip Name");
    String cat = row.getString("Category");
    String need = row.getString("Needs");
    String feel = row.getString("Feelings");
    String act = row.getString("Label");

    println(name + " -> (" + cat + ") | Needs: " + need + " || Feelings: " + feel + " || Label: " + act);
  }
}

void keyPressed() {
    if (key == 'p' || key == 'P') {
      clip.pause();
    }else {
      clip.play();
    }
}

void oscEvent(OscMessage incoming) {
    String s = incoming.get(0).stringValue();
    String[] parsedMessage = splitTokens(s, " ");
    println(s);
    selectAClip(parsedMessage);
    triggerListener();
}

void triggerListener() {
    OscMessage msg = new OscMessage("/mouth");
    oscNet.send(msg, destination);
}

void movieEvent(Movie m){
  m.read();
}

void myEoS() {
  isPlaying = false;
}
