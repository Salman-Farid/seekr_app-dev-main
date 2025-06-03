class Record {
  final String date;
  final String time;
  final String text;

  Record({
    required this.date,
    required this.time,
    required this.text,
  });

  Record.fromJson(Map<String, dynamic> json)
      : date = json['date'],
        time = json['time'],
        text = json['text'];

  Map<String, dynamic> toJson() => {
        'date': date,
        'time': time,
        'text': text,
      };
}
