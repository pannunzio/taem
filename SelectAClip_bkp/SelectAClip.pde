import processing.video.*;

import netP5.*;
import oscP5.*;

String[] feelingsInventory = {"affectionate", "engaged", "hopeful", "confident", "excited", "grateful", "inspired", "joyful", "exhilarated", "peaceful", "refreshed", "afraid", "annoyed", "angry", "aversion", "confused", "disconnected", "disquiet", "embarassed", "fatigue", "pain", "sad", "tense", "vulnerable", "yearning"};
String[] needsInventory = {"connection", "physicalWellbeing", "honesty", "play", "peace", "autonomy", "meaning"};

enum State{
  WAITING,
  ACTION,
  QUESTION,
  REACTION
};

enum Engagement{
  LISTENING,
  SPEAKING,
  ALONE
};

Machine machine = new Machine();
XML dictionary;

Movie clip;
Boolean isPlaying = false;

OscP5 oscNet;
int listeningPort = 11999;

NetAddress destination;
int destinationPort = 12000;

String fileDirectory = "../tags.csv";
String destinationIP = "127.0.0.1";
String selectedClip;
String FILEPATH = "../../clips/";

int timer = 15000;
float deltaTime = 0;

Boolean didIHearYou = false;

void setup(){
  fullScreen(2);
  //size(800, 600);
  
  dictionary = loadXML("../wordsReceived.xml");
  
  oscNet = new OscP5(this, listeningPort);
  destination = new NetAddress(destinationIP, destinationPort);
  triggerListener();
  
  selectAClip();
  clip.play();
  //println(getRequestUrl() + getToken());
}

void draw() {
  background(0);
  updateState();
  try{
    pushMatrix();
      translate(width/2 - clip.width/2, height/2 - clip.height/2);
      image(clip, 0, 0);
    popMatrix();
  } catch(ArrayIndexOutOfBoundsException e){
  }
  deltaTime += millis();
  if(didIHearYou){
    didIHearYou = false;
    deltaTime = 0;
  } else {
    
    //have you been waiting long?
    //update state with negative connection & meaning
    if(deltaTime > timer){
      ArrayList<Pair> l = new ArrayList<Pair>();
      l.add(new Pair("connection", false));
      l.add(new Pair("meaning", false));
      machine.updateState(l);
    }
  }
}

void updateState(){
}

void selectAClip(){
  this.selectedClip = getVid();
  isPlaying = true;
  clip = new Movie(this, FILEPATH + this.selectedClip);
/*  
  switch(machine.getCurrentState()){
    case WAITING:
      //  TO DO
      break;
    case REACTION:
      //TO DO
      break;
      
    case ACTION:
      break;
    case QUESTION:
      break;
    default:
      break;
  }
  */
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

    didIHearYou = true;
    beginPhraseAnalysis(parsedMessage);
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
    if(machine.getCurrentState() == State.QUESTION)
      machine.setState(State.REACTION);
    else
      machine.setState(State.WAITING);
    selectAClip();
    clip.play();
  }
}
