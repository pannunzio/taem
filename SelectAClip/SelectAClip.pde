import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import javax.sql.DataSource;
import java.sql.ResultSet;
import java.util.Random;

import processing.video.*;

import netP5.*;
import oscP5.*;

Connection conn = null;
PFont anton;
PFont arial;
String[] feelingsInventory = {"affectionate", "engaged", "hopeful", "confident", "excited", "grateful", "inspired", "joyful", "exhilarated", "peaceful", "refreshed", "afraid", "annoyed", "angry", "aversion", "confused", "disconnected", "disquiet", "embarassed", "fatigue", "pain", "sad", "tense", "vulnerable", "yearning"};
String[] needsInventory = {"connection", "physicalWellbeing", "honesty", "play", "peace", "autonomy", "meaning"};

enum State{
  ALONE,
  SPEAKING,
  LISTENING
};

enum Behavior{
  PROMPT,
  WAITING,
  REACTION
}

enum Engagement{
  DISMISSAL,
  AGREE,
  DISAGREE,
  QUESTION,
  STATEMENT,
  GREETING
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

int timer = 2000;
int deltaTime = 0;
int subtitleTimer = 0;
int subtitleMax = 250;

Boolean didIHearYou = false;
Boolean trigger = false;
String subtitle;

void setup(){
  fullScreen(2);
  size(800, 600);
  initDBConnection();
  machine = new Machine();
  
  oscNet = new OscP5(this, listeningPort);
  destination = new NetAddress(destinationIP, destinationPort);
  anton = createFont("Anton-Regular.ttf", 100);
  arial = createFont("Arial", 12);
  triggerListener();
 // greetingFlag = true;
  selectAClip();
  clip.volume(0);
  clip.play();
  drawSpeak();
}

void drawSpeak(){
  textAlign(CENTER, CENTER);
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
  }else {
    if(machine.getState() == State.LISTENING){
      deltaTime++;
      if(deltaTime > timer){
        machine.resetTimer();
        machine.setState(State.ALONE);
        clip.volume(0);
        deltaTime = 0;
      }
    }
  } 
  
  drawStats();
  
  if (machine.getState() == State.ALONE){
    drawSpeak();
  }
  
  drawSubtitles();
  
  if(trigger){
    triggerListener();
    trigger = false;
  }
}

void drawSubtitles(){
  textAlign(CENTER, CENTER);
  
  subtitleTimer++;
  textFont(arial);
  textSize(20);
  if(subtitleTimer >= subtitleMax)
    subtitle = null;
  else if(subtitle != null)
    text("\"" + subtitle + "\"", width/2, height - 80);
  if( machine.getState() == State.SPEAKING && machine.getSubtitle() != null)
    text("\"" + machine.getSubtitle() + "\"", width/2, height-40);
}

void drawStats() {
  textSize(12);
  textFont(arial);
  
  textAlign(CORNER, TOP);
  text("primary need: " + machine.getPrimaryNeed(), 10, 10); 
  text("current state: " + machine.getStateString(), 10, 30); 
  if(machine.getState() == State.SPEAKING){
   text("current engagement: " + machine.getEngagementString(), 10, 50);
   text("current behavior: " + machine.getBehaviorString(), 10, 70);  
  }
}

// AKA did i hear you?
void oscEvent(OscMessage incoming) {
  if(incoming.checkAddrPattern("/brain")){
    //the brains willll send array of words
    if(incoming.arguments().length > 0) {
      didIHearYou = true;
      if (machine.getState() == State.ALONE){
          machine.setState(State.SPEAKING);
          clip.volume(10);
      } else if(machine.getState() == State.LISTENING){
          machine.setState(State.SPEAKING);
          clip.volume(10);
          machine.setBehavior(Behavior.REACTION);
          
          float r = new Random().nextInt(100);
          if(r < 25)
            machine.setEngagement(Engagement.QUESTION);
          else if (r < 50)
            machine.setEngagement(Engagement.STATEMENT);
          else if (r < 75)
            machine.setEngagement(Engagement.AGREE);
          else
            machine.setEngagement(Engagement.DISAGREE);
        }
      String s = "";
      for (Object arg: incoming.arguments()){
        s += " " + (String) arg;
      }
      subtitle = s;
      subtitleTimer = 0;
      machine.updateState();
    }
  }
  
  else if (incoming.checkAddrPattern("/researchAssistant")){
    
    for(int i = 0; i < incoming.arguments().length - 1; i += 2){
      String needs = incoming.get(i).stringValue();
      int score = incoming.get(i+1).intValue();
      println("research incoming: " + needs + ": " + score);
      
      machine.updateNeed(needs.toLowerCase(), score);
      println("NEEDS ---> " + needs);
    }
      //machine.updateNeed(n.toLowerCase());
  }
}

void triggerListener() {
    OscMessage msg = new OscMessage("/mouth");
    oscNet.send(msg, destination);
}

void movieEvent(Movie m){
  
  if(machine.getState() == State.ALONE){
    
    machine.setBehavior(Behavior.PROMPT);
    machine.setEngagement(Engagement.GREETING);
    if(clip.time() >= 0.3){
      clip.jump(0.0);
    }
  } 

  m.read();
  
  if(clip.time() >= clip.duration()-0.1){
    if(machine.getState() == State.ALONE ){
        clip.volume(0);
    } 
    
    
    if(machine.getState() == State.SPEAKING 
        && (machine.getPreviousState() == State.LISTENING || machine.getPreviousState() == State.ALONE )){
      machine.setState(State.SPEAKING);
      clip.volume(10);
    }else if (machine.getState() == State.SPEAKING && machine.getPreviousState() == State.SPEAKING){
      machine.setState(State.LISTENING);
      clip.volume(2);
      trigger = true;
    }
    
    selectAClip();
    clip.play();
  }
}
 
