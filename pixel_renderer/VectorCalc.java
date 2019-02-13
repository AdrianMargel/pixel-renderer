public class VectorCalc{
  static float dotProduct(Vector v1,Vector v2){
    return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z;
  }
  static Vector crossProduct(Vector v1,Vector v2){
    return new Vector(v1.y*v2.z-v1.z*v2.y  ,  v1.z*v2.x-v1.x*v2.z  ,  v1.x*v2.y-v1.y*v2.x);
    /*
      X1,Y1,Z1,X1,Y1,Z1
           X  X  X
      X2,Y2,Z2,X2,Y2,Z2
      
      v1.y*v2.z-v1.z*v2.y  ,  v1.z*v2.x-v1.x*v2.z  ,  v1.x*v2.y-v1.y*v2.x
    */
  }
}