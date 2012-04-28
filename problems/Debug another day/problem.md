# DEBUGGER CONFUSED
## Question 10

### Points: 4(out of 5)
### Language: F#
### Resources:

- [Language Tutorial](http://www.visualfsharp.com/fsharp/Lesson01.htm)
or [For reference](http://msdn.microsoft.com/en-us/library/dd233181.aspx)

Agent 007 has infiltrated the North Korean military base to gather information about illegal trading. The base has the following arrangement for maximum security:

- Critical documents are spread across different rooms.
- Each member belongs to multiple user groups. Each document can be accessed only by certain user groups.
- Each member can access only few rooms.
Hence, a member can read a document only if he has access to that room as well as the document. 

Mr. Bond has already taken down a man and has dressed up like him for the purpose of accessing documents. Right now he knows all the rooms that the victim has access to, as well as all the user groups the victim is a part of. To make things easier and quicker, he uses Mr. Q’s magical device that tells him all the documents he can possibly access. Alas, the device is malfunctioning.

As Mr. Q’s assistant (You thought I’ll make you James Bond?), you have been assigned the task of debugging the device as fast as possible. 

The device requires the following information:

- User groups (as array)
- Room rights (all rooms Bond has access to, again as array) and,
- Records (as array). The ‘records’ contains the document name, the room the document lies in as well as all the user groups that can read that document.


### Source code file: misson.fs

### Input
Line 1: No. of records (say N)
Line 2: No. of user groups (say O)
Line 3: No. of rooms Bond can access (say P)
This is followed by N lines where each line contains:
documentName<space>room<space>UserGroup
O lines follow where each line is the user group Bond ‘belongs in’. Finally, P lines of rooms are inputted.


### Output
List of documents Bond can access, each in separate line. If all documents are inaccessible, “All the best” is outputted.