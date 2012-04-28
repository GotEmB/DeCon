open System
open System.Collections
open System.Collections.Generic

let documentAccess records userGroups roomRights = 
    let mutable reach = new Dictionary<string, bool>()
    for document in records do
        let blah = document.Split ' '
        let doc = blah[1]
        let room = blah[2]
        let user = blah[3]
        let canUse = false
        let canRoom = false
        for right in userGroups do
            if user = right then
                canUse <- true
        for rRoom in roomRights do
            if rRoom = room then
                canRoom <- true
        if canRoom || canUse then
            reach.Item doc <- true
    if reach.Count = 0 then
        Console.WriteLine "All the best"         
        
for reachableDocument in reach do
    Console.WriteLine reachableDocument.Key 
  

let records, userGroups, roomRights = new List<string>(), new List<string>(), new List<string>()
let numberOfRecords, numberOfUserGroups, numberOfRoomRights = int(Console.ReadLine()), int(Console.ReadLine()), int(Console.ReadLine())
for i = 1 to numberOfRecords do
    records.Add( Console.ReadLine() )
for i = 1 to numberOfUserGroups do
    userGroups.Add( Console.ReadLine() )
for i = 1 to numberOfRoomRights do
    roomRights.Add( Console.ReadLine() )
documentAccess records userGroups roomRights
