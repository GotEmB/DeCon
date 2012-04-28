myDict = {
                'a':'.-',
                'b':'-...',
                'c':'-.-.',
                'd':'-..',
                'e':'.',
                'f':'..-.',
                'g':'--.',
                'h':'....',
                'i':'..',
                'j':'.---',
                'k':'-.-',
                'l':'.-..',
                'm':'--',
                'n':'-.',
                'o':'---',
                'p':'.--.',
                'q':'--.-',
                'r':'.-.',
                's':'...',
                't':'-',
                'u':'..-',
                'v':'...-',
                'w':'.--',
                'x':'-..-',
                'y':'-.--',
                'z':'--..',
                '1':'.----',
                '2':'..---',
                '3':'...--',
                '4':'....-',
                '5':'.....',
                '6':'-....',
                '7':'--...',
                '8':'---..',
                '9':'----.',
                '0':'-----',
                }
 
text = raw_input('\n')
text_div = list(text)
my_list = list()
for char in text
{
        for key in myDict
       {
                if (char.lower() == key)
	  {
                        value = myDict[key]
                        my_list.append(value)
                }
       }
}
 
#print my_list
my_out = ''
for item in my_list:
        my_out = my_out + item + ' '
print my_out