using System;
using System.Collections.Generic;
using System.Linq;

namespace Laziness
{
    class Program
    {
        void main()
        {
            List keyWords = new List<string>();
            List keyWordsMarks = new List<int>();
            int total = 0;
            string answer;
            int numberOfWords;

            string word;
            int marks;

            numberOfWords = int.Parse(Console.ReadLine());

            for(int i=0; i<numberOfWords; i++)
            {
                word = Console.ReadLine();
                marks = int.Parse(Console.ReadLine());
                keyWords.Add(word);
                keyWordsMarks.Add(marks);
            }

            answer = Console.ReadLine();
            List<string> checkWords = answer.Split(' ').ToList();

            foreach(string entry in checkWords)
            {
                int index = keyWords.IndexOf(entry);

                if( index != -1 )
                {
                    total += keyWordsMarks[index];
                    keyWords.RemoveAt(index);
                    keyWordsMarks.RemoveAt(index);
                }
            }
              
            Console.WriteLine(total);      
        }
    }
}
