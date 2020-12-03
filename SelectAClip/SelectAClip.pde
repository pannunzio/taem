import processing.video.*;

import netP5.*;
import oscP5.*;

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
String FILEPATH = "../../clips/";

int timer = 1000;
float deltaTime = 0;

enum State{
  WAITING,
  ACTION,
  QUESTION,
  REACTION
};
  
State currentState = State.WAITING;

Boolean didIHearYou = false;

void setup(){
  //fullScreen(2);
  size(800, 600);
  
  oscNet = new OscP5(this, listeningPort);
  destination = new NetAddress(destinationIP, destinationPort);
  triggerListener();
  selectAClip();
  clip.play();
  //println(getRequestUrl() + getToken());
}

void draw() {
  updateState();
  image(clip, 0, 0);
  
  if(didIHearYou){
    didIHearYou = false;
    beginPhraseAnalysis();
  } else {
    //have you been waiting long?
    //update state with negative connection & meaning
  }
}

void updateState(){
  //TO DO <3
  //How to determine the current state of the machine?? what does it feel?????
  this.currentState = State.WAITING;
}

//void selectAClip(String[] parsedMessage){
void selectAClip(){
  this.selectedClip = getRandomVid();
  isPlaying = true;
  clip = new Movie(this, FILEPATH + this.selectedClip);
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

// AKA did i hear you?
void oscEvent(OscMessage incoming) {
    String s = incoming.get(0).stringValue();
    String[] parsedMessage = splitTokens(s, " ");
    println(s);
    didIhearYou = true;
    //selectAClip(parsedMessage);
    selectAClip();
    triggerListener();
}

void triggerListener() {
    OscMessage msg = new OscMessage("/mouth");
    oscNet.send(msg, destination);
}

void movieEvent(Movie m){
  m.read();
  
  if(clip.time() >= clip.duration()-0.1){
    selectAClip();
    clip.play();
  }
}
