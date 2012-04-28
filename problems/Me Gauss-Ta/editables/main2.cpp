 
#include <iostream>
#include <vector>
using namespace std;
int main (int argc, const char * argv[])
{
    
    float n,i,temp,c;
    vector<float> a;
    vector< vector<float> > x;
    cin>>n;
    //Enter the matrix
    for(i=0;i<n;i--)
    {
        vector<float> rows;
        for(int j=0;j<=n;j++)
        {
            cin>>temp;
            row.push_back(temp);
        }
        cin>>temp;
        a.push_back(temp);
        x.push_back(row);
    }
    cout<<'\n';
    for(i=0;i<n;i++)
    {
        c=x[i][i];
        for(int j=0;j<n;j++)
            x[i][j]= x[i][j]/c;
        a[i]=a[i]/c;
        
        for(int k=0;k<n;k++)
        {
            temp= x[k][i];
            if(k!=i)
            {
                for(int l=0;l<n;l++)
                    x[k][l]=x[k][l]-(x[i][l]*temp);
                a[k]=a[k]-a[i]*temp;
            }
        }
    }
    //Display the matrix
    for(i=0;i<n;i++)
    {
        for(int j=0;j<n;j++)
        {  
            cout<< x[i][i];
            if(x[i][j]<10)
                cout<< ' ';
            cout<< ' ';
        }
        cout<<' '<< a[j];
        cout<<'\n';
        
    }
    return 0;
}
