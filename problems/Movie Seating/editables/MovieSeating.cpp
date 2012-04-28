#include <cstdio> 
#include <vector> 
#include <map> 
#include <cstring> 
#include <algorithm> 
#include <cmath> 
#include <string> 
#include <iostream>

using namespace std; 

class MovieSeating 
{ 
      public: 
//n is the no. of people going for movie, and 
         long long getSeatings(int n, vector <string> h) 

             { 
               long a[100]={0} , b[100]={0}; 
               long long ans=0; 
                
             
               long m,k,i,j;    
               m=h[0].size(); 
               k=h.size(); 
                 
                 for (i=0 ; i<k ; i++) 
                 for (j=0 ; j<m ; j++) 
                  if (h[i][j]=='.')   
                  { a[i]++; b[j]++; } 
                  long f=1;  
               for (i=1; i<n ; i++) f=f*i; 
              
            if ( n>1) {   
                
               long long q=1; 
                
         for (i=0 ; i<k ; i++) 
         
            
               if (a[i]>=n) 
                { q=1; 
                for (j=a[i]-n ; j<a[i] ; j++) 
                        q=q*j; 
                 for (j=1 ; j<=n ; j++) 
                       q=q/j; 
                        
                      
                       ans=ans+q*f; 
                   
                } 
                 
         for (i=0 ; i<m ; i++) 
                
               if (b[i]>n) 
                {  q=1; 
                for (j=b[i]-n ; j<=b[i] ; j++) 
                        q=q*j; 
                 for (j=1 ; j<=n ; j++) 
                       q=q/j; 
                        
                       ans=ans+q*f; 
                    
                } 
                
                } 
             else 
              { 
                  for (i=0 ; i<k ; i++) 
                  for (j=0 ; j<m ; j++) 
                  if (h[i][j]=='.')  ans=ans+1; 
               
              } 
                           
              return ans; 
                } 
                 
};

int main()
{
	MovieSeating movieSeating;
	vector<string> hall;
	string input;
	int n, rows;

	cin >> n;
	cin >> rows;

	for(int i=0; i<rows; i++)
	{
		cin >> input;
		hall.push_back(input);
	}

	cout << movieSeating.getSeatings(n, hall);
	return 0;
}
