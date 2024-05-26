import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_geojson/flutter_map_geojson.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:path/path.dart' as p;
import 'package:vilnius100km/constants.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

class OfflineMapDataReader {
  static const _assetPMTiles = 'assets/pmtiles/vilnius.pmtiles';
  static const _assetStyle = 'assets/styles/bright/style.json';
  static const _assetSpriteJson = 'assets/styles/bright/sprites/bright.json';
  static const _assetSpriteImage = 'assets/styles/bright/sprites/bright.png';
  static const _assetTracksGeoJson = 'assets/geojson/tracks.geojson';

  Future<OfflineMapData> read() async {
    final directory = await getApplicationCacheDirectory();

    final trackPolylines = await _getTrackPolylines();
    final theme = await _getTheme();
    final sprites = await _getSprites();
    final pmTilesProvider = await _getPmTilesVectorTileProvider(directory);

    return OfflineMapData(
      pmTilesProvider: pmTilesProvider,
      theme: theme,
      sprites: sprites,
      trackPolylines: trackPolylines,
    );
  }

  Future<PmTilesVectorTileProvider> _getPmTilesVectorTileProvider(
    Directory directory,
  ) async {
    final file = await _copyAssetToFile(_assetPMTiles, directory);

    return PmTilesVectorTileProvider.fromSource(file.path);
  }

  Future<SpriteStyle> _getSprites() async {
    final spriteJsonString = await rootBundle.loadString(_assetSpriteJson);
    final spriteIndex = SpriteIndexReader().read(jsonDecode(spriteJsonString));

    return SpriteStyle(
      index: spriteIndex,
      atlasProvider: () async {
        final bytes = await rootBundle.load(_assetSpriteImage);
        return bytes.buffer.asUint8List();
      },
    );
  }

  Future<Theme> _getTheme() async {
    final themeJsonString = await rootBundle.loadString(_assetStyle);

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
    final bytes = await rootBundle.load(assetPath);
    final file = File(p.join(directory.path, assetPath));

    await file.create(recursive: true);
    return file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
  }
}

class OfflineMapData {
  final Theme theme;
  final SpriteStyle sprites;
  final PmTilesVectorTileProvider pmTilesProvider;
  final List<Polyline> trackPolylines;

  const OfflineMapData({
    required this.theme,
    required this.sprites,
    required this.pmTilesProvider,
    required this.trackPolylines,
  });
}
