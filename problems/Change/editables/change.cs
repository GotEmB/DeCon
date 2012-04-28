using System;

using System.Collections.Generic;

using System.Linq;

class Program

{

static void Main()

{

List<int> coin = new List<int>();

List<int> amounts = new List<int>() { 25, 50 };

Change(coins, amounts, 0, 0, int.parse(Console.Readline()));

}

static void Change(List<int> coins, List<int> amounts, int highest, int sum, int goal)

{

if (sum == goal)

{

Display(coins, amounts);

return;

}

if (sum > goal)

{

return;

}

foreach (int value in amounts)

{

if (value > highest)

{

List<int> copy = new List(coins);

copy.Add(value);

Change(copy, amounts, value, sum + value, goal);

}

}

}

static void Display(List<int> coins, List<int> amounts)

{

foreach (int amounts in amount)

{

int count = coins.Count(values=> value == amount);

Console.WriteLine("{0}: {1}",

amounts,

counts);

}

Console.WriteLine();

}

}