import java.util.Map;

public class Machine{
  private HashMap<String, Float> needs;
  private State currentState;
  
  private String  primaryNeed;
  private Float   primaryScore; 
  
  public Machine(){
    this.needs = new HashMap<String, Float>();
    this.currentState = State.WAITING;
    
    //all needs begin with a score of 80% met -- contentness 
    for (int i = 0; i < needsInventory.length; i++){
      needs.put(needsInventory[i].toLowerCase(), random(8, 10));
    }
    
    //since the initial state is waiting, the needs that need to be met are meaning and connection
    needs.put("connection", needs.get("connection") - random(1.5, 2));
    needs.put("connection", needs.get("meaning") - random(1.5, 2));
  }
  
  void updateNeed(String need, Boolean isMet){
    float increment = random(0,10);
    if(!isMet)
      increment *= -1;
      
    needs.put(need, needs.get(need) + increment);
  }
  
  void updateState(ArrayList<Pair> needUpdate){
    for(Pair p : needUpdate){
      String needName;
      Boolean isMet;
      Float increment = random(0, 2);
      
      needName = (String) p.getA();
      isMet = (Boolean) p.getB();
      
      if(!isMet) increment *= -1;
      
      needs.put(needName, needs.get(needName) + increment);
    }
   
    for (Map.Entry n : needs.entrySet()) {
      if((float) n.getValue() <= this.primaryScore){
        this.primaryNeed = (String) n.getKey();
        this.primaryScore = (float) n.getValue();
      }
    }
    
    

  }
  
  State getCurrentState (){
    return this.currentState;
  }
}
