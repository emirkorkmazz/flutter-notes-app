import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_ai_suggestion_response.g.dart';

@JsonSerializable()
class GetAiSuggestionResponse with EquatableMixin {
  GetAiSuggestionResponse({
    this.isSuccess,
    this.errorCode,
    this.message,
    this.data,
  });

  factory GetAiSuggestionResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAiSuggestionResponseFromJson(json);
  bool? isSuccess;
  String? errorCode;
  String? message;
  GetAiSuggestionData? data;

  Map<String, dynamic> toJson() => _$GetAiSuggestionResponseToJson(this);

  @override
  List<Object?> get props => [isSuccess, errorCode, message, data];

  GetAiSuggestionResponse copyWith({
    bool? isSuccess,
    String? errorCode,
    String? message,
    GetAiSuggestionData? data,
  }) {
    return GetAiSuggestionResponse(
      isSuccess: isSuccess ?? this.isSuccess,
      errorCode: errorCode ?? this.errorCode,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}

@JsonSerializable()
class GetAiSuggestionData with EquatableMixin {
  GetAiSuggestionData({
    this.noteType,
    this.importanceLevel,
    this.category,
    this.suggestions,
    this.suggestedTags,
    this.rawAnalysis,
  });

  factory GetAiSuggestionData.fromJson(Map<String, dynamic> json) =>
      _$GetAiSuggestionDataFromJson(json);

  @JsonKey(name: 'note_type')
  String? noteType;

  @JsonKey(name: 'importance_level')
  String? importanceLevel;

  String? category;

  List<String>? suggestions;

  @JsonKey(name: 'suggested_tags')
  List<String>? suggestedTags;

  @JsonKey(name: 'raw_analysis')
  String? rawAnalysis;

  Map<String, dynamic> toJson() => _$GetAiSuggestionDataToJson(this);

  @override
  List<Object?> get props => [
    noteType,
    importanceLevel,
    category,
    suggestions,
    suggestedTags,
    rawAnalysis,
  ];

  GetAiSuggestionData copyWith({
    String? noteType,
    String? importanceLevel,
    String? category,
    List<String>? suggestions,
    List<String>? suggestedTags,
    String? rawAnalysis,
  }) {
    return GetAiSuggestionData(
      noteType: noteType ?? this.noteType,
      importanceLevel: importanceLevel ?? this.importanceLevel,
      category: category ?? this.category,
      suggestions: suggestions ?? this.suggestions,
      suggestedTags: suggestedTags ?? this.suggestedTags,
      rawAnalysis: rawAnalysis ?? this.rawAnalysis,
    );
  }
}
