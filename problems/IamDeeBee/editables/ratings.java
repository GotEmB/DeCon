import java.io.*;

public class Main
{
  public double calculate(int[] ratings, int lowCount, int highCount)
  {
    double sum = 0;
    double tot = 0;
    
    Arrays.sort(ratings);
    
    for(int i=lowCount+1; i<=ratings.length-highCount; i++){
      sum+=ratings[i]*1.0;
      tot++;
    }
    
    return sum/tot;
  }
  
  public void main()
  {
	int i;
	Scanner sc = new Scanner(System.in);
	int noOfRatings = sc.nextInt();
     	int[] ratings = new int[noOfRatings];
     	for(i=0; i<noOfRatings; i++)
		ratings[i] = sc.nextInt();
     	int lowCount = sc.nextInt();
     	int highCount = sc.nextInt();
     	double ans = calculate(ratings, lowCount, highCount);
     	System.out.println(ans);
  }
}