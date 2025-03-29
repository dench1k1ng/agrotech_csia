import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> batches = [
    {'name': 'Руккола', 'date': '20.03.2025', 'status': 'Готова через 5 дней'},
    {
      'name': 'Кресс-салат',
      'date': '18.03.2025',
      'status': 'Готова через 3 дня',
    },
    {'name': 'Горчица', 'date': '22.03.2025', 'status': 'Готова через 7 дней'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Мои грядки")),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: batches.length,
        itemBuilder: (context, index) {
          final batch = batches[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              title: Text(
                batch['name']!,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Посажено: ${batch['date']}\n${batch['status']}",
                style: TextStyle(fontSize: 14),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.green,
              ),
              onTap: () {}, // Позже добавим переход на карточку партии
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {}, // Позже добавим экран добавления
        child: Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}
