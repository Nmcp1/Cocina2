import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/theme.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:solar_icons/solar_icons.dart';

class MainNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  MainNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final List<_NavItemData> _items = [
    _NavItemData(FontAwesomeIcons.solidHome, 'Inicio'),
    _NavItemData(PhosphorIconsFill.listStar, 'Palabras'),
    _NavItemData(SolarIconsBold.cupStar, 'Top'),
    _NavItemData(MingCuteIcons.mgc_question_fill, 'Cómo jugar'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimary,
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final isActive = index == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Fondo de la opción activa, menor altura
                  if (isActive)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 80, // ancho personalizado
                          height: 65,
                          decoration: const BoxDecoration(
                            color: kSecondary,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Ícono y texto
                  Container(
                    height: 90,
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Icon(
                          _items[index].icon as IconData,
                          color: isActive ? kBackground2 : kBackground1,
                          size: 30,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _items[index].label,
                          style: TextStyle(
                            color: isActive ? kBackground2 : kBackground1,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItemData {
  final dynamic icon;
  final String label;
  _NavItemData(this.icon, this.label);
}