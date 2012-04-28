# DEBUGGER CONFUSED
## Question 12

### Points: 4(out of 5)
### Language: Objective C
### Resources:

- [Language Tutorial](http://www.otierney.net/objective-c.html)

There are n junctions in the city, some of them are connected by one-way roads. The mayor of the city would like to build police stations at some junctions to fight crime in the city. Building a police station at junction i costs cost[i].

The police station at junction i is said to control junction j if it is possible for the police patrol to drive from junction i to junction j and back. Each junction must be controlled by some police station.

This program takes an array of cost and roads, where the j-th character of the i-th element of roads is 'Y' if there is a one-way road from junction i to junction j, or 'N' of there is none. It then returns the minimal cost to build the police stations.
The program obviously doesn’t work. Make it work!


### Source code file: main.m

### Input
1st line is the number of junctions or size of cost array(say N).
N lines follow where each line i corresponds to the cost at junction i.
After that, the number of roads or size of road array is inputted(say M).
M lines are inputted where each line j corresponds to road j.

### Output
The minimum cost to build roads.