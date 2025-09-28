import 'package:data4impact/core/service/api_service/Model/study.dart';
import 'package:equatable/equatable.dart';

class DataCollectState extends Equatable {
  final Study? study;
  final bool isLoading;
  final String? error;
  final int currentQuestionIndex;
  final Map<String, dynamic> answers;
  final Set<String> requiredQuestions;
  final Set<String> skipQuestions;
  final String? jumpTarget;
  final List<int> navigationHistory;
  final Map<int, int> logicJumps;

  // Audio recording properties
  final bool isRecording;
  final int recordingDuration;
  final String? audioFilePath;
  final bool isUploadingAudio;
  final Map<String, dynamic>? audioUploadResult;

  // Audio playback properties
  final bool isPlayingAudio;
  final Duration audioPosition;
  final Duration audioDuration;

  // Language selection properties
  final String selectedLanguage;
  final List<Map<String, dynamic>> availableLanguages;

  // Location properties
  final LocationData? locationData;
  final bool isLocationLoading;
  final bool isLocationRequired;

  // Welcome screen state
  final bool hasSeenWelcome;

  // Submission properties
  final bool isSubmitting;
  final Map<String, dynamic>? submissionResult;
  final int maxRecordingDuration;

  const DataCollectState({
    this.study,
    this.isLoading = false,
    this.error,
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.requiredQuestions = const {},
    this.skipQuestions = const {},
    this.jumpTarget,
    this.navigationHistory = const [],
    this.logicJumps = const {},

    // Audio recording defaults
    this.isRecording = false,
    this.recordingDuration = 0,
    this.audioFilePath,
    this.isUploadingAudio = false,
    this.audioUploadResult,

    // Audio playback defaults
    this.isPlayingAudio = false,
    this.audioPosition = Duration.zero,
    this.audioDuration = Duration.zero,

    // Language selection defaults
    this.selectedLanguage = 'default',
    this.availableLanguages = const [],

    // Location defaults
    this.locationData,
    this.isLocationLoading = false,
    this.isLocationRequired = false,

    // Welcome screen default
    this.hasSeenWelcome = false,

    // Submission defaults
    this.isSubmitting = false,
    this.submissionResult,
    this.maxRecordingDuration = 180,
  });

  DataCollectState copyWith({
    Study? study,
    bool? isLoading,
    String? error,
    int? currentQuestionIndex,
    Map<String, dynamic>? answers,
    Set<String>? requiredQuestions,
    Set<String>? skipQuestions,
    String? jumpTarget,
    List<int>? navigationHistory,
    Map<int, int>? logicJumps,

    // Audio recording copyWith parameters
    bool? isRecording,
    int? recordingDuration,
    String? audioFilePath,
    bool? isUploadingAudio,
    Map<String, dynamic>? audioUploadResult,

    // Audio playback copyWith parameters
    bool? isPlayingAudio,
    Duration? audioPosition,
    Duration? audioDuration,

    // Language selection copyWith parameters
    String? selectedLanguage,
    List<Map<String, dynamic>>? availableLanguages,

    // Location copyWith parameters
    LocationData? locationData,
    bool? isLocationLoading,
    bool? isLocationRequired,

    // Welcome screen copyWith parameter
    bool? hasSeenWelcome,

    // Submission copyWith parameters
    bool? isSubmitting,
    Map<String, dynamic>? submissionResult,
    int? maxRecordingDuration,
  }) {
    return DataCollectState(
      study: study ?? this.study,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      requiredQuestions: requiredQuestions ?? this.requiredQuestions,
      skipQuestions: skipQuestions ?? this.skipQuestions,
      jumpTarget: jumpTarget ?? this.jumpTarget,
      navigationHistory: navigationHistory ?? this.navigationHistory,
      logicJumps: logicJumps ?? this.logicJumps,

      // Audio recording copyWith
      isRecording: isRecording ?? this.isRecording,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      isUploadingAudio: isUploadingAudio ?? this.isUploadingAudio,
      audioUploadResult: audioUploadResult ?? this.audioUploadResult,

      // Audio playback copyWith
      isPlayingAudio: isPlayingAudio ?? this.isPlayingAudio,
      audioPosition: audioPosition ?? this.audioPosition,
      audioDuration: audioDuration ?? this.audioDuration,

      // Language selection copyWith
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      availableLanguages: availableLanguages ?? this.availableLanguages,

      // Location copyWith
      locationData: locationData ?? this.locationData,
      isLocationLoading: isLocationLoading ?? this.isLocationLoading,
      isLocationRequired: isLocationRequired ?? this.isLocationRequired,

      // Welcome screen copyWith
      hasSeenWelcome: hasSeenWelcome ?? this.hasSeenWelcome,

      // Submission copyWith
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionResult: submissionResult ?? this.submissionResult,
      maxRecordingDuration: maxRecordingDuration ?? this.maxRecordingDuration,
    );
  }

  @override
  List<Object?> get props => [
    study,
    isLoading,
    error,
    currentQuestionIndex,
    answers,
    requiredQuestions,
    skipQuestions,
    jumpTarget,
    navigationHistory,
    logicJumps,
    isRecording,
    recordingDuration,
    audioFilePath,
    isUploadingAudio,
    audioUploadResult,
    isPlayingAudio,
    audioPosition,
    audioDuration,
    selectedLanguage,
    availableLanguages,
    locationData,
    isLocationLoading,
    isLocationRequired,
    hasSeenWelcome,
    isSubmitting,
    submissionResult,
    maxRecordingDuration,
  ];

  @override
  bool get stringify => true;
}

class LocationData extends Equatable {
  final String lat;
  final String lng;

  const LocationData({required this.lat, required this.lng});

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  @override
  List<Object> get props => [lat, lng];

  @override
  bool get stringify => true;

  @override
  String toString() {
    return 'LocationData{lat: $lat, lng: $lng}';
  }
}