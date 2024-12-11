import 'package:flutter/material.dart';
import 'package:gully_king/pages/new_unranked_game_page.dart';

class NewInningsSetupDialog extends StatelessWidget {
  final Function(Player, Player, Player) onBatsmenAndBowlerSelected;
  final List<Player> availableBatsmen;
  final List<Player> availableBowlers;

  const NewInningsSetupDialog({
    super.key,
    required this.onBatsmenAndBowlerSelected,
    required this.availableBatsmen,
    required this.availableBowlers,
  });

  @override
  Widget build(BuildContext context) {
    Player? newStrike;
    Player? newNonStrike;
    Player? newBowler;

    return AlertDialog(
      title: const Text('Set Up Second Innings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<Player>(
            hint: const Text('Select Strike Batsman'),
            value: newStrike,
            onChanged: (Player? player) {
              newStrike = player;
            },
            items: availableBatsmen.map((Player batsman) {
              return DropdownMenuItem<Player>(
                value: batsman,
                child: Text(batsman.name),
              );
            }).toList(),
          ),
          DropdownButton<Player>(
            hint: const Text('Select Non-Strike Batsman'),
            value: newNonStrike,
            onChanged: (Player? player) {
              newNonStrike = player;
            },
            items: availableBatsmen.map((Player batsman) {
              return DropdownMenuItem<Player>(
                value: batsman,
                child: Text(batsman.name),
              );
            }).toList(),
          ),
          DropdownButton<Player>(
            hint: const Text('Select Bowler'),
            value: newBowler,
            onChanged: (Player? player) {
              newBowler = player;
            },
            items: availableBowlers.map((Player bowler) {
              return DropdownMenuItem<Player>(
                value: bowler,
                child: Text(bowler.name),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (newStrike != null && newNonStrike != null && newBowler != null) {
              onBatsmenAndBowlerSelected(newStrike!, newNonStrike!, newBowler!);
              Navigator.of(context).pop();
            } else {
              // Handle the case where all values are not selected (optional)
            }
          },
          child: const Text('Start'),
        ),
      ],
    );
  }
}
