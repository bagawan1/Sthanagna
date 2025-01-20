import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class PlaceInfoWidget extends StatefulWidget {
  final Map<String, dynamic> placeInfo;
  final VoidCallback onClose;

  const PlaceInfoWidget({Key? key, required this.placeInfo, required this.onClose}) : super(key: key);

  @override
  _PlaceInfoWidgetState createState() => _PlaceInfoWidgetState();
}

class _PlaceInfoWidgetState extends State<PlaceInfoWidget> {
  String? wikipediaSummary;
  bool _isOpen = true;

  @override
  void initState() {
    super.initState();
    fetchWikipediaSummary(widget.placeInfo['name']);
  }

  Future<void> fetchWikipediaSummary(String placeName) async {
    final String wikipediaUrl =
        'https://en.wikipedia.org/api/rest_v1/page/summary/$placeName';
    try {
      final response = await http.get(Uri.parse(wikipediaUrl));
      if (response.statusCode == 200) {
        final json = convert.jsonDecode(response.body);
        if (json.containsKey('extract')) {
          setState(() {
            wikipediaSummary = json['extract'];
          });
        }
      }
    } catch (e) {
      print('Error fetching Wikipedia summary: $e');
    }
  }

  @override
  void didUpdateWidget(covariant PlaceInfoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placeInfo['name'] != widget.placeInfo['name']) {
      fetchWikipediaSummary(widget.placeInfo['name']);
      setState(() {
        _isOpen = true; // Open the card when new placeInfo is provided
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isOpen
        ? Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.placeInfo['name'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isOpen = false; // Close the card
                    });
                    widget.onClose(); // Call the onClose callback
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.placeInfo['formatted_address'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            if (wikipediaSummary != null) ...[
              const Text(
                'Wikipedia Summary:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                wikipediaSummary!,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    )
        : SizedBox.shrink(); // Hide the widget if _isOpen is false
  }
}


