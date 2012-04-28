# DEBUGGER CONFUSED
## Question 11

### Points: 3(out of 5)
### Language: Java
### Resources:

- [Language Tutorial](http://docs.oracle.com/javase/tutorial/java/index.html)

This code calculates the rating of a particular movie. People who have watched the movie rate it on the scale of 0 to 100, inclusive. To remove a certain amount of biasing it removes the last few lowest ratings as well as few of the highest ratings. For example: for 15 ratings, top 2 and bottom 5 ratings are removed.

### Source code file: rating.java

### Input
1st line : No. of ratings.(say N)
Line 2 to N+1: Values of each rating
Above is then followed by a line containing no. of lowest ratings to be discarded. This is again followed by a line that tells the no. of highest ratings to be discarded.


### Output
The composite rating(actual rating).