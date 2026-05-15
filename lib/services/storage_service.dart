import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path_provider/path_provider.dart';
import '../models/trip_model.dart';
import '../models/expense_model.dart';

class StorageService {
  static late Box<Trip> _tripBox;
  static late Box<Expense> _expenseBox;

  static Future<void> initHive() async {
    _tripBox = await Hive.openBox<Trip>('trips');
    _expenseBox = await Hive.openBox<Expense>('expenses');
  }

  static Future<void> saveTrip(Trip trip) async {
    await _tripBox.put(trip.id, trip);
    await _tripBox.flush();
  }

  static List<Trip> getAllTrips() {
    return _tripBox.values.toList();
  }

  static Future<void> deleteTrip(String id) async {
    await _tripBox.delete(id);
    await _tripBox.flush();
  }

  static Future<void> updateTrip(Trip trip) async {
    await _tripBox.put(trip.id, trip);
    await _tripBox.flush();
  }

  static Future<void> saveExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
    await _expenseBox.flush();
  }

  static List<Expense> getExpensesForTrip(String tripId) {
    return _expenseBox.values.where((expense) => expense.tripId == tripId).toList();
  }

  static Future<void> deleteExpense(String id) async {
    await _expenseBox.delete(id);
    await _expenseBox.flush();
  }
}
