import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vilnius100km/offline/offline_map_data_reader.dart';

class TailMapScreen extends StatelessWidget {
  const TailMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vilnius 100km"),
      ),
      body: const TailMapScreenBody(),
    );
  }
}

class TailMapScreenBody extends StatefulWidget {
  const TailMapScreenBody({super.key});

  @override
  State<TailMapScreenBody> createState() => _TailMapScreenBodyState();
}

class _TailMapScreenBodyState extends State<TailMapScreenBody> {
  final offlineMapDataFuture = OfflineMapDataReader().read();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OfflineMapData>(
      future: offlineMapDataFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return OfflineMap(data: snapshot.requireData);
        } else if (snapshot.hasError) {
          return Center(child: Text("${snapshot.error}"));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class OfflineMap extends StatelessWidget {
  final OfflineMapData data;

  const OfflineMap({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(54.687157, 25.279652),
        initialZoom: 11,
      ),
      children: [
        VectorTileLayer(
          // the map theme
          theme: data.theme,
          sprites: data.sprites,
          fileCacheTtl: const Duration(seconds: 10),
          layerMode: VectorTileLayerMode.vector,
          tileProviders: TileProviders({
            'openmaptiles': data.pmTilesProvider,
          }),
        ),
        PolylineLayer(polylines: data.trackPolylines),
      ],
    );
  }
}
