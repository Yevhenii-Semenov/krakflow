import 'dart:convert';

void main() {

  String jsonTextA = '''
  [1, 5, 8, 3, 2]
  ''';

  final lista = jsonDecode(jsonTextA);

  int suma = 0;

  print("Liczby:");
  for (int liczba in lista) {
    print(liczba);
    suma += liczba;
  }

  print("Suma: $suma");


  String jsonTextB = '''
  {
    "group": "Dart",
    "students": ["Ola", "Adam", "Kasia"]
  }
  ''';

  final dataB = jsonDecode(jsonTextB);

  print("Grupa: ${dataB["group"]}");

  for (String student in dataB["students"]) {
    print(student);
  }


  String jsonTextC = '''
  {
    "product": {
      "name": "Laptop",
      "price": 3500
    }
  }
  ''';

  final dataC = jsonDecode(jsonTextC);

  print(dataC["product"]["name"]);
  print(dataC["product"]["price"]);
}