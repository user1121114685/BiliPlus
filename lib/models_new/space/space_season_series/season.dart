import 'package:bili_plus/models_new/space/space_season_series/archive.dart';
import 'package:bili_plus/models_new/space/space_season_series/stat.dart';
import 'package:bili_plus/utils/extension.dart';

class SpaceSsModel {
  List<SpaceSsArchive>? archives;
  SpaceSsMeta? meta;
  List<int>? recentAids;

  SpaceSsModel({
    this.archives,
    this.meta,
    this.recentAids,
  });

  factory SpaceSsModel.fromJson(Map<String, dynamic> json) => SpaceSsModel(
    archives: (json["archives"] as List?)
        ?.map((e) => SpaceSsArchive.fromJson(e))
        .toList(),
    meta: json["meta"] == null ? null : SpaceSsMeta.fromJson(json["meta"]),
    recentAids: (json["recent_aids"] as List?)?.fromCast(),
  );
}
