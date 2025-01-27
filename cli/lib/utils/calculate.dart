void calculateDuration(
    DateTime startTime, DateTime endTime, double pricePerHour) {
  final duration = endTime.difference(startTime);
  final hours = duration.inHours + (duration.inMinutes % 60) / 60.0;
  final cost = hours * pricePerHour;
  print(
      'Total parkeringstid: ${duration.inHours} timmar och ${duration.inMinutes % 60} minuter');
  print('Total kostnad: $cost SEK');
}
