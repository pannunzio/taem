public class Pair{
  Object a;
  Object b;
  
  public Pair(Object a, Object b){
    this.a = a;
    this.b = b;
  }
  
  Object getA(){
    return this.a;
  }
  
  Object getB(){
    return this.b;
  }
  
  void setA(Object a){
    this.a = a;
  }
  
  void setB(Object b){
    this.b = b;
  }
}
