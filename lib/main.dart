import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'services/game_state.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/game_body.dart';
import 'widgets/settings_dialog.dart';
import 'widgets/game_over_screen.dart';
import 'widgets/loading_screen.dart';
import 'widgets/how_to_play_dialog.dart';
import 'widgets/fancy_play_again_button.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(),
      child: MaterialApp(
        title: 'Cossack Adventure',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const GamePage(),
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  void initState() {
    super.initState();
    // Initialize the game state when the page loads
    Future.microtask(() => context.read<GameState>().initialize());
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<GameState>(
        builder: (context, gameState, _) {
          return SettingsDialog(
            soundEnabled: gameState.soundEnabled,
            imagesEnabled: gameState.imagesEnabled,
            onSoundChanged: gameState.toggleSound,
            onImagesChanged: gameState.toggleImages,
          );
        },
      ),
    );
  }

  void _showHowToPlayDialog() {
    showDialog(
      context: context,
      builder: (context) => const HowToPlayDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, _) {
        if (gameState.error != null) {
          return GameOverScreen(
            error: gameState.error!,
            playAgainButton: FancyPlayAgainButton(
              onPressed: gameState.restartGame,
            ),
          );
        }

        if (gameState.isLoading || gameState.currentNode == null) {
          return const LoadingScreen();
        }

        return Scaffold(
          appBar: CustomAppBar(
            points: gameState.points, // Updated to use points
            onHelpPressed: _showHowToPlayDialog,
            onSettingsPressed: _showSettingsDialog,
          ),
          body: GameBody(
            node: gameState.currentNode!,
            imagesEnabled: gameState.imagesEnabled,
            onActionPressed: gameState.makeChoice,
            onRestartPressed: gameState.restartGame,
          ),
        );
      },
    );
  }
}
