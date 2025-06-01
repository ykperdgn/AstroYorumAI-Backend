import 'package:flutter/material.dart';

class CelestialEvent {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String type; // 'new_moon', 'full_moon', 'eclipse', 'retrograde', 'ingress', 'aspect'
  final String? planetInvolved;
  final String? signInvolved;
  final String? aspectType;
  final bool isImportant;
  final String? impactDescription;

  CelestialEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.type,
    this.planetInvolved,
    this.signInvolved,
    this.aspectType,
    this.isImportant = false,
    this.impactDescription,
  });

  factory CelestialEvent.fromJson(Map<String, dynamic> json) {
    return CelestialEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dateTime: DateTime.parse(json['dateTime']),
      type: json['type'],
      planetInvolved: json['planetInvolved'],
      signInvolved: json['signInvolved'],
      aspectType: json['aspectType'],
      isImportant: json['isImportant'] ?? false,
      impactDescription: json['impactDescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'type': type,
      'planetInvolved': planetInvolved,
      'signInvolved': signInvolved,
      'aspectType': aspectType,
      'isImportant': isImportant,
      'impactDescription': impactDescription,
    };
  }

  String getEventIcon() {
    switch (type) {
      case 'new_moon':
        return '🌑';
      case 'full_moon':
        return '🌕';
      case 'eclipse':
        return '🌘';
      case 'retrograde':
        return '⚡';
      case 'ingress':
        return '🌟';
      case 'aspect':
        return '⭐';
      default:
        return '✨';
    }
  }

  Color getEventColor() {
    switch (type) {
      case 'new_moon':
        return Colors.indigo;
      case 'full_moon':
        return Colors.amber;
      case 'eclipse':
        return Colors.red;
      case 'retrograde':
        return Colors.orange;
      case 'ingress':
        return Colors.purple;
      case 'aspect':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String getPlanetEmoji() {
    switch (planetInvolved?.toLowerCase()) {
      case 'sun':
        return '☉';
      case 'moon':
        return '☽';
      case 'mercury':
        return '☿';
      case 'venus':
        return '♀';
      case 'mars':
        return '♂';
      case 'jupiter':
        return '♃';
      case 'saturn':
        return '♄';
      case 'uranus':
        return '♅';
      case 'neptune':
        return '♆';
      case 'pluto':
        return '♇';
      default:
        return '';
    }
  }
}
