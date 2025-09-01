import 'dart:math';
import 'package:medimate_ai/models/reminder_model.dart';

class MLService {
  // Simple logistic regression implementation for reminder prediction
  List<double> _weights = [];
  double _bias = 0.0;
  double _learningRate = 0.01;
  int _maxIterations = 1000;
  
  // Feature weights for reminder prediction
  static const Map<String, double> _featureWeights = {
    'time_of_day': 0.3,
    'day_of_week': 0.2,
    'medicine_type': 0.15,
    'previous_adherence': 0.25,
    'reminder_frequency': 0.1,
  };

  MLService() {
    _initializeModel();
  }

  void _initializeModel() {
    // Initialize with random weights
    final random = Random();
    _weights = List.generate(5, (index) => random.nextDouble() * 2 - 1);
    _bias = random.nextDouble() * 2 - 1;
  }

  /// Predicts the likelihood of a user missing a medication dose
  double predictMissedDoseProbability(ReminderModel reminder, Map<String, dynamic> userContext) {
    try {
      // Extract features
      final features = _extractFeatures(reminder, userContext);
      
      // Calculate weighted sum
      double weightedSum = _bias;
      for (int i = 0; i < features.length && i < _weights.length; i++) {
        weightedSum += features[i] * _weights[i];
      }
      
      // Apply sigmoid function to get probability
      return _sigmoid(weightedSum);
    } catch (e) {
      print('Prediction failed: $e');
      return 0.5; // Default to 50% probability
    }
  }

  /// Extracts features from reminder and user context
  List<double> _extractFeatures(ReminderModel reminder, Map<String, dynamic> userContext) {
    final features = <double>[];
    
    // Feature 1: Time of day (normalized to 0-1)
    final hour = reminder.time.hour;
    final timeOfDay = hour / 24.0;
    features.add(timeOfDay);
    
    // Feature 2: Day of week (normalized to 0-1)
    final dayOfWeek = reminder.frequency == ReminderFrequency.daily ? 0.5 : 
                      (reminder.customDays?.first ?? 1) / 7.0;
    features.add(dayOfWeek);
    
    // Feature 3: Medicine type (categorical encoding)
    final medicineType = _encodeMedicineType(reminder.medicineName);
    features.add(medicineType);
    
    // Feature 4: Previous adherence rate
    final previousAdherence = userContext['previousAdherence'] ?? 0.8;
    features.add(previousAdherence);
    
    // Feature 5: Reminder frequency
    final frequency = _encodeFrequency(reminder.frequency);
    features.add(frequency);
    
    return features;
  }

  double _encodeMedicineType(String medicineName) {
    final lowerName = medicineName.toLowerCase();
    
    if (lowerName.contains('vitamin') || lowerName.contains('supplement')) {
      return 0.1; // Low priority
    } else if (lowerName.contains('antibiotic') || lowerName.contains('pain')) {
      return 0.9; // High priority
    } else if (lowerName.contains('chronic') || lowerName.contains('diabetes') || lowerName.contains('heart')) {
      return 1.0; // Critical priority
    } else {
      return 0.5; // Medium priority
    }
  }

  double _encodeFrequency(ReminderFrequency frequency) {
    switch (frequency) {
      case ReminderFrequency.daily:
        return 1.0;
      case ReminderFrequency.weekly:
        return 0.5;
      case ReminderFrequency.custom:
        return 0.7;
    }
  }

  double _sigmoid(double x) {
    return 1.0 / (1.0 + exp(-x));
  }

  /// Trains the model with historical data
  void trainModel(List<Map<String, dynamic>> trainingData) {
    try {
      for (int iteration = 0; iteration < _maxIterations; iteration++) {
        double totalLoss = 0.0;
        
        for (final data in trainingData) {
          final features = data['features'] as List<double>;
          final actualLabel = data['label'] as double;
          
          // Forward pass
          final prediction = _predict(features);
          
          // Calculate loss
          final loss = _binaryCrossEntropyLoss(prediction, actualLabel);
          totalLoss += loss;
          
          // Backward pass (gradient descent)
          _updateWeights(features, prediction, actualLabel);
        }
        
        // Early stopping if loss is very low
        if (totalLoss < 0.01) {
          break;
        }
      }
    } catch (e) {
      print('Training failed: $e');
    }
  }

  double _predict(List<double> features) {
    double weightedSum = _bias;
    for (int i = 0; i < features.length && i < _weights.length; i++) {
      weightedSum += features[i] * _weights[i];
    }
    return _sigmoid(weightedSum);
  }

  double _binaryCrossEntropyLoss(double prediction, double actual) {
    if (prediction == 0) prediction = 0.0001;
    if (prediction == 1) prediction = 0.9999;
    
    return -(actual * log(prediction) + (1 - actual) * log(1 - prediction));
  }

  void _updateWeights(List<double> features, double prediction, double actual) {
    final error = prediction - actual;
    
    // Update bias
    _bias -= _learningRate * error;
    
    // Update weights
    for (int i = 0; i < features.length && i < _weights.length; i++) {
      _weights[i] -= _learningRate * error * features[i];
    }
  }

  /// Optimizes reminder timing based on user behavior
  TimeOfDay optimizeReminderTime(ReminderModel reminder, Map<String, dynamic> userContext) {
    try {
      // Get current reminder time
      final currentTime = reminder.time;
      
      // Analyze user's best adherence times
      final bestTimes = _analyzeBestAdherenceTimes(userContext);
      
      if (bestTimes.isNotEmpty) {
        // Find the best time closest to current time
        TimeOfDay? bestTime;
        int minDifference = 24;
        
        for (final time in bestTimes) {
          final difference = _calculateTimeDifference(currentTime, time);
          if (difference < minDifference) {
            minDifference = difference;
            bestTime = time;
          }
        }
        
        if (bestTime != null) {
          return bestTime;
        }
      }
      
      // Default optimization: move reminder 15 minutes earlier
      return _adjustTime(currentTime, -15);
    } catch (e) {
      print('Time optimization failed: $e');
      return reminder.time;
    }
  }

  List<TimeOfDay> _analyzeBestAdherenceTimes(Map<String, dynamic> userContext) {
    final adherenceData = userContext['adherenceByTime'] ?? <String, double>{};
    final bestTimes = <TimeOfDay>[];
    
    // Find times with adherence > 80%
    adherenceData.forEach((timeStr, adherence) {
      if (adherence > 0.8) {
        final timeParts = timeStr.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        bestTimes.add(TimeOfDay(hour: hour, minute: minute));
      }
    });
    
    return bestTimes;
  }

  int _calculateTimeDifference(TimeOfDay time1, TimeOfDay time2) {
    final minutes1 = time1.hour * 60 + time1.minute;
    final minutes2 = time2.hour * 60 + time2.minute;
    return (minutes1 - minutes2).abs();
  }

  TimeOfDay _adjustTime(TimeOfDay time, int minutes) {
    final totalMinutes = time.hour * 60 + time.minute + minutes;
    final newHour = (totalMinutes ~/ 60) % 24;
    final newMinute = totalMinutes % 60;
    return TimeOfDay(hour: newHour, minute: newMinute);
  }

  /// Generates personalized reminder suggestions
  List<String> generatePersonalizedSuggestions(ReminderModel reminder, Map<String, dynamic> userContext) {
    final suggestions = <String>[];
    final missedProbability = predictMissedDoseProbability(reminder, userContext);
    
    if (missedProbability > 0.7) {
      suggestions.add('Consider setting multiple reminders for this medication');
      suggestions.add('Try setting the reminder 15 minutes earlier');
      suggestions.add('Enable push notifications for better adherence');
    } else if (missedProbability > 0.5) {
      suggestions.add('Set a backup reminder 30 minutes after the scheduled time');
      suggestions.add('Consider weekly medication review');
    } else {
      suggestions.add('Great adherence! Keep up the good work');
      suggestions.add('Consider setting reminders for refills');
    }
    
    return suggestions;
  }

  /// Analyzes user's medication adherence patterns
  Map<String, dynamic> analyzeAdherencePatterns(List<ReminderModel> reminders) {
    try {
      final patterns = <String, dynamic>{};
      
      // Calculate overall adherence rate
      int totalReminders = 0;
      int takenReminders = 0;
      
      for (final reminder in reminders) {
        if (reminder.status != ReminderStatus.pending) {
          totalReminders++;
          if (reminder.status == ReminderStatus.taken) {
            takenReminders++;
          }
        }
      }
      
      final adherenceRate = totalReminders > 0 ? takenReminders / totalReminders : 0.0;
      patterns['overallAdherence'] = adherenceRate;
      
      // Analyze adherence by time of day
      final adherenceByTime = <String, List<int>>{};
      for (final reminder in reminders) {
        if (reminder.status != ReminderStatus.pending) {
          final timeKey = '${reminder.time.hour.toString().padLeft(2, '0')}:${reminder.time.minute.toString().padLeft(2, '0')}';
          adherenceByTime.putIfAbsent(timeKey, () => [0, 0]);
          
          adherenceByTime[timeKey]![1]++; // Total
          if (reminder.status == ReminderStatus.taken) {
            adherenceByTime[timeKey]![0]++; // Taken
          }
        }
      }
      
      final adherenceByTimeRate = <String, double>{};
      adherenceByTime.forEach((time, counts) {
        adherenceByTimeRate[time] = counts[1] > 0 ? counts[0] / counts[1] : 0.0;
      });
      
      patterns['adherenceByTime'] = adherenceByTimeRate;
      
      // Identify problematic times (adherence < 50%)
      final problematicTimes = adherenceByTimeRate.entries
          .where((entry) => entry.value < 0.5)
          .map((entry) => entry.key)
          .toList();
      
      patterns['problematicTimes'] = problematicTimes;
      
      return patterns;
    } catch (e) {
      print('Pattern analysis failed: $e');
      return {};
    }
  }
}
