class Todo {
  Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
  });
  final String id;
  final String title;
  final bool isCompleted;

  Todo copyWith({String? title, bool? isCompleted}) => Todo(
        id: id,
        title: title ?? this.title,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  // ignore: prefer_constructors_over_static_methods
  static Todo fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}
