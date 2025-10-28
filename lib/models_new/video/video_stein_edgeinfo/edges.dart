import 'package:bili_plus/models_new/video/video_stein_edgeinfo/dimension.dart';
import 'package:bili_plus/models_new/video/video_stein_edgeinfo/question.dart';
import 'package:bili_plus/models_new/video/video_stein_edgeinfo/skin.dart';

class Edges {
  Dimension? dimension;
  List<Question>? questions;
  Skin? skin;

  Edges({this.dimension, this.questions, this.skin});

  factory Edges.fromJson(Map<String, dynamic> json) => Edges(
    dimension: json['dimension'] == null
        ? null
        : Dimension.fromJson(json['dimension'] as Map<String, dynamic>),
    questions: (json['questions'] as List<dynamic>?)
        ?.map((e) => Question.fromJson(e as Map<String, dynamic>))
        .toList(),
    skin: json['skin'] == null
        ? null
        : Skin.fromJson(json['skin'] as Map<String, dynamic>),
  );
}
