import 'package:bili_plus/models_new/match/match_info/contest.dart';

class MatchInfoData {
  MatchContest? contest;

  MatchInfoData({this.contest});

  factory MatchInfoData.fromJson(Map<String, dynamic> json) => MatchInfoData(
    contest: json['contest'] == null
        ? null
        : MatchContest.fromJson(json['contest'] as Map<String, dynamic>),
  );
}
