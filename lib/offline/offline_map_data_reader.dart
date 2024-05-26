import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:path/path.dart' as p;
import 'package:vilnius100km/constants.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

class OfflineMapDataReader {
  static const _assetPMTiles = 'assets/pmtiles/vilnius.pmtiles';
  static const _assetStyle = 'assets/styles/bright/style.json';
  static const _assetTracksGeoJson = 'assets/geojson/tracks.geojson';

  Future<OfflineMapData> read() async {
    final directory = await getApplicationCacheDirectory();

    final trackPolylines = await _getTrackPolylines();
    final theme = await _getTheme();
    final pmTilesProvider = await _getPmTilesVectorTileProvider(directory);

    return OfflineMapData(
      pmTilesProvider: pmTilesProvider,
      theme: theme,
      trackPolylines: trackPolylines,
    );
  }

  Future<PmTilesVectorTileProvider> _getPmTilesVectorTileProvider(
    Directory directory,
  ) async {
    final file = await _copyAssetToFile(_assetPMTiles, directory);

    return PmTilesVectorTileProvider.fromSource(file.path);
  }

  Future<Theme> _getTheme() async {
    var themeJsonString = await rootBundle.loadString(_assetStyle);

    return ThemeReader().read(jsonDecode(themeJsonString));
  }

  Future<List<Polyline>> _getTrackPolylines() async {
    final trackGeoJson = await rootBundle.loadString(_assetTracksGeoJson);
    final trackParser = GeoJsonParser(
      defaultPolylineColor: Constants.primaryColor.withOpacity(0.7),
    )..parseGeoJsonAsString(trackGeoJson);

    return trackParser.polylines;
  }

  static Future<File> _copyAssetToFile(
    String assetPath,
    Directory directory,
  ) async {
    var bytes = await rootBundle.load(assetPath);
    var file = File(p.join(directory.path, assetPath));

    await file.create(recursive: true);
    return file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
  }
}

class OfflineMapData {
  final Theme theme;
  final PmTilesVectorTileProvider pmTilesProvider;
  final List<Polyline> trackPolylines;

  OfflineMapData({
    required this.theme,
    required this.pmTilesProvider,
    required this.trackPolylines,
  });
}
