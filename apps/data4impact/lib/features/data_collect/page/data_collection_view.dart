import 'package:data4impact/features/study_detail/pages/study_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum QuestionType {
  singleChoice,
  multipleChoice,
  textInput,
  rating,
  yesNo,
}

class Question {
  final String id;
  final String title;
  final String subtitle;
  final QuestionType type;
  final List<String>? options;
  final int? maxRating;
  final String? placeholder;
  final bool isRequired;

  const Question({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.options,
    this.maxRating,
    this.placeholder,
    this.isRequired = true,
  });
}

class DataCollectionView extends StatefulWidget {
  const DataCollectionView({super.key});

  @override
  State<DataCollectionView> createState() => _DataCollectionViewState();
}

class _DataCollectionViewState extends State<DataCollectionView> {
  int currentQuestionIndex = 0;
  Map<String, dynamic> answers = {};

  // Sample questions
  final List<Question> questions = [
    Question(
      id: 'age',
      title: 'Your age',
      subtitle: 'Select your age category',
      type: QuestionType.singleChoice,
      options: [
        '15-24 years',
        '25-34 years',
        '35-44 years',
        '45-54 years',
        '55+ years'
      ],
    ),
    Question(
      id: 'gender',
      title: 'Gender',
      subtitle: 'Please select your gender',
      type: QuestionType.singleChoice,
      options: ['Male', 'Female', 'Non-binary', 'Prefer not to say'],
    ),
    Question(
      id: 'education',
      title: 'Education Level',
      subtitle: 'What is your highest level of education?',
      type: QuestionType.singleChoice,
      options: [
        'High school or below',
        'Some college',
        'Bachelor\'s degree',
        'Master\'s degree',
        'PhD or higher'
      ],
    ),
    Question(
      id: 'interests',
      title: 'Your interests',
      subtitle: 'Select all that apply to you',
      type: QuestionType.multipleChoice,
      options: [
        'Technology',
        'Sports',
        'Music',
        'Reading',
        'Travel',
        'Cooking',
        'Art',
        'Gaming'
      ],
    ),
    Question(
      id: 'experience',
      title: 'Tell us about yourself',
      subtitle: 'Describe your professional background or main activities',
      type: QuestionType.textInput,
      placeholder: 'Type your answer here...',
    ),
    Question(
      id: 'satisfaction',
      title: 'Overall satisfaction',
      subtitle: 'Rate your satisfaction with our service',
      type: QuestionType.rating,
      maxRating: 5,
    ),
    Question(
      id: 'recommend',
      title: 'Would you recommend us?',
      subtitle: 'Would you recommend our service to friends or family?',
      type: QuestionType.yesNo,
    ),
    Question(
      id: 'feedback',
      title: 'Additional feedback',
      subtitle: 'Any additional comments or suggestions?',
      type: QuestionType.textInput,
      placeholder: 'Share your thoughts...',
      isRequired: false,
    ),
  ];

  Question get currentQuestion => questions[currentQuestionIndex];
  bool get isFirstQuestion => currentQuestionIndex == 0;
  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;

  bool get canProceed {
    final answer = answers[currentQuestion.id];
    if (!currentQuestion.isRequired) return true;

    switch (currentQuestion.type) {
      case QuestionType.singleChoice:
      case QuestionType.yesNo:
        return answer != null;
      case QuestionType.multipleChoice:
        return answer != null && (answer as List).isNotEmpty;
      case QuestionType.textInput:
        return answer != null && (answer as String).trim().isNotEmpty;
      case QuestionType.rating:
        return answer != null && (answer as int) > 0;
    }
  }

  void _updateAnswer(String questionId, dynamic value) {
    setState(() {
      answers[questionId] = value;
    });
  }

  void _nextQuestion() {
    if (isLastQuestion) {
      _submitSurvey();
    } else {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (!isFirstQuestion) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void _submitSurvey() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Survey Completed',
          style: GoogleFonts.lexendDeca(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Thank you for your responses!',
          style: GoogleFonts.lexendDeca(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              setState(() {
                currentQuestionIndex = 0;
                answers.clear();
              });
            },
            child: Text(
              'OK',
              style: GoogleFonts.lexendDeca(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Survey ${currentQuestionIndex + 1}/${questions.length}',
          style: GoogleFonts.lexendDeca(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
              backgroundColor: colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 32),

            // Question content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentQuestion.title,
                    style: GoogleFonts.lexendDeca(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentQuestion.subtitle,
                    style: GoogleFonts.lexendDeca(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Question input based on type
                  Expanded(child: _buildQuestionInput()),
                ],
              ),
            ),

            // Navigation buttons
            Row(
              children: [
                if (!isFirstQuestion)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _previousQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.surfaceVariant,
                        foregroundColor: colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: GoogleFonts.lexendDeca(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                if (!isFirstQuestion) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canProceed ? _nextQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canProceed
                          ? colorScheme.primary
                          : colorScheme.surfaceVariant,
                      foregroundColor: canProceed
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isLastQuestion ? 'Submit' : 'Next',
                      style: GoogleFonts.lexendDeca(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionInput() {
    switch (currentQuestion.type) {
      case QuestionType.singleChoice:
        return _buildSingleChoice();
      case QuestionType.multipleChoice:
        return _buildMultipleChoice();
      case QuestionType.textInput:
        return _buildTextInput();
      case QuestionType.rating:
        return _buildRating();
      case QuestionType.yesNo:
        return _buildYesNo();
    }
  }

  Widget _buildSingleChoice() {
    final theme = Theme.of(context);
    final selectedValue = answers[currentQuestion.id];

    return ListView.builder(
      shrinkWrap: true,
      itemCount: currentQuestion.options?.length ?? 0,
      itemBuilder: (context, index) {
        final option = currentQuestion.options![index];
        final isSelected = selectedValue == option;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _updateAnswer(currentQuestion.id, option),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withOpacity(0.6),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 14,
                            color: theme.colorScheme.onPrimary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: GoogleFonts.lexendDeca(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMultipleChoice() {
    final theme = Theme.of(context);
    final selectedValues = (answers[currentQuestion.id] as List<String>?) ?? [];

    return ListView.builder(
      shrinkWrap: true,
      itemCount: currentQuestion.options?.length ?? 0,
      itemBuilder: (context, index) {
        final option = currentQuestion.options![index];
        final isSelected = selectedValues.contains(option);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              final updatedList = List<String>.from(selectedValues);
              if (isSelected) {
                updatedList.remove(option);
              } else {
                updatedList.add(option);
              }
              _updateAnswer(currentQuestion.id, updatedList);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withOpacity(0.6),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            size: 14,
                            color: theme.colorScheme.onPrimary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: GoogleFonts.lexendDeca(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextInput() {
    final theme = Theme.of(context);

    return TextField(
      onChanged: (value) => _updateAnswer(currentQuestion.id, value),
      decoration: InputDecoration(
        hintText: currentQuestion.placeholder,
        hintStyle: GoogleFonts.lexendDeca(
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        contentPadding: const EdgeInsets.all(16),
      ),
      style: GoogleFonts.lexendDeca(
        color: theme.colorScheme.onSurface,
      ),
      maxLines: 5,
      minLines: 3,
      textInputAction: TextInputAction.newline,
    );
  }

  Widget _buildRating() {
    final theme = Theme.of(context);
    final rating = answers[currentQuestion.id] as int? ?? 0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(currentQuestion.maxRating!, (index) {
              final starValue = index + 1;
              return GestureDetector(
                onTap: () => _updateAnswer(currentQuestion.id, starValue),
                child: Icon(
                  starValue <= rating ? Icons.star : Icons.star_border,
                  size: 40,
                  color: starValue <= rating
                      ? Colors.amber
                      : theme.colorScheme.outline.withOpacity(0.4),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            rating == 0
                ? 'Tap to rate'
                : 'You rated: $rating/${currentQuestion.maxRating}',
            style: GoogleFonts.lexendDeca(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYesNo() {
    final theme = Theme.of(context);
    final selectedValue = answers[currentQuestion.id];

    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _updateAnswer(currentQuestion.id, true),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: selectedValue == true
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedValue == true
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                'Yes',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexendDeca(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: selectedValue == true
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _updateAnswer(currentQuestion.id, false),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: selectedValue == false
                    ? theme.colorScheme.error.withOpacity(0.1)
                    : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedValue == false
                      ? theme.colorScheme.error
                      : theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                'No',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexendDeca(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: selectedValue == false
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
