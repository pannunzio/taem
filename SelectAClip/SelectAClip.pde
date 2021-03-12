import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import javax.sql.DataSource;
import java.sql.ResultSet;

import processing.video.*;

import netP5.*;
import oscP5.*;

Connection conn = null;
PFont anton;
String[] feelingsInventory = {"affectionate", "engaged", "hopeful", "confident", "excited", "grateful", "inspired", "joyful", "exhilarated", "peaceful", "refreshed", "afraid", "annoyed", "angry", "aversion", "confused", "disconnected", "disquiet", "embarassed", "fatigue", "pain", "sad", "tense", "vulnerable", "yearning"};
String[] needsInventory = {"connection", "physicalWellbeing", "honesty", "play", "peace", "autonomy", "meaning"};

enum State{
  WAITING,
  ACTION,
  QUESTION
};

enum Engagement{
  LISTENING,
  SPEAKING,
  ALONE
};

Machine machine;
XML dictionary;

Movie clip;
Boolean isPlaying = false;

OscP5 oscNet;
int listeningPort = 12103; //hears from the RA

NetAddress destination;
int destinationPort = 12001; //talks to brain

String fileDirectory = "../tags.csv";
String destinationIP = "127.0.0.1";
String selectedClip;
String FILEPATH = "../../clips/";

int timer = 30000;
int deltaTime = 0;

Boolean didIHearYou = false;

Boolean greetingFlag = false;
Boolean movementFlag = false;
Boolean dialogFlag = false;
Boolean reactionFlag = false;
Boolean questionFlag = false;
Boolean cancelDialog = false;
Boolean actionFlag = false;

Boolean speakingFlag = false;
Boolean interrupt = false;

void setup(){
  fullScreen();
  //size(800, 600);
  initDBConnection();
  machine = new Machine();
  
  oscNet = new OscP5(this, listeningPort);
  destination = new NetAddress(destinationIP, destinationPort);
  anton = createFont("Anton-Regular.ttf", 100);
  textAlign(CENTER, CENTER);
  triggerListener();
  greetingFlag = true;
  selectAClip();
  clip.volume(0);
  clip.play();
  drawAnton();
}

void drawAnton(){
  textFont(anton);
  text("SPEAK", width/2, height/2);
}

void draw() {
  background(0);
  try{
    image(clip, 0, 0);
  } catch(ArrayIndexOutOfBoundsException e){
    println(e.getMessage());
  }
  
  if(didIHearYou){
    deltaTime = 0;
    didIHearYou = false;
    if(machine.getCurrentEngagementState() == Engagement.LISTENING){
      //machine.setEngagementeState(Engagement.SPEAKING);
      speakingFlag = true;
      clip.volume(10);
      dialogFlag = true;
    } else {
      clip.volume(3);
    }
  }else {
    deltaTime++;
    if(machine.getCurrentEngagementState() == Engagement.SPEAKING){
      //machine.setEngagementeState(Engagement.LISTENING);
      //clip.volume(3);
      //cancelDialog = true;
    }
    if(deltaTime > timer){
      if(machine.updateState(deltaTime)){
        deltaTime = 0;
      }
    }
  } 
  
  textSize(12);
  text("current state: " + machine.getCurrentStateString(), 100, 30); 
  textSize(12);
  text("current engagement: " + machine.getCurrentEngagementString(), 100, 50); 
  textSize(12);
  text("primary need: " + machine.getPrimaryNeed(), 100, 70); 
  
  if (machine.getCurrentEngagementState() == Engagement.ALONE
        && machine.getCurrentState() == State.WAITING){
          drawAnton();
    }
}

// AKA did i hear you?
void oscEvent(OscMessage incoming) {
  if(incoming.checkAddrPattern("/brain")){
    //the brains willll send array of words
    if(incoming.arguments().length > 0) {
      didIHearYou = true;
      reactionFlag = true;
      if (machine.getCurrentEngagementState() == Engagement.ALONE
        && machine.getCurrentState() == State.WAITING){
          machine.setEngagementeState(Engagement.SPEAKING);
          clip.volume(10);
          machine.setState(State.QUESTION);
          cancelDialog = false;
          dialogFlag = true;
      } 
      machine.updateState(deltaTime);
      triggerListener();
  }
  else if (incoming.checkAddrPattern("/researchAssistant")){
    //only sends a single word --> the need!
    String n = incoming.get(0).stringValue();
    println("research incoming: " + n);
    if(n != null) {
      machine.updateNeed(n.toLowerCase());
    }
  }
}

void triggerListener() {
    OscMessage msg = new OscMessage("/mouth");
    oscNet.send(msg, destination);
}

void movieEvent(Movie m){
  
  if(machine.getCurrentState() == State.WAITING){
    if(machine.getCurrentEngagementState() == Engagement.ALONE){
      greetingFlag = true;
      if(clip.time() >= 0.3){
        clip.jump(0.0);
      }
    } 
  }
  
  m.read();
  
  if(clip.time() >= clip.duration()-0.1){
   //machine.updateState(deltaTime);
   println("called from video event");
    if(machine.getCurrentEngagementState() == Engagement.ALONE ){
      if(machine.getCurrentState() == State.WAITING){
        clip.volume(0);
      }
    } else if(machine.getCurrentEngagementState() == Engagement.LISTENING){
        dialogFlag = false;
        cancelDialog = true;
        clip.volume(3);
    } 
    if(machine.getCurrentEngagementState() == Engagement.SPEAKING && !speakingFlag){
      machine.setEngagementeState(Engagement.LISTENING);
      dialogFlag = false;
      cancelDialog = true;
      clip.volume(3);
    } 
    if(speakingFlag){
      machine.setEngagementeState(Engagement.SPEAKING);
      speakingFlag = false;
      dialogFlag = true;
      cancelDialog = true;
    }
    
    selectAClip();
    clip.play();
  }
}
void resetFlags(){
  greetingFlag = false;
  movementFlag = false;
  dialogFlag   = false;
  reactionFlag = false;
  questionFlag = false;
  cancelDialog = false;
  actionFlag = false;
}
 
void printFlags(){
  println("flags: " +greetingFlag + " " + movementFlag + " " +dialogFlag + " " +reactionFlag + " " +questionFlag + " " +cancelDialog + " " +actionFlag);
}
  
Boolean hasFlags(){
  if(greetingFlag || movementFlag || dialogFlag || reactionFlag || questionFlag || cancelDialog || actionFlag)
    println("has flags!");
  else
    println("no flags ):");
  return greetingFlag || movementFlag || dialogFlag || reactionFlag || questionFlag || cancelDialog || actionFlag;
}
