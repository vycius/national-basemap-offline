import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pmtiles/pmtiles.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_map_tiles_pmtiles/vector_map_tiles_pmtiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';
import 'package:vilnius100km/screens/trail/MapStyles.dart';

class TailMapScreen extends StatelessWidget {
  const TailMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vilnius 100 km"),
      ),
      body: TailMapScreenBody(),
    );
  }
}

class TailMapScreenBody extends StatelessWidget {
  TailMapScreenBody({super.key});

  Future<PmTilesVectorTileProvider> getPMTilesProvider() async {
    return PmTilesVectorTileProvider.fromSource(
      "https://cdn.startupgov.lt/tiles/vector/pmtiles/lithuania.pmtiles",
    );

    final byteData = await rootBundle.load('assets/pmtiles/vilnius.pmtiles');

    final bytes = byteData.buffer.asUint8List();

    final archive = await PmTilesArchive.fromBytes(bytes);

    return PmTilesVectorTileProvider.fromArchive(archive);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PmTilesVectorTileProvider>(
      future: getPMTilesProvider(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return FlutterMap(
            options:
                const MapOptions(initialCenter: LatLng(54.687157, 25.279652)),
            children: [
              VectorTileLayer(
                // the map theme
                theme: MapStyles.bright,
                layerMode: VectorTileLayerMode.vector,

                tileProviders: TileProviders({
                  'openmaptiles': snapshot.requireData,
                }),
              ),
            ],
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text("${snapshot.error}"));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
