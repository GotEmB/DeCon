Module Module1
 
    Sub Main()
        Dim temperatureInCelcius As Double
        Dim temperatureInFarenheit As Double
        Dim input = Console.ReadLine()
        temperatureInCelcius = Convert.ToDouble(input)
        temperatureInFarenheit = ((temperatureInCelcius * 9) / 5) + 32
        Console.WriteLine(temperatureInFarenheit)
    End Sub
 
End Module