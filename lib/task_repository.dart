class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;

  const Task({
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });
}

class TaskRepository {
  static List<Task> tasks = [
    const Task(
      title: "Przygotować prezentację",
      deadline: "jutro",
      done: true,
      priority: "wysoki",
    ),
    const Task(
      title: "Oddać raport z laboratoriów",
      deadline: "dzisiaj",
      done: false,
      priority: "wysoki",
    ),
    const Task(
      title: "Powtórzyć widgety Flutter",
      deadline: "w piątek",
      done: true,
      priority: "średni",
    ),
    const Task(
      title: "Napisać notatki do kolokwium",
      deadline: "w weekend",
      done: false,
      priority: "niski",
    ),
  ];
}