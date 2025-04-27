import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_weather_app/model/weather_model.dart';

void main() async {
  await dotenv.load();
  runApp(const MyWeatherApp());
}

class MyWeatherApp extends StatelessWidget {
  const MyWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> cities = [
    "İzmir",
    "Buca",
    "Bornova",
    "Ankara",
    "Ereğli",
    "Alanya",
    "Trabzon",
    "Konya",
    "Düzce",
    "Diyarbakır",
    "Batman",
    "Mersin",
    "Siverek",
    "Bismil",
  ];

  String? selectedCityName;
  Future<WeatherModel>? weatherFuture;

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.openweathermap.org/data/2.5',
      queryParameters: {
        "appid": dotenv.env['API_KEY'],
        "lang": "tr",
        "units": "metric",
      },
    ),
  );

  void selectCity(String city) {
    setState(() {
      selectedCityName = city;
      weatherFuture = getWeather(city);
    });
  }

  Future<WeatherModel> getWeather(String city) async {
    final response = await dio.get("/weather", queryParameters: {"q": city});

    final model = WeatherModel.fromJson(response.data);
    debugPrint(model.name);
    return model;
  }

  Widget buildWeatherCard(WeatherModel weatherModel) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              weatherModel.name ?? "City Not Found",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "${weatherModel.main?.temp?.round() ?? 0}°",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(weatherModel.weather?.first.description ?? "No Description"),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Icon(Icons.water_drop),
                    const SizedBox(height: 4),
                    Text("${weatherModel.main?.humidity?.round() ?? 0}"),
                  ],
                ),
                const SizedBox(width: 32),
                Column(
                  children: [
                    const Icon(Icons.air),
                    const SizedBox(height: 4),
                    Text("${weatherModel.wind?.speed?.round() ?? 0}"),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Weather App')),
      body: Column(
        children: [
          if (weatherFuture != null)
            FutureBuilder<WeatherModel>(
              future: weatherFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                if (snapshot.hasData) {
                  return buildWeatherCard(snapshot.data!);
                }
                return const SizedBox.shrink();
              },
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: cities.length,
              itemBuilder: (context, index) {
                final city = cities[index];
                final isSelected = selectedCityName == city;
                return GestureDetector(
                  onTap: () => selectCity(city),
                  child: Card(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                    child: Center(
                      child: Text(
                        city,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
