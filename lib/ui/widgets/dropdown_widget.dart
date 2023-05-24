import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class DropdownWidget<T> extends DropdownButtonFormField2<T> {

  DropdownWidget({
    super.key,
    required super.value,
    required super.onChanged,
    required List<T> items,
    required String Function(T x) getText
  }) : super(
    buttonHighlightColor: Colors.transparent,
    buttonSplashColor: Colors.transparent,
    focusColor: Colors.transparent,
    decoration: InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.zero,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    isExpanded: true,
    icon: const Icon(
      Icons.arrow_drop_down,
      color: Colors.black45,
    ),
    iconSize: 30,
    buttonHeight: 60,
    buttonPadding: const EdgeInsets.only(right: 10),
    dropdownDecoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
    ),
    items: items
        .map((item) =>
            DropdownMenuItem<T>(
              value: item,
              child: Text(
                getText(item),
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            )
        )
        .toList(),
  );

}