import 'package:flutter/material.dart';

class WeekView extends StatefulWidget {
  // נוסיף Callback כדי לדווח על שינויים
  final Function(int dayIndex) onDaySelected;

  const WeekView({super.key, required this.onDaySelected});

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  int _selectedDayIndex = 3; // נתחיל מיום רביעי (אינדקס 3)

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
        final numbers = ['12', '13', '14', '15', '16', '17', '18'];
        final isSelected = index == _selectedDayIndex;

        return GestureDetector(
          // עטפנו ב-GestureDetector כדי לאפשר לחיצה
          onTap: () {
            setState(() {
              _selectedDayIndex = index;
            });
            widget.onDaySelected(index); // קריאה ל-Callback
          },
          child: Column(
            children: [
              Text(days[index],
                  style: TextStyle(
                      color: isSelected ? Colors.amber[800] : Colors.grey,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal)),
              const SizedBox(height: 4),
              AnimatedContainer(
                // הוספנו אנימציה לבחירה
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFFFFF4CC) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  numbers[index],
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.amber[800] : Colors.black),
                ),
              ),
              const SizedBox(height: 4),
              // מציג נקודות אינדיקציה לאירועים
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(index % 3 + 1, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (i % 2 == 0 ? Colors.cyan : Colors.red)
                          : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              )
            ],
          ),
        );
      }),
    );
  }
}
