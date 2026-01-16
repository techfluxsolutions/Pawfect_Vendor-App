class FAQModel {
  final String question;
  final String answer;

  FAQModel({required this.question, required this.answer});

  factory FAQModel.fromJson(Map<String, dynamic> json) {
    return FAQModel(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'question': question, 'answer': answer};
  }
}
