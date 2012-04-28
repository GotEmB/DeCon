#include <stdio.h>

struct Player
{
	char name[50];
	int runs;
	int ballFaced;
}
	
void HTMLheader()
{
	printf("<!DOCTYPE html>\n");
	printf("<body>\n");
}

void HTMLtableStart()
{
	printf("<table>");
	printf("<tr><th>S.No</th><th>Name</th><th>Runs</th><th>Balls faced</th></tr>");
}

void HTMLtableEnd()
{
	printf("</table>");
}

void HTMLend()
{
	printf("</body>");
	printf("</html>");
}

int main()
{
	int i,n;
	struct Player player;
	scanf("%d", &n);

	HTMLheader();
	HTMLtableStart();
	for(int i=0; i<n; i++)
	{
		scanf("%s%d%d", player.name, &player.runs, &player.ballFaced); 
		printf("\n<tr>");
		printf("\n<td>%s</td><td>%d</td><td>%d</td>", player.name, player.runs, player.ballFaced);
		printf("\n</tr>");
	}
	
	HTMLtableEnd();
	HTMLend();
	return 0;
}