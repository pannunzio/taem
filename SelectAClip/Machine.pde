import java.util.Map;

float timeout = 10000;

public class Machine{
  private HashMap<String, Float> needs;
  private State currentState;
  private Engagement engagementState;
  
  private String  primaryNeed;
  private Float   primaryScore;
  
  public Machine(){
    this.needs = new HashMap<String, Float>();
    this.currentState = State.WAITING;
    this.engagementState = Engagement.ALONE;
    this.primaryNeed = "connection";
    this.primaryScore = 0.0;
    
    //all needs begin with a score of 80% met -- contentness 
    for (int i = 0; i < needsInventory.length; i++){
      needs.put(needsInventory[i].toLowerCase(), 0.0f);
    }
    
    //since the initial state is waiting, the needs that need to be met are meaning and connection
    //needs.put("connection", needs.get("connection") - random(1.5, 2));
    //needs.put("meaning", needs.get("meaning") - random(1.5, 2));
    
    updatePrimaryNeed();
  }
  
  void updateNeed(String need){  
    println("need updated: " + need);
    needs.put(need, needs.get(need) + 1);
    updatePrimaryNeed();
  }
  
  void updatePrimaryNeed(){
    for (Map.Entry n : needs.entrySet()) {
      if((float) n.getValue() > this.primaryScore){
        this.primaryNeed = (String) n.getKey();
        this.primaryScore = (float) n.getValue();
      }
    }
    println("primary Need: " + primaryNeed);
  }
  
  void resetNeeds(){
     for (int i = 0; i < needsInventory.length; i++){
      needs.remove(needsInventory[i].toLowerCase());
    }
    for (int i = 0; i < needsInventory.length; i++){
      needs.put(needsInventory[i].toLowerCase(), 0.0f);
    }
  }
   
   
  void stateChanger(){
    String tieBreaker = "honesty";
    Float minScore = 10.0;
    for (Map.Entry n : needs.entrySet()) {
      if((float) n.getValue() >= minScore
          && !this.primaryNeed.equals((String) n.getKey())){
        tieBreaker = (String) n.getKey();
        minScore = (float) n.getValue();
      }
    }
    
    //so we got the top 2 needs now
    switch(this.primaryNeed){
      case "connection":
        if(getCurrentEngagementState() == Engagement.LISTENING){
            reactionFlag = true;
            dialogFlag = false;
            cancelDialog = true;
        }else if(getCurrentEngagementState() == Engagement.SPEAKING){
          dialogFlag = true;
          cancelDialog = false;
          if(getCurrentState() == State.ACTION){
            if(tieBreaker.equals("peace")){
              setState(State.WAITING);
              reactionFlag = true;
            } else {
              setState(State.QUESTION);
              questionFlag = true;
            }
          }
        } else if(getCurrentEngagementState() == Engagement.ALONE){
          cancelDialog = true;
          dialogFlag = false;
          if(getCurrentState() == State.ACTION){
            if(tieBreaker.equals("play") || tieBreaker.equals("physicalWellbeing") || tieBreaker.equals("meaning")){
              setState(State.QUESTION);
              questionFlag = true;
            } else {
              setState(State.WAITING);
              greetingFlag = true;
              questionFlag = false;
            }
          }
        }
        break;
      case "physicalwellbeing":
      case "play":
        setState(State.ACTION);
        movementFlag = true;
        break;
      case "meaning":
        if(getCurrentEngagementState() == Engagement.ALONE){
          setState(State.ACTION);
        } else if(getCurrentEngagementState() == Engagement.SPEAKING){
            setState(State.QUESTION);
            questionFlag = true;
            dialogFlag = true;
            cancelDialog = false;
        } else if(getCurrentEngagementState() == Engagement.LISTENING){
            dialogFlag = false;
            reactionFlag = true;
            cancelDialog = true;
        }
        break;
      case "honesty":
        if(getCurrentEngagementState() == Engagement.LISTENING){
          cancelDialog = true;
          dialogFlag = false;
          if( getCurrentState() == State.ACTION){
            if(!tieBreaker.equals("peace")){
              setState(State.QUESTION);
              questionFlag = true;
            }else
               setState(State.WAITING);
               reactionFlag = true;
          }
        } else if(getCurrentEngagementState() == Engagement.SPEAKING){
          if( getCurrentState() != State.QUESTION){
            setState(State.QUESTION);
          }
          dialogFlag = true;
          questionFlag = true;
          cancelDialog = false;
        } 
        break;
      case "autonomy": 
        dialogFlag = true;
        if(getCurrentEngagementState() != Engagement.SPEAKING){
          setEngagementeState(Engagement.SPEAKING);
        }
        if(tieBreaker.equals("physicalwellbeing") || tieBreaker.equals("play")) {
          setState(State.ACTION);
          movementFlag = true;
        } else{
          setState(State.QUESTION);
          questionFlag = true;  
        }
        reactionFlag = false;
        break;
      case "peace":
          setState(State.ACTION);
          dialogFlag = false;
          cancelDialog = true;
          questionFlag = false;
          reactionFlag = false;
        break;
      default:
        break;
    }
    println("get Engagement: " + getCurrentEngagementString());
    println("get state: " + this.currentState);
  }
  
  boolean updateState(float deltaTime){
    boolean resetTimeout = false;
    
    stateChanger();
   
    if(getCurrentEngagementState() == Engagement.LISTENING 
      && getCurrentState() == State.WAITING
      && deltaTime > timeout){
      setEngagementeState(Engagement.ALONE);
      resetTimeout = true;
      cancelDialog = true;
      greetingFlag = true;
      dialogFlag = false;
      resetNeeds();
    }
    println("new state: " + this.currentState);
    return resetTimeout;
  }
  
  Engagement getCurrentEngagementState(){
    return this.engagementState;
  }
  
  String getCurrentEngagementString(){
    switch(this.engagementState){
      case LISTENING:
       return "LISTENING";
      case SPEAKING:
       return "SPEAKING";
      case ALONE:
        return "ALONE";
      default:
        return "ALONE";
    }
  }
  
  void setEngagementeState(Engagement e){
    this.engagementState = e;
  }
  
  State getCurrentState (){
    return this.currentState;
  }

  String getCurrentStateString (){
    switch(this.currentState){
      case WAITING:
       return "WAITING";
      case QUESTION:
       return "QUESTION";
      case ACTION:
        return "ACTION";
      default:
        return null;
    }
  }  
  
  void setState(State state){
    this.currentState = state;
  }
  
  String getPrimaryNeed(){
    return this.primaryNeed;
  }
  
  //FOR TESTING ONLY!!!!
  void setPrimaryNeed(String need){
    this.primaryNeed = need;
  }
}
